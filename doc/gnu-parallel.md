# Installing gnu parallel

## ... in Linux manjaro

Just remember to cite:

```sh
sudo pamac install parallel  

```



## ... in Mac OSX

Easy as following these examples: https://omgenomics.com/blog/parallel

Just remember to cite:

```sh
brew install parallel 
parallel --citation
```

> Tange, O. (2024, April 22). GNU Parallel 20240422 ('Børsen'). Zenodo. https://doi.org/10.5281/zenodo.11043435

## Using gnu parallel

To run a script for reprojecting all tif files, just make sure we use enough cores (https://support.macincloud.com/support/solutions/articles/8000087401-how-can-i-check-the-number-of-cpu-cores-on-a-mac), eight seems to be the best here:

```sh
cd $SCRIPTDIR/sandbox
mkdir -p eck4
chmod +x ../gdal/toeck4.sh 
parallel --jobs 8 ../gdal/toeck4.sh ::: $(ls *tif)
```

For these to work, need to specify the gisdata location consistently, one option is doing:

```sh
ln -s /opt/gisdata ~/gisdata
```


```sh
cd $SCRIPTDIR/sandbox
parallel --jobs 8 python ../python/Update-raster-stats-EFG-WB.py  ::: $(ls SF*tif)

## esta usa gpkg en vez de shapefiles y aplicamos un filtro...
parallel --jobs 4 python ../python/Update-raster-stats-EFG-EEZ.py  ::: $(ls *M[SF0-9]*tif)
```

We can create a more flexible script and indicate to parallel to use the raster file name as the first argument:

```sh
parallel --jobs 8 python ../python/Update-raster-stats-EFG.py {1} csvs-LMEADM  /opt/gisdata/admin/global/LME-admin/lme_admin_20210519.zip region_id title_en ::: $(ls *tif)

parallel --jobs 5 python ../python/Update-raster-stats-EFG.py {1} csvs-WB  /opt/gisdata/admin/global/World-Bank/wb_countries_admin0_10m.zip OBJECTID WB_NAME ::: $(ls *tif)
```

This works for World Bank and the custom ADM+LME data, but for the EEZ we have additional stesps that have not been added to the script.
