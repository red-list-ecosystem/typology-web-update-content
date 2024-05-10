#!/usr/bin/env python
# coding: utf-8

# # Update map statistics
# 
# ## Calculate area statistics for one layer
# This is one way to calculate area statistics using python

# ### Import modules
import sys
import os
import re
import numpy as np
from pathlib import Path
import zipfile
import geopandas as gpd
import pandas as pd
import rasterio
from rasterstats import zonal_stats
import tempfile
import pyprojroot

# arguments
thisfile = sys.argv[1]
outcsvdir = sys.argv[2]
zfile = sys.argv[3]
idcol1 = sys.argv[4]
idcol2 = sys.argv[5]

# ### File paths
repodir = pyprojroot.find_root(pyprojroot.has_dir(".git"))
getimdir = repodir / "sandbox" / "eck4"
csvdir = repodir / "sandbox" / outcsvdir
csvdir.mkdir(parents=True, exist_ok=True)



thisefg = re.findall(r'[MFTS]+[0-9]\.[0-9]+', thisfile)
output_csv = csvdir / ('EFG-%s.csv' % thisefg[0])
if os.path.exists(output_csv):
    print("skipping %s" % (thisfile))
else:
    tmpdir = tempfile.TemporaryDirectory()
    # ### For LME+admin layer used in the website
    file = zipfile.ZipFile(Path(zfile))
    file.extractall(path= tmpdir.name)
    for r, d, f in os.walk(tmpdir.name):
        for ff in f:
            if ff.endswith(".shp"):
                vectorfile = os.path.join(r, ff)
    selection = gpd.read_file(vectorfile)

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
        tsrs = raster.crs.to_proj4()
        selection_xy=selection.to_crs(tsrs).reset_index()
        selection_xy['area']=selection_xy.area
    zs = zonal_stats(vectors=selection_xy.loc[:, 'geometry'], raster=rst, categorical=True)
    stats = pd.DataFrame(zs).fillna(0) * cellarea#One column per raster category, and pixel count as value
    stats.columns = cn
    results = pd.concat([selection_xy.loc[:,(idcol1,idcol2,'area')], stats], axis = 1)
    results["EFG"] = thisefg[0]
    results["mapfile"] = thisfile
    results.to_csv(output_csv)