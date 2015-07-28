#!/usr/bin/env python
#
# Code doing some preprocessing in GRASS for goemonierTest.gaml script in Gamas
#
# This program is free software under the GNU General Public
# License (>=v2).
#
# annalisa.minelli at gmail.com

#example string on server 2: ./preProc.sh 6834686 6829341 149166 142840 depart decharge bathy_goemTrou100 "/home/annalisa/DATAGRASS/LL_RGF93_CC/annalisa/" "/home/annalisa/Scaricati/Gama1.6.1_Linux_64bits/Gama/headless/samples/includes/" "/home/annalisa/Scaricati/Gama1.6.1_Linux_64bits/Gama/headless/gama-headless.sh" "/home/annalisa/Scaricati/Gama1.6.1_Linux_64bits/Gama/headless/samples/" "goemonierTest"

#example string on infolab: infolab@2letg118:~/Dropbox/gamaExperiments$ ./preProc.sh 6834686 6829341 149166 142840 depart descharge bathy_goemTrou100 "/home/infolab/DATAGRASS/PRJ_LAMBERT_RGF93_102110/bathymetrie/" "/home/infolab/Downloads/Gama1.6.1_Linux_64bits/Gama/headless/samples/includes/" "/home/infolab/Downloads/Gama1.6.1_Linux_64bits/Gama/headless/gama-headless.sh" "/home/infolab/Downloads/Gama1.6.1_Linux_64bits/Gama/headless/samples/" "goemonierTest"

#example zoom for example dataset:
#north=6834686
#south=6829341
#east=149166
#west=142840
import os,sys,re
from subprocess import call

north = sys.argv[1]
south = sys.argv[2]
east = sys.argv[3]
west = sys.argv[4]
startingP = sys.argv[5]
endingP = sys.argv[6]
bathyName = sys.argv[7]
dataGrassMapset = sys.argv[8]
gamaHeadlessIncludes = sys.argv[9]
pathToHeadless = sys.argv[10]
pathToConfig = sys.argv[11]
codename = sys.argv[12]
startDate = sys.argv[13]
endDate = sys.argv[14]

print north

n = float(north) + 200
s = float(south) - 200
e = float(east) + 200
w = float(west) - 200

#example paths:
#path to datagrass mapset where you want to work
#dataGrassMapset="/home/annalisa/DATAGRASS/LL_RGF93_CC/annalisa/"
#path to Gama includes-to-be-written by grass
#gamaHeadlessIncludes="/home/annalisa/Scaricati/Gama1.6.1_Linux_64bits/Gama/headless/samples/includes/"
#path to headless shell script file
#pathToHeadless="/home/annalisa/Scaricati/Gama1.6.1_Linux_64bits/Gama/headless/gama-headless.sh"
#path to experiment configuration xml file
#pathToConfig="/home/annalisa/Scaricati/Gama1.6.1_Linux_64bits/Gama/headless/samples/"

#the DEM must be squared-cell and the resolution exactotherwise Gama will not read it

call(["grass71",dataGrassMapset,"--exec","g.region","-pa",str(n),str(s),str(e),str(w),"res=100"])
call(["grass71",dataGrassMapset,"--exec","r.out.gdal",bathyName,"output="+gamaHeadlessIncludes+"bathy.asc","format=AAIGrid","nodata=-9999"])
call(["grass71",dataGrassMapset,"--exec","v.in.region","rettangolo"])
call(["grass71",dataGrassMapset,"--exec","v.select","ainput="+startingP,"binput=rettangolo","operator=intersects","output=partenza"])
call(["grass71",dataGrassMapset,"--exec","v.select","ainput="+endingP,"binput=rettangolo","operator=intersects","output=arrivo"])
call(["grass71",dataGrassMapset,"--exec","v.out.ogr","partenza","output="+gamaHeadlessIncludes+"partenza.shp"])
call(["grass71",dataGrassMapset,"--exec","v.out.ogr","arrivo","output="+gamaHeadlessIncludes+"arrivo.shp"])

#configuration of simulation parameter in writing of xml file
xmlIn = open(pathToConfig+codename+".xml",'r')
a = xmlIn.readlines()
str1='    <Parameter name="dtOne" type="STRING" value="'+startDate+'" />'
str2='    <Parameter name="dtTwo" type="STRING" value="'+endDate+'" />'
xmlOut=open(pathToConfig+codename+"1.xml",'w')
for i in a:
	if re.match('  <Parameters',i):
		xmlOut.writelines("  <Parameters>\n")
		xmlOut.writelines(str1+"\n")
		xmlOut.writelines(str2+"\n")
	else:
		xmlOut.writelines(i)       
xmlOut.close()

#calling and executing gama-headless
call(["sh",pathToHeadless,pathToConfig+codename+"1.xml","outputHeadLess"])

