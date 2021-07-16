#!/bin/bash
k=$(ls ${BIODIR}/*-${1}.md)
echo $k
# extract title
grep "title: " $k | sed -e "s/title: /\n# /" > tmp

## add  foto
FOTOlink=$(basename $k | sed -e "s:0100-01-01-:FOTO/:" -e "s/.md/.jpg/")

JSpath=$(basename $k | sed -e "s:0100-01-01-::" -e "s/.md//")

FOTOcaption=$(jq '.[] | select(.path=="'$JSpath'") | .image.caption.en' $BIOJSN | sed -e 's/"//g')
FOTOcredit=$(jq '.[] | select(.path=="'$JSpath'") | .image.credit.en' $BIOJSN | sed -e 's/"//g')

echo '
![]('${FOTOlink}')
#### '${FOTOcaption}'.
##### Credit: '${FOTOcredit} >> tmp

tail -n +10 $k >> tmp

##add to pile
cat tmp >> all_profiles.md

rm tmp
