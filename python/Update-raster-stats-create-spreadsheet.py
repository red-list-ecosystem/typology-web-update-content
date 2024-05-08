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



targetdir = repodir / 'data' 
files = [f for f in targetdir.iterdir() if f.match("EFG*ADMLME.csv")]

dfs = list()
for f in files:
    data = pd.read_csv(f)
    dfs.append(data)

finalresults = pd.concat(dfs, axis = 0)
finalresults = finalresults.fillna(0)
finalresults['p.major'] = finalresults['major']*100/finalresults['area']
finalresults['p.both'] = (finalresults['major']+finalresults['minor'])*100/finalresults['area']
filteredresults = finalresults.loc[finalresults['p.both']>0,]
countryresults = pd.pivot_table(finalresults, index='title_en',columns='EFG',values='p.both',aggfunc="sum")
    
with pd.ExcelWriter(repodir / 'data' / 'EFG-ADMLME.xlsx') as writer:  
    filteredresults.to_excel(writer, sheet_name='crosstab_EFG_by_polygon')
    countryresults.to_excel(writer, sheet_name='EFG_by_countries')
