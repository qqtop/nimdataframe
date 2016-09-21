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
##   Compiler    : Nim >= 0.14.3
##
##   OS          : Linux
##
##   Description :
##   
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
      nimis* = seq[int]           # nim integer seq

proc newNimDf*():nimdf = @[]
proc newNimSs*():nimss = @[]
proc newNimIs*():nimis = @[]


var dfcolwd = newNimIs()            # holds dataframe column widths 
var csvrows = -1                    # in case of getdata2 csv files we may get processed rowcount back

var temp = ""

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
        try:
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
        except CsvError: 
           discard
        
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
      ## 
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

       
proc showDf*(df:nimdf,rows:int = 10,cols:nimis = @[], colwd:nimis = @[], showframe:bool = false,framecolor:string = white,header:bool = false,headertext:nimss = @[]) =
    ## showDf
    ## 
    ## allows selective display of columns , with column numbers passed in as a seq
    ## 
    ## Convention :  the first column = 1 
    ## 
    ## Displays a dataframe 
    ## 
    ## number of rows default =  10
    ## 
    ## with cols from left to right according to cols default = 2
    ## 
    ## column width default = 18
    ## 
    ## showFrame  default = off
    ## 
    ## header indicates if an actual header is available
    ## 
    ## frame character can be shown in selectable color
    ## 
    ## headerless data can be show with headertest supplied
    ##
      
    var okrows = rows
    var okcols = cols
    var okcolwd = colwd  
    var toplineflag = false
    var displaystr = ""   
    
    # dynamic col width with colwd passed in if not colwd for all cols = 15 
         
    if okcolwd.len < okcols.len:
       # we are missing some colwd data we add default widths
       while okcolwd.len < okcols.len:
             okcolwd.add(15)
      
    
    # if not cols seq is specified we assume all cols
    if okcols == @[] and df[0].len > 0:
      try:
        for colno in 1.. df[0].len:    # note colno starts at 1 
             okcols.add(colno)
      except IndexError:
              discard
              
    # we need a check to see if request cols actually exist
    for col in okcols:
      if col > df[0].len:
         printLn("Error : showDfSelect needs correct column to display parameters cols",red) 
         printLn("Error : Requested Column >= " & $col & " does not exist in dataframe",red)
         # we exit
         doFinish()
   
   
    # calculate length of topline of frame based on cols and colwd 
    var frametoplinelen = 0
    assert okcols.len == okcolwd.len
    frametoplinelen = frametoplinelen + sum(okcolwd) +  (2 * okcols.len) + 1
    
    # take care of over lengths
    if okrows == 0 or okrows > df.len: okrows = df.len
               
    for row in 0.. <okrows:   # note we get rows data rows back and the header
             
      for col in 0.. <okcols.len:
      
              try:                    
                 displaystr = $df[row][col]  # will be cut to size by fma below to fit into colwd
              except IndexError:
                 # just throw it away ..
                 discard
                                       
              var colfm = "<" & $(okcolwd[col])  # constructing the format string
              var fma = @[colfm,""]  
              if showframe == false:
                  if row == 0:  
                      # no frame , but header either in data or just first row will be used 
                      if header == true and headertext == @[]:  # first line will be header
                          print(fmtx(fma,displaystr,spaces(2)),yellowgreen,styled = {styleunderscore})  # here we make sure that there are 2 spaces between cols
                      
                      elif header == false:
                          # no header  
                          print(fmtx(fma,displaystr,spaces(2)),styled = {})  # here we make sure that there are 2 spaces between cols
                      
                      elif header == true and headertext.len > 0:
                          # header using headertext 
                          print(fmtx(fma,headertext[col],spaces(2)),yellowgreen,styled = {styleunderscore}) 
                        
                        
                  else:
                      # all other rows data
                      print(fmtx(fma,displaystr,spaces(2)),lightgrey,styled = {})  # here we make sure that there are 2 spaces between cols
              
              
              else:  # show the frame
                  if row == 0:
                      
                      if header == true and headertext == @[]: # first line will be used as header
                          # set up topline of frame
                          if toplineflag == false:
                             print(".",lime)
                             hline(frametoplinelen - 2 ,framecolor,xpos = 2) 
                             println(".",lime)
                             toplineflag = true   
                             
                          if col == 0:    # first col of header          
                              print(framecolor & "|" & yellowgreen & fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),yellowgreen,styled = {styleunderscore})  # here we make sure that there are 2 spaces between cols
                          else: # other cols of header
                              print(fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),yellowgreen,styled = {styleunderscore})  # here we make sure that there are 2 spaces between cols
                      
                      elif header == true and headertext.len > 0:  # we use headers supplied in headertext
                          ## here is still a problem .. the right framing not ok
                          if toplineflag == false:
                             
                              print(".",lime)
                              hline(frametoplinelen - 2 ,framecolor,xpos = 2) 
                              println(".",lime)
                              toplineflag = true
                               
                              for hs in 0.. <headertext.len:
                                 var ncolfm = "<" & $(okcolwd[hs])  # constructing the format string
                                 var nfma = @[ncolfm,""]
                                 if col == 0:                                                                    
                                      print(framecolor & "|" & yellowgreen & fmtx(nfma,headertext[hs].strip(true,true),spaces(1) &  white),yellowgreen,styled = {styleunderscore})
                                 else :
                                      print(fmtx(nfma,headertext[hs].strip(true,true),spaces(1) & framecolor & "|" & white),yellowgreen,styled = {styleunderscore})
                              
                                 if hs == headertext.len - 1:
                                     print("|",framecolor)
                              
                              echo()   
          
                          if col == 0 : # if first col
                              print(framecolor & "|" & white & fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),white,styled = {})
                                                       
                          else:  # all other cols
                              print(fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),white,styled = {})  # here we make sure that there are 2 spaces between cols
                       
                      elif header == false:
                        
                             if toplineflag == false:
                             
                                  print(".",lime)
                                  hline(frametoplinelen - 2 ,framecolor,xpos = 2) 
                                  println(".",lime)
                                  toplineflag = true   
                                            
                             print(framecolor & "|" & yellowgreen & fmtx(fma,displaystr,spaces(1) & white),yellowgreen,styled = {styleUnderscore})
                             if col == okcols.len - 1:
                                print("|",framecolor)
                            
                               
                      
                      else:
                          print(framecolor & "|" & white & fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),styled = {})  # here we make sure that there are 2 spaces between cols
                  
                  else:
                     if col == 0:
                        print(framecolor & "|" & white & fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),lightgrey,styled = {})  # here we make sure that there are 2 spaces between cols
                     else:
                        print(fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),lightgrey,styled = {})  # here we make sure that there are 2 spaces between cols
      
      echo()   # need this here
    if showframe == true:
          # draw a bottom frame line
          print("|",framecolor)
          hline(frametoplinelen - 2 ,framecolor) 
          println("|",framecolor)
          


#proc showDfDynamic()
  ##  this will show a dataframe with selective cols and selective colls width for each col
  ##  each col shall be
  ##  individually colorable 
  ##  sort able 
  ##  parts shall be easyly extract able 
  ##  


proc showDataframeInfo*(df:nimdf) = 
   ## showDataframeInfo
   ## 
   ## some basic information of the dataframe
   ## 
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
            try:
              result.add(df[x][col])
            except IndexError:
              discard

proc getRowData*(df:nimdf,row:int = 1 ,dfcols: varargs[int]):nimss =
     ## getRowData
     ## 
     ## gets one row of a nimdf dataframe
     ## 
     result = newNimSs()
     if dfcols.len > 0:       # we have varargs that is specified cols
          for x in 0.. <dfcols.len:
             if dfcols[x] > df[row].len:
                println("Error: Columns > " & $df[row].len & " cannot be specified.",red)
                print("Check getRowData dfcols parameters given as : ",red)
                for va in dfcols:
                    print($va & spaces(1),red)
                echo()
                doFinish()
             else:   
                result.add(df[row][dfcols[x]])
     
     else:   # no varargs  that is we use all cols
          for y in 0.. <df[row].len:
             result.add(df[row][y])
     
 
 

proc getRowDataRange*(df:nimdf,rows:nimis = @[0] ,dfcols: varargs[int]):nimdf =
     ## getRowData
     ## 
     ## gets one row of a nimdf dataframe
     ## 
     result = newNimDf()
       
     for row in rows:
        result.add(getRowData(df,row,dfcols))
        
        
          
  
     
     

proc getCellData*(df:nimdf,row:int = 1 ,col:int = 1):string =
     ## getCellData
     ## 
     ## gets Data from a cell of the df at pos row/col 
     result = df[row][col]



# we want to sort data in one column desc or asc
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


proc sortdf*(df:nimdf,col:int):nimdf =
  ## sortdf
  ##
  ## sort df based on column number col 
  ##
  ##
  discard





proc makeNimDf*(dfcols : varargs[nimss]):nimdf = 
  ## makeNimDf
  ## 
  ## creates a nimdf with passed in col data which is of type nimss
  ## 
  # still will need to check if all cols are same length otherwise append 
  # 
  # NaN etc
  # 
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

  println(clearline)