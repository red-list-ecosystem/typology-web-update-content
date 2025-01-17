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
target.dir <- sprintf("%s/_posts/explore/1_biomes/es/", Sys.getenv("WEBCONTENTREPO"))

setwd(work.dir)


qry <- sprintf("SELECT b.biome_code,b.name,d.description,d.version,d.update FROM biome_translations as b LEFT JOIN biome_descriptions as d
USING (biome_code, language) WHERE d.version='v2.1' AND b.language='es'")

biome.info <- dbGetQuery(con,qry)

dbDisconnect(con)

# search and replace
s.a.r <- data.frame(
      search=c("ml-1","m2","m3/s",##"e.g.","i.e.",## not necessary according to Timo
      "et al.",
      "C4", "C3","in situ","1st","2nd","3rd","0th","2th",">="),
      replace=c("ml<sup>-1</sup>","m<sup>2</sup>","m<sup>3</sup>/s",##"<i>e.g.</i>","<i>i.e.</i>",
      "<i>et al.</i>","C<sub>4</sub>","C<sub>3</sub>","<i>in situ</i>","1<sup>st</sup>","2<sup>nd</sup>","3<sup>rd</sup>","0<sup>th</sup>","2<sup>th</sup>","&geq;"),stringsAsFactors=F)


for (k in 1:nrow(biome.info)) {
   ## prepare output
##   target.arch <- sprintf("%s/%s.md",target.dir,target.EFG)
   target.arch <- sprintf("%s/0100-01-01-%s.md",target.dir,gsub("([0-9])","_\\1",tolower( biome.info[k,"biome_code"])))

   the.description <- gsub("([SMFT]+[0-9].[0-9]+)","[\\1](/explore/groups/\\1)",biome.info[k,"description"])
   the.description <- gsub("biome \\(([SMFT]+[0-9])\\)","biome ([\\1](/explore/biomes/\\1))",the.description)
   the.description <- gsub("biome ([SMFT]+[0-9])","[\\1](/explore/biomes/\\1)",the.description)
   for (g in 1:nrow(s.a.r))
      the.description <- gsub(s.a.r[g,"search"],s.a.r[g,"replace"],the.description,fixed=T)

## output header
cat(file=target.arch,sprintf("---
layout: default
published: true
permalink: /es/biomes/%1$s
content-id: %2$s
lang: es
title: %3$s
version: %4$s, %5$s
---

%6$s
",
gsub("([0-9])","_\\1",tolower(biome.info[k,"biome_code"])),
biome.info[k,"biome_code"],
biome.info[k,"name"],
biome.info[k,"version"],
biome.info[k,"update"],
the.description
))


}
