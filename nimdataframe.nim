{.deadCodeElim: on.}
##
##   Library     : nimdataframe.nim
##
##   Status      : development
##
##   License     : MIT opensource
##
##   Version     : 0.0.5
##
##   ProjectStart: 2016-09-16
##   
##   Latest      : 2018-10-06
##
##   Compiler    : Nim >= 0.19.x  devel branch
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
##                 able to create subdataframes from dataframes and sorting on columns and column statistics
##
##
##   Usage       : import nimdataframe
##
##   Project     : https://github.com/qqtop/NimDataFrame
##
##   Docs        : http://qqtop.github.io/nimdataframeindex.html
##   
##                 http://qqtop.github.io/nimdataframe.html
##
##   Tested      : OpenSuse Tumbleweed , Debian
## 
##   Todo        : additional calculations on dataframes
##                 allow right or left align for each column
##                 fullRotate df
##                 improve tests and example
##                 dataframe names
##                 instead of col number use col names .. 
##                 trying to better handle json data  see new json lib by araq
##                 future filterDf(df:nimdf,cols:nimis,operator:nimss,vals:nimss)
##                 var ndf11 = filterDf(ndf9,@[3,5],@[">","=="],@["Borussia Dortmund","4"]
##                 strings with accents may mess up the frame alignment --> needs to be taken care off in showdf
##                 directly use more datasources other than csv , eg: select query outputs etc.
##
##   Install     : nimble install https://github.com/qqtop/nimdataframe.git
##  
##  

import nimcx
import parsecsv,streams,algorithm,stats
import db_sqlite
export stats

let NIMDATAFRAMEVERSION* = "0.0.5"

const 
      asc*  = "asc"
      desc* = "desc"
      
# dfcellobject related code is experimental and still may be changed in the near future      
type      
    dfcellobject* =   object {.inheritable.} 
         cellrow*   : int
         cellcol*   : int
         cellcolor* : string

proc newdfcellobject*():dfcellobject =
      #new(result)
      result.cellrow = -1
      result.cellcol = -1
      result.cellcolor = ""
         
type        
    nimss*    = seq[string]         # nim string seq
    nimis*    = seq[int]            # nim integer seq
    nimfs*    = seq[float]          # nim float seq
    nimbs*    = seq[bool]           # nim bool seq
    nimcells* = seq[dfcellobject]   # dataframe cell sequence
    
    
type
    nimdf* =  ref object  {.inheritable.}       
           df* : seq[nimss]     # nim data frame 
           hasHeader* : bool
           colcount*  : int
           rowcount*  : int
           colcolors* : nimss
           colwidths* : nimis
           colHeaders*: nimss
           rowHeaders*: nimss
           # how about individual cell properties
           dfcells*   : nimcells
           status*    : bool
           frtexttop* : nimss   # write text into the top frame line
           frtextbot* : nimss   # write text into the bottom frame line
    
proc newNimDf*():nimdf = 
           new(result)          # needed for ref object  gc managed
           result.df = @[]
           result.hasHeader  = false
           result.colcount   = 0
           result.rowcount   = 0
           result.colcolors  = @[]
           result.colwidths  = @[]
           result.colHeaders = @[]
           result.rowHeaders = @[]  
           result.dfcells    = @[]     # not in use yet
           result.status     = true  
           result.frtexttop  = @[""]   # experimental
           result.frtextbot  = @[""]   # not in use yet
           
           
# # Dfobject 
# type      
#     Dfobject* = object {.inheritable}     # using ref object here would throw errors as the gc would remove this ref object
#          df*     : nimdf
#          status* : bool             
#                       
             
proc newNimSs*():nimss = @[]
proc newNimIs*():nimis = @[]
proc newNimFs*():nimfs = @[]
proc newNimBs*():nimbs = @[]

converter toNimSs*(aseq:seq[string]):nimss = 
          result = aseq
converter toNimIs*(aseq:seq[int]):nimis = 
          result = aseq       
converter toNimFs*(aseq:seq[float]):nimfs = 
          result = aseq          
converter toNimBs*(aseq:seq[bool]):nimbs = 
          result = aseq
converter fsToNimSs*(aseq:seq[float]):nimss =
          result = newNimSs()
          for x in aseq: result.add($x)
converter isToNimSs*(aseq:seq[int]):nimss =
          result = newNimSs()
          for x in aseq: result.add($x)            
            
# forward declaration          
proc createDataFrame*(filename:string,cols:int = 2,rows:int = -1,sep:char = ',',hasHeader:bool = false):nimdf 

# used in sortdf
var intflag    : bool = false
var floatflag  : bool = false
var stringflag : bool = false


proc getData1*(url:string,timeout:int = 12000):string =
  ## getData1
  ## 
  ## used for internet based data in csv format 
  ## 
  try:
       var zcli = newHttpClient()
       result  = zcli.getContent(url)   # orig data5   
  except OsError:
       printLnStatusMsg("nimdataframe ==> getData1")
       var a = url & " content could not be fetched " 
       printLnErrorMsg(a) 
       printLnErrorMsg("Use -d:ssl or see check if terminal is sandboxed      ")
       var b = getCurrentExceptionMsg().splitLines()
       for x in b:
          printLnErrorMsg(cxpad(x,a.len))
       doFinish()


proc makeDf1*(ufo1:string,hasHeader:bool = false):nimdf =
   ## makeDf
   ## 
   ## used to create a dataframe with data string received from getData1
   ## 
   #printLn("Executing makeDf1",peru)
   
   var ufol = splitLines(ufo1)
   var df = newNimDf()
  
   var ufos = ufol[0].split(",")
   var ns = newNimSs()
           
   df.colwidths = toNimis(toSeq(0..<ufos.len))
   
   for x in 0..<ufol.len:
      ufos = ufol[x].split(",")  # problems may arise if column data has commas ... then need some preprocessing
      ns = newNimSs()
      for xx in 0..<ufos.len:
          ns.add(ufos[xx].strip(true,true))
          if df.colwidths[xx] < ufos[xx].len: 
             df.colwidths.add(ufos[xx].strip(true,true).len)
          
      df.df.add(ns)
   
   df.rowcount = df.df.len
   df.colcount = df.df[0].len
   df.hasHeader = hasHeader
   result = df  


proc getData2*(filename:string,cols:int = 2,rows:int = -1,sep:char = ','):auto = 
    ## getData2
    ## 
    ## used for csv files with a path and filename available
    ## 
    var gd2 = newCxTimer("getData2")
    gd2.startTimer
    # we read by row but add to col seqs --> so myseq contains seqs of col data 
    var csvrows = -1    # in case of getdata2 csv files we may get processed rowcount back
    var ccols = cols 
    var rrows = rows
    if rrows == -1 : rrows = 50000  # limit any dataframe to 50000 rows if no rows param given
    var csvp: CsvParser
    var s = newFileStream(filename, fmRead)
    
    if isNil(s):
            printLnBiCol("Error : " & filename & " content could not be accessed.",red,bblack,":",0,true,{}) 
            printLn(getCurrentExceptionMsg(),red,xpos = 9)
            doFinish()
    else: 
        # we need to check if required cols actually exist or there will be an error
        open(csvp, s, filename,separator = sep)
        # we read one row:
        discard readRow(csvp)
        var itemcount = 0
        for val in items(csvp.row): inc itemcount
        close(csvp)
        close(s)
        
        # now we make sure that the passed in cols is not larger than itemcount
        if ccols > itemcount: ccols = itemcount
        
        var myseq = newNimDf()
        for x in 0..<ccols:  myseq.df.add(@[])
           
        # here we actually use everything
        s = newFileStream(filename, fmRead)
        open(csvp, s, filename,separator = sep)
        var dxset = newNimSs()
        var c = 0  # counter
        try:
          while readRow(csvp) and csvrows < rrows: 
          
              try:   
                    for val in items(csvp.row):
                      if c < ccols :
                        dxset.add(val)
                        myseq.df[c].add(dxset)   
                        inc c
                        dxset = @[]
                    c = 0  
              except:
                    c = 0
                    discard
              
              csvrows = processedRows(csvp)
              
        except CsvError: 
              discard
        
        close(csvp)
        myseq.rowcount = csvrows
        myseq.colcount = ccols
        gd2.stopTimer
        showTimerresults()
        clearAllTimerResults() 
        result = myseq    # this holds col data now
        
        
proc makeDf2*(ufo1:nimdf,cols:int = 0,rows:int = -1,hasHeader:bool = false):nimdf =
   ## makeDf2
   ## 
   ## used to create a dataframe with nimdf object received from getData2  that is local csv
   ## if we actually pass in a df and not use getdata2 as asource the df will be rotated ,  
   ## that is header line will become col1
   ## which also may come handy
   ## note that overall it is better to preprocess data to check for row quality consistency
   ## which is not done here yet , so errors may show
   var md2 = newCxTimer("makeDf2")
   md2.startTimer
   var df = newNimDf()       # new dataframe to be returned
   var arow = newNimSs()     # one row of the data frame
   
   # now need to get the col data out and massage into rows
 
   try:
       df.colcount  = ufo1.df.len  
       df.rowcount  = ufo1.df[0].len  # this assumes all cols have same number of rows maybe should check this
       df.hasHeader = ufo1.hasHeader
       df.status    = ufo1.status
   except IndexError:
       printLn("df.colscount = " & $df.colcount,red)
       printLn("df.rowscount = " & $df.rowcount,red)
       printLn("IndexError raised . Exiting now...",red)
       doFinish()  
  
   for rws in 0..<df.rowcount:      # rows count  
     arow = @[]
     var olderrorrow = 0            # so we only display errors once per row
     for cls  in 0..<df.colcount:   # cols count  
       # now build our row 
       try: 
            arow.add(ufo1.df[cls][rws]) 
            # feedback line - comment out if not wanted
            # printLnInfoMsg("Row  ",$rws & " of " & $(df.rowcount - 1),xpos = 0);curup(1)
       except IndexError:
            printLn("Error row :  " & $arow,red)
            try:
                 printLn("ufo1   = " & $ufo1.df[cls][rws],red)
            except IndexError:
                 printLn("Invalid row data found ! Check for empty rows ,missing columns data etc. in the data file",red)
                 
            printLn("IndexError position at about: ",red)      
            if rws <> olderrorrow:
               printLnBiCol("column : " & $cls,yellowgreen,truetomato,":",6,false,{})
               printLnBiCol("row    : " & $rws,yellowgreen,truetomato,":",6,false,{})
               echo()
            olderrorrow = rws  
            # we could stop here too
            #printLn("Exiting now...",red)
            #doFinish()   
            
     df.df.add(arow)   
     df.hasHeader = hasHeader
   
   md2.stopTimer
   showTimerresults()
   clearAllTimerResults()   
   result = df  


proc rotateDf*(ufo1:nimdf,cols:int = 0,hasHeader:bool = false):nimdf =  
     # rotateDf
     # 
     # rotates a df to the left that is former header line is now first col
     # 
     result = makedf2(ufo1,cols,hasHeader = false)
      
proc getColHdx(df:nimdf): nimss =
      ## getColHeaders
      ## 
      ## get the first line of the dataframe df 
      ## 
      ## we assume line 0 contains headers
      ## 
     
      result = newNimss()
      for hx in df.df[0]:
         result.add(hx.strip(true,true))      

proc getTotalHeaderColsWitdh*(df:nimdf):int = 
     ## getTotalHeaderColsWitdh
     ## 
     ## sum of all headers width
     ## 
     result = 0
     var ch = getcolhdx(df)
     for x in 0..<ch.len:
         result = result + ch[x].strip(true,true).len

proc showRaw*[T](df:nimdf,rrows:openarray[T]) =
   ## showRaw
   ## 
   ## needs a df object and a seq with two values the first being the startrow the second the end row to show
   ## if you need to return rows see getRowDataRange()
   ## 
   ## 
   for x in rrows[0]..rrows[1]:
      printLn(df.df[x],xpos = 2) 
      
proc showFirstLast*(df:nimdf,nrows:int = 5) =
   ## shows first and last n lines of df incl. headers if any of dataframe
   ## 
   ## 
   let leftfmt = "<18"
   if df.hasHeader == true:
      printLnInfoMsg(fmtx([leftfmt],"Header and First") , $nrows & " rows ",yellowgreen,xpos = 2)
      if df.colHeaders.len > 0:
        printLn(df.colHeaders,xpos = 2)
        showRaw(df,@[0,nrows])
      else:
        showRaw(df,@[0,nrows])
   else:
      printLnInfoMsg(fmtx([leftfmt],"First") , $nrows & " rows ",yellowgreen,xpos = 2)
      showRaw(df,@[0,nrows - 1])
      
   echo()
   printLnInfoMsg(fmtx([leftfmt],"Last"), $nrows & " rows ",yellowgreen,xpos = 2)
   showRaw(df,@[df.rowcount - nrows,df.rowcount - 1])
   echo() 
         
proc showHeaderStatus*(df:nimdf,xpos:int = 2) = 
   ## showHeaderStatus
   ##  
   var leftfmt = "<18"
   printLnInfoMsg(fmtx([leftfmt],"hasHeader"),fmtx([">10"],$df.hasHeader),xpos = xpos)
   
   
proc showCounts*(df:nimdf,xpos:int = 2) = 
   var leftfmt = "<18"
   var rightfmt = ">10"
   if df.status == true:  
       printLnInfoMsg(fmtx([leftfmt],"Columns"), fmtx([rightfmt],$df.colcount),xpos = xpos)
       if df.hasHeader == true:
          if df.colHeaders.len() > 0 :
             printLnInfoMsg(fmtx([leftfmt],"Data Rows"),  fmtx([rightfmt],$(df.rowcount)),xpos = xpos)
          else:
             printLnInfoMsg(fmtx([leftfmt],"Data Rows") ,  fmtx([rightfmt],$(df.rowcount - 1)),xpos = xpos)
       else:
       
         if df.colHeaders.len() > 0 :
             printLnInfoMsg(fmtx([leftfmt],"Data Rows") , fmtx([rightfmt], $(df.rowcount)),xpos = xpos)
         else:
             printLnInfomsg(fmtx([leftfmt],"Data Rows") ,  fmtx([rightfmt],$(df.rowcount - 1)),xpos = xpos)
              
   else:   
       printLnInfoMsg(fmtx([leftfmt],"NIMDF"), " Data not available in dataframe", red,xpos = xpos)
       decho(2) 
       # maybe we should quit here
       doFinish()
       
              
       
proc colFitMax*(df:nimdf,cols:int = 0,adjustwd:int = 0):nimis =
   ## colFitMax
   ## 
   ## # TODO : provide better fit tw as basis is to wide for df with few cols
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
   if ccols == 0:  ccols = df.colcount
   var optcolwd = tw div ccols - ccols + adjustwd  
   var cwd = newNimIs()
   for x in 0..<ccols: cwd.add(optcolwd)
   result = cwd
  
  
proc checkDfOk(df:nimdf,xpos:int = 3):bool =
     # checkdf checks if something can be displayed at all
     var resultflag = true
     if df.df.len == 0:
        printLnErrorMsg("Dataframe has no data... ")
        resultflag = false
        
     if df.rowcount == 0 and df.hasHeader == false:
        printLnErrorMsg("Dataframe has no rows or headers specified")
        resultflag = false
            
     if df.colcount == 0 :
        printLnErrorMsg("Dataframe has no columns to show specified")
        resultflag = false

     result = resultflag 
      
      
proc showDf*(df:nimdf,
             rows          : int     = 10,
             cols          : nimis   = @[],   #@[1,2],   # toSeq(1 .. df.colcount)
             colwd         : nimis   = @[],   #@[6,6],   # nweSeqWidth(10,1 .. df.colcount)
             colcolors     : nimss   = @[white,white],
             showframe     : bool    = false,
             framecolor    : string  = palegreen,
             showHeader    : bool    = false,
             headertext    : nimss   = @[],
             leftalignflag : bool    = false,
             cellcolors    : nimss   = @[],    # cell features for coloring individual cells to be implemented
             cellrows      : nimis   = @[],
             cellcols      : nimis   = @[],
             cellcalc      : nimss   = @[],    # placeholder for some sort of plugin feature to pass in manipulations/calculations on cells
             frtexttop     : nimss   = @[],
             frtextbot     : nimss   = @[],
             xpos          : int     = 2) =
             
  ## showDf
  ## 
  ## Displays a dataframe 
  ## 
  ## allows selective display of columns , with column numbers passed in as a seq
  ## https://github.com/amallia/GaussianNB
  ## Convention :  the first column = 1 
  ## 
  ## number of rows    default = 10
  ## number of columns default = all  if none given
  ## columnwidth default       =  8   if none given
  ## 
  ## an equal columnwidth can be achieved with colwd = colfitmax(df,0) 
  ## the second param is to nudge the width a bit if required
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
  ## Note : best to fill in desired values , a quick showDf(mydf) will not always be satisfactory 
  ## 
  #
  if checkDfok(df) == true: 
    var okrows = rows
    var okcols = cols
    var okcolwd = colwd 
    var nofirstrowflag = false    
    var header = showHeader
    
    if header == true and df.hasHeader == false: header = false   # this hopefully avoids first line is header display
    if header == false and df.hasHeader == true: nofirstrowflag = true
    if header == false and df.hasHeader == true and headertext != @[] : nofirstrowflag = false
    
    var frame  = showFrame
    let vfc  = "|"               # vertical frame char for column separation
    let vfcs = "|"               # efs2 or efb2   # vertical frame char for left (and right side <--- needs to be implemented )
    let hfct = efs2   # "_"      # horizontal framechar top of frame
    let hfcb = efs2              # horizontal framechar for bottom of frame
    
    # try to setup automatic if no values in cols or colwd was passed in
    if cols == @[]: okcols = toSeq(1..df.colcount)  # display all cols by default
        
    if cols.len == 1:
        # to display one column data showheader and showFrame must be false
        # to avoid messed up display , Todo: take care of this eventually 
        header = false
        frame = false
    
    #if cols.len != okcolwd.len: okcolwd = colfitmax(df,cols.len)   # try to best fit rather than to throw error
          
    # uncomment if required
    #if cols.len != colcolors.len:
    #   printLnBiCol("NOTE  : Dataframe columns cols and colcolors parameter are of different length",":",red,peru)
     
    if df.df[0].len == 0: 
       printLnErrorMsg("Dataframe appears to have no columns. See showDf command. Exiting ..")
       quit(0)
    

    var toplineflag = false
    var displaystr = ""   
    var okcolcolors = colcolors
    
    # dynamic col width with colwd passed in if not colwd for all cols = 15 
         
    if okcolwd.len < okcols.len:
       # we are missing some colwd data we add default widths
       for col in okcolwd.len .. okcols.len: okcolwd.add(8)
      
    
    # if no cols seq is specified we assume all cols
    if okcols == @[] and df.colcount > 0:
      try:
             okcols = toSeq(0..<df.colcount)    # note column indexwise numbering starts at 0 , first col = 0             
      except IndexError:
             currentLine()
             raise
    
    #  need a check to see if request cols actually exist
    for col in okcols:
      if col > df.colcount:
         printLnErrorMsg("showDf needs correct column specification parameters")
         printLnErrorMsg("Requested Column >= " & $col & " does not exist in dataframe , which has " & $df.colcount & " columns")
         # we exit
         doFinish()
   
    # set up column text and background color
    
    if okcolcolors == @[]: # default lightgrey on black
        var tmpcols = newNimSs()
        for col in 0 ..< okcols.len: tmpcols.add(lightgrey)
        okcolcolors = tmpcols   
           
    else: # we get some colors passed in but not for all columns  , unspecified colors are set to lightgrey    
      
        var tmpcols = newNimSs()
        tmpcols = okcolcolors
        for col in tmpcols.len .. okcols.len: tmpcols.add(lightgrey)
        okcolcolors = tmpcols         
                   
   
    # calculate length of topline of frame based on cols and colwd 
    var frametoplinelen = 0
    if okcols.len <> okcolwd.len:
       cxAlert(2)
       printLnErrorMsg("Number of columns and column width in showDf imbalanced.")
       printLnErrorMsg("Program will now exit with assertion error message")
       echo()
       
    # printLnInfoMsg("Debug","")
    # echo okcols.len
    # echo okcolwd.len   
    
    doassert okcols.len == okcolwd.len # will display as out of memory error
    frametoplinelen = frametoplinelen + sum(okcolwd) + (2 * okcols.len) + 1
    
    # take care of over lengths
    if okrows == 0 or okrows > df.df.len: okrows = df.df.len
     
    var headerflagok = false 
    var bottomrowflag = false 
    var ncol = 0 
    
    
    if nofirstrowflag == true:
      for brow in 1..<okrows:   # note we get okrows data rows back and the header
        var row = brow       
        for col in 0..<okcols.len:
           
          ncol = okcols[col] - 1
          if ncol < 0: ncol = 0
         
          try:                    
                displaystr = $df.df[row][ncol]  # will be cut to size by fma below to fit into colwd
          except IndexError:
                # if row data not available we put NA , the actual df column does not contain NA
                displaystr = "NA"          
          
          var colfm = ""
          var fma   = newSeq[string]()
          if leftalignflag == true:
              colfm = "<" & $(okcolwd[col])  # constructing the format string
          else:
              colfm = ">" & $(okcolwd[col])  # constructing the format string
          fma = @[colfm,""]  
          
          # new setup 6 display options
          
          #noframe noheader           1 ok
          #noframe firstlineheader    2 ok   
          #noframe headertextheader   3 ok
          
          # ok for more than 1 col  
          #frame   noheader           4 ok
          #frame   firstlineheader    5 ok   
          #frame   headertextheader   6 ok
          
          if frame == false:
          
                if header == false and headertext == @[] :
                            if col == 0 :
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {},xpos = xpos) 
                            elif col > 0:
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {})
                                if col == okcols.len - 1: echo()  
                            else: discard
                            
                            
                elif header == false and headertext != @[] :
                            if col == 0 :
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {},xpos = xpos) 
                            elif col > 0:
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {})
                                if col == okcols.len - 1: echo()  
                            else: discard
                            
                            
                  
                elif header == true and headertext == @[]:

                            if col == 0 and row == 0:
                                print(fmtx(fma,displaystr,spaces(2)),yellowgreen,styled = {styleunderscore},xpos = xpos)  
                            
                            elif col > 0 and row == 0:
                                print(fmtx(fma,displaystr,spaces(2)),yellowgreen,styled = {styleunderscore})                                   
                                if col == okcols.len - 1: echo()                      
                                
                            # all other rows data
                            elif col == 0 and row > 0:
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {},xpos = xpos) 
                            elif col > 0 and row > 0:
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {})
                                      
                                if col == okcols.len - 1:          
                                    echo()  
                            else: discard
           
                elif  header == true and headertext != @[] :
                            
                            if headerflagok == false:                   # print the header first    
                              
                                for hcol in 0..<okcols.len:
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
                                            headerflagok = true            # set the flag as all headertext items printed
                            
                            if headerflagok == true:                       # all other rows data
                                if col == 0 and row >= 0  :
                                      print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {},xpos = xpos) 
                                elif col > 0 and row >= 0 :
                                      print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {})     
                                      if col == okcols.len - 1: echo()           
                                
                    
                       
          if frame == true:            
              
              if  header == false and headertext == @[] :
                      
                      if toplineflag == false:                              # set up topline of frame
                          print(".",yellow,xpos = xpos)
                          hline(frametoplinelen - 2 ,framecolor,xpos = xpos + 1,lt = hfct) 
                          # experimental
                          if frtexttop.len > 0:
                             if frtexttop[0].len > 0:
                                  print("[",dodgerblue,xpos = xpos + 3)
                                  print(frtexttop[0])
                                  print("]",dodgerblue)
                                  printLn(".",lime,xpos = frametoplinelen + frtexttop[0].len - (frtexttop[0].len - 2))    # <<<----2
                                  # end exp uncomm line below
                          else:
                                  printLn(".",lime)
                          toplineflag = true                                # set toplineflag , topline of frame ok
                      
                      if col == 0: 
                            print(framecolor & vfcs & okcolcolors[col] & fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {},xpos = xpos)
                            if col == okcols.len - 1: echo()
                      else: # other cols of header
                            print(fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {})  
                            if col == okcols.len - 1: echo() 
              
              
              elif  header == false and headertext != @[]:
                      
                      if toplineflag == false:                              # set up topline of frame
                          print(".",yellow,xpos = xpos)
                          hline(frametoplinelen - 2 ,framecolor,xpos = xpos + 1,lt = hfct) 
                          # experimental
                          if frtexttop.len > 0:
                            if frtexttop[0].len > 0:
                                  print("[",dodgerblue,xpos = xpos + 3)
                                  print(frtexttop[0])
                                  print("]",dodgerblue)
                                  printLn(".",lime,xpos = frametoplinelen + frtexttop[0].len - (frtexttop[0].len - 2))    # <<<----2
                                  # end exp uncomm line below
                          else:
                                  printLn(".",lime)
                          toplineflag = true                                # set toplineflag , topline of frame ok
                      
                      if col == 0: 
                            print(framecolor & vfcs & okcolcolors[col] & fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {},xpos = xpos)
                            if col == okcols.len - 1: echo()
                      else: # other cols of header
                            print(fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {})  
                            if col == okcols.len - 1: echo() 
              
              
              
              elif  header == true and headertext == @[]:                  # first line will be used as header
                      # set up topline of frame
                      if toplineflag == false:
                          print(".",magenta,xpos = xpos)
                          hline(frametoplinelen - 2 ,framecolor,xpos = xpos + 1,lt = hfct) 
                          # experimental
                          if frtexttop.len > 0:
                            if frtexttop[0].len > 0:
                                  print("[",dodgerblue,xpos = xpos + 3)
                                  print(frtexttop[0])
                                  print("]",dodgerblue)
                                  printLn(".",lime,xpos = frametoplinelen + frtexttop[0].len - (frtexttop[0].len - 2))    # <<<----2
                          # end exp uncomm line below
                          else:
                                  printLn(".",lime)
                          toplineflag = true   
                        
                                              
                      # first row as header 
                      if col == 0 and row == 0:
                              print(framecolor & vfcs & yellowgreen & fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),yellowgreen,styled = {styleunderscore},xpos = xpos)                           
                              
                      elif col > 0 and row == 0:
                                  print(fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),yellowgreen,styled = {styleunderscore})  
                                  if col == okcols.len - 1: echo()                      
                                
                      # all other rows data
                      elif col == 0 and row > 0:
                                  print(framecolor & vfcs & okcolcolors[col] & fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {},xpos = xpos)
                              
                      elif col > 0 and row > 0:
                                  print(fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {}) 
                                  if col == okcols.len - 1: echo()  
                      else: discard
                
              elif  header == true and headertext != @[] :
                  
                            
                            if toplineflag == false:                            # set up topline of frame
                                print(".",magenta,xpos = xpos)
                                hline(frametoplinelen - 2 ,framecolor,xpos = xpos + 1,lt = hfct) 
                                printLn(".",lime)
                                toplineflag = true   
                        
                  
                            #print the header first
                            
                            if headerflagok == false:
                              
                                for hcol in 0..<okcols.len:
                                    
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
                                      print(framecolor & vfcs & yellowgreen & fmtx(hfma,headertext[nhcol],spaces(1) & framecolor & vfc & white),yellowgreen,styled = {styleunderscore},xpos = xpos) 
                                    elif hcol > 0:
                                      print(fmtx(hfma,headertext[nhcol],spaces(1) & framecolor & vfc & white),yellowgreen,styled = {styleunderscore}) 
                                      if hcol == okcols.len - 1: 
                                          echo()    
                                          headerflagok = true
                                          
                            
                            if headerflagok == true:   
                               # all other rows data
                              
                              if header == true: 
                                                              
                                if col == 0 and row >= 0  :
                                     print(framecolor & vfcs & okcolcolors[col] & fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {},xpos = xpos) 
                                elif col > 0 and row >= 0 :
                                     print(fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {})     
                                     if col == okcols.len - 1: echo()  
                              
        
          

          if row + 1 == okrows and col == okcols.len - 1  and bottomrowflag == false and frame == true:
                          # draw a bottom frame line  
                          print(".",lime,xpos = xpos)  # left dot
                          hline(frametoplinelen - 2 ,framecolor,xpos = xpos + 1,lt = hfcb) # hfx
                          printLn(".",lime)
                          bottomrowflag = true
          
    else :
      for brow in 0..<okrows:   # note we get okrows data rows back and the header
        var row = brow       
        for col in 0..<okcols.len:
       
            
          ncol = okcols[col] - 1
          if ncol < 0: ncol = 0
             
          try:                    
                displaystr = $df.df[row][ncol]  # will be cut to size by fma below to fit into colwd
          except IndexError:
                # if row data not available we put NA , the actual df column does not contain NA
                displaystr = "NA"
          
          var colfm = ""
          var fma   = newSeq[string]()
          if leftalignflag == true:
              colfm = "<" & $(okcolwd[col])  # constructing the format string
          else:
              colfm = ">" & $(okcolwd[col])  # constructing the format string
          fma = @[colfm,""]  
          
          # new setup 6 display options
          
          #noframe noheader           1 ok
          #noframe firstlineheader    2 ok   
          #noframe headertextheader   3 ok
          
          # ok for more than 1 col  
          #frame   noheader           4 ok
          #frame   firstlineheader    5 ok   
          #frame   headertextheader   6 ok
          
          if frame == false:
          
                if header == false and headertext == @[] :
                            if col == 0 :
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {},xpos = xpos) 
                            elif col > 0:
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {})
                                if col == okcols.len - 1: echo()  
                            else: discard
                            
                            
                elif header == false and headertext != @[] :
                            if col == 0 :
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {},xpos = xpos) 
                            elif col > 0:
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {})
                                if col == okcols.len - 1: echo()  
                            else: discard
                               
                  
                elif header == true and headertext == @[]:

                            if col == 0 and row == 0:
                                print(fmtx(fma,displaystr,spaces(2)),yellowgreen,styled = {styleunderscore},xpos = xpos)  
                            
                            elif col > 0 and row == 0:
                                print(fmtx(fma,displaystr,spaces(2)),yellowgreen,styled = {styleunderscore})                                   
                                if col == okcols.len - 1: echo()                      
                                
                            # all other rows data
                            elif col == 0 and row > 0:
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {},xpos = xpos) 
                            elif col > 0 and row > 0:
                                print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {})
                                      
                                if col == okcols.len - 1:          
                                    echo()  
                            else: discard
           
                elif  header == true and headertext != @[] :
                            
                            if headerflagok == false:                   # print the header first    
                              
                                for hcol in 0..<okcols.len:
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
                                            headerflagok = true            # set the flag as all headertext items printed
                            
                            if headerflagok == true:                       # all other rows data
                                if col == 0 and row >= 0  :
                                      print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {},xpos = xpos) 
                                elif col > 0 and row >= 0 :
                                      print(fmtx(fma,displaystr,spaces(2)),okcolcolors[col],styled = {})     
                                      if col == okcols.len - 1: echo()           
                                
                    
                       
          if frame == true:            
              
              if  header == false and headertext == @[] :
                      
                      if toplineflag == false:                              # set up topline of frame
                          print(".",yellow,xpos = xpos)
                          hline(frametoplinelen - 2 ,framecolor,xpos = xpos + 1,lt = hfct) 
                          # experimental
                          if frtexttop.len > 0:
                            if frtexttop[0].len > 0:
                                  print("[",dodgerblue,xpos = xpos + 3)
                                  print(frtexttop[0])
                                  print("]",dodgerblue)
                                  printLn(".",lime,xpos = frametoplinelen + frtexttop[0].len - (frtexttop[0].len - 2))    # <<<----2
                                  # end exp uncomm line below
                          else:                          
                                  printLn(".",lime)
                          toplineflag = true                                # set toplineflag , topline of frame ok
                      
                      if col == 0: 
                            print(framecolor & vfcs & okcolcolors[col] & fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {},xpos = xpos)
                            if col == okcols.len - 1: echo()
                      else: # other cols of header
                            print(fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {})  
                            if col == okcols.len - 1: echo() 
              
              
              elif  header == false and headertext != @[]:
                      
                      if toplineflag == false:                              # set up topline of frame
                          print(".",yellow,xpos = xpos)
                          hline(frametoplinelen - 2 ,framecolor,xpos = xpos + 1,lt = hfct) 
                          # experimental
                          if frtexttop.len > 0:
                            if frtexttop[0].len > 0:
                                  print("[",dodgerblue,xpos = xpos + 3)
                                  print(frtexttop[0])
                                  print("]",dodgerblue)
                                  printLn(".",lime,xpos = frametoplinelen + frtexttop[0].len - (frtexttop[0].len - 2))    # <<<----2
                                  # end exp uncomm line below
                          else:   
                                  printLn(".",lime)
                          toplineflag = true                                # set toplineflag , topline of frame ok
                      
                      if col == 0: 
                            print(framecolor & vfcs & okcolcolors[col] & fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {},xpos = xpos)
                            if col == okcols.len - 1: echo()
                      else: # other cols of header
                            print(fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {})  
                            if col == okcols.len - 1: echo() 
              
              
              
              elif  header == true and headertext == @[]:                  # first line will be used as header
                      # set up topline of frame
                      if toplineflag == false:
                          print(".",magenta,xpos = xpos)
                          hline(frametoplinelen - 2 ,framecolor,xpos = xpos + 1,lt = hfct) 
                          # experimental
                          if frtexttop.len > 0:
                            if frtexttop[0].len > 0:
                                  print("[",dodgerblue,xpos = xpos + 3)
                                  print(frtexttop[0])
                                  print("]",dodgerblue)
                                  printLn(".",lime,xpos = frametoplinelen + frtexttop[0].len - (frtexttop[0].len - 2))    # <<<----2
                                  # end exp uncomm line below
                          else:
                                  printLn(".",lime)
                          toplineflag = true   
                        
                                              
                      # first row as header 
                      if col == 0 and row == 0:
                              print(framecolor & vfcs & yellowgreen & fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),yellowgreen,styled = {styleunderscore},xpos = xpos)                           
                              
                      elif col > 0 and row == 0:
                                  print(fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),yellowgreen,styled = {styleunderscore})  
                                  if col == okcols.len - 1: echo()                      
                                
                      # all other rows data
                      elif col == 0 and row > 0:
                                  print(framecolor & vfcs & okcolcolors[col] & fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {},xpos = xpos)
                              
                      elif col > 0 and row > 0:
#                                   #experimental cell stuff
#                                   var currentcellcolor = okcolcolors[col]
#                                   # we need to check the df.dfcells seq and every object there if we need to change the color
#                                   # this looks rather inefficientr so what to do ?
#                                   
#                                   for xcell in 0..<df.dfcells.len:
#                                       if df.dfcells[xcell].cellrow == row and df.dfcells[xcell].cellcoll == col:
#                                          var ccc1 = parsefloat(df.df[df.dfcells[xcell].cellrow][df.dfcells[xcell].cellcol]
                                     
                                         #var ccc2 =  ???
#                                           
#                                          if ccc1 < ccc2 : currentcellcolor = lime
#                                          elif ccc1  > ccc2 : currentcellcolor = truetomato 
#                                          elif ccc1 == ccc2 : currentcellcolor = lightcyan                                                              
#                                          print(fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),currentcellcolor,styled = {})
#                                       else: 
#                                           
#                                           print(fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),currentcellcolor,styled = {}) 
#                                   # end experimental -- unintend line below  if not used   
#                                   
                                  print(fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white), okcolcolors[col],styled = {}) 
                                  if col == okcols.len - 1: echo()  
                      else: discard
                
              elif  header == true and headertext != @[] :
                  
                            if toplineflag == false:                            # set up topline of frame
                                print(".",magenta,xpos = xpos)
                                hline(frametoplinelen - 2 ,framecolor,xpos = xpos + 1,lt = hfct) 
                                # experimental
                                if frtexttop.len > 0:
                                 if frtexttop[0].len > 0:
                                   print("[",dodgerblue,xpos = xpos + 3)
                                   print(frtexttop[0])
                                   print("]",dodgerblue)
                                   printLn(".",lime,xpos = frametoplinelen + frtexttop[0].len - (frtexttop[0].len - 2))    # <<<----2
                                   # end exp uncomm line below
                                else:
                                  printLn(".",lime)
                                toplineflag = true   
                        
                  
                            #print the header first
                            
                            if headerflagok == false:
                              
                                for hcol in 0..<okcols.len:
                                    
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
                                      print(framecolor & vfcs & yellowgreen & fmtx(hfma,headertext[nhcol],spaces(1) & framecolor & vfc & white),yellowgreen,styled = {styleunderscore},xpos = xpos) 
                                    elif hcol > 0:
                                      print(fmtx(hfma,headertext[nhcol],spaces(1) & framecolor & vfc & white),yellowgreen,styled = {styleunderscore}) 
                                      if hcol == okcols.len - 1: 
                                          echo()    
                                          headerflagok = true
                                          
                            
                            if headerflagok == true:   
                               # all other rows data
                              
                              if header == true: 
                                                              
                                if col == 0 and row >= 0  :
                                     print(framecolor & vfcs & okcolcolors[col] & fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {},xpos = xpos) 
                                elif col > 0 and row >= 0 :
                                     print(fmtx(fma,displaystr,spaces(1) & framecolor & vfc & white),okcolcolors[col],styled = {})     
                                     if col == okcols.len - 1: echo()  
                              
        
          

          if row + 1 == okrows and col == okcols.len - 1  and bottomrowflag == false and frame == true:
                          # draw a bottom frame line  
                          print(".",lime,xpos = xpos)  # left dot
                          hline(frametoplinelen - 2 ,framecolor,xpos = xpos + 1,lt = hfcb) # hfx
                          printLn(".",lime)
                          bottomrowflag = true
          


proc showDataframeInfo*(df:nimdf) = 
   ## showDataframeInfo
   ## 
   ## some basic information of the dataframe
   ## mainly usefull during debugging.
   ## 
   echo()
   hdx(printLn("Dataframe Inspection ",peru,styled = {}))
   showHeaderStatus(df)
   showCounts(df)
   echo()
   showFirstLast(df,5)
   echo()
   printLn(dodgerblue & rightarrow & sandybrown & " Display parameters if available inside the df object ",sandybrown,xpos = 2)
   printLn(dodgerblue & rightarrow & sandybrown & " Column headers / first row will be shown if hasHeader == true ",sandybrown,xpos = 2)
   echo()
   printLn("Column Headers ( if any ) :",greenyellow,xpos = 2)
   if df.hasHeader == true:
      if df.colHeaders.len > 0 :
          printLn(df.colHeaders,xpos = 2)
      else:    
          #try first row as hasHeader == true
          printLn(df.df[0],xpos = 2)
      
   else :
        printLn("none",xpos = 2)
   echo()
 
   printLn("Column Widths  ( if any ) :",greenyellow,xpos = 2)   
   if df.colwidths.len > 0:
      printLn(df.colwidths,xpos = 2)
   else:
      printLn("none",xpos = 2)   
   echo()
   
   printLn("Column Colors  ( as specified , if any ) :",greenyellow,xpos = 2)
   if df.colColors.len > 0:
     for x in 0..<df.colcolors.len:
        if x == 0:
             #print("col" & $(x + 1) & "-" getColorName(df.colcolors[x]) & ", ",df.colcolors[x],xpos = 2)
              print(getColorName(df.colcolors[x]) & ", ",df.colcolors[x],xpos = 2)
        else:
           if x == df.colcolors.len - 1:   # the last entry
              #print("col" & $(x + 1) &  getColorName(df.colcolors[x]),df.colcolors[x])
              printLn(getColorName(df.colcolors[x]),df.colcolors[x])
           else:
               #print("col" & $(x + 1) &  getColorName(df.colcolors[x]) & ", ",df.colcolors[x])
               print(getColorName(df.colcolors[x]) & ", ",df.colcolors[x])
   else:
      printLn("none",xpos = 2)
   echo() 
   
   printLn("Row Headers    ( if any ) :",greenyellow,xpos = 2)   # not in use yet
   if df.rowheaders.len > 0:
      printLn(df.rowheaders,xpos = 2)
   else:
      printLn("none",xpos = 2)      
      
   decho(2)    
   hdx(printLn("End of dataframe inspection ", zippi,styled = {}))
   decho(1)
   

proc showDfInfo*(df:nimdf) = showDataframeInfo(df)   # convenience function same as showDataframeInfo

   
proc getColData*(df:nimdf,col:int):nimss =
     ## getColData
     ## 
     ## get one column from a nimdf dataframe
     ## 
     ## Note : col = 1 denotes first col of df , which is consistent with showDf 
     ##          
     ## 
     ## 
     
     # currently we quit if data is not good to meet df specifications maybe we should be more lenient here ??
     var zcol = col - 1
     if df.colcount > 0:
        if zcol < 0 or zcol > df.colcount :
            printLnErrorMsg("Wrong column number specified or incorrect data received")
            printLnErrorMsg("Most likely reason is free api call limit exceeded or server hit to fast")
            printLnInfoMsg("nimdataframe","getColData")
            echo "zcol/dfcol: ",zcol,"  /  ",df.colcount
            doByeBye()
            quit(0)
        
        result = newNimSs()
        if df.hasHeader == false:
            for x in 0..<df.df.len:
                try:
                    result.add(df.df[x][zcol])    
                except IndexError:
                    discard

        else:   # so there is a header in the first row            
            for x in 1..<df.df.len:     
                try:
                    result.add(df.df[x][zcol])    
                except IndexError:
                    discard

                    
proc getRowDataRange*(df:nimdf,rows:nimis = @[] , cols:nimis = @[]) : nimdf =
  ## getRowDataRange
  ## 
  ## creates a new df with rows and cols as stipulated extracted from an exisiting df
  ## 
  ## if rows or cols not stipulated all rows will be brought in
  ## 
  ## Following example uses rows 1,2,4,6 and cols 1,2,3 from df ndf5 to create a new df
  ## 
  ## ..code-block:: nim
  ##   var ndf6 = getRowDataRange(ndf5,rows = @[1,2,4,6],cols = @[1,2,3])
  ## 
  var aresult = newNimDf()
  aresult.hasHeader = df.hasHeader
  aresult.colcount = cols.len
  aresult.rowcount = rows.len

  var b = newNimSs()
  var arows = rows
  var acols = cols
  
  if arows.len == 0:
     arows = toSeq(0..<df.rowcount)
        
        
  if acols.len == 0:
     acols = toSeq(0..<df.colcount)
  
  # we extract named rows and cols from a df and create a new df
  for row in 0..<arows.len:     
     for col in 0..<acols.len:
         b.add(df.df[arows[row]][acols[col] - 1])       
     aresult.df.add(b) 
     b = @[]   
  result = aresult
 

proc `$`[T](some:typedesc[T]): string = name(T)
proc typetest[T](x:T): T =
  # used to determine the field types in the temp sqllite table used for sorting
  # note these procs are used only locally , a generic typetest exists in cx
  
  #echo "type: ", type(x), ", value: ", x
  var cvflag = false
  intflag    = false
  floatflag  = false
  stringflag = false
    
  if cvflag == false and floatflag == false and intflag == false and stringflag == false:
    try:#let db = open(":memory:", nil, nil, nil)  # this now fails
       var i1 =  parseInt(x)
       if $type(i1) == "int":
          intflag = true
          #printLnBiCol("Intflag = true : " & $x )
          cvflag = true
    except ValueError:
          discard
    
  if cvflag == false and floatflag == false and intflag == false and stringflag == false:
   try:
      var f1 = parseFloat(x)
    
      if $type(f1) == "float":
         floatflag = true 
         #printLnBiCol("Floatflag = true : " & $x )
         cvflag = true
   except ValueError:
          discard
         

  if cvflag == false and intflag == false and floatflag == false and stringflag == false:
        try:
          # as all incoming are strings this will never fail and is put last here
          if $type(x) == "string":
             stringflag = true 
             #printLnBiCol("Stringflag = true : " & $x )
             cvflag = true
        except ValueError:
             discard 
 
  result = $type(x)   


proc sortdf*(df:nimdf,sortcol:int = 1,sortorder = asc):nimdf =
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
  ##  
  ## Note : data columns passed in must be correct for all rows , that is rows with different column count will result in errors
  ##        this will be addressed in future versions
  ##     

  var asortcol = sortcol
  #let db = open("localhost", "user", "password", "dbname")
  let db = open(":memory:", "", "", "")
  
  db.exec(sql"DROP TABLE IF EXISTS dfTable")
  var createstring = "CREATE TABLE dfTable (Id INTEGER PRIMARY KEY "
  for x in 0..<df.colcount:
       discard typetest(df.df[1][x])   # here we do the type testing for table creation
       
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
  for col in 0..<df.colcount:
        if col < df.colcount - 1:
          tabl = tabl & $char(col + 65) & ","       
        else:   
          tabl = tabl & $char(col + 65)

  # set up the values of the insert sql   
  var startrow = 0
  var orgheader:nimss = @[]
  if df.hasHeader == true: 
     startrow = 1 
     for x in 0..<df.colcount:
        orgheader.add(df.df[0][x])
  
  for row in startrow..<df.rowcount :
      for col in 0..<df.colcount:
       try: 
         if typetest(df.df[row][col]) == "string":
        
            if col < df.colcount - 1:
              vals = vals & dbQuote(df.df[row][col]) & ","
              
            else:   
              vals = vals & dbQuote(df.df[row][col])
              
         elif typetest(df.df[row][col]) == "integer":
           
            if col < df.colcount - 1:
              vals = vals & df.df[row][col] & ","
            else:   
              vals = vals & df.df[row][col]
              
         elif typetest(df.df[row][col]) == "float":
           
            if col < df.colcount - 1:
              vals = vals & df.df[row][col] & ","
            else:   
              vals = vals & df.df[row][col]
       
       except IndexError:
              printLn("Error : Sorting of dataframe with columns of different row count currently only possible",red)
              printLn("        if the column with the least rows is the first column of the dataframe",red)
              echo()
              discard
              #raise
              
       
      insql = insql & tabl & ") VALUES (" & vals & ")"   # the insert sql
      #echo insql
      
      try:
        db.exec(sql(insql))
      except DbError,IndexError:
        #echo insql
        discard
        
      insql = "INSERT INTO dfTable (" 
      vals = ""  
   
  db.exec(sql"COMMIT")    
  
  var filename =  "nimDftempData.csv"               
  var  data2 = newFileStream(filename, fmWrite) 
  if asortcol - 1 < 1: asortcol = 1
  var sortcolname = $chr(64 + asortcol) 
  var selsql = "select * from dfTable ORDER BY" & spaces(1) & sortcolname & spaces(1) & sortorder 
  for dbrow in db.fastRows(sql(selsql)) :
     for x in 1..<dbrow.len - 1:    
        data2.write(dbrow[x] & ",")
     data2.writeLine(dbrow[dbrow.len - 1])
  data2.close()
  db.exec(sql"DROP TABLE IF EXISTS dfTable")
  db.close()
  #prepare for output
  result =  createDataFrame(filename = filename,cols = df.df[0].len,rows = df.rowcount,hasHeader = df.hasHeader)
  result.colHeaders = orgheader
  removeFile(filename)
  
proc filterDf*(df:nimdf,cols:nimis,operator:nimss,vals:nimss) =
     ## filterDf
     ## 
     ## TODO
     ## 
     ## show rows passing a condition
     ## 
     discard
  

proc makeNimDf*(dfcols : varargs[nimss],status:bool = true,hasHeader:bool = false):nimdf = 
  ## makeNimDf
  ## 
  ## creates a nimdf with passed in col data which should be of type nimss
  ## 
  #  TODO  will need to check if all cols are same length otherwise append  NaN etc
  #        and put in the status check
  # 
  var df = newNimDf()
  for x in dfcols: df.df.add(x)
  result = makeDf2(df,hasheader = hasHeader)



proc dfDefaultSetup*(df:nimdf,headertext:nimss = @[]):nimdf =    
   ## dfDefaultSetup  
   ## WIP , needs more testing
   ## 
   ## quick default setup , which can be adjusted later during showDf if needed
   ## 
   ## column colors : white
   ## column widths : 10
   ## header text   : pass in or auto column name will be generated 
   ## 
   if headertext != @[] :
      if headertext.len >= df.colcount:  # make sure its the same or add some headers
         df.colheaders = headertext[0..df.colcount]
      else:
         for x in headertext.len + 1..<df.colcount:
             df.colheaders.add("col" & $x)
    
   elif df.hasHeader == true:
   
        if headertext == @[]:             # hasHeader and headertext is empty we provide a autoheader
            for x in 0..<df.colcount:
                df.colheaders.add("col" & $(x + 1))    # auto col starts from 1 
        else:                             # use the first row as header and hope there is actually a header there
            for x in 0..<df.colcount: df.colheaders.add(df.df[0][x])    # row 0 col x
   for x in 0..<df.colcount: df.colcolors.add(termwhite)                # default colors for columns
   for x in 0..<df.colcount: df.colwidths.add(10)                       # create a colwidths for each column default here is 10
   result = df
  
  
  
proc createDataFrame*(filename:string,cols:int = 2,rows:int = -1,sep:char = ',',hasHeader:bool = false):nimdf = 
  ## createDataFrame
  ## 
  ## attempts to create a nimdf dataframe from url or local path
  ## 
  ## prefered are comma delimited csv or txt files
  ## 
  ## other should be clean , preprocess as needed
  ## 
  ## hasHeader refers to actual data having a header (true) or no header (false)
  ## if data has no header but a header will be added in showdf set hasHeader to true
  ## so showdfinfo will calculate the correct row count otherwise there may be an off by 1 error
  ## 
  
  #printLn("Processing ...",skyblue) 
  #curup(1)
  
  if filename.startswith("http") == true:
      var data1 = getData1(filename)
      result = makeDf1(data1,hasHeader = hasHeader)
  else:
      var data2 = getdata2(filename = filename,cols = cols,rows = rows,sep = sep)  
      result = makeDf2(data2,cols,rows,hasHeader)

  printLn(clearline)
  
 
proc createBinaryTestData*(filename:string = "nimDfBinaryTestData.csv",datarows:int = 2000,withHeaders:bool = false) = 

  var  data = newFileStream(filename, fmWrite)
  # cols,colwd parameters seqs must be of equal length
  var cols      = @[1,2,3,4,5,6,7,8]
  var colwd     = @[2,2,2,2,2,2,2,2]
  
  if withHeaders == true:
     var headers   = @["A"]
     for x in 66.. 90: headers.add($char(x)) 
     for dx in 0..<cols.len - 1: data.write(headers[dx] & ",")  
     data.writeLine(headers[cols.len - 1])
  
  for dx in 0..<datarows:
      for cy in 0..<cols.len - 1:
          data.write($getRndInt(0,1) & ",")
      data.writeLine($getRndInt(0,1))
  data.close()
  printLn("Created test data file : " & filename )  
  
  
proc createRandomTestData*(filename:string = "nimDfTestData.csv",datarows:int = 2000,withHeaders:bool = false) =
  ## createRandomTestData
  ##
  ## a file will be created in current working directory
  ## 
  ## default name nimDfTestData.csv or as given
  ## 
  ## default columns 8 
  ## default rows 2000
  ## default headers none
  ## 
  ## 
  
  var  data = newFileStream(filename, fmWrite)
  
  # cols,colwd parameters seqs must be of equal length
  var cols      = @[1,2,3,4,5,6,7,8]
  var colwd     = @[10,10,10,10,10,10,14,10]

  if withHeaders == true:
     var headers = @["A"]
     for x in 66 .. 90: headers.add($char(x)) 
     for dx in 0..<cols.len - 1: data.write(headers[dx] & ",")  
     data.writeLine(headers[cols.len - 1])
  
  
  for dx in 0..<datarows:
       
      data.write(getRndDate() & ",")
      data.write($getRndInt(0,100000) & ",")
      data.write($getRndInt(0,100000) & ",")
      data.write(newWord(3,8) & ",")
      data.write(ff(getRndFloat() * 345243.132310 * getRandomSignF(),2) & ",")
      data.write(newWord(3,8) & ",")
      data.write($getRndBool() & ",")
      data.writeLine($getRndInt(0,100))
  
  data.close()
  printLn("Created test data file : " & filename )  
  

proc dfRowStats*(df:nimdf,row:int,exceptCols:seq[int] = @[]):Runningstat =
   # sumStats
   # 
   # calculates statistics for numeric rows and returns a Runningstat instance
   # columns in exceptCols will not be included
   # 
   
   var psdata = newSeq[Runningstat]()
   var ps : Runningstat
   for col in 0..<toNimis(toSeq(0..<df.colcount)).len:
           try:
             var ecflag = false 
             if exceptCols.len > 0:
                for a in exceptCols:
                   if a - 1 == col: ecflag = true
           
             if ecflag == false:
                 ps.push(parsefloat(df.df[row][col]))
                 psdata.add(ps)
           except:
              discard   # rough error handling ,discarding any parsefloat errors due to na or text column etc
   result = ps
  
  
  
  
proc dfColumnStats*(df:nimdf,colseq:seq[int]): seq[Runningstat] =
        ## dfColumnStats
        ## 
        ## returns a seq[Runningstat] for all columns specified in colseq for dataframe df
        ## 
        ## so if colSeq = @[1,3,6] , we would get stats for cols 1,3,6
        ## 
        ## see nimdfT11.nim  for an example
        ## 
        
        var psdata = newSeq[Runningstat]()
        for x in colseq:
           var coldata = getColData(df,x)
           var ps : Runningstat
           ps.clear()
           for xx in coldata:
              try:
                 var xxx =  parsefloat(xx.strip())
                 ps.push(xxx)
              except ValueError:
                 discard
           psdata.add(ps)      
        result = psdata

        

proc dfShowColumnStats*(df:nimdf,desiredcols:seq[int],colspace:int = 25,xpos:int = 1) =
  ## dfShowColumnStats
  ## 
  ## shows output from dfColumnStats
  ## 
  ## TODO: check for headers in first line to avoid crashes
  ##       assert that column data is Somenumber type or have an automatic selector for anything numeric
  ## 
  ## xpos the starting display position
  ## colspace allows to nudge the distance between the displayed column statistics
  ## 
  printLn("Dataframe Column Statistics\n",peru,xpos = 2)
  
  # check that desiredcols is not more than available in df.colcount to avoid indexerrors etc later
  # we just cut off the right most entry of desiredcols until it fits
  let cc = df.colcount
  var ddesiredcols = desiredcols
  while  ddesiredcols.len > cc:  ddesiredcols.delete(ddesiredcols.len - 1)
  #echo ddesiredcols
  #echo df.colheaders
      
  var mydfstats = dfColumnStats(df,ddesiredcols)
  var nxpos = xpos

  var colhitem = -1   
  for mx in 0..<mydfstats.len:
      # if there are many columns we try to display grid wise
      if nxpos > tw - 22:
        curdn(20)
        nxpos = xpos
      
      if df.colHeaders.len > 0:
           inc colhitem
           var zz = ddesiredcols[colhitem] - 1
           printLnBiCol("Column " & $(ddesiredcols[mx]) & " - " & df.colheaders[zz],xpos = nxpos,styled={styleUnderscore})
      else:
           printLnBiCol("Column " & $(ddesiredcols[mx]) & " Statistics",xpos = nxpos,styled={styleUnderscore})
      showStats(mydfstats[mx],xpos = nxpos) 
      nxpos += colspace
      curup(15)
      
  curdn(20) 
  if df.hasheader == true:
      printLnBiCol(" hasHeader : " & $df.hasHeader,xpos = 1)
      printLnBiCol(" Processed " & dodgerblue & "->" & yellowgreen & " Rows : " & $(df.rowcount - 1),xpos = 1)
  else: 
      printLnBiCol(" hasHeader :" & $df.hasHeader,xpos = 1)
      printLnBiCol(" Processed " & dodgerblue & "->" & yellowgreen & " Rows : " & $df.rowcount,xpos = 1)
    
  printLnBiCol(" Processed " & dodgerblue & "->" & yellowgreen & " Cols : " & $ddesiredcols.len & " of " & $df.colcount,xpos = 1)



proc sumStats*(df:nimdf,numericCols:nimis):Runningstat =
   # sumStats
   # 
   # calculates statistics for numeric columns sums
   # 
   let mydfstats = dfColumnStats(df,numericCols)
   var psdata = newSeq[Runningstat]()
   var ps : Runningstat
   for x in 0..<mydfstats.len:
           ps.push(float(mydfstats[x].sum))
           psdata.add(ps) 
   result = ps
   
  
proc dfShowSumStats*(df:nimdf,numericCols:nimis,xpos = 2) =
     ## showSumStats
     ## 
     ## shows a statistic for all column sums
     ## 
     ## maybe usefull if a dataframe has many columns where there is a need to know the 
     ## 
     ## total sum of all numeric columns and relevant statistics of the resulting sums row
     ## 
     echo()
     printLn("Dataframe Statistics for Column Sums  -- > Sum is the Total of columns sum statistic\n",peru,xpos = xpos)  
     showStats(sumStats(df,numericCols),xpos = xpos)
     printLnBiCol(" Processed Sums " & dodgerblue & "->" & yellowgreen & " Rows : " & $1,xpos = 1)
     printLnBiCol(" Processed      " & dodgerblue & "->" & yellowgreen & " Cols : " & $numericCols.len & " of " & $df.colcount,xpos = 1)
     echo()  
  

  
proc dfLoad*(filename:string):nimdf = 
     ## dfLoad
     ## 
     ## dfLoad creates a new df from a file created with dfSave
     ## 
     var tresult = newNimDf()
     
     withFile(fs, filename, fmRead):
        var line = ""
        var lc = 0
        while fs.readLine(line):
            inc lc
            case lc 
              of 1 :  
                      if strip(line) == "true"  : tresult.hasHeader = true
                      elif strip(line) == "false" : tresult.hasHeader = false
                      else : tresult.hasHeader = false
              of 2 :
                     if line.len > 0:
                        tresult.colcount = parseInt(strip(line))
                     else:
                        tresult.colcount = 0
              of 3 :
                     if line.len > 0:
                        tresult.rowcount = parseInt(strip(line))
                     else:
                        tresult.rowcount = 0
              
              of 4 : 
                     if line.len > 0:
                                       var cccols = split(strip(line),sep = ',')
                                       for acolor in cccols:
                                           tresult.colcolors.add(getColorConst(acolor))  
                     else:
                        tresult.colcolors = @[]
                        
              of 5 :           
                       
                     if line.len > 0:
                     
                                       var ccwds = split(strip(line),sep = ',')
                                       for n in ccwds:
                                           tresult.colwidths.add(parseInt(n))
                     else:
                        tresult.colwidths = @[]
                        
              of 6 :           
                       
                     if line.len > 0:
                     
                                       var cchds = split(strip(line),sep = ',')
                                       tresult.colHeaders = cchds
                     else:
                        tresult.colHeaders = @[]     
                        
              of 7 :           
                       
                     if line.len > 0:
                     
                                       var ccrds = split(strip(line),sep = ',')
                                       tresult.rowHeaders = ccrds
                     else:
                        tresult.rowHeaders = @[]          
                        
              of 8 :
                      doAssert(strip(line) == "DATA")
                      
              else:
                    var ccdds = split(strip(line),sep = ',')
                    tresult.df.add(ccdds) 
                    
     result = tresult                  
 
 
proc dfSave*(df:nimdf,filename:string,quiet:bool = false) = 
     ## dfSave
     ## 
     ## save a dataframe data to a csv file 
     ## 
     ## quiet = true will show no feedback
     ## 
     ## Note if data is not clean crashes may occure if compiled with  -d:release 
     ##
  
     var rowcounter1 = newCxcounter()
     var totalcolscounter1 = newCxcounter()
     var errorcounter1 = newCxcounter()
     var errCount = 0
     var errFlag:bool = false
     var data = newFileStream(filename, fmWrite)
     var errorrows = newNimIs()
     
     data.writeLine(df.hasHeader)
     data.writeLine(df.colcount)
     data.writeLine(df.rowcount)
     if df.colcolors.len >= 2:
        for cn in 0..df.colcolors.len-2:
            data.write(getColorName(df.colcolors[cn]) & ",")
        data.writeLine(getColorName(df.colcolors[df.colcolors.high]))
     elif df.colcolors.len == 1:    
        data.writeLine(getColorName(df.colcolors[df.colcolors.high]))
     else:
        data.writeLine("")  
       
     if df.colwidths.len >= 2:
        for cn in 0..df.colwidths.len-2:
            data.write($df.colwidths[cn] & ",")
        data.writeLine($df.colwidths[df.colwidths.high])
     elif df.colwidths.len == 1:    
        data.writeLine($df.colwidths[df.colwidths.high])
     else:
        data.writeLine("")  
     
     if df.colHeaders.len >= 2:
        for cn in 0..df.colHeaders.len-2:
            data.write(df.colHeaders[cn] & ",")
        data.writeLine(df.colHeaders[df.colHeaders.high])
     elif df.colHeaders.len == 1:    
        data.writeLine(df.colHeaders[df.colHeaders.high])
     else:
        data.writeLine("")  
     
     if df.rowHeaders.len >= 2:
        for cn in 0..df.rowHeaders.len-2:
            data.write(df.rowHeaders[cn] & ",")
        data.writeLine(df.rowHeaders[df.rowHeaders.high])
     elif df.rowHeaders.len == 1:    
        data.writeLine(df.rowHeaders[df.rowHeaders.high])
     else:
        data.writeLine("")  
   
     data.writeLine("DATA")    # to have a nmarker for parsing
     
     for row in 0..<df.rowcount:
        if df.df[row].len < df.colcount:
              errorrows.add(row)
        for col in  0..<df.colcount:
             try:
                if col <= df.colcount - 2 : 
                    data.write(df.df[row][col] & ",")
                else : 
                    data.writeLine(df.df[row][col])
                totalcolscounter1.add
             except IndexError  :
                errorcounter1.add
                discard
      
        rowcounter1.add
        
     data.close()
     echo()
     
     if quiet == false:
        printLnBiCol("Dataframe saved to   : " & filename,xpos = 2)
        printLnBiCol("Rows written         : " & $rowcounter1.value,xpos = 2)
        printLnBiCol("Errors count         : " & $errorcounter1.value,xpos = 2) 
        printLnBiCol("Error rows           : " & wordwrap($errorrows,newLine = "\x0D\x0A" & spaces(25)),xpos = 2)  # align seq printout
        printLnBiCol("Expected Total Cells : " & $(df.colcount * df.rowcount),xpos = 2)     # cell is one data element of a row
        printLnBiCol("Actual Total Cells   : " & $totalcolscounter1.value,xpos = 2)
        if  df.colcount * df.rowcount <> totalcolscounter1.value:
            printLnBiCol("Saved status         : Saved with row errors. Original data may need preprocessing",yellowgreen,red,":",2,false,{})
        else:
            printLnBiCol("Saved status         : ok",xpos = 2)
        echo()

        
### end of nimdataframe.nim ###############################################################################################        
