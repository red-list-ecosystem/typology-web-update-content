#!/usr/bin/env python
# coding: utf-8

# # Update map statistics
# 
# ## Calculate area statistics for one layer
# This is one way to calculate area statistics using python

# ### Import modules

import os
import re
import numpy as np
from pathlib import Path
import zipfile
import geopandas as gpd
import pandas as pd
import rasterio
from rasterstats import zonal_stats
import openpyxl
from matplotlib import pyplot
import random

# ### File paths

import pyprojroot
repodir = pyprojroot.find_root(pyprojroot.has_dir(".git"))

tmpdir = Path(os.path.expanduser('~')) / "workdir/tmp/typology-web-update-content"
gisdata = Path("/opt/gisdata/")
getimdir = Path(os.path.expanduser('~')) / "workdir/tmp/GET-IM-xport-zenodo/"


# ### For LME+admin layer used in the website

file = zipfile.ZipFile(gisdata / 'admin/global/LME-admin/lme_admin_20210519.zip')
file.extractall(path= tmpdir)

selection = gpd.read_file(tmpdir / 'lme_admin.shp' )

## all files
targetdir = getimdir / 'output-rasters/geotiff-eck4/'
files = [f for f in targetdir.iterdir() if f.match("*.tif")]
random.shuffle(files)

for file in files:
    thisfile = os.path.basename(file)
    thisefg = re.findall(r'[MFTS]+[0-9]\.[0-9]+', thisfile)
    output_csv = repodir / 'data' / ('EFG-%s-ADMLME.csv' % thisfile)
    if not os.path.exists(output_csv):
        print("%s :: %s" % (thisefg[0], thisfile))
        rst = getimdir / 'output-rasters/geotiff-eck4' / thisfile
        with rasterio.open(rst) as raster:
            cellarea = np.prod(raster.res)
            array = raster.read(1)
            if array.max() == 1:
                cn = ["major"]
            elif 1 in np.unique(array):
                cn = ["major","minor"]
            else:
                cn = ["minor"]
            tsrs = raster.crs.to_proj4()
            selection_xy=selection.to_crs(tsrs).reset_index()
            selection_xy['area']=selection_xy.area
        zs = zonal_stats(vectors=selection_xy.loc[:, 'geometry'], raster=rst, categorical=True)
        stats = pd.DataFrame(zs).fillna(0) * cellarea#One column per raster category, and pixel count as value
        stats.columns = cn
        results = pd.concat([selection_xy.loc[:,('region_id','title_en','area')], stats], axis = 1)
        results["EFG"] = thisefg[0]
        results["mapfile"] = thisfile
        results.to_csv(output_csv)