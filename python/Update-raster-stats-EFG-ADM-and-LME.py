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

for file in files:
    thisfile = os.path.basename(file)
    thisefg = re.findall(r'[MFTS]+[0-9]\.[0-9]+', thisfile)
    print(thisefg[0])
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
    if 'finalresults' not in locals():
        finalresults = results
    else:
        finalresults = pd.concat([results,finalresults], axis = 0)
    finalresults = finalresults.fillna(0)
    with pd.ExcelWriter(repodir / 'data' / 'EFG-ADMLME.xlsx') as writer:  
        finalresults.to_excel(writer, sheet_name='crosstab_EFG_by_polygon')
        if 'major' in finalresults.columns:
            finalresults['p.major'] = finalresults['major']*100/finalresults['area']
            if 'minor' in finalresults.columns:
                finalresults['p.both'] = (finalresults['major']+finalresults['minor'])*100/finalresults['area']
                countryresults = pd.pivot_table(finalresults, index='title_en',columns='EFG',values='p.both',aggfunc="sum")
            else:
                countryresults = pd.pivot_table(finalresults, index='title_en',columns='EFG',values='p.major',aggfunc="sum")
            countryresults.to_excel(writer, sheet_name='EFG_by_countries')
