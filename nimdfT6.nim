import cx , nimdataframe 

# nimdfT6
# 
# Testing sorting dataframes
# 
# for best display run in full terminal
# 
# dates > 2099-12 will throw errors
# 


var frmd = "2016-01-01"
var rows = 10  # rows of data to display in dataframe

var colAI = createSeqDate(frmd,1000)
var colBI = createSeqInt(10000,0,1000)
var colCI = createSeqFloat(10000,3)

converter dfc[T](s:T):nimss =
      result = @[]
      for x in s: result.add($x)   


var ndf2  = makeNimDf(dfc(colAI),dfc(colBI),dfc(colCI))
var headertext =  @["Date","Integer","Float"]  
printlnBiCol("Original as created") 
showDf(ndf2,rows = rows ,cols = @[1,2,3],colwd = @[10,10,10],showFrame = true,showHeader = true,
       colcolors = @[violet,pastelgreen],
       headertext = headertext,leftalignflag = true)    
showDataframeInfo(ndf2)


var asortcol = 1
var sortcolname = headertext[asortcol - 1]
printlnBiCol("Sorted desc on Col : " & $asortcol & " Name : " & sortcolname,xpos = 1) 
var ndf3 = sortdf(ndf2,asortcol,"desc")
showDf(ndf3,rows = rows ,cols = @[1,2,3],colwd = @[10,8,8],showFrame = true,showHeader = true,
       colcolors = @[lime,pastelgreen,pastelgreen],
       headertext = headertext,leftalignflag = false)    

curup(15)
asortcol = 2
sortcolname = headertext[asortcol - 1]
printlnBiCol("Sorted on Col : " & $asortcol & " Name : " & sortcolname,":",brightyellow,xpos = 37) 
var ndf4 = sortdf(ndf2,asortcol,"asc")
showDf(ndf4,rows = rows ,cols = @[1,2,3],colwd = @[10,8,8],showFrame = true,showHeader = true,
       colcolors = @[pastelgreen,lime,pastelgreen],
       headertext = headertext,leftalignflag = false,xpos = 37)    



curup(rows + 5)
asortcol = 3
sortcolname = headertext[asortcol - 1]
printlnBiCol("Sorted on Col : " & $asortcol & " Name : " & sortcolname,":",lime,xpos = 73) 
var ndf5 = sortdf(ndf2,asortcol,"asc")
showDf(ndf5,rows = rows ,cols = @[1,2,3],colwd = @[10,8,8],showFrame = true,showHeader = true,
       colcolors = @[pastelgreen,pastelgreen,lime],
       headertext = headertext,leftalignflag = false,xpos = 73)    

decho(3)
printlnBiCol("New df: with selected rows and cols stipulated via getRowDataRange from existing df ndf5")
var ndf6 = getRowDataRange(ndf5,rows = @[1,2,4,6],cols = @[1,2,3])
showDf(ndf6,rows = rows ,cols = @[1,2,3],colwd = @[10,8,8],showFrame = true,showHeader = true,
       colcolors = @[pastelgreen,pastelgreen,pastelgreen],
       headertext = headertext,leftalignflag = false)    


doFinish()