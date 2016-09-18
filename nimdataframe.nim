{.deadCodeElim: on.}
##
##   Library     : nimdataframe.nim
##
##   Status      : development
##
##   License     : MIT opensource
##
##   Version     : 0.0.1
##
##   ProjectStart: 2016-09-16
##   
##   Latest      : 2016-09-18
##
##   Compiler    : Nim >= 0.14.2
##
##   OS          : Linux
##
##   Description :
##                 simple dataframe 
##                 
##                 create a dataframe for display or processing
##                 
##                 from online or local csv files
##
##
##   Usage       : import nimdataframe
##
##   Project     : https://github.com/qqtop/NimDataFrame
##
##   Docs        : http://qqtop.github.io/nimdataframe.html
##
##   Tested      : OpenSuse 13.2 ,  OpenSuse Tumbleweed 
## 
##   Notes       : Initial feeble attempt ...  
## 
##  

import cx,httpclient,browsers,terminal
import parsecsv,streams,algorithm


   
type      
      nimdf* = seq[seq[string]]   # nim data frame
      nimss* = seq[string]        # nim string seq

proc newNimDf():nimdf = @[]
proc newNimSs():nimss = @[]

var dfcolwd = newSeq[int]()         # holds dataframe column widths 
var csvrows = -1                    # in case of getdata2 csv files we may get processed rowcount back

proc getData1*(url:string):auto =
  ## getData
  ## 
  ## used for internet based data in csv format
  ## 
  try:
       result  = getcontent(url)   # orig test data
  except :
      printLnBiCol("Error : " & url & " content could not be fetched . Retry with -d:ssl",":",red) 
      printLn(getCurrentExceptionMsg(),red,xpos = 9)
      doFinish()


proc getData2*(filename:string,cols:int = 2,sep:char = ','):auto = 
    ## getData2
    ## 
    ## used for csv files with a path and filename available
    ## 
 
    # we read by row but add to col seqs --> so myseq contains seqs of col data 
    var ccols = cols 
      
    var x: CsvParser
    var s = newFileStream(filename, fmRead)
    if s == nil: 
            printLnBiCol("Error : " & filename & " content could not be accessed.",":",red)
            printLn(getCurrentExceptionMsg(),red,xpos = 9)
            doFinish()
    else: 
        # we need to check if required cols actually exist or there will be an error
        open(x, s, filename,separator = sep)
        # we read one row:
        discard readRow(x)
        var itemcount = 0
        for val in items(x.row):
          inc itemcount
        close(x)
        close(s)
        
        # now we make sure that the passed in cols is not larger than itemcount
        if ccols > itemcount: ccols = itemcount
        
        var myseq = newNimDf()
        for x in 0.. <ccols:
           myseq.add(@[])
           
        # here we actually use everything
        s = newFileStream(filename, fmRead)
        open(x, s, filename,separator = sep)
        var dxset = newNimSs()
        var c = 0  # counter
       
        while readRow(x):
          try:   
                for val in items(x.row):
                  if c < ccols :
                    dxset.add(val)
                    myseq[c].add(dxset)   
                    inc c
                    dxset = @[]
                c = 0  
          except:
                c = 0
                discard
               
        csvrows = processedRows(x)
        close(x)
        result = myseq    # this holds col data now
        

proc makeDf1*(ufo1:string):nimdf =
   ## makeDf
   ## 
   ## used to create a dataframe with data string received from getData
   ## 

   var ufol = splitLines(ufo1)
   var df = newNimDf()
  
   var ufos = ufol[0].split(",")
   var ns = newNimSs()
   # init the dfcolwd that is we put a 0 into all possible positions
   for xx in 0.. <ufos.len: dfcolwd.add(0)
   
   for x in 0.. <ufol.len:
      ufos = ufol[x].split(",")  # problems may arise if text has commas ... then need some preprocessing
      ns = newNimSs()
      var wdc = 0
      for xx in 0.. <ufos.len:
          ns.add(ufos[xx].strip(true,true))
          if wdc == dfcolwd.len:
            wdc = 0
          if dfcolwd[wdc] < ufos[xx].len:
                dfcolwd[wdc] = ufos[xx].strip(true,true).len
                     
          inc wdc     
      df.add(ns)
   result = df  


proc makeDf2*(ufo1:nimdf,cols:int = 0):nimdf =
   ## makeDf2
   ## 
   ## used to create a dataframe with nimdf object received from getData2
   ## 

   var df = newNimDf()       # new dataframe to be returned
   var arow = newNimSs()     # one row of the data frame
   
   # now need to get the col data out and massage into rows
   var dfcols = 0
   var dfrows = 0
   try:
     dfcols = ufo1.len  
     dfrows = ufo1[0].len  # this assumes all cols have same number of rows maybe shud check this
   except IndexError:
       printLn("dfcols = " & $dfcols,red)
       printLn("dfrows = " & $dfrows,red)
       printLn("IndexError raised . Exiting now...",red)
       doFinish()  
  
   for rws in 0.. <dfrows:     # rows count  
     arow = @[]
     for cls  in 0.. <dfcols:  # cols count  
       # now build our row for df
       try:
         if rws == dfrows - 1:
            arow.add(ufo1[cls][rws])  
         else:
            arow.add(ufo1[cls][rws])  
       except IndexError:
            printLn("arow   = " & $arow,red)
            try:
               printLn("ufo1   = " & $ufo1[cls][rws],red)
            except IndexError:
                  printLn("This error basically tells that the row data is not good\ncheck for empty rows or column less rows etc in the data file",red)
            printLn("dfcols = " & $dfcols,red)
            printLn("dfrows = " & $dfrows,red)
            printLn("cls    = " & $cls,red)
            printLn("rws    = " & $rws,red)
            printLn("IndexError raised .",red)
            # we could stop here too
            #printLn("Exiting now...",red)
            #doFinish()   
            
     df.add(arow)   
   
   result = df  


proc getcolheaders*(df:nimdf): nimss =
      ## getcolheaders
      ## 
      ## get the first line of the dataframe df 
      ## we assume line 0 contains headers
      ## 
     
      result = newNimss()
      for hx in df[0]:
         result.add(hx.strip(true,true))

proc getTotalHeaderColsWitdh*(df:nimdf):int = 
     ## getTotalHeaderColsWitdh
     ## 
     ## sum of all headers width
     ## 
     var ch = getcolheaders(df)
     result = 0
     for x in 0.. <ch.len:
         result = result + ch[x].strip(true,true).len

proc showHeader*(df:nimdf) = 
   ## showHeader
   ## 
   ## shows headers or first row of dataframe
   ## 

   var headers = getcolheaders(df)
   echo()
   printLn("Headers or first Line",salmon,xpos = 2,styled = {})
   printLn(headers,xpos = 2)
   echo()
proc showCounts*(df:nimdf) =    
   printLn("Columns and Rows Count",salmon,xpos = 2,styled = {})
   printLnBiCol("Col count : " & $getcolheaders(df).len,xpos = 2)
   printLnBiCol("Row count : " & $df.len,xpos = 2)
   echo()
  

proc showMaxColWidths*(df:nimdf) = 
    # here we show the actual max col widths found
    # currently not in use
    decho(1)
    printLn("Column Widths Total",salmon,xpos = 2,styled = {})
    var sumwd = 0
    var headers = getcolheaders(df)
    for y in 0.. <dfcolwd.len:
          printLnBiCol(fmtx(["<17","",""],headers[y],"--> ",dfcolwd[y]),"--> ",xpos = 2)
          sumwd = sumwd + dfcolwd[y]
    echo() 
 
    if sumwd == 0:
      printLnBiCol(fmtx(["<17","",""],"Row Width    Max ","--> ","N.A."),"--> ",darkgray,red,xpos = 2)
    else:
      printLnBiCol(fmtx(["<17","",""],"Row Width    Max ","--> ",sumwd),"--> ",xpos = 2)
    
    printLnBiCol(fmtx(["<17","",""],"Header Width Max ","--> ",getTotalHeaderColsWitdh(df)),"--> ",xpos = 2)
    printLn("For data where there are no headers header data is taken from the first row.",lightgrey,xpos = 2)
    decho(2)

  
  
proc showDf*(df:nimdf,rows:int = 10,cols:int = 2 ,colwd:int = 18, showframe:bool = false,header:bool = false) =
    ## showDf
    ##
    ## Displays a dataframe 
    ## 
    ## number of rows default =  10
    ## with cols from left to right according to cols default = 2
    ## column width default = 18
    ## showFrame  default = off
    ## header indicates if an actual header is available
    ## frame character can be shown
    ##
  
    var okrows = rows
    var okcols = cols
    
    # if we have some over lengths specified we reset to ax possible
    if okcols > df[0].len : okcols = df[0].len 
    if okrows == 0 or okrows > df.len: okrows = df.len
           
    for x in 0.. <okrows:     # note we get rows data rows back and the header
             
      for y in 0.. <okcols:
          var displaystr = ""        
         
         # this cuts the column contents to max colwd 
          try:
            for z in 0.. <df[x][y].len:
              if z < colwd:
                   displaystr = displaystr & $df[x][y][z]
          except IndexError:
             # for time being we do like this , needs improvement
             printLn(getCurrentExceptionMsg(),red,xpos = 9)
             continue
                  
          var colfm = "<" & $(colwd)
          var fma = @[colfm,""]  
          if showframe == false:
              if x == 0:
                  if header == true:
                      print(fmtx(fma,displaystr,spaces(2)),yellowgreen,styled = {styleunderscore})  # here we make sure that there are 2 spaces between cols
                  else:
                      print(fmtx(fma,displaystr,spaces(2)),styled = {})  # here we make sure that there are 2 spaces between cols
                     
              else:
                  print(fmtx(fma,displaystr,spaces(2)),lightgrey,styled = {})  # here we make sure that there are 2 spaces between cols
          
          else:  # show the frame
              if x == 0:
                  if header == true:  
                      print(fmtx(fma,displaystr,spaces(1) & "|"),yellowgreen,styled = {styleunderscore})  # here we make sure that there are 2 spaces between cols
                  else:
                      print(fmtx(fma,displaystr,spaces(1) & "|"),styled = {})  # here we make sure that there are 2 spaces between cols
              
              else:
                  print(fmtx(fma,displaystr,spaces(1) & "|"),lightgrey,styled = {})  # here we make sure that there are 2 spaces between cols
    
      echo()   
  

     
proc showDfSelect*(df:nimdf,rows:int = 10,cols:seq[int] = @[1,2]  ,colwd:int = 18, showframe:bool = false,header:bool = false) =
    ## showDfSelect 
    ## 
    ## allows selective display of columns , with column numbers passed in as a seq
    ## the first column = 1 
      
    var okrows = rows
    var okcols = cols
    var displaystr = ""
    
    # we need a check to see if request cols actually exist
    for x in cols:
      if x > df[0].len:
         printLn("Error : showDfSelect needs correct column to display parameters cols",red) 
         printLn("Error : Requested Column >= " & $x & " do not exist in dataframe",red)
         # we exit
         doFinish()
    
    # take care of over lengths
    if okrows == 0 or okrows > df.len: okrows = df.len
               
    for x in 0.. <okrows:   # note we get rows data rows back and the header
             
      for yy in okcols:
          var y = yy - 1          
          if y > -1:   # need as the seq count starts with 0
              try:                    
                 displaystr = $df[x][y]  # will be cut to size by fmtx to fit into colwd
              except IndexError:
                 # just throw it away ..
                 discard
              
              var colfm = "<" & $(colwd)  # constructing the format string
              var fma = @[colfm,""]  
              if showframe == false:
                  if x == 0:
                      if header == true:
                          print(fmtx(fma,displaystr,spaces(2)),yellowgreen,styled = {styleunderscore})  # here we make sure that there are 2 spaces between cols
                      else:
                          print(fmtx(fma,displaystr,spaces(2)),styled = {})  # here we make sure that there are 2 spaces between cols
                        
                  else:
                      print(fmtx(fma,displaystr,spaces(2)),lightgrey,styled = {})  # here we make sure that there are 2 spaces between cols
              
              else:  # show the frame
                  if x == 0:
                      if header == true:  
                          print(fmtx(fma,displaystr,spaces(1) & "|"),yellowgreen,styled = {styleunderscore})  # here we make sure that there are 2 spaces between cols
                      else:
                          print(fmtx(fma,displaystr,spaces(1) & "|"),styled = {})  # here we make sure that there are 2 spaces between cols
                  
                  else:
                      print(fmtx(fma,displaystr,spaces(1) & "|"),lightgrey,styled = {})  # here we make sure that there are 2 spaces between cols
      
      echo()   


#proc showDfDynamic()
  ##  this will show a dataframe with selective cols and selective colls width for each col
  ##  each col shall be
  ##  individually colorable 
  ##  sort able 
  ##  parts shall be easyly extract able 
  ##  




proc showDataframeInfo*(df:nimdf) = 
   echo()
   hdx(printLn("Dataframe Info ",peru,styled = {}))
   showHeader(df)
   showCounts(df)
   #showMaxColWidths(df)  # not really interesting
   if csvrows - 1 > -1:
       printLnBiCol("Processed Original Data Rows : " & $(csvrows - 1),xpos = 2)   
   echo()    
   printLn("End of Dataframe Info",xpos = 2,lightskyblue)
   hlineln(tw,lightgrey)
   decho(1)


proc getColData*(df:nimdf,col:int):nimss =
   ## getColData
   ## 
   ## get one column from a nimdf dataframe
   ## 

   result = newNimSs()
   for x in 0.. <df.len:
        result.add(df[x][col])


# we want to sort data in one column des or asc
# maybe see there for multiple col df sorting 
# http://nim-lang.org/docs/algorithm.html#*,int,SortOrder
# 
proc sortcoldata*(coldata:nimss,order = Ascending):nimss = 
   ## sortcoldata
   ## 
   ## available order Ascending, Descending
   ## 
   var datacol = coldata
   datacol.sort(cmp[string],order = order) 
   result = datacol



proc makeNimDf*(dfcols : varargs[nimss]):nimdf = 
  ## makeNimDf
  ## 
  ## creates a nimdf with passed in col data which is of type nimss
  ## 
  ## still will need to check if all cols are same length otherwise append 
  ## 
  ## NaN etc
  ## 
  var df = newNimDf()
  for x in dfcols:
      df.add(x)
  result = makeDf2(df)


proc createDataFrame*(filename:string,cols:int = 2,sep:char = ','):nimdf = 
  ## createDataFrame
  ## 
  ## attempts to create a nimdf dataframe from url or local path
  ## 
  ## prefered are comma delimited csv or txt files
  ## 
  ## other should be clean , preprocess as needed
  ## 
  ## 
  
  printLn("Processing ...",skyblue) 
  curup(1)
  
  if filename.startswith("http") == true:
      var data1 = getData1(filename)
      result = makeDf1(data1)
  else:
      var data2 = getdata2(filename = filename,cols = cols,sep = sep)  
      result = makeDf2(data2,cols)
