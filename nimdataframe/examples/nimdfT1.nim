import nimcx , nimdataframe 

## nimdfT1.nim
## Testing nimdataframe
## compile with : nim c -d:ssl -d:release -r nimdfT1

# var ufo =  "http://bit.ly/uforeports"    # data used in pandas documentation
# #var ufo = "http://www.randalolson.com/wp-content/uploads/percent-bachelors-degrees-women-usa.csv"  # some other data for which code below has not been adjusted
# 
# var ndf = createDataFrame(ufo)           # create a nimdataframe with data provided via an url
# printLnBiCol("Data Source : " & ufo)
# echo()
let displayCols       = @[1,2,3,4,5]
let displayColsWidths = @[15,7,14,6,15]
let displayColsColors = @[lightgreen,pastelpink,peru,gold,pastelblue]
# 
# showDf(ndf,
#        rows = 15,
#        cols = displayCols,
#        colwd = displayColsWidths,
#        colcolors = displayColsColors,
#        showframe = true,
#        framecolor = lightsteelblue,
#        showHeader = false,
#        leftalignflag = false,
#        xpos = 2) 
# echo()
# showDataframeInfo(ndf)
# # 
# dfSave(ndf,"ufo.csv")

## nimdfT1.nim
## Testing nimdataframe
## compile with : nim c -d:release -d:ssl -r nimdfT1

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
doFinish()

