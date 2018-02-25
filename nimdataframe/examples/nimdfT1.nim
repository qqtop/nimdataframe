## nimdfT1.nim
## Testing nimdataframe
## 
## data from web maybe corrupt or needs preprocessing therefore 
## it is better to compile first with:
##  nim c  -d:ssl -r nimdfT1
##
## once data has been cleaned you can compile as usual with
##  nim c  -d:ssl -d:release  -r nimdfT1
##

import nimdataframe , nimcx

let ufo  ="http://bit.ly/uforeports"    # data used in pandas documentation
#let ufo = """https://raw.githubusercontent.com/justmarkham/pandas-videos/master/data/ufo.csv"""
var ndf9 = createDataFrame(ufo,hasHeader = true)

ndf9 = dfDefaultSetup(ndf9)              # basic setup
ndf9.colwidths = @[15,7,14,6,15]         # change the default columnwidths created in dfDefaultSetup
ndf9.colcolors = @[pastelgreen,pastelpink,peru,gold]

printLnInfoMsg("Data Source", ufo)
echo()
showDf(ndf9,
   rows = 25,
   cols =  toNimis(toSeq(1..ndf9.colcount)),                       
   colwd = ndf9.colwidths,
   colcolors = @[pastelgreen,pastelpink,peru,gold],
   showFrame = true,
   framecolor = dodgerblue,
   showHeader = true,
   leftalignflag = true,
   xpos = 3) 
decho(3)
showDataframeInfo(ndf9)
doFinish()

