I tried with some python modules, but they are unnecessarily complicated.

This works good enough:
```sh
mkdir -p sandbox
cd sandbox
wget --continue https://zenodo.org/api/records/10081251/files-archive --output-document='record-10081251-files-archive.zip'
unzip -U record-10081251-files-archive.zip
rm record-10081251-files-archive.zip 
tar -xjvf all-maps-raster-geotiff.tar.bz2 


```