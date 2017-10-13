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
#  2017-10-13
#  

var dmaxrows = 3000        # any number larger than actual row count is fine 
let ddata = "d96data.csv"  # your data file     
var dndf:nimdf             # define a nim dataframe

dndf = createDataFrame(ddata,cols = 5,rows=dmaxrows)  # specify desired cols as per data file , default = 2 
printLnBiCol("Data Source : " & ddata)
# display the dataframe
var displaycols = @[1,2,3,4,5]
showDf(dndf, rows = 15,cols = displaycols,colwd = @[10,10,10,10,10], colcolors = @[pastelgreen,pastelpink],showframe = true,framecolor = goldenrod,showHeader = false,leftalignflag = false) 
echo()
showDataframeInfo(dndf)  # show some information about dataframe
dfShowColumnStats(dndf,displaycols)
doFinish()
