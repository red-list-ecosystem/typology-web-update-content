#!/bin/bash
filelist=$1
for k in $(cat ${filelist})
do
  echo $k
  # extract title
  grep "title: " $MDDIR/$k | sed -e "s/title: /\n# /" > tmp

  # starting and ending lines and delete selected lines
  FIRSTline=$(grep -n -e "^# Ecological Traits" $MDDIR/$k | cut -d: -f1)
  LASTline=$(grep -n -e "^### Map references" $MDDIR/$k | cut -d: -f1)
  # sed  $FIRSTline','$LASTline'p'  $MDDIR/$k >> tmp
  [ "$LASTline" == "" ] && LASTline=$(wc -l $MDDIR/$k | cut -d" " -f1)

  sed -n $FIRSTline','$LASTline'p'  $MDDIR/$k | sed -e 's/^# /## /g' >> tmp
  sed -i -e '/^## Distribution/ {n;n;n;n;d;}' -e '$d' -e '/Citation/,+5d' -e '/Map references/d' tmp

  ## add the Diagram and foto
  DAMlink=$(echo $k | sed -e "s:0100-01-01-:DAM/:" -e "s/.md/-diagram.png/")
  FOTOlink=$(echo $k | sed -e "s:0100-01-01-:FOTO/:" -e "s/.md/.jpg/")
  JSpath=$(echo $k | sed -e "s:0100-01-01-::" -e "s/.md//")
  FOTOcaption=$(jq '.[] | select(.path=="'$JSpath'") | .image.caption.en' $JSONFILE | sed -e 's/"//g')
  FOTOcredit=$(jq '.[] | select(.path=="'$JSpath'") | .image.credit.en' $JSONFILE | sed -e 's/"//g')

  sed -i -e "/\[DIAGRAM\]/i\![](${FOTOlink})\n\n#### ${FOTOcaption}. \n##### Credit: ${FOTOcredit}\n\n" tmp

  sed -i -e "s;\[DIAGRAM\];\![]("${DAMlink}");" tmp
  #sed -i -e "s;\[DIAGRAM\];<img src='"${DAMlink}"' width='200'>;" tmp # does not work with pandoc

  ## add the map
  MAPpat=$(echo $k | sed -e "s:0100-01-01-:MAP/:" -e "s/.md/*/" -e "s/\([tsmf]\+\)_/\U\1/" -e "s/\([0-9]\)_\([0-9]\+\)/\1.\2./")
  MAPlink=$(ls $MAPpat)
  sed -i -e '/^## Distribution/i\![]('${MAPlink}')\n' tmp

  sed -i -e "s/^## Ecological Traits/***Ecosystem properties***: /" -e "s/^## Key Ecological Drivers/***Ecological drivers***: /" -e "s/^## Distribution/***Distribution***:/" -e "s/^## References/### References:/"  tmp
  sed -i -e '/^\*/,/^[A-Z]/{/^\*/!{/^[A-Z]/!d}}' tmp

  ## sed -i -e 's/^* //g' tmp
  ## sed -e 's/\(*\)DOI: */\1/g' tmp
   sed -i -e "s/DOI: $PARTITION_COLUMN.*//g" tmp

   sed -i -e 's/^\* /- /g' -e '/^\- /{s/\([ a-z\.]\)\*/\1/g}' tmp


  ##add to pile
  cat tmp >> all_profiles.md

  ## add page break
  ##echo "<div style="page-break-after: always"></div>" >> all_profiles.md # does not work with pandoc
  ## echo "\\pagebreak" >> all_profiles.md
  ## clean desk
  rm tmp
done
