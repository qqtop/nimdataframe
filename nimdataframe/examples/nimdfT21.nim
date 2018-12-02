import nimcx
import nimdataframe

# nimdfT21
# Example for nimdataframe 
# last 2018-12-02

let datarows = 35500   # note data rows starting with 1
let afile = "nimDfTestData.csv"

# select one to test
#createRandomTestData(afile,datarows = datarows)       # mixed data types   ,do not generate headers here
createRandomTestDataInt(afile,datarows = datarows)    # int                ,do not generate headers here
#createRandomTestDataFloat(afile,datarows = datarows)  # float              ,do not generate headers here

var ndf9 = createDataframe(afile,rows=datarows,cols=6,hasHeader=true)
ndf9.colHeaders = @["A1","A2","A3","A4","A5","A6"]
ndf9.rowheaders = toSeq(0..<ndf9.rowcount)
ndf9.colwidths = @[10,10,10,10,10,10]
ndf9.colcolors = @[pink]
printLnBicol("Dataframe : ndf9 - The original dataframe holding all test data",xpos=2)
showDf(ndf9,
       colwd=ndf9.colwidths,
       colcolors=ndf9.colcolors,
       showframe=true,
       headertext=ndf9.colHeaders,
       showHeader=true)

       
# example usage of save and load dfSave also saves specified df params
#dfSave(ndf9,afile)
#ndf9 = dfLoad(afile)

# show some statistcs on cols 1,2,3 and 6 
# colspace adjusts col width
decho()
dfShowColumnStats(ndf9,desiredcols = @[1,2,3,6],colspace = 35)
decho()

# try to make a new dfs out of ndf9 with var rowheaders being row number
 
let leftfmt = "<18"    
var rowheaders = getRowRange(1,5)
printLnBicol("Dataframe : ndf10  - Dispalying first five rows of ndf9",xpos=2)
printLnInfoMsg(fmtx([leftfmt],"Header and Rows") , $(rowheaders[0] + 1) & " to " & $(rowheaders[rowheaders.len - 1] + 1) ,yellowgreen,xpos = 2)
var ndf10 = getRowDataRange(ndf9,rows = getRowRange(1,5),cols = toSeq(1..6),rowheaders=rowheaders)
showDf(ndf10,colwd=ndf9.colwidths,colcolors=ndf9.colcolors,showframe=true,headertext=ndf9.colHeaders,showHeader=true)
decho()

rowheaders = getRowRange(1000,1004)
printLnBicol("Dataframe : ndf11 - Displaying an intermediate range of rows of ndf9",xpos=2)
printLnInfoMsg(fmtx([leftfmt],"Header and Rows") , $(rowheaders[0] + 1) & " to " & $(rowheaders[rowheaders.len - 1] + 1) ,yellowgreen,xpos = 2)
var ndf11 = getRowDataRange(ndf9,rows = rowheaders,cols = toSeq(1..6),rowheaders=rowheaders)
showDf(ndf11,colwd=ndf9.colwidths,colcolors=ndf9.colcolors,showframe=true,headertext=ndf9.colHeaders,showHeader=true)
#echo()
#showAnyRowRange(ndf9,rowheaders) # here somewhere 5 rows
decho()

# show last 5 rows
rowheaders = getRowRange((ndf9.rowcount - 4),ndf9.rowcount)
printLnBicol("Dataframe : ndf12   - Displaying last 5 rows of ndf9",xpos=2)
printLnInfoMsg(fmtx([leftfmt],"Header and Rows") , $(rowheaders[0] + 1) & " to " & $(rowheaders[rowheaders.len - 1] + 1) ,yellowgreen,xpos = 2)
var ndf12 = getRowDataRange(ndf9,rows = getRowRange(ndf9.rowcount - 4,ndf9.rowcount),cols = toSeq(1..6),rowheaders=rowheaders)
showDf(ndf12,colwd=ndf9.colwidths,colcolors=ndf9.colcolors,showframe=true,headertext=ndf9.colHeaders,showHeader=true)

# show raw
decho()
printLnBicol("Dataframe : ndf12   - Displaying last 5 rows of ndf9 in raw format",xpos=2)
showAnyRowRange(ndf9,rowheaders) 

# show rotated
decho()
var ndf13 = rotateDf(ndf12,hasHeader=true)
printLnBicol("Dataframe : ndf13   - Displaying a rotated ndf12 former rows are now columns",xpos=2)
showDf(ndf13,showframe=true,framecolor=skyblue,headertext=ndf9.colheaders,showheader=true)


doFinish()
