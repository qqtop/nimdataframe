import os,cx,nimFinLib,strutils,nimdataframe

#  nimdfT3.nim
#  
#  Tests for nimdataframe
# 
#  shows usage of nimdataframe with yahoo finance data obtained via nimfinlib
#  
#  and usage of nimfinlib Stocks object with nimdataframe
#  
#  display possibilities, column coloring and alignment
#  


# converters are used to convert Stock objects data to nimss
# (nimss  nimStringSequence)
# (nimis  nimIntegerSeqence)
# (nimdf  nimdataframe)
# 
# 
# 
# 

var mystock = "AAPL"   # yahoo stock code format

 
converter finlibdate(astock:Stocks):nimss =
      result = @[]
      for x in astock.date:
          result.add(x) 

 
converter finlibopen(astock:Stocks):nimss =
      result = @[]
      for x in astock.open:
          result.add(ff2(x,3))   
 

converter finlibhigh(astock:Stocks):nimss =
      result = @[]
      for x in astock.high:
          result.add(ff2(x,3))  


converter finliblow(astock:Stocks):nimss =
      result = @[]
      for x in astock.low:
          result.add(ff2(x,3))  


converter finlibclose(astock:Stocks):nimss =
      result = @[]
      for x in astock.close:
          result.add(ff2(x,3))
          

converter finlibvolume(astock:Stocks):nimss =
      result = @[]
      for x in astock.vol:
          result.add(ff2(x,0))
          

converter finlibadjc(astock:Stocks):nimss =
      result = @[]
      for x in astock.adjc:
          result.add(ff2(x,3))   
          
 
var myD2 = getSymbol2(mystock,minusdays(getDateStr(),365),getDateStr())   
decho(3)

var ndf = makeNimDf(finlibdate(myD2),finlibopen(myD2),finliblow(myD2),finlibhigh(myD2),finlibclose(myD2),finlibadjc(myD2),finlibvolume(myD2))

var headertext = @["Date","Open","Low","High","Close","Adj.Close","Volume"]  # custom header text for each col in dataframe
var rows = 3  # data rows to display

# cols,colwd,colcolors parameters seqs must be of equal length
var cols      = @[1,2,3,4,5,6,7]
var colwd     = @[10,10,10,10,10,10,14]
var colcolors = @[yellow,pastelyellowgreen,palegreen,pastelpink,pastelblue,pastelwhite,violet]

var pbl = "90"
var pcl = pastelyellowgreen  

printLnBiCol("Nimdataframe test with yahoo stock data : " & mystock)
echo()
println(fmtx(["<" & pbl,""],"#1 no frame , no header  --> ok","\n"),pcl,styled={stylereverse})
showDf(ndf,rows = rows,cols = cols ,colwd = colwd,colcolors = colcolors,showFrame = false,showHeader = false,headertext = @[])
  
echo()
println(fmtx(["<" & pbl,""],"#2 no frame , header =  first line --> ok","\n"),pcl,styled={stylereverse})
showDf(ndf,rows = rows,cols = cols ,colwd = colwd,colcolors = colcolors,showFrame = false,showHeader = true,headertext = @[])
      
  
decho(1)
println(fmtx(["<" & pbl,""],"#3 no frame , header = headertext alignright  --> ok","\n"),pcl,styled={stylereverse})
showDf(ndf,rows = rows, cols = cols , colwd = colwd, colcolors = colcolors, showFrame = false, showHeader = true,headertext = headertext,leftalignflag = false)

 
decho(1)
println(fmtx(["<" & pbl,""],"#4 frame , no header  alignright --> ok","\n"),pcl,styled={stylereverse})
showDf(ndf,rows = rows, cols = cols , colwd = colwd, colcolors = colcolors ,showFrame = true,framecolor = yellow,showHeader = false,headertext = @[],leftalignflag = false)

   
decho(1)
println(fmtx(["<" & pbl,""],"#5 frame , header  = first line  alignright --> ok","\n"),pcl,styled={stylereverse})
showDf(ndf,rows = rows, cols = cols , colwd = colwd, colcolors = colcolors ,showFrame = true,framecolor = yellow,showHeader = true,headertext = @[],leftalignflag = false)

    
decho(1)
println(fmtx(["<" & pbl,""],"#6 frame , header , aligned rightside  -->  ok","\n"),pcl,styled={stylereverse})
showDf(ndf,rows = rows, cols = cols , colwd = colwd, colcolors = colcolors ,showFrame = true,showHeader = true,headertext = headertext,leftalignflag = false)
     
      
     
doFinish()  