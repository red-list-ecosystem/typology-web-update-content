JI=${1}
[ ! -e eck4/$JI ] && gdalwarp -co "COMPRESS=DEFLATE" -t_srs "+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs" $JI eck4/$JI