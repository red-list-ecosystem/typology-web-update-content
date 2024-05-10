
### Python script

The code to import the information is documented using a jupyter lab notebook. To run the jupyter lab I set up an environment named `jptr` using my local version of conda:

```sh
source env/project-env.sh
cd $SCRIPTDIR/

python -m venv ~/workdir/venv/jupyterlab
#conda activate jptr
# or  
source ~/workdir/venv/jupyterlab/bin/activate
## after an update:
# python -m ensurepip --default-pip
pip install --upgrade pip
pip install jupyterlab
pip install python-docx odfpy ## to be able to read ODS files
pip install openpyxl  pyprojroot matplotlib
pip install numpy geopandas rasterstats
#pip install zenodo_client
#pip install zenodo_get         
jupyter-lab
```

The scripts are located in the [python/](python/) folder.


## Jupyter books to python executable:


If we want to use the code in a script:
```sh
jupyter nbconvert --to python Update-raster-stats-per-country.ipynb 
```

Then we can edit this to make it easier to run for all EFGs.


```sh
 python Update-raster-stats-EFG-ADM-and-LME.py # this one runs faster? prob due to simplified polygons
 python Update-raster-stats-EFG-EEZ.py
```

These can crash the JupyterLab server or terminal if run simultaneously (maybe too many open connections to one dataset?). Problem is with some files with larger resolution.
