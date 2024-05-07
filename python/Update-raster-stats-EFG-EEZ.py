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


# ### For EEZ layer
# As requested by Emily (7 May 2024).

file = zipfile.ZipFile(gisdata / 'admin/global/EEZ/World_EEZ_v12_20231025_gpkg.zip')
file.extractall(path= tmpdir)
#os.listdir(tmpdir / 'World_EEZ_v12_20231025_gpkg')

eez_zones = gpd.read_file(tmpdir / 'World_EEZ_v12_20231025_gpkg' / 'eez_v12.gpkg' )

## Select EEZ zones of type 200 Nautical miles
selection = eez_zones.loc[eez_zones['POL_TYPE']=="200NM"]
selection.reset_index()

## all marine + SM + FM + MT + MFT
targetdir = getimdir / 'output-rasters/geotiff-eck4/'
files = [f for f in targetdir.iterdir() if f.match("*M[FT0-9]*.tif")]

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
    results = pd.concat([selection_xy.loc[:,('GEONAME','SOVEREIGN1','area')], stats], axis = 1)
    results["EFG"] = thisefg[0]
    if 'finalresults' not in locals():
        finalresults = results
    else:
        finalresults = pd.concat([results,finalresults], axis = 0)
    finalresults = finalresults.fillna(0)
    with pd.ExcelWriter(repodir / 'data' / 'EFG-EEZ.xlsx') as writer:  
        finalresults.to_excel(writer, sheet_name='crosstab_EFG_by_EEZ')
        if 'major' in finalresults.columns:
            finalresults['p.major'] = finalresults['major']*100/finalresults['area']
            if 'minor' in finalresults.columns:
                finalresults['p.both'] = (finalresults['major']+finalresults['minor'])*100/finalresults['area']
                countryresults = pd.pivot_table(finalresults, index='SOVEREIGN1',columns='EFG',values='p.both',aggfunc="sum")
            else:
                countryresults = pd.pivot_table(finalresults, index='SOVEREIGN1',columns='EFG',values='p.major',aggfunc="sum")
            countryresults.to_excel(writer, sheet_name='EFG_by_countries')
