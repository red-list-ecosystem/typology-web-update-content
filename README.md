# typology-web-update-content
Scripts to update content of the typology web site


## Export content for typology website

We have an R script for exporting from the postgresql database to the local repository.

Run the scripts for all biomes:

```sh
source $HOME/proyectos/typology-website/typology-web-update-content/env/project-env.sh
cd $WORKDIR

Rscript --vanilla $SCRIPTDIR/R/update-biome-content-typology-website.R
```

Run the script for one ecosystem functional group:

```sh
source $HOME/proyectos/typology-website/typology-web-update-content/env/project-env.sh
cd $WORKDIR

Rscript --vanilla $SCRIPTDIR/R/update-efg-content-typology-website.R S1.2 v2.0
```

Examples to run the script for several functional groups:

```sh

for k in  TF1.6 TF1.7
do
  Rscript --vanilla $SCRIPTDIR/R/update-efg-content-typology-website.R ${k} v2.0
done


for j in $(seq 1 4)
do
   for k in $(seq 1 4)
   do
      Rscript --vanilla  $SCRIPTDIR/R/update-efg-content-typology-website.R M${j}.${k} v2.0
   done
done
```