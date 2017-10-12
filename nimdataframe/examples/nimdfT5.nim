import os,nimcx,nimdataframe

# nimdfT5
# 
# Testing sorting dataframes
# 
# showDf needs at least 2 cols to display 
# 
proc makeHeader(cols:int):nimss =
     result = newnimss()
     for dx in 1.. cols: 
        for x in 65.. 90:
            result.add($char(x) & $dx)



var data = "nimDfTestData.csv"   # change name as desired
createRandomTestData(data,datarows = 5000)       # creates a data file with random data 7 columns and 2000 rows
 
var ndf:nimdf                    # define a nim dataframe
ndf = createDataFrame(data,cols = 8)  # specify desired cols as per data file , default = 2 

printLnBiCol("Data Source : " & data)

var rows = 10
var cols  =  @[1,2,3,4,5,6,7,8]
var colwd =  @[12,10,10,10,10,10,14,4]   # column width must be specified for all cols 

showDf(ndf,
       rows = rows,
       cols = cols,
       #colwd = colwd,
       showframe = true,
       showHeader = true,
       headertext = makeHeader(cols.len),       #@["A","B","C","D","E","F","G"],
       colcolors = @[pastelgreen,pastelpink,peru,gold,pastelblue],
       framecolor = dodgerblue,
       leftalignflag = false) 
       
echo()
# show info
showDataframeInfo(ndf)

# sort this dataframe on the last column
printlnBiCol("Sorted Dataframe  : ndf2   sorted col in lime")
var ndf2 = sortdf(ndf,cols.len,"desc")  # and have a new dataframe sorted on last column

var myheadertext = makeHeader(cols.len) # we use a customheader for the sorted dataframe
myheadertext[0] = "DATE"                # change the header of the first col to DATE

showDf(ndf2,
       rows = rows,
       cols = cols,
       colwd = colwd,
       showFrame = true,
       showHeader = true,
       colcolors = @[pastelgreen,pastelpink,peru,gold,white,white,white,lime],
       headertext = myheadertext,
       leftalignflag = false)    
       
showDataframeInfo(ndf2)

removeFile(data)
doFinish()
