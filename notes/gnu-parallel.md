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

```sh
cd $SCRIPTDIR/sandbox
parallel --jobs 8 python ../python/Update-raster-stats-EFG-WB.py  ::: $(ls *tif)
parallel --jobs 8 python ../python/Update-raster-stats-EFG-EEZ.py  ::: $(ls *tif)
```