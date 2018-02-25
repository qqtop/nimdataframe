import nimcx,nimdataframe

#  nimdfT8.nim
#  
#  Tests for nimdataframe
# 
#  shows usage of nimdataframe with test data created with gendata.py  from bluenotes nim dataframe
#  we actually get 2000 random rows out of above test data and run our tests with this data ....
#  
#  2017-05-02
#  


var data = "supported_tickers.csv"   
let displayrows = 8              # header row is counted as row to display
 
var ndf:nimdf                    # define a nim dataframe
 
ndf = createDataFrame(data,cols = 6,hasHeader=true)  # specify desired cols as per data file , default = 2 
printLnBiCol("Data Source : " & data)

# display various configurations of this df
showDf(ndf,
       rows = displayrows,
       cols = @[1,2,3,4,5,6],
       colwd = @[10,10,10,8,10,10],
       colcolors = @[goldenrod,pastelpink],
       showframe = true,
       framecolor = goldenrod,
       showHeader = true,
       leftalignflag = false) 
echo()
showDataframeInfo(ndf)

# Workaround a bug : no header when asc or no sortorder specified in sortdf
# the workaround is to inject the header again unless sortorder is desc
let myorder = asc
var myheadertext = newnimss()
if myorder == asc: myheadertext = ndf.df[0] 

var ndf2 = sortdf(ndf,sortcol = 1,myorder)   #<--- header disappears when asc or no sortorder specified here
showDf(ndf2,                                 #     this issue does not show for desc
       rows = displayrows,
       cols = @[1,2,3,4,5,6],
       colwd = @[10,8,8],
       showFrame = true,
       showHeader = true,
       colcolors = @[lime,pastelgreen,pastelgreen],
       headertext = myheadertext,
       leftalignflag = false,
       xpos = 1)    
echo()
printLn("Ordered on first column descending",peru)
showDataframeInfo(ndf2)



doFinish()
