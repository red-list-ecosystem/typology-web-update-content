for j in $(ls $FOTOIN | egrep '[mfts]+_[0-9]_[0-9]+.jpg')
do
  #  Fw=identify -format "%[fx:w]" $FOTODIR/$j
  #  Fh=identify -format "%[fx:h]" $FOTODIR/$j
  convert $FOTOIN/$j -density 200x200 -resize 290x290 $FOTOOUT/$j # if we want to resize them
done

for j in $(ls $DAMIN/*diagram.png)
do
  # resize de 18.45 cm a 10cm
   convert $j -resize 36% $DAMOUT/$(basename $j) # if we want to resize them
  # cp $j DAM/$(basename $j)
done

for j in $(ls $MAPIN/*)
do
  # resize de 18.45 cm a 12cm
   convert $j -resize 44% $MAPOUT/$(basename $j)
  # cp $j MAP/$(basename $j)
done
