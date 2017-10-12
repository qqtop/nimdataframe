import nimcx , nimdataframe 

# nimdfT6
# 
# Testing sorting dataframes
# 
# for best display run in full terminal
# 
# dates > 2099-12 will throw errors
# 
converter dfc[T](s:T):nimss = 
      result = newnimss()
      for x in 0 .. <s.len: 
           result.add($s[x])  

var frmd = "2016-01-01"
var rows = 10  # rows of data to display in dataframe

var colAI = dfc(createSeqDate(frmd,10))
var colBI = dfc(createSeqInt(10,0,1000))
var colCI = dfc(createSeqFloat(10,3))

 


var ndf2  = makeNimDf(colAI,colBI,colCI)       # this will use makedDf2 internally
var headertext =  @["Date","Integer","Float"]  
printlnBiCol("Original as created") 

showDf(ndf2,
       rows = rows,
       cols = @[1,2,3],
       colwd = @[10,10,10],
       showFrame = true,
       showHeader = true,
       colcolors = @[violet,pastelgreen],
       headertext = headertext,
       leftalignflag = true)    
       
curup(rows + 3)
printlnBiCol("Original as created with showHeader = false",xpos = 40) 
showDf(ndf2,
       rows = rows,
       cols = @[1,2,3],
       colwd = @[10,10,10],
       showFrame = true,
       showHeader = false,
       colcolors = @[violet,pastelgreen],
       headertext = headertext,
       leftalignflag = true,
       xpos = 40)          

curdn(rows + 7)       
showDataframeInfo(ndf2)


var asortcol = 1
var sortcolname = headertext[asortcol - 1]
printlnBiCol("Sorted asc on Col : " & $asortcol & " Name : " & sortcolname,xpos = 1) 

var ndf3 = sortdf(ndf2,asortcol,"asc")

showDf(ndf3,
       rows = rows,
       cols = @[1,2,3],
       colwd = @[10,8,8],
       showFrame = true,
       showHeader = true,
       colcolors = @[lime,pastelgreen,pastelgreen],
       headertext = headertext,
       leftalignflag = false,
       xpos = 1)    

       
curup(14)

asortcol = 2
sortcolname = headertext[asortcol - 1]
printlnBiCol("Sorted on Col : " & $asortcol & " Name : " & sortcolname,brightyellow,bblack,":",37,false,{}) 

var ndf4 = sortdf(ndf2,asortcol,"asc")

showDf(ndf4,
       rows = rows,
       cols = @[1,2,3],
       colwd = @[10,8,8],
       showFrame = true,
       showHeader = true,
       colcolors = @[pastelgreen,lime,pastelgreen],
       headertext = headertext,
       leftalignflag = false,
       xpos = 37)    



curup(14)
asortcol = 3
sortcolname = headertext[asortcol - 1]
printlnBiCol("Sorted on Col : " & $asortcol & " Name : " & sortcolname,lime,bblack,":",73,false,{}) 
var ndf5 = sortdf(ndf2,asortcol,"asc")
showDf(ndf5,rows = rows ,cols = @[1,2,3],colwd = @[10,8,8],showFrame = true,showHeader = true,
       colcolors = @[pastelgreen,pastelgreen,lime],
       headertext = headertext,leftalignflag = false,xpos = 73)    

decho(3)
printlnBiCol("New df: with selected rows and cols stipulated via getRowDataRange from sorted df ndf5")
var ndf6 = getRowDataRange(ndf5,rows = @[1,2,4,6],cols = @[1,2,3])
showDf(ndf6,rows = rows ,cols = @[1,2,3],colwd = @[10,8,8],showFrame = true,showHeader = true,
       colcolors = @[pastelgreen,pastelgreen,pastelgreen],
       headertext = headertext,leftalignflag = false)    


doFinish()
