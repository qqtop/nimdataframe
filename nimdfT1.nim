import nimcx , nimdataframe 

## nimdfT1.nim
## Testing nimdataframe
## compile with : nim c -d:ssl -d:release -r nimdfT1

var ufo =  "http://bit.ly/uforeports"    # data used in pandas documentation
var ndf:nimdf                            # define a nim dataframe
 
ndf = createDataFrame(ufo)
printLnBiCol("Data Source : " & ufo)
echo()
showDf(ndf, rows = 15,cols = @[1,2,3,4,5],colwd = @[15,7,14,6,15],colcolors = @[pastelgreen,pastelpink,peru,gold,pastelblue],showframe = true,framecolor = dodgerblue,showHeader = true,leftalignflag = false) 
echo()
showDataframeInfo(ndf)


var mySeq = @[1, 2, 3, 4, 5]

echo "Last element:  ", mySeq[^1]
echo "Last two    :  ", mySeq[^2..^1]
echo "First element: ", mySeq[^1]
var ml = mySeq.len
echo "All          : ", mySeq[^ml..^1]


doFinish()
