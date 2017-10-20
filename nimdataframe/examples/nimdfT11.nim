import nimcx , nimdataframe

# nimdfT11
# 
# another example showing testdata creation and var statistics
# 
# 
# status : ok
# 

createRandomTestdata(datarows = 30000)             # create test data which will by default 8 cols x 2000 rows saved into nimDfTestData.csv 

var ndf8 = createDataFrame("nimDfTestData.csv",cols=8,rows=30000)   # load this data into a df
showDataframeInfo(ndf8)                                             # show df information

var cols = @[1,2,3,4,5,6,7,8]                                       # specify columns to display (createRandomTestdata generates 8 cols)

showDf(ndf8,                                                        # show the df
      rows = 15,
      cols = cols,
      colwd = @[10,10,10,10,10,10,14,10],                           # columnwidths for display can be adjusted
      colcolors = @[salmon],                                        # specify a color for the first column or adjust as needed
      showframe = true,
      framecolor = goldenrod,
      showHeader = true,                                            # show header 
      headertext = @["1","2","3","4","5","6","7","8"],              # some header
      leftalignflag = false) 
 
echo()
var statcols = @[2,3,5,8]                                          # select the numeric cols 

dfShowColumnStats(ndf8,statcols,colspace = 30,xpos = 2)            # show stats for numeric cols
decho(2)                                                           # 2 blank lines

var ndf9 = getRowDataRange(ndf8,rows = @[1,2,4,6],cols = statcols) # create a new df with these 4 numeric cols but only use specific rows

showDf(ndf9,                                                       # show the new df
      rows = 15,
      cols = @[1,2,3,4],
      colwd = @[10,10,10,10],
      colcolors = @[],
      showframe = true,
      framecolor = goldenrod,
      showHeader = true,                                            # show header 
      headertext = @["2","3","5","8"] ,                             # use the selected numeric cols from ndf8 as header text
      leftalignflag = false) 

      
dfShowColumnStats(ndf9,@[1,2,3,4],colspace = 30,xpos = 2)          # show stats for all 4 cols of this dataframe
      
dfShowSumStats(ndf9,@[1,2,3,4])                                    # show stats for horizontal sums that is: Sum is the total of all cols summed

doFinish()                                                         # print bottom info
