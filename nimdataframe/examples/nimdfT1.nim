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

import nimcx , nimdataframe

let ufo =  "http://bit.ly/uforeports"    # data used in pandas documentation
var ndf9 = createDataFrame(ufo,hasHeader = true)

printLnBiCol("Data Source : " & ufo)
echo()
showDf(ndf9,
   rows = 25,
   cols = @[1,2,3,4,5],
   colwd = @[15,7,14,6,15],
   colcolors = @[pastelgreen,pastelpink,peru,gold],
   showFrame = true,
   framecolor = dodgerblue,
   showHeader = true,
   xpos = 3) 
decho(3)

doFinish()

