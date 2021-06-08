##R --vanilla
require(dplyr)
require(xml2)
require(stringr)
require("RPostgreSQL")
drv <- dbDriver("PostgreSQL") ## remember to update .pgpass file
ccon <- dbConnect(drv, dbname = Sys.getenv("DBNAME"),
              host = Sys.getenv("DBHOST"),
              port = Sys.getenv("DBPORT"),
              user = Sys.getenv("DBUSER"))

work.dir <- Sys.getenv("WORKDIR")
script.dir <- Sys.getenv("SCRIPTDIR")

setwd(work.dir)

qry <- "SELECT * FROM (SELECT f.code,f.name,b.name as biome,f.biome_code,map_code,map_version,map_source,map_url,m.contributors,row_number() over (PARTITION BY f.code ORDER BY map_version DESC) as rn FROM map_metadata as m LEFT JOIN functional_groups f ON f.code=m.code LEFT JOIN biomes b ON f.biome_code=b.biome_code ORDER BY map_code) AS T WHERE rn=1"

rslts <-   dbGetQuery(con,qry)

cat(file="~/proyectos/UNSW/Ecosystem-profiles-comments/Map-summary.html","---
layout: default
title: Map summary
section: browse
---
<h2> Summary of map details</h2>
<p> This table summarizes information regarding sources used for generating the indicative maps for all Ecosystem Functional Groups. Alternatively, follow <a href='/Ecosystem-profiles-comments/Map-references.html'>this link to see the list of references used for the maps</a>.</p>
<table>
<tr><th>Map version</th><th>Description</th><th>Contributors</th></tr>
")

for (k in unique(rslts$biome)) {
   cat(file="~/proyectos/UNSW/Ecosystem-profiles-comments/Map-summary.html",
sprintf("
<tr><th colspan=3>%s</th></tr>
",k),append=T)
   for (j in unique(subset(rslts,biome %in% k)$name)) {

ss <- subset(rslts,name %in% j)

cat(file="~/proyectos/UNSW/Ecosystem-profiles-comments/Map-summary.html",
sprintf("
<tr><td colspan=3><a href='/Ecosystem-profiles-comments/EFGs/%s'><b style='font-size: 15px;font-weight: bold; color:black;'>%s</b></a></td></tr>
",unique(ss$code),j),append=T)

ss <- subset(rslts,name %in% j)
cat(file="~/proyectos/UNSW/Ecosystem-profiles-comments/Map-summary.html",
sprintf("
<tr><td>
 %s <br/>  %s <br/>%s
</td>
<td> %s</td>
<td>%s </td></tr>
", ss$map_code,ss$map_version,ifelse(is.na(ss$map_url),"",sprintf("DOI: <a href='http://doi.org/%1$s' target='_blank'>%1$s</a>",ss$map_url)), ss$map_source, gdata::trim(gsub("\\{|\\}|\\\""," ",ss$contributors))
),append=T)

   }
}

cat(file="~/proyectos/UNSW/Ecosystem-profiles-comments/Map-summary.html","</table>",append=T)


qry <- sprintf("SELECT l.ref_cite,m.map_code,m.map_version,mm.code  FROM map_references as m LEFT JOIN ref_list l ON l.ref_code=m.ref_code LEFT JOIN map_metadata as mm ON mm.map_code=m.map_code WHERE m.map_code IN (%s) ORDER BY map_code",paste("'",rslts$map_code,"'",sep="",collapse=", "))

rslt2 <-   dbGetQuery(con,qry)
tt <- with(rslt2,tapply(code,list(gdata::trim(ref_cite),map_version),function(x) paste(sprintf("<a href='/Ecosystem-profiles-comments/EFGs/%1$s'>%1$s</a>",x),collapse=", ")))

cat(file="~/proyectos/UNSW/Ecosystem-profiles-comments/Map-references.html","---
layout: default
title: Map references
section: browse
---
<h2> Summary of references used in the indicative maps</h2>
<p> This table indicates which references were used for generating the indicative maps of each functional group. Alternatively, follow <a href='/Ecosystem-profiles-comments/Map-summary.html'>this link to see a summary of map details</a>.</p>
<table style='table-layout: fixed;
    width: 500px;'>
<tr><th width='60%'>Reference</th><th>Map version 1.0</th><th>Map version 2.0</th></tr>
")

for (k in 1:nrow(tt)) {
   cat(file="~/proyectos/UNSW/Ecosystem-profiles-comments/Map-references.html",sprintf("<tr>%s<td>%s</td><td>%s</td></tr>", gsub("p>","td>",markdown::markdownToHTML(text=rownames(tt)[k],fragment.only=T)),ifelse(is.na(tt[k,1]),"",tt[k,1]),ifelse(is.na(tt[k,2]),"",tt[k,2])),append=T)
}

cat(file="~/proyectos/UNSW/Ecosystem-profiles-comments/Map-references.html","</table>",append=T)

dbDisconnect(con)
