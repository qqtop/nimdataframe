import cx , nimdataframe 

## nimdfT1.nim
## Testing nimdataframe
## compile with : nim c -d:ssl -d:release -r nimdfT1


var ufo =  "http://bit.ly/uforeports"    # data used in pandas documentation
var ndf:nimdf                            # define a nim dataframe
 
ndf = createDataFrame(ufo)
printLnBiCol("Data Source : " & ufo)
echo()

showDf(ndf, rows = 25,cols = @[1,2,3,4,5],colwd = @[15,15,14,6,15],showframe = true,framecolor = salmon,header = true) 
showDataframeInfo(ndf)
doFinish()
