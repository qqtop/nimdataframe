import nimcx , nimdataframe 

## nimdfT1.nim
## Testing nimdataframe
## compile with : nim c  -d:ssl -r nimdfT1

import nimcx , nimdataframe 

let ufo =  "http://bit.ly/uforeports"    # data used in pandas documentation
 
var ndf = createDataFrame(ufo)
printLnBiCol("Data Source : " & ufo)
echo()
showDf(ndf,
   rows = 15,
   cols = @[1,2,3,4,5],
   colwd = @[15,7,14,6,15],
   colcolors = @[pastelgreen,pastelpink,peru,gold],
   showFrame = true,
   framecolor = dodgerblue,
   showHeader = true,
   xpos = 3) 
decho(3)

echo()
showDataframeInfo(ndf)
dfSave(ndf,"uforeports.csv")
doFinish()

