export MIHOST=$(hostname -s)
export SCRIPTDIR=$HOME/proyectos/
export WORKDIR=$HOME/tmp/
export PROJECT=typology-web-update-content
export SCRIPTDIR=$SCRIPTDIR/typology-website/$PROJECT
export WORKDIR=$WORKDIR/$PROJECT
mkdir -p $WORKDIR

source $HOME/.ecospheredb
