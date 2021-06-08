##R --vanilla
require(dplyr)
require(xml2)
require(stringr)
require("RPostgreSQL")
drv <- dbDriver("PostgreSQL") ## remember to update .pgpass file
con <- dbConnect(drv, dbname = Sys.getenv("DBNAME"),
              host = Sys.getenv("DBHOST"),
              port = Sys.getenv("DBPORT"),
              user = Sys.getenv("DBUSER"))
              
work.dir <- Sys.getenv("WORKDIR")
script.dir <- Sys.getenv("SCRIPTDIR")

setwd(work.dir)

the.codes <- dbGetQuery(con,sprintf("SELECT distinct code FROM functional_groups WHERE biome_code = 'T2'"))$code

the.codes <- dbGetQuery(con,sprintf("SELECT distinct code FROM functional_groups"))$code

target.dir <- "/home/jferrer/proyectos/UNSW/Ecosystem-profiles-comments/_EFGs/"

for (target.EFG in the.codes) {
   ## prepare output
   target.arch <- sprintf("%s/%s.md",target.dir,target.EFG)
   authors <- c()

   ## Query basic info

   qry <- sprintf("SELECT code,f.biome_code,f.name,b.name as biome_name,realms,f.update as original_date FROM functional_groups f
   LEFT JOIN biomes b
   ON b.biome_code=f.biome_code
   WHERE code = '%s'",
   target.EFG)

   efg.info <-   dbGetQuery(con,qry)

   ## Query text section

   efg.texts <- data.frame()
   for (tbl.name in c("Ecological Traits","Key Ecological Drivers","Distribution")) {
      qry <- sprintf("SELECT '%s' as section,description,contributors,version,update FROM efg_%s WHERE code = '%s' AND language = 'en' ORDER BY update DESC limit 1",
      tbl.name,gsub(" ","_",tolower(tbl.name)),target.EFG)
      rslts <-   dbGetQuery(con,qry)
      efg.texts <- rbind(efg.texts,rslts[,c("section","description","version","update")])
      authors <- unique(c(authors,strsplit(gsub("\\{|\\}|\"","",rslts$contributors),",")[[1]]))

   }

   efg.texts <- rbind(efg.texts,data.frame(section="Diagramatic assembly model",description="{% include DAM.html %}",version=NA,update=NA))

   ## Query map info
   qry <- sprintf("SELECT map_code,map_source,contributors,map_version FROM map_metadata WHERE code = '%s' AND status='valid' AND map_type='Indicative Map' ORDER BY map_version DESC limit 1", target.EFG)
      efg.maps <-   dbGetQuery(con,qry)

   map.authors <- strsplit(gsub("\\{|\\}|\"","",efg.maps$contributors),",")[[1]]


   ## Query References

   qry <- sprintf("SELECT ref_cite  FROM efg_references as e LEFT JOIN ref_list as l ON e.ref_code=l.ref_code WHERE code = '%s' ", target.EFG, max(efg.texts$version,na.rm=T))
      text.references <-   dbGetQuery(con,qry)$ref_cite


      qry <- sprintf("SELECT ref_cite  FROM map_references as e LEFT JOIN ref_list as l ON e.ref_code=l.ref_code WHERE map_code = '%s' AND map_version = '%s'", efg.maps$map_code, max(efg.maps$map_version,na.rm=T))
         map.references <-   dbGetQuery(con,qry)$ref_cite





## output header
cat(file=target.arch,sprintf("---
name: %1$s
biome: %8$s
realm: %9$s
code: %2$s
biomecode: %3$s
contributors: %4$s
mapcontributors: %7$s
version: %5$s, %6$s
---",
efg.info$name,
efg.info$code,
efg.info$biome_code,
paste(authors,collapse=", "),
max(efg.texts$version,na.rm=T),
max(efg.texts$update,na.rm=T),
paste(map.authors,collapse=", "),
efg.info$biome_name,
paste(strsplit(gsub("\\{|\\}|\"","",efg.info$realms),",")[[1]],collapse=", ")

))

## output sections
cat(file=target.arch,sprintf("\n# %s\n \n%s\n", efg.texts$section[c(1,2,4,3)], efg.texts$description[c(1,2,4,3)]), append=T)

## output map info

cat(file=target.arch, sprintf("
{%% capture map_det %%}
%s
{%% endcapture %%}
{%% include MAP.html %%}
",efg.maps$map_source), append=T)

## output references

cat(file=target.arch,sprintf("
## References
### Main References
%s
### Map References
%s
",paste("*",text.references,sep=" ",collapse="\n"),paste("*",map.references,sep=" ",collapse="\n")), append=T)

}

dbDisconnect(con)
