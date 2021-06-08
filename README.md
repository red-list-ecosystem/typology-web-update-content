# typology-web-update-content
Scripts to update content of the typology web site


## Export content for typology website

We have an R script for exporting from the postgresql database to the local repository.

```sh
source $HOME/proyectos/typology-website/typology-web-update-content/env/project-env.sh

cd $WORKDIR

Rscript --vanilla $SCRIPTDIR/R/update-biome-content-typology-website.R

##Rscript --vanilla $SCRIPTDIR/inc/R/export-updated-profiles/update-efg-content-typology-website.R
Rscript --vanilla $SCRIPTDIR/inc/R/export-updated-profiles/update-efg-content-typology-website.R S1.2 v2.0

for k in $(seq 1 4)
do
  Rscript --vanilla $SCRIPTDIR/inc/R/export-updated-profiles/update-efg-content-typology-website.R MT1.${k} v2.0
done

## these ones are ready with version 1.0 of profile

for k in  TF1.6 TF1.7
do
  Rscript --vanilla $SCRIPTDIR/inc/R/export-updated-profiles/update-efg-content-typology-website.R ${k} v2.0
done

## these ones are ready with version 2.0 of profile

for k in F2.7 F2.8 F2.9 F2.2 F2.3 F2.4 F3.2 F3.5 TF1.5 F3.4 T2.2 T2.6 T3.3 T3.4 T4.1 T4.3 T4.4 T5.4 T6.5 M1.2 M1.4 M3.1 M3.6 M4.1 M4.2 M3.2 M3.3 M3.4 TF1.1 M2.5 M2.4 M2.3 M2.2 M2.1 F3.1 FM1.3 TF1.3 M3.5 M3.7 F2.5 F2.6 T5.1 T7.2 T7.3 F2.10 M1.1 M1.3 F1.2 F1.3 F1.5 TF1.2 F2.1 F3.3 F1.6 FM1.2 M1.7 M1.8 M1.9 MFT1.3 T2.1 T3.1 T4.2 T6.1 T6.3 SF2.2 T1.2 T5.3 F1.1 F1.7 FM1.1 F1.4 M1.5 M1.6 T1.1 T1.3 T1.4 T7.1 T3.2 T2.3 TF1.4 T2.4 T2.5 T4.5 T5.2 T5.5 T6.2 T6.4 T7.5
do
  Rscript --vanilla $SCRIPTDIR/inc/R/export-updated-profiles/update-efg-content-typology-website.R ${k} v2.0
done

for j in $(seq 1 4)
do
   for k in $(seq 1 4)
   do
      Rscript --vanilla $SCRIPTDIR/inc/R/export-updated-profiles/update-efg-content-typology-website.R M${j}.${k} v2.0
   done
done
```
