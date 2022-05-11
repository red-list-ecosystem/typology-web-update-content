#!/bin/bash
cd $WORKDIR

 unzip ~/Downloads/Fig\ S1.\ BiomeAssemblyModels_editv1+revieweditsJul2020+Jun2021+Dec2021.zip -d DAMslides/

convert DAMslides/Slide105.jpg -alpha off -fuzz 10% -fill none -draw "matte 0,0 floodfill"  \
\( +clone -alpha extract -blur 0x2 -level 50x100% \) \
-alpha off -compose copy_opacity -composite \
m_1_9-diagram.png

convert  DAMslides/Slide105.jpg -fuzz 5% -fill none -draw 'matte 0,0 floodfill' m_1_9-diagram.png
convert  DAMslides/Slide105.jpg  -fuzz 5% -transparent "#dce6f2"  m_1_9-diagram.png
convert  DAMslides/Slide120.jpg  -fuzz 5% -transparent "#dce6f2"  m_3_6-diagram.png
mv m_1_9-diagram.png m_3_6-diagram.png $WEBCONTENTREPO/assets/uploads
convert  DAMslides/Slide119.jpg  -fuzz 5% -transparent "#dce6f2"  $WEBCONTENTREPO/assets/uploads/m_3_5-diagram.png
