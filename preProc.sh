#!/bin/sh

#example zoom for example dataset:
#north=6834686
#south=6829341
#east=149166
#west=142840

north=$1
south=$2
east=$3
west=$4
startingP=$5
endingP=$6
bathyName=$7
dataGrassMapset=$8
gamaHeadlessIncludes=$9
pathToHeadless=$10
pathToConfig=$11
codename=$12


n=`echo "$(($north+200))"`
s=`echo "$(($south-200))"`
e=`echo "$(($east+200))"`
w=`echo "$(($west-200))"`

#example paths:
#path to datagrass mapset where you want to work
#dataGrassMapset="/home/annalisa/DATAGRASS/LL_RGF93_CC/annalisa/"
#path to Gama includes-to-be-written by grass
#gamaHeadlessIncludes="/home/annalisa/Scaricati/Gama1.6.1_Linux_64bits/Gama/headless/samples/includes/"
#path to headless shell script file
#pathToHeadless="/home/annalisa/Scaricati/Gama1.6.1_Linux_64bits/Gama/headless/gama-headless.sh"
#path to experiment configuration xml file
#pathToConfig="/home/annalisa/Scaricati/Gama1.6.1_Linux_64bits/Gama/headless/samples/"

#the DEM resolution must be exact and the raster squared-cell otherwise Gama will not read it
grass71 $dataGrassMapset --exec g.region n=$n s=$s e=$e w=$w -a res=100
grass71 $dataGrassMapset --exec r.mapcalc expression='bathy=bathy_goemTrou100'
grass71 $dataGrassMapset --exec r.out.gdal $bathyName output=$gamaHeadlessIncludes'bathy.asc' format=AAIGrid nodata=-9999
grass71 $dataGrassMapset --exec v.in.region rettangolo
grass71 $dataGrassMapset --exec v.select ainput=$startingP binput=rettangolo operator=intersects output=partenza
grass71 $dataGrassMapset --exec v.select ainput=$endingP binput=rettangolo operator=intersects output=arrivo
grass71 $dataGrassMapset --exec v.out.ogr partenza output=$gamaHeadlessIncludes'partenza.shp'
grass71 $dataGrassMapset --exec v.out.ogr arrivo output=$gamaHeadlessIncludes'arrivo.shp'

sh $pathToHeadless $pathToConfig$codename'.xml' outputHeadLess

