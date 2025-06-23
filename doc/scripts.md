
### Scripts for importing to database

Initially the content was imported using manual inserts into the database or via a webform written in `php`. This required copy-and-paste from the word document.

For the current version, the information was imported using python and the module `python-docx`.

### Scripts for exporting from database

Over the time, we have used several scripts to read the current version of the content from the database and produce output documents for different applications.

#### Export content for typology website

We have an R script for exporting from the postgresql database to the local copy of the repository.

##### Biome descriptions

Run the scripts for all biomes:

```sh
source $HOME/proyectos/typology-website/typology-web-update-content/env/project-env.sh
cd $WORKDIR

Rscript --vanilla $SCRIPTDIR/R/update-biome-content-typology-website.R
```

##### EFG descriptions
Run the script for one ecosystem functional group:

```sh
source $HOME/proyectos/typology-website/typology-web-update-content/env/project-env.sh
cd $WORKDIR

Rscript --vanilla $SCRIPTDIR/R/update-efg-content-typology-website.R S1.2 v2.1
```

##### Examples
These run the script for several functional groups:

```sh
for k in TF1.1  TF1.2  TF1.3  TF1.4  TF1.5 TF1.6 TF1.7
do
  Rscript --vanilla $SCRIPTDIR/R/update-efg-content-typology-website.R ${k} v2.1
done

for j in $(seq 1 4)
do
   for k in $(seq 1 4)
   do
      Rscript --vanilla  $SCRIPTDIR/R/update-efg-content-typology-website.R M${j}.${k} v2.1
   done
done
```



##### Translations
Similar scripts for alternative languages:

```sh
source env/project-env.sh
for k in TF1.1  TF1.2  TF1.3  TF1.4  TF1.5 TF1.6 TF1.7
do
  Rscript --vanilla $SCRIPTDIR/R/update-efg-es-content-typology-website.R ${k} v2.1
done

for j in $(seq 1 4)
do
   for k in $(seq 1 4)
   do
      Rscript --vanilla  $SCRIPTDIR/R/update-efg-es-content-typology-website.R M${j}.${k} v2.1
   done
done
```

#### Then...

After running the scripts we need to commit and push the changes in the local repo to the remote:

```sh
cd $WEBCONTENTREPO
git status
git add *
git commit -m "updated content"
git push
```

### Export to word document

In some occasions we needed to consolidate the current version of the content from the database into a word document for editing.

For this, we first bundle all markdown documents from the local copy of the repo into a single file, and place the appropriate images in the right place. Then we can use `pandoc` to export the contents in a word (or pdf, or ...) document.

We will use this directory for the output

```sh
mkdir -p $WORKDIR/profile-docx
cd $WORKDIR/profile-docx
```

#### Copy assets

Now we can copy the files (fotos, maps and diagramms) using this bash script:

```sh
export FOTOIN=$HOME/proyectos/typology-website/typology-map-content/assets/uploads
export DAMIN=$HOME/proyectos/typology-website/typology-map-content/assets/uploads
export MAPIN=$HOME/tmp/GET-IM-xport-zenodo/output-rasters/profile-png

export FOTOOUT=$WORKDIR/profile-docx/FOTO
export DAMOUT=$WORKDIR/profile-docx/DAM
export MAPOUT=$WORKDIR/profile-docx/MAP
mkdir -p $DAMOUT
mkdir -p $MAPOUT
mkdir -p $FOTOOUT

bash $SCRIPTDIR/bash/copy-assets.sh
```

#### Extract info from json files

To extract the captions and credits for the photographs we can use `jq` to query the json files. Here are some examples of queries that can be done with `jq`:

```sh
EFGJSN=$HOME/proyectos/typology-website/typology-map-data/data/config/groups.json
jq ".path[f_1_1]" $EFGJSN
jq '.[] | select(.path=="f_1_2") | .[].image.caption.en' $EFGJSN
jq .[].path $EFGJSN
jq .[].image.caption.en $EFGJSN
jq .[].image.credit.en $EFGJSN
jq '.[] | select(.path=="'tf_1_6'") ' $EFGJSN
```

These will be used in the following step

### Bundle and pre-process markdown files

Declare input directories:
```sh
export BIODIR=$HOME/proyectos/typology-website/typology-map-content/_posts/explore/1_biomes/
export EFGDIR=$HOME/proyectos/typology-website/typology-map-content/_posts/explore/2_groups/
export BIOJSN=$HOME/proyectos/typology-website/typology-map-data/data/config/biomes.json
export EFGJSN=$HOME/proyectos/typology-website/typology-map-data/data/config/groups.json

```

Create a list of files in the appropriate order:
```sh
cd $WORKDIR/profile-docx
rm all_profiles.*
rm $WORKDIR/profile-docx/file.list

for BIOME in t_1 t_2 t_3 t_4 t_5 t_6 t_7 s_1 s_2 sf_1 sf_2 sm_1 tf_1 f_1 f_2 f_3 fm_1 m_1 m_2 m_3 m_4 mt_1 mt_2 mt_3 mft_1
do
  bash $SCRIPTDIR/bash/pre-process-markdown-per-biome.sh ${BIOME}
  #  '*-t_*' '*-s_*' '*-sf_*' '*-sm_*' '*-tf_*' '*-f_*' '*-fm_*' '*-m_*' '*-mt_*' '*-mft_*'
  find $EFGDIR -name '*-'${BIOME}'_*' -exec basename {} \; | sort | cat >> $WORKDIR/profile-docx/file.list
  bash $SCRIPTDIR/bash/pre-process-markdown.sh $WORKDIR/profile-docx/file.list
  rm $WORKDIR/profile-docx/file.list

done
```

Now run this script to add images and delete/modify lines in each markdown and add them to the output `all_profiles.md` file

```sh
```

#### Export with `pandoc`

Download this template, edit and rename as `custom-reference-David.docx`:

```sh
pandoc -o custom-reference.docx -t docx --print-default-data-file reference.docx > custom-reference.docx
```

Download a lua-filter for pagebreaks:

```sh
# this does not work with my version of pandoc
#wget https://raw.githubusercontent.com/pandoc/lua-filters/master/pagebreak/pagebreak.lua
```

Now export using pandoc with the reference doc defined above:

```sh
pandoc -o all_profiles.docx -f markdown -t docx all_profiles.md --reference-doc=custom-reference-David.docx
```

## upload to OSF

We will use OSF to keep copies in cloud storage.

Install the osfclient in python from https://github.com/osfclient/osfclient:

```sh
pip install osfclient
```
Read the docs: https://osfclient.readthedocs.io/en/stable/

Add a configuration file:
```sh
cd $SCRIPTDIR/data
osf init
```
Append to this a line with the personal access token, the file is named `.osfcli.config`. and has the following structure:

```
[osf]
username = ...@mail.xyz
project = .....
token = ....
```
Then we can list the files in the project

```sh
osf list 
```

Or upload files:

```sh
osf upload IUCN-GET-profiles-exported-2023-06-14.xlsx IUCN-GET-profiles-exported-2023-06-14.xlsx 
```

Overwrite uploaded file:

```sh
osf upload -f IUCN-GET-profiles-exported-2023-06-15.xlsx IUCN-GET-profiles-exported-2023-06-14.xlsx
```
