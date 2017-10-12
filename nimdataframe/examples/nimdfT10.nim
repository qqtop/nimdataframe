import nimcx , nimdataframe 

# nimdfT10
# 
# Testing sorting dataframes and saving dataframes
# 
# 
cleanscreen()
converter dfc[T](s:T):nimss = 
      result = newnimss()
      for x in 0 .. <s.len: 
           result.add($s[x])  

var frmd = today
var displayrows = 10  # rows of data to display in dataframe

var colA = dfc(createSeqDate(frmd,10))
var colB = dfc(createSeqInt(10,0,1000))
var colC = dfc(createSeqFloat(10,3))


var ndf2  = makeNimDf(colA,colB,colC)
printlnBiCol("Original as created") 

showDf(ndf2,
       rows = displayrows,
       cols = @[1,2,3],
       colwd = @[10,10,10],
       showFrame = true,
       showHeader = true,
       colcolors = @[violet,pastelgreen],
       headertext = @["Date","Integer","Float"] ,
       leftalignflag = true)    

dfsave(ndf2,"testdata_nimdfT10.csv")       
showDataframeInfo(ndf2)


var ndf3 = sortdf(ndf2,2,"asc")

showDf(ndf3,
       rows = displayrows,
       cols = @[1,2,3],
       colwd = @[10,10,10],
       showFrame = true,
       showHeader = true,                           #true,true ok firstline not shown and not included in sort order
       colcolors = @[violet,pastelgreen],
       headertext = @["Date","Integer","Float"] ,
       leftalignflag = true)    

dfsave(ndf3,"testdatasorted_nimdfT10.csv")       
showDataframeInfo(ndf3)
