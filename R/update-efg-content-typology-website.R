##R --vanilla
require(dplyr)
require(xml2)
require(stringr)
require("RPostgreSQL")
require(jsonlite)
drv <- dbDriver("PostgreSQL") ## remember to update .pgpass file

con <- dbConnect(drv, dbname = Sys.getenv("DBNAME"),
              host = Sys.getenv("DBHOST"),
              port = Sys.getenv("DBPORT"),
              user = Sys.getenv("DBUSER"))

work.dir <- Sys.getenv("WORKDIR")
script.dir <- Sys.getenv("SCRIPTDIR")
target.dir <- sprintf("%s/_posts/explore/2_groups/", Sys.getenv("WEBCONTENTREPO"))
config.json <- read_json(sprintf("%s/data/config/groups.json", Sys.getenv("WEBDATAREPO")))

setwd(work.dir)
args <- commandArgs(TRUE)
if (length(args)>0) {
   the.codes <- args[1]
   if (!is.null(args[2])) {
      the.vers <- args[2]
   } else {
      the.vers <- "v2.1"
   }
} else {
   ##the.codes <- dbGetQuery(con,sprintf("SELECT distinct code FROM functional_groups WHERE biome_code = 'T2'"))$code
   the.codes <- dbGetQuery(con,sprintf("SELECT distinct code FROM functional_groups"))$code
   the.vers <- "v2.1"
}


s.a.r <- data.frame(
      search=c("ml-1","m2","m3/s",#"e.g.","i.e.", # remove this according to Timo
      "et al.","mg.C.m-3",
      "C4", "C3","in situ","1st","2nd","3rd","0th","2th",">="),
      replace=c("ml<sup>-1</sup>","m<sup>2</sup>","m<sup>3</sup>/s",##"_e.g._","_i.e._",
      "_et al._","mgC m<sup>-3</sup>","C<sub>4</sub>","C<sub>3</sub>","_in situ_","1<sup>st</sup>","2<sup>nd</sup>","3<sup>rd</sup>","0<sup>th</sup>","2<sup>th</sup>","≥"),stringsAsFactors=F)


for (target.EFG in the.codes) {
   print(target.EFG)
   ## prepare output
##   target.arch <- sprintf("%s/%s.md",target.dir,target.EFG)
   target.arch <- sprintf("%s/0100-01-01-%s.md",target.dir,gsub("([0-9])\\.([0-9])","_\\1_\\2",tolower(target.EFG)))
   authors <- c()

   ## Query basic info

   qry <- sprintf("SELECT code,f.biome_code,f.name,f.shortdesc,b.name as biome_name,realms,f.update as original_date FROM functional_groups f
   LEFT JOIN biomes b
   ON b.biome_code=f.biome_code
   WHERE code = '%s'",
   target.EFG)

   efg.info <-   dbGetQuery(con,qry)

   ## Query text section

   efg.texts <- data.frame()
   for (tbl.name in c("Ecological Traits","Key Ecological Drivers","Distribution")) {
      qry <- sprintf("SELECT '%s' as section, description, contributors, version, update FROM efg_%s WHERE code = '%s' AND language = 'en' AND version = '%s' ORDER BY update DESC limit 1",
      tbl.name, gsub(" ","_",tolower(tbl.name)), target.EFG, the.vers)
      rslts <-   dbGetQuery(con,qry)
      efg.texts <- rbind(efg.texts,rslts[,c("section","description","version","update")])
      authors <- unique(c(authors,strsplit(gsub("\\{|\\}|\"","",rslts$contributors),",")[[1]]))
   }
   efg.texts$section <- gsub("Key Ecological Drivers","Ecological Drivers",efg.texts$section)
   efg.texts$section <- gsub("Ecological Traits","Ecosystem Properties",efg.texts$section)
   ## need to do this for each description
   ## sed -e 's|\([MFT+][0-9].[0-9+]\)|[\1](explore/groups/\1)|g' 0100-01-01-f_1_2.md

   efg.texts$description <- gsub("([SMFT]+[0-9].[0-9]+)","[\\1](/explore/groups/\\1)",efg.texts$description)
   efg.texts$description <- gsub("biome ([SMFT]+[0-9])","[\\1](/explore/biomes/\\1)",efg.texts$description)

   # exclude this note, this should be in map description
   efg.texts$description <- gsub(" See map caveats (Table [S4.1](/explore/groups/S4.1)).", "", efg.texts$description, fixed=T)

   for (k in 1:nrow(s.a.r))
      efg.texts$description <- gsub(s.a.r[k,"search"],s.a.r[k,"replace"],efg.texts$description,fixed=T)

if (is.na(efg.info$shortdesc)) {
  short.desc <- "SHORT DESCRIPTION IN PREPARATION"
} else {
  short.desc <- gsub("([SMFT]+[0-9].[0-9]+)","[\\1](/explore/groups/\\1)",efg.info$shortdesc)
  short.desc <- gsub("biome ([SMFT]+[0-9])","[\\1](/explore/biomes/\\1)",short.desc)
  for (k in 1:nrow(s.a.r))
     short.desc <- gsub(s.a.r[k,"search"],s.a.r[k,"replace"],short.desc,fixed=T)

}


##   efg.texts <- rbind(efg.texts,data.frame(section="Diagramatic assembly model",description="{% include DAM.html %}",version=NA,update=NA))

   ## Query map info

   y <- unlist(lapply(config.json,function(x) if(x$id == target.EFG) return(x)))
   map_file <- switch(y['layer.type'],"topojson"=y['layer.path'] ,"raster"= y['layer.tileset'])
   qry <- sprintf("SELECT map_code, map_source, contributors, map_version, map_type, status, DATE(update) as update, map_file, file_description, file_comments FROM map_files f LEFT JOIN map_metadata m USING(map_code, map_version) WHERE code = '%s' AND map_file ILIKE ('%%%s%%') ORDER BY update DESC LIMIT 1", target.EFG,map_file)
      efg.maps <-   dbGetQuery(con,qry)

      if (nrow(efg.maps)==0) {
        cat(sprintf("Map file %s not documented in database ",map_file))
        map.authors <- ""
              } else {
        map.authors <- unique(strsplit(gsub("\\{|\\}|\"","",efg.maps$contributors),",")[[1]])
      }


   ## Query References

   qry <- sprintf("SELECT ref_cite,author_list, title, container_title, date, post_title, doi  FROM efg_references as e LEFT JOIN ref_list as l ON e.ref_code=l.ref_code WHERE code = '%s' ORDER BY author_list", target.EFG)

   biblio <- dbGetQuery(con,qry)
   biblio$ftext <- with(biblio,sprintf("%1$s (%2$s) *%3$s*. **%4$s** %5$s.%6$s",
 author_list,date,title,container_title,ifelse(is.na(post_title),"",post_title),ifelse(is.na(doi) | doi=="","",sprintf(" DOI: [%1$s](http://doi.org/%1$s)",doi))))


      text.references <-   gsub(" *NA*. ", " ",biblio$ftext,fixed=T)

## output header
cat(file=target.arch,sprintf("---
layout: default
published: true
permalink: /en/groups/%1$s
content-id: %2$s
lang: en
title: %3$s
version: '%4$s, %5$s'
---

%6$s
",
gsub("([0-9])\\.([0-9])","_\\1_\\2",tolower(target.EFG)),
target.EFG,
efg.info$name,
max(efg.texts$version,na.rm=T),
max(efg.texts$update,na.rm=T),
short.desc
))

## output sections
cat(file=target.arch,sprintf("\n# %s\n \n%s\n", efg.texts$section[1], efg.texts$description[1]), append=T)

cat(file=target.arch,"\n[DIAGRAM]\n", append=T)

cat(file=target.arch,sprintf("\n# %s\n \n%s\n", efg.texts$section[-1], efg.texts$description[-1]), append=T)

## output map info
if (nrow(efg.maps)==1) {

  efg.maps$map_source <- gsub("([SMFT]+[0-9].[0-9]+)","[\\1](/explore/groups/\\1)",efg.maps$map_source)
  efg.maps$map_source <- gsub("biome \\(([SMFT]+[0-9])\\)","biome ([\\1](/explore/biomes/\\1))",efg.maps$map_source)

  for (k in 1:nrow(s.a.r))
     efg.maps$map_source <- gsub(s.a.r[k,"search"],s.a.r[k,"replace"],efg.maps$map_source,fixed=T)

   cat(file=target.arch,sprintf("\n%s\n", efg.maps$map_source), append=T)

   qry <- sprintf("SELECT ref_cite, author_list, title, container_title, date, post_title, doi  FROM map_references as e LEFT JOIN ref_list as l ON e.ref_code=l.ref_code WHERE map_code = '%s' AND map_version = '%s'  ORDER BY author_list", efg.maps$map_code, max(efg.maps$map_version,na.rm=T))

   biblio <- dbGetQuery(con,qry)
   if (nrow(biblio)>0) {
     biblio$ftext <- with(biblio,sprintf("%1$s (%2$s) *%3$s*. **%4$s** %5$s.%6$s",
   author_list,date,title,container_title,ifelse(is.na(post_title),"",post_title),ifelse(is.na(doi) | doi=="","",sprintf(" DOI: [%1$s](http://doi.org/%1$s)",doi))))
   map.references <-
sprintf(
"### Map references
%s
", paste("*", gsub(" *NA*. ", " ",biblio$ftext,fixed=T), sep=" ",collapse="\n"))
   } else {
     map.references <- ""
   }
   if (length(map.authors)>1) {
     ys <- rep(", ",length(map.authors))
     ys[length(map.authors)] <- "."
     ys[length(map.authors)-1] <- " and "
   } else {
     ys <- "."
   }
   map.author.list <- paste(map.authors,ys,sep="",collapse="")
 map.version <- sprintf("**Map version**: %1$s %2$s, updated %3$s.",efg.maps$map_code,efg.maps$map_version,efg.maps$update)

} else {
   cat(file=target.arch,sprintf("\nMAP IN PREPARATION\n"), append=T)
   map.references <- ""
   map.version <- ""
}

## output references


if (length(authors)>1) {
  ys <- rep(", ",length(authors))
  ys[length(authors)] <- "."
  ys[length(authors)-1] <- " and "
} else {
  ys <- "."
}

cat(file=target.arch,sprintf("
## References

**Citation**: %3$s (2020). *%7$s*. In: Keith, D.A., Ferrer-Paris, J.R., Nicholson, E. and Kingsford, R.T. (eds.) (2020). **The IUCN Global Ecosystem Typology 2.0: Descriptive profiles for biomes and ecosystem functional groups**. Gland, Switzerland: IUCN. DOI:[10.2305/IUCN.CH.2020.13.en](https://doi.org/10.2305/IUCN.CH.2020.13.en).
**Content version**: %4$s, updated %5$s.

%6$s

### Main references
%1$s

%2$s",paste("*",text.references,sep=" ",collapse="\n"),map.references,paste(authors,ys,sep="",collapse=""),max(efg.texts$version,na.rm=T),substr(max(efg.texts$update,na.rm=T),1,10),map.version,efg.info$name), append=T)

}


dbDisconnect(con)
