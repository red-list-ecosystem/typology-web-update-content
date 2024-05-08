#!/usr/bin/env python
# coding: utf-8

# # Update map statistics
# 
# ## Calculate area statistics for one layer
# This is one way to calculate area statistics using python

# ### Import modules
import sys
import re
import os
import numpy as np
from pathlib import Path
import zipfile
import geopandas as gpd
import pandas as pd
import rasterio
from rasterstats import zonal_stats
import tempfile
import pyprojroot

# ### File paths
repodir = pyprojroot.find_root(pyprojroot.has_dir(".git"))
gisdata = Path(os.path.expanduser('~')) / "gisdata"
getimdir = repodir / "sandbox" / "eck4"
csvdir = repodir / "sandbox" / "csvs"
csvdir.mkdir(parents=True, exist_ok=True)

thisfile = sys.argv[1]
thisefg = re.findall(r'[MFTS]+[0-9]\.[0-9]+', thisfile)
output_csv = csvdir / ('EFG-%s-WB.csv' % thisefg[0])
if not os.path.exists(output_csv):
    # read WorldBank boundaries
    tmpdir = tempfile.TemporaryDirectory()
    file = zipfile.ZipFile(gisdata / 'admin/global/World-Bank/wb_countries_admin0_10m.zip')
    file.extractall(path =  tmpdir.name)
    selection = gpd.read_file(Path(tmpdir.name) / 'WB_countries_Admin0_10m/WB_countries_Admin0_10m.shp' )

    print("%s :: %s" % (thisefg[0], thisfile))
    rst = getimdir / thisfile
    with rasterio.open(rst) as raster:
        cellarea = np.prod(raster.res)
        array = raster.read(1)
        if array.max() == 1:
            cn = ["major"]
        elif 1 in np.unique(array):
            cn = ["major","minor"]
        else:
            cn = ["minor"]
        tsrs = raster.crs
        selection_xy=selection.to_crs(tsrs).reset_index()
        selection_xy['area']=selection_xy.area
    zs = zonal_stats(vectors=selection_xy.loc[:, 'geometry'], raster=rst, categorical=True)
    stats = pd.DataFrame(zs).fillna(0) * cellarea#One column per raster category, and pixel count as value
    stats.columns = cn
    results = pd.concat([selection_xy.loc[:,('OBJECTID','WB_NAME','area')], stats], axis = 1)
    results["EFG"] = thisefg[0]
    results["mapfile"] = thisfile
    results.to_csv(output_csv)