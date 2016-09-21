import cx , nimdataframe ,algorithm

## Testing nimdataframe
## compile with : nim c -d:ssl -d:relaease -r nimdfT1


var ufo =  "http://bit.ly/uforeports"    # data used in pandas documentation
var ndf:nimdf                            # define a nim dataframe
 
ndf = createDataFrame(ufo)
printLnBiCol("Data Source : " & ufo)
echo()

showDf(ndf, rows = 25,cols = @[1,3,4],colwd = @[],showframe = true,framecolor = salmon,header = true) 
showDataframeInfo(ndf)
doFinish()
