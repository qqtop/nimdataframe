import nimcx,nimdataframe

#  nimdfT4.nim
#  
#  Tests for nimdataframe
# 
#  shows usage of nimdataframe with test data created with createRandomTestData
#  
#  


var data = "nimDfTestData.csv"   # change name as desired
createRandomTestData(data)       # creates a data file with random data 7 columns and 2000 rows
 
var ndf:nimdf                    # define a nim dataframe
 
ndf = createDataFrame(data,cols = 7)  # specify desired cols as per data file , default = 2 
printLnBiCol("Data Source : " & data)

# display various configurations of this df
showDf(ndf, rows = 15,cols = @[1,2,3,4,5,6,7],colwd = @[10,10,10,10,10,10,14], colcolors = @[pastelgreen,pastelpink,peru,gold,pastelblue],showframe = true,framecolor = dodgerblue,showHeader = true,leftalignflag = false) 
echo()

showDf(ndf, rows = 35,cols = @[1,2,3,4,5,6,7],colwd = colfitmax(ndf,7,3), colcolors = @[pastelgreen,pastelpink,peru,gold,pastelblue],showframe = true,framecolor = dodgerblue,showHeader = true,leftalignflag = false) 
echo()

showDf(ndf, rows = 15,cols = @[1,2,3,4,5,6,7],colwd = colfitmax(ndf,7,4),colcolors = @[pastelgreen,pastelpink,peru,gold,pastelblue],showframe = false,framecolor = dodgerblue,showHeader = true,leftalignflag = false) 
echo()

# show info
showDataframeInfo(ndf)


# make a new df called ndf2 using TWO columns from ndf created above 
var colA  = getColdata(ndf,1)  # get first col
#var colAs = sortcoldata(colA,true,Descending)  # we can sort a single col 

var colB  = getColdata(ndf,2)  # get 2nd col
var ndf2  = makeNimDf(colA,colB,hasHeader=false) # combine into new df

# display the new ndf2 
# Note if only 1 column is to be displayed frame and header will not be shown even if true
        
showDf(ndf2,rows = 10 ,cols = @[1,2],colwd = colfitmax(ndf2),showFrame = true,showHeader = true,colcolors = @[violet,pastelgreen],headertext = @["a","b"],leftalignflag = true)    
showDataframeInfo(ndf2)


doFinish()

