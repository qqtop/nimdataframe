import os,cx,nimFinLib,strutils,nimdataframe

#  nimdfT3.nim
#  
#  Tests for nimdataframe
# 
#  shows usage of nimdataframe with yahoo finance data obtained via nimfinlib
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

var mystock = "0001.HK"   # yahoo stock code format


converter myclose(astock:Stocks):nimss =
      result = @[]
      for x in astock.close:
          result.add($(x))
 
converter mydate(astock:Stocks):nimss =
      result = @[]
      for x in astock.date:
          result.add($(x)) 
 
 
converter myvolume(astock:Stocks):nimss =
      result = @[]
      for x in astock.vol:
          result.add($x)  
 

converter myhigh(astock:Stocks):nimss =
      result = @[]
      for x in astock.high:
          result.add($x)  



converter mylow(astock:Stocks):nimss =
      result = @[]
      for x in astock.low:
          result.add($x)  
 
 

converter myadjc(astock:Stocks):nimss =
      result = @[]
      for x in astock.adjc:
          result.add($x)   
          
 
var myD2 = getSymbol2(mystock,minusdays(getDateStr(),365),getDateStr())   
decho(3)

var ndf = makeNimDf(mydate(myD2),myhigh(myD2),myadjc(myD2),myvolume(myD2))

printLnBiCol("Nimdataframe test with yahoo stock data : " & mystock)
echo()
println("#1 no header , no frame  --> ok\n")
showDf(ndf,rows = 5, cols = @[1,2,3,4] , colwd = @[10,8,9,13], colcolors = @[yellow,lightblue,palegreen,pastelpink], showframe = false,header = false,headertext = @["Date","High","Adj.Close","Volume"])
  
decho(1)
println("#2 no frame , header w/headertext  --> ok\n")
showDf(ndf,rows = 5, cols = @[1,2,3,4] , colwd = @[10,8,9,13], colcolors = @[yellow,green,red], showframe = false, header = true,headertext = @["Date","High","Adj.Close","Volume"])
  
decho(1)
println("#3 frame , no header first row assumed header  --> ok\n")
showDf(ndf,rows = 5, cols = @[1,2,3,4] ,colwd = @[10,8,9,13],colcolors = @[cyan,yellow,red,lightgreen],showframe = true,framecolor = yellow,header = false,headertext = @[])
    
decho(1)
println("#4 frame , header , aligned rightside  -->  ok \n ")
showDf(ndf,rows = 5, cols = @[1,2,3,4] ,colwd = @[10,8,9,13],colcolors = @[lime,red,green,peru],showframe = true,header = true,headertext = @["Date","High","Adj.Close","Volume"],leftalignflag = false)
     
doFinish()  