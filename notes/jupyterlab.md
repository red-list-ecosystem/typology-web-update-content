
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

The script is located in the [python/](python/) folder.
