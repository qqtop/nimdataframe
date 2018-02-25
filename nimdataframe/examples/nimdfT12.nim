
import nimcx , nimdataframe

# nimdfT12
# 
# another example showing testdata creation and var statistics
# 
# this also shows the header issues we need to improve this and check everywhere if headers are actually passed from another df down
# 
let maxdatarows = 5   # this includes header if any

when declared(nimdataframe3):
   createBinaryTestdata(datarows=maxdatarows,withHeaders=true) 
   var ndf8 = createDataFrame("nimDfBinaryTestData.csv",cols=8,rows=maxdatarows,hasHeader=true)    # load this data into a df
else:
   createBinaryTestdata(datarows=maxdatarows,withHeaders=false)             # create test data which will by default 8 cols x 2000 rows saved into nimDfTestData.csv 
   var ndf8 = createDataFrame("nimDfBinaryTestData.csv",cols=8,rows=maxdatarows)
showDataframeInfo(ndf8)                                             # show df information

var cols = @[1,2,3,4,5,6,7,8]   # specify columns to display (createRandomTestdata generates 8 cols)

printlnbicol("Dataframe : ndf8 original")
showDf(ndf8,                                                        # show the df
      rows = 15,                                                    # how many rows to show
      cols = cols,                                                  # which cols to show
      colwd = @[2,2,2,2,2,2,2,2],                                   # columnwidths for display can be adjusted manualy or  eg.: colwd = newSeqWith(ndf.colcount,2)
      colcolors = @[],                                              # specify a color for the first column or adjust as needed
      showframe = true,
      framecolor = goldenrod,
      showHeader = true,                                           # show header 
      leftalignflag = false) 
 
echo()
var statcols = @[1,2,3,4,5,6,7,8]                                   # select the numeric cols 

dfShowColumnStats(ndf8,statcols,colspace = 30,xpos = 2)            # show stats for numeric cols
decho(2)                                                           # 2 blank lines

var ndf9 = getRowDataRange(ndf8,rows = toSeq(0 .. (ndf8.rowcount - 1)),cols = statcols)        # create a new df with these 4 numeric cols but only use specific rows
when declared(nimdataframe3):
   doassert ndf8.df == ndf9.df
   doassert ndf8.hasHeader == ndf9.hasHeader

when declared(nimdataframe3):
   assert ndf8 == ndf9 
   
printLnBicol("Dataframe : ndf9 same as ndf8")
showDataframeInfo(ndf9) 


showDf(ndf9,                                                       # show the new df
      rows = 15,
      cols = statcols,
      colwd = @[2,2,2,2,2,2,2,2],
      colcolors = @[],
      showframe = true,
      framecolor = goldenrod,
      showHeader = false,                                          # show header 
      headertext = @[] ,                                           # use the selected numeric cols from ndf8 as header text
      leftalignflag = false) 

      
dfShowColumnStats(ndf9,statcols,colspace = 30,xpos = 2)          # show stats for all cols of this dataframe
      
dfShowSumStats(ndf9,statcols)                                    # show stats for horizontal sums that is: Sum is the total of all cols summed


doFinish()                                                         # print bottom info
