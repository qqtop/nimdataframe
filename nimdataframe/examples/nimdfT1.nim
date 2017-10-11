import nimcx , nimdataframe 

## nimdfT1.nim
## Testing nimdataframe
## compile with : nim c -d:ssl -d:release -r nimdfT1

var ufo =  "http://bit.ly/uforeports"    # data used in pandas documentation
#var ufo = "http://www.randalolson.com/wp-content/uploads/percent-bachelors-degrees-women-usa.csv"  # some other data for which code below has not been adjusted
var ndf:nimdf                            # define a nim dataframe
 
ndf = createDataFrame(ufo)
printLnBiCol("Data Source : " & ufo)
echo()
showDf(ndf, rows = 15,cols = @[1,2,3,4,5],colwd = @[15,7,14,6,15],colcolors = @[lightgreen,pastelpink,peru,gold,pastelblue],showframe = true,framecolor = lightsteelblue,showHeader = true,leftalignflag = false) 
echo()
showDataframeInfo(ndf)

doFinish()
