{.deadCodeElim: on.}
##
##   Library     : nimdataframe.nim
##
##   Status      : development
##
##   License     : MIT opensource
##
##   Version     : 0.0.1.2
##
##   ProjectStart: 2016-09-16
##   
##   Latest      : 2016-10-13
##
##   Compiler    : Nim >= 0.15
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
import os
import cx,httpclient,browsers,terminal
import parsecsv,streams,algorithm
import db_sqlite
import typetraits,typeinfo

let NIMDATAFRAMEVERSION* = "0.0.1.2"
   
type      
      
      nimss* = seq[string]         # nim string seq
      nimis* = seq[int]            # nim integer seq
      nimdf* = seq[nimss]          # nim data frame

proc newNimDf*():nimdf = @[]
proc newNimSs*():nimss = @[]
proc newNimIs*():nimis = @[]

proc createDataFrame*(filename:string,cols:int = 2,sep:char = ','):nimdf 


var dfcolwd = newNimIs()            # holds dataframe column widths 
var csvrows = -1                    # in case of getdata2 csv files we may get processed rowcount back

# used in sortdf
var intflag:bool = false
var floatflag:bool = false
var stringflag:bool = false



proc getData1*(url:string):auto =
  ## getData
  ## 
  ## used for internet based data in csv format
  ## 
  try:
       var zcli = newHttpClient()
       result  = zcli.getcontent(url)   # orig test data
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


proc getColCount*(df:nimdf):int = 
     result = df[0].len 
  
proc getRowCount*(df:nimdf):int = 
     result = df.len 


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
   printLnBiCol("Col count : " & $getColCount(df),xpos = 2)
   printLnBiCol("Row count : " & $getRowCount(df),xpos = 2)
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

proc colfitmax*(df:nimdf,cols:int = 0,adjustwd:int = 0):nimis =
  ## colfitmax
  ## 
  ## calculates best column width to fit into terminal width
  ## 
  ## all column widths will be same size
  ## 
  ## cols parameter must state number of cols to be shown default = all cols
  ## 
  ## if the cols parameter in showDf is different an error will be thrown
  ## 
  ## adjustwd allows to nudge the column width if a few column chars are not shown
  ## 
  ## which may happen if no frame is shown
  ## 
  
  var ccols = cols
  if ccols == 0:
    ccols = getColCount(df)
  
  var optcolwd = tw div ccols - ccols + adjustwd  
  var cwd = newNimIs()
  for x in 0.. <ccols: cwd.add(optcolwd)
  result = cwd
  
  
proc checkDfOk(df:nimdf):bool =
     if df.len > 0:
        result = true
     else:
        printLnBiCol("ERROR  : Dataframe has no data. Exiting .. ",":",red,red)
        result = false

       
proc showDf*(df:nimdf,rows:int = 10,cols:nimis = @[],colwd:nimis = @[], colcolors:nimss = @[], showframe:bool = false,framecolor:string = white,showHeader:bool = false,headertext:nimss = @[],leftalignflag:bool = true,xpos:int = 1) =
    ## showDf
    ## 
    ## Displays a dataframe 
    ## 
    ## allows selective display of columns , with column numbers passed in as a seq
    ## 
    ## Convention :  the first column = 1 
    ## 
    ## 
    ## number of rows default =  10
    ## 
    ## with cols from left to right according to cols default = 2
    ## 
    ## column width default = 18
    ## 
    ## an equal columnwidth can be achieved with colwd = colfitmax(df,0) the second param is to nudge the width a bit if required
    ## 
    ## showFrame  default = off
    ## 
    ## showHeader indicates if an actual header is available
    ## 
    ## frame character can be shown in selectable color
    ## 
    ## headerless data can be show with headertext supplied
    ##
    ## cols,colwd,colcolors parameters seqs must be of equal length and corresponding to each other
    ## 
    
    var okcolwd = colwd 
        
    if checkDfok(df) == false:  doFinish()
      
    var header = showHeader
    var frame  = showFrame
       
    if cols.len == 1:
      # to display one column data showheader and showFrame must be false
      # to avoid messed up display , Todo: take care of this eventually 
      
      header = false
      frame = false
    
    if cols.len != okcolwd.len:
       okcolwd = colfitmax(df,cols.len)   # try to best fit rather than to throw error
       #println("ERROR : Dataframe columns cols and colwd parameter are of different length. See showDf command. Exiting ..",red,truetomato)
       #doAssert cols.len == okcolwd.len 
    
    # turn this one if you want this info
    #if cols.len != colcolors.len:
    #   printLnBiCol("NOTE  : Dataframe columns cols and colcolors parameter are of different length",":",red,peru)
     
    if df[0].len == 0: 
       printLnBiCol("ERROR : Dataframe appears to have no columns. See showDf command. Exiting ..",":",red,truetomato)
       quit(0)
       
    var okrows = rows
    var okcols = cols
     
    var toplineflag = false
    var displaystr = ""   
    var okcolcolors = colcolors
    
    # dynamic col width with colwd passed in if not colwd for all cols = 15 
         
    if okcolwd.len < okcols.len:
       # we are missing some colwd data we add default widths
       while okcolwd.len < okcols.len:
             okcolwd.add(15)
      
    
    # if not cols seq is specified we assume all cols
    if okcols == @[] and getColCount(df) > 0:
      try:
        for colno in 0.. <getColCount(df):    # note column numbering starts at 0 , first col = 0
             okcols.add(colno)
      except IndexError:
              #discard
              raise
   
    
    #  need a check to see if request cols actually exist
    for col in okcols:
      if col > getColCount(df):
         printLn("Error : showDf needs correct column to display parameters cols",red) 
         printLn("Error : Requested Column >= " & $col & " does not exist in dataframe",red)
         # we exit
         doFinish()
   
    # set up column text and background color
    
    if okcolcolors == @[]: # default white on black
        var tmpcols = newNimSs()
        for col in 0.. <okcols.len:
            tmpcols.add(lightgrey)
        okcolcolors = tmpcols   
           
    else: # we get some colors passed in but not for all columns we set to white    
      
        var tmpcols = newNimSs()
        tmpcols = okcolcolors
        while tmpcols.len < okcols.len  :
                 tmpcols.add(lightgrey)
        okcolcolors = tmpcols         
                   
   
    # calculate length of topline of frame based on cols and colwd 
    var frametoplinelen = 0
    assert okcols.len == okcolwd.len
    frametoplinelen = frametoplinelen + sum(okcolwd) +  (2 * okcols.len) + 1
    
    # take care of over lengths
    if okrows == 0 or okrows > df.len: okrows = df.len
     
    var headerflagok = false 
    var bottomrowflag = false 
    var ncol = 0 
     
    for row in 0.. <okrows:   # note we get okrows data rows back and the header
             
      for col in 0.. <okcols.len:
          #var zcol = col
          #if col < 1: zcol = 0
            
          ncol = okcols[col] - 1
          if ncol < 0: ncol = 0
          
          #printlnBiCol("\nncol        : " & $ncol)
          #printLnBiCol("okcols[col] : " & $okcols[col])
          #printlnBicol("col         : " & $col )
         
          try:                    
                displaystr = $df[row][ncol]  # will be cut to size by fma below to fit into colwd
          except IndexError:
                # if row data not available we put NA , the actual df column does not contain NA
                displaystr = "NA"
                #echo row,"  ",ncol
                #raise
                
                
          var colfm = ""
          var fma   = newSeq[string]()
          if leftalignflag == true:
              colfm = "<" & $(okcolwd[col])  # constructing the format string
          else:
              colfm = ">" & $(okcolwd[col])  # constructing the format string
          fma = @[colfm,""]  
          
          # new setup 6 options
          
          #noframe noheader           1 ok
          #noframe firstlineheader    2 ok
          #noframe headertextheader   3 ok
          
          # ok for more than 1 col  
          #frame   noheader           4 ok
          #frame   firstlineheader    5 ok
          #frame   headertextheader   6 ok
          
          if frame == false:
          
                if frame == false and header == false:
                            if col == 0 :
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {},xpos = xpos) 
                            elif col > 0:
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {})
                                if col == okcols.len - 1: echo()  
                        
                  
                elif frame == false and header == true and headertext == @[]:
                            
                            if col == 0 and row == 0:
                                print(fmtx(fma,displaystr,spaces(2)),yellowgreen,styled = {styleunderscore},xpos = xpos)  
                            
                            elif col > 0 and row == 0:
                                print(fmtx(fma,displaystr,spaces(2)),yellowgreen,styled = {styleunderscore})                                   
                                if col == okcols.len - 1: echo()                      
                                
                            # all other rows data
                            if col == 0 and row > 0:
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {},xpos = xpos) 
                            elif col > 0 and row > 0:
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {})
                                      
                                if col == okcols.len - 1:          
                                    echo()  
                        
           
                elif frame == false and header == true and headertext != @[]:
                            
                            #print the header first
                            
                            if headerflagok == false:
                              
                                for hcol in 0.. <okcols.len:
                                    var nhcol = okcols[hcol] - 1
                                  
                                    var hcolfm = ""
                                    var hfma   = newSeq[string]()
                                    if leftalignflag == true:
                                          hcolfm = "<" & $(okcolwd[hcol])  # constructing the format string
                                    else:
                                          hcolfm = ">" & $(okcolwd[hcol])  # constructing the format string
                                    hfma = @[hcolfm,""]   
                                                                  
                                    if hcol == 0:
                                      print(fmtx(hfma,headertext[nhcol],spaces(2)),yellowgreen,styled = {styleunderscore},xpos = xpos) 
                                    elif hcol > 0:
                                      print(fmtx(hfma,headertext[nhcol],spaces(2)),yellowgreen,styled = {styleunderscore}) 
                                      if hcol == okcols.len - 1: 
                                          echo()    
                                          headerflagok = true 
                            
                            if headerflagok == true:
                                # all other rows data
                                if col == 0 and row >= 0  :
                                    print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {},xpos = xpos) 
                                elif col > 0 and row >= 0 :
                                    print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {})     
                                    if col == okcols.len - 1: echo()           
                                
                    
                      
          if frame == true:            
              
              if frame == true and header == false:
                      # set up topline of frame
                      if toplineflag == false:
                          print(".",lime,xpos = xpos)
                          hline(frametoplinelen - 2 ,framecolor,xpos = 2) 
                          println(".",lime)
                          toplineflag = true 
                      
                      if col == 0: 
                            print(framecolor & "|" & okcolcolors[col] & fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),okcolcolors[col],styled = {},xpos = xpos)
                            if col == okcols.len - 1: echo()
                      else: # other cols of header
                            print(fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),okcolcolors[col],styled = {})  
                            if col == okcols.len - 1: echo() 
                
              if frame == true and header == true and headertext == @[]: # first line will be used as header
                      # set up topline of frame
                      if toplineflag == false:
                          print(".",magenta,xpos = xpos)
                          hline(frametoplinelen - 2 ,framecolor,xpos = 2) 
                          println(".",lime)
                          toplineflag = true   
                        
                                              
                      # first row as header 
                      if col == 0 and row == 0:
                              print(framecolor & "|" & yellowgreen & fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),yellowgreen,styled = {styleunderscore},xpos = xpos)                           
                              
                      elif col > 0 and row == 0:
                                  print(fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),yellowgreen,styled = {styleunderscore})  
                                  if col == okcols.len - 1: echo()                      
                                
                      # all other rows data
                      if col == 0 and row > 0:
                                  print(framecolor & "|" & okcolcolors[col] & fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),okcolcolors[col],styled = {},xpos = xpos)
                              
                      elif col > 0 and row > 0:
                                  print(fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),okcolcolors[col],styled = {}) 
                                  if col == okcols.len - 1: echo()  
                  
                
              if frame == true and header == true and headertext != @[]:
                  
                            # set up topline of frame
                            if toplineflag == false:
                              print(".",magenta,xpos = xpos)
                              hline(frametoplinelen - 2 ,framecolor,xpos = 2) 
                              println(".",lime)
                              toplineflag = true   
                        
                  
                            #print the header first
                            
                            if headerflagok == false:
                              
                                for hcol in 0.. <okcols.len:
                                    
                                    var nhcol = okcols[hcol] - 1
                                    if nhcol == -1:
                                      nhcol = 0
                                                                         
                                  
                                    var hcolfm = ""
                                    var hfma   = newSeq[string]()
                                    if leftalignflag == true:
                                          hcolfm = "<" & $(okcolwd[hcol])  # constructing the format string
                                    else:
                                          hcolfm = ">" & $(okcolwd[hcol])  # constructing the format string
                                    hfma = @[hcolfm,""]   
                                                                  
                                    if hcol == 0:
                                      print(framecolor & "|" & yellowgreen & fmtx(hfma,headertext[nhcol],spaces(1) & framecolor & "|" & white),yellowgreen,styled = {styleunderscore},xpos = xpos) 
                                    elif hcol > 0:
                                      print(fmtx(hfma,headertext[nhcol],spaces(1) & framecolor & "|" & white),yellowgreen,styled = {styleunderscore}) 
                                      if hcol == okcols.len - 1: 
                                          echo()    
                                          headerflagok = true 
                            
                            if headerflagok == true:
                                # all other rows data
                                if col == 0 and row >= 0  :
                                    print(framecolor & "|" & okcolcolors[col] & fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),okcolcolors[col],styled = {},xpos = xpos) 
                                elif col > 0 and row >= 0 :
                                    print(fmtx(fma,displaystr,spaces(1) & framecolor & "|" & white),okcolcolors[col],styled = {})     
                                    if col == okcols.len - 1: echo()           


          if row + 1 == okrows and col == okcols.len - 1  and bottomrowflag == false and frame == true:
                          # draw a bottom frame line 
                          print(".",lime,xpos = xpos)  # left dot
                          hline(frametoplinelen - 2 ,framecolor) 
                          println(".",lime)
                          bottomrowflag = true
          
             

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
     ## Note : col = 1 denotes first col of df , which is consistent with showDf 
     ##          
     ## 
     ## 
     
     var zcol = col - 1
     if zcol < 0 or zcol > getColCount(df) :
        println("Error : Wrong column number specified",red)
        quit(0)
     
     result = newNimSs()
     for x in 1.. <df.len:
            try:
              result.add(df[x][zcol])
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
proc sortcoldata*(coldata:nimss,header:bool = false,order = Ascending,sort:bool = true):nimss = 
   ## sortcoldata
   ## 
   ## sorts data in a single column 
   ## 
   ## available order Ascending, Descending 
   ## 
   ## if sort is false no sorting will be performed
   ## 
   ## 
    
   var datacol = coldata
   
   if sort == true :
   
      if header == true:
          datacol = datacol[1.. <datacol.len]
   
      datacol.sort(cmp[string],order = order) 
      
   elif sort == false:
     
      if header == true:
          datacol = datacol[1.. <datacol.len]
          
   result = datacol



proc `$`[T](some:typedesc[T]): string = name(T)
proc typetest[T](x:T): T =
  # used to determine the field types in the temp sqllite table used for sorting
  
  #echo "type: ", type(x), ", value: ", x
  var cvflag = false
  intflag    = false
  floatflag  = false
  stringflag = false
    
  if cvflag == false and floatflag == false and intflag == false and stringflag == false:
    try:
       var i1 =  parseInt(x)
       if $type(i1) == "int":
          intflag = true
          #printlnBiCol("Intflag = true : " & $x )
          cvflag = true
    except ValueError:
          discard
    
  if cvflag == false and floatflag == false and intflag == false and stringflag == false:
   try:
      var f1 = parseFloat(x)
    
      if $type(f1) == "float":
         floatflag = true 
         #printlnBiCol("Floatflag = true : " & $x )
         cvflag = true
   except ValueError:
          discard
         

  if cvflag == false and intflag == false and floatflag == false and stringflag == false:
        try:
          # as all incoming are strings this will never fail and is put last here
          if $type(x) == "string":
             stringflag = true 
             #printlnBiCol("Stringflag = true : " & $x )
             cvflag = true
        except ValueError:
             discard 
 
  result = $type(x)   


proc sortdf*(df:nimdf,sortcol:int = 1,sortorder = ""):nimdf =
  ## sortdf
  ## 
  ## sorts a dataframe asc or desc 
  ## 
  ## supported sort types are integer ,float or string columns
  ## 
  ## other types maybe added later
  ## 
  ## the idea implemented here is to read the df into a temp sqllite table
  ## sort it and return the sorted output as nimdf
  ## 
  ##  .. code-block:: nim
  ##  
  ##     var ndf2 = sortdf(ndf,5,"asc")  $ sort a dataframe on the fifth col ascending

  var asortcol = sortcol
  
  let db = open("localhost", "user", "password", "dbname")
  db.exec(sql"DROP TABLE IF EXISTS dfTable")
  var createstring = "CREATE TABLE dfTable (Id INTEGER PRIMARY KEY "
  for x in 0.. <getColCount(df):
       discard typetest(df[1][x])   # here we do the type testing for table creation
       
       if intflag == true:
          createstring = createstring & "," & $char(x + 65) & " integer "   
      
       elif floatflag == true:
          createstring = createstring & "," & $char(x + 65) & " float "  
      
       elif stringflag == true:
          createstring = createstring & "," & $char(x + 65) & " varchar(50) "
       
     
  createstring = createstring & ")"
  db.exec(sql"BEGIN")
  db.exec(sql(createstring))

  # now the table exists and we add data

  var insql = "INSERT INTO dfTable (" 
  var tabl = ""
  var vals = ""

  # set up the cols of the insert sql 
  for col in 0.. <getcolcount(df):
        if col < getColCount(df) - 1:
          tabl = tabl & $char(col + 65) & ","       
        else:   
          tabl = tabl & $char(col + 65)
          

  # set up the values of the insert sql   
  for row in 1.. <getRowCount(df):
      for col in 0.. <getColCount(df):
       try: 
         if typetest(df[row][col]) == "string":
        
            if col < getColCount(df) - 1:
              vals = vals & dbQuote(df[row][col]) & ","
            else:   
              vals = vals & dbQuote(df[row][col])
              
         elif typetest(df[row][col]) == "integer":
           
            if col < getColCount(df) - 1:
              vals = vals & df[row][col] & ","
            else:   
              vals = vals & df[row][col]
              
         elif typetest(df[row][col]) == "float":
           
            if col < getColCount(df) - 1:
              vals = vals & df[row][col] & ","
            else:   
              vals = vals & df[row][col]
       
       except IndexError:
              println("Error : Sorting of dataframe with columns of different row count currently only possible",red)
              println("        if the column with the least rows is the first column of the dataframe",red)
              echo()
              raise
       
      insql = insql & tabl & ") VALUES (" & vals & ")"   # the insert sql
      #echo insql
      db.exec(sql(insql))
      insql = "INSERT INTO dfTable (" 
      vals = ""  
   
  db.exec(sql"COMMIT")    
  
  var filename =  "nimDftempData.csv"
  var  data2 = newFileStream(filename, fmWrite) 
  if asortcol - 1 < 1: asortcol = 1
  var sortcolname = $chr(64 + asortcol) 
  var selsql = "select * from dfTable ORDER BY" & spaces(1) & sortcolname & spaces(1) & sortorder 
  for dbrow in db.fastRows(sql(selsql)) :
    for x in 1.. <dbrow.len - 1:    
      data2.write(dbrow[x] & ",")
    data2.writeLine(dbrow[dbrow.len - 1])
  data2.close()
  db.exec(sql"DROP TABLE IF EXISTS dfTable")
  db.close()
  
  #prepare for output
  var df2 =  createDataFrame(filename = filename,cols = df[0].len)
  removeFile(filename)
  result = df2


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
  

proc createRandomTestData*(filename:string = "nimDfTestData.csv",datarows:int = 2000) =
  ## createRandomTestData
  ##
  ## a file will be created in current working directory
  ## 
  ## default name nimDfTestData.csv or as given
  ##
  
  # cols,colwd,colcolors parameters seqs must be of equal length
  var headers   = @["A"]
  for x in 66.. 90: headers.add($char(x))  
  var cols      = @[1,2,3,4,5,6,7]
  var colwd     = @[10,10,10,10,10,10,14]
  var colcolors = @[yellow,pastelyellowgreen,palegreen,pastelpink,pastelblue,pastelwhite,violet]
  
  var cs = newWord(3,8)
  var ci = getRandomInt(0,100000)
  var cf = getrandomfloat() * 2345243.132310 * getRandomSignF()

  var  data = newFileStream(filename, fmWrite)
  
  for dx in 0.. <cols.len - 1: data.write(headers[dx] & ",")  
  data.writeLine(headers[cols.len - 1])
  
  for dx in 0.. <datarows:
       
      data.write(getRandomDate() & ",")
      data.write($getRandomInt(0,100000) & ",")
      data.write($getRandomInt(0,100000) & ",")
      data.write(newWord(3,8) & ",")
      data.write(ff(getrandomfloat() * 345243.132310 * getRandomSignF(),2) & ",")
      data.write(newWord(3,8) & ",")
      data.writeln(newWord(3,8))
  
  data.close()
    
  
  