import nimcx,nimdataframe,algorithm,stats

#  nimdfT9.nim
#  
#  Linux only , run in full terminal 
#  
#  Tests for nimdataframe
# 
#  shows usage of nimdataframe with test data d96data.csv
#  
#  nimble install nimcx
#  nimble install https://github.com/qqtop/nimdataframe.git
#  
#  2017-10-07
#  

var dmaxrows = 3000        # any number larger than actual row count is fine 
let ddata = "d96data.csv"  # your data file     
var dndf:nimdf             # define a nim dataframe

dndf = createDataFrame(ddata,cols = 5,rows=dmaxrows)  # specify desired cols as per data file , default = 2 
printLnBiCol("Data Source : " & ddata)
# display the dataframe
showDf(dndf, rows = 15,cols = @[1,2,3,4,5],colwd = @[10,10,10,10,10], colcolors = @[pastelgreen,pastelpink],showframe = true,framecolor = goldenrod,showHeader = false,leftalignflag = false) 
echo()
showDataframeInfo(dndf)  # show some information about dataframe
printLn("Statistics  ",peru)
let desiredcols = @[1,2,3,4,5]  # we want stats for all columns  or just state the ones you need
var mydfstats = dfColumnStats(dndf,desiredcols)
var xpos = 1
curup(3)
for x in 0..<mydfstats.len:
   printLnBiCol("Column : " & $(desiredcols[x]) & " Statistics",xpos = xpos,styled={styleUnderscore})
   showStats(mydfstats[x],xpos = xpos) 
   xpos += 25
   curup(15)
curdn(18)   
printLnBiCol("Statistics -> Rows processed: " & $getRowcount(dndf))
printLnBiCol("Statistics -> Cols processed: " & $desiredcols.len & " of " & $getColcount(dndf))   

doFinish()
