#!/usr/bin/env python
# coding: utf-8

# ### Import modules

import os
import re
import numpy as np
from pathlib import Path
import pandas as pd
import openpyxl
import pyprojroot

## file paths
repodir = pyprojroot.find_root(pyprojroot.has_dir(".git"))

targetdir = repodir / 'sandbox' / 'csvs' 
files = [f for f in targetdir.iterdir() if f.match("EFG*WB.csv")]

dfs = list()
for f in files:
    data = pd.read_csv(f)
    dfs.append(data)

finalresults = pd.concat(dfs, axis = 0)
finalresults = finalresults.fillna(0)
finalresults['p.major'] = finalresults['major']*100/finalresults['area']
finalresults['p.both'] = (finalresults['major']+finalresults['minor'])*100/finalresults['area']
filteredresults = finalresults.loc[finalresults['p.both']>0,].sort_values(['WB_NAME','p.both'], ascending=[True, False])
filteredresults = filteredresults[['OBJECTID','WB_NAME','area','EFG','mapfile','major','minor','p.major','p.both']]
countryresults = pd.pivot_table(finalresults, index='WB_NAME',columns='EFG',values='p.both',aggfunc="sum")
    
with pd.ExcelWriter(repodir / 'data' / 'EFG-WB.xlsx') as writer:  
    filteredresults.to_excel(writer, sheet_name='crosstab_EFG_by_polygon')
    countryresults.to_excel(writer, sheet_name='EFG_by_countries')


targetdir = repodir / 'sandbox' / 'csvs-EEZ' 
files = [f for f in targetdir.iterdir() if f.match("EFG*M[FST0-9]*.csv")]

dfs = list()
for f in files:
    data = pd.read_csv(f)
    dfs.append(data)

finalresults = pd.concat(dfs, axis = 0)
finalresults = finalresults.fillna(0)
finalresults['p.major'] = finalresults['major']*100/finalresults['area']
finalresults['p.both'] = (finalresults['major']+finalresults['minor'])*100/finalresults['area']
filteredresults = finalresults.loc[finalresults['p.both']>0,].sort_values(['SOVEREIGN1','p.both'], ascending=[True, False])
filteredresults = filteredresults[['GEONAME','SOVEREIGN1','area','EFG','mapfile','major','minor','p.major','p.both']]
countryresults = pd.pivot_table(finalresults, index='SOVEREIGN1',columns='EFG',values='p.both',aggfunc="sum")
    
with pd.ExcelWriter(repodir / 'data' / 'EFG-EEZ.xlsx') as writer:  
    filteredresults.to_excel(writer, sheet_name='crosstab_EFG_by_polygon')
    countryresults.to_excel(writer, sheet_name='EFG_by_countries')
