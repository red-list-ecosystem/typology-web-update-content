export MIHOST=$(hostname -s)
export SCRIPTHOME=$HOME/proyectos
export WORKDIR=$HOME/tmp/
export PROJECT=typology-web-update-content
export SCRIPTDIR=$SCRIPTHOME/typology-website/$PROJECT
export WORKDIR=$WORKDIR/$PROJECT
mkdir -p $WORKDIR

export WEBCONTENTREPO=$SCRIPTHOME/typology-website/typology-map-content
export WEBDATAREPO=$SCRIPTHOME/typology-website/typology-map-data

## credentials for connecting to the database:
##source $HOME/.ecospheredb
## export DBHOST=...
## export DBUSER=...
## export DBNAME=...
## export DBPORT=...
grep -A4 psqlaws $HOME/.database.ini | tail -n +2 > tmpfile
while IFS="=" read -r key value; do
  case "$key" in
    "host") export DBHOST="$value" ;;
    "port") export DBPORT="$value" ;;
    "database") export DBNAME="$value" ;;
    "user") export DBUSER="$value" ;;
  esac
done < tmpfile
rm tmpfile
## password in .pgpass file
