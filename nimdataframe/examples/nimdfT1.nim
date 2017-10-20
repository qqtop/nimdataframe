## nimdfT1.nim
## Testing nimdataframe
## compile with : nim c  -d:ssl -r nimdfT1

import nimcx , nimdataframe

printLn("## compile with : nim c  -d:ssl -r nimdfT1  ##")

let ufo =  "http://bit.ly/uforeports"    # data used in pandas documentation
var ndf9 = createDataFrame(ufo,hasHeader = true)

printLnBiCol("Data Source : " & ufo)
echo()
showDf(ndf9,
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
showDataframeInfo(ndf9)
dfSave(ndf9,"uforeports.csv")
doFinish()

