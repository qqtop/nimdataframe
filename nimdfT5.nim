import os,cx,nimdataframe

# nimdfT5
# 
# Testing sorting dataframes
# 
# showDf needs at least 2 cols to display 
# 

var data = "nimDfTestData.csv"   # change name as desired
createRandomTestData(data)       # creates a data file with random data 7 columns and 2000 rows
 
var ndf:nimdf                    # define a nim dataframe
ndf = createDataFrame(data,cols = 7)  # specify desired cols as per data file , default = 2 

printLnBiCol("Data Source : " & data)
showDf(ndf, rows = 15,cols = @[1,2,3,4,5,6,7],colwd = @[10,10,10,10,10,10,14], colcolors = @[pastelgreen,pastelpink,peru,gold,pastelblue],showframe = true,framecolor = dodgerblue,showHeader = true,leftalignflag = false) 
echo()
# show info
showDataframeInfo(ndf)

# sort this dataframe on the 1st column
printlnBiCol("Sorted Dataframe  : ndf2")
var ndf2 = sortdf(ndf,1,"asc")  # and have a new dataframe sorted on some column
var headertext = @["Date","B","C","D","E","F","G"]
showDf(ndf2,rows = 15 , cols = @[1,2,3,4,5,6,7],colwd = @[10,10,10,10,10,10,14],showFrame = true,showHeader = true,colcolors = @[violet,pastelgreen],headertext = headertext,leftalignflag = false)    
showDataframeInfo(ndf2)

removeFile(data)
doFinish()