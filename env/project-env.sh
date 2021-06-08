export MIHOST=$(hostname -s)
export SCRIPTHOME=$HOME/proyectos
export WORKDIR=$HOME/tmp/
export PROJECT=typology-web-update-content
export SCRIPTDIR=$SCRIPTHOME/typology-website/$PROJECT
export WORKDIR=$WORKDIR/$PROJECT
mkdir -p $WORKDIR

export WEBCONTENTREPO=$SCRIPTHOME/typology-website/typology-map-content

source $HOME/.ecospheredb
