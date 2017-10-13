import nimcx,nimdataframe,algorithm,stats

#  nimdfT7.nim
#  
#  Tests for nimdataframe
# 
#  shows usage of nimdataframe with test data created with gendata.py  from bluenotes nim dataframe
#  dataset to large errored out maybe we should have an option to pipe to sqllite right away for huge datasets
#  
#  
#  
#  2017-10-13
#  

var maxrows = 3000   # 300000
var data = "test_01.csv"         # 4 numeric cols  1M rows
var ndf:nimdf                    # define a nim dataframe
ndf = createDataFrame(data,cols = 4,rows=maxrows)  # specify desired cols as per data file , default = 2 
printLnBiCol("Data Source : " & data)
# display various configurations of this df
showDf(ndf, rows = 15,cols = @[1,2,3,4],colwd = @[10,10,10,10], colcolors = @[pastelgreen,pastelpink],showframe = true,framecolor = goldenrod,showHeader = true,leftalignflag = false) 
echo()
showDataframeInfo(ndf)



data = "test_02_a.csv"            # 4 numeric cols  8M rows
var ndf2:nimdf                    # define a nim dataframe
ndf2 = createDataFrame(data,cols = 4,rows=maxrows)  # specify desired cols as per data file , default = 2 
printLnBiCol("Data Source : " & data)
# display various configurations of this df
showDf(ndf2, rows = 15,cols = @[1,2,3,4],colwd = @[10,10,10,10], colcolors = @[pastelgreen,pastelpink],showframe = true,framecolor = dodgerblue,showHeader = false,leftalignflag = false) 
echo()

data = "test_02_b.csv"           # 4 numeric cols   8M rows
var ndf3:nimdf                    # define a nim dataframe
 
ndf3 = createDataFrame(data,cols = 4,rows=maxrows)  # specify desired cols as per data file , default = 2 
printLnBiCol("Data Source : " & data)

# display various configurations of this df
showDf(ndf3,
       rows = 15,
       cols = @[1,2,3,4],
       colwd = @[10,10,10,10],
       colcolors = @[pastelgreen,pastelpink],
       showframe = true,
       framecolor = dodgerblue,
       showHeader = true) 
echo()



#var colAs = sortcoldata(colA,true,Descending)  # we can sort a single col 

# lets try to simply join test-02_a and test_02_b regardless of sort order

var colA  = getColdata(ndf2,1)  # get 1st col of ndf2
var colB  = getColdata(ndf2,2)  # get 2nd col
var colC  = getColdata(ndf2,3)  # get 3rd col
var colD  = getColdata(ndf2,4)  # get 4th col


var colE  = getColdata(ndf3,1)  # get 1st col of ndf3
var colF  = getColdata(ndf3,2)  
var colG  = getColdata(ndf3,3) 
var colH  = getColdata(ndf3,4) 

var ndf4  = makeNimDf(colA,colB,colC,colD,colE,colF,colG,colH) # combine into new df
currentLine()
showDf(ndf4, rows = 15,cols = @[1,2,3,4,5,6,7,8],colwd = @[10,10,10,10,10,10,10,10], colcolors = @[pastelgreen,pastelpink],showframe = true,framecolor = dodgerblue,showHeader = true,headertext = @["df 1","B","C","D","df 2","B","C","D"],leftalignflag = false) 
echo()


# lets try to join ndf2 and ndf3 based on the date fields
# what happens if there are no matching fields ?
# so basically we do a join on some condition like in sql and show the resulting dataframe
# further we want to have sum,mean of the numeric columns etc

# experiment
# sort on col df 1
var colseq = @[1,2,3,4,5,6,7,8]
var colwdseq = @[10,10,10,10,10,10,10,10]
var colorsseq = newSeq[string]()
for x in 0.. <colseq.len: colorsseq.add(randcol())
var ndf5 = sortdf(ndf4,1,"desc")
showDf(ndf5, rows = 15,cols = colseq ,colwd = colwdseq , colcolors = colorsseq,showframe = true,framecolor = dodgerblue,showHeader = true,headertext = @["Date 1","B","C","D","Date 2","B","C","D"],leftalignflag = false) 
showDataframeInfo(ndf5)
echo()

dfShowColumnStats(ndf5,colseq,colspace = 30)
   
doFinish()
