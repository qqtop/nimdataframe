import nimcx,nimdataframe
# nimdfT19
# Latest : 2017-12-17
#
# tests for displaying a dataset read in from a csv file
# then sorting the dataframe on a column and redisplying a sorted dataframe
#  

# displaying dataset 
# note that rows in createDataFrame indicates with how many rows we play with
# if set rows = -1 then a max 50000 rows will be considered
# 

#var ndf9 = createDataFrame(filename = "Top_of_Book_20130206.csv",cols = 8,rows = 1_000_000,sep = ',',hasheader = true)
var ndf9 = createDataFrame(filename = "TradeLog20130206.csv",cols = 8,rows = 1_000_000,sep = ',',hasheader = true)
#var ndf9 = createDataFrame(filename = "Bundesliga.csv",cols = 8,rows = 1_000_000,sep = ',',hasheader = true)   # from bluenote10 / nimdata

#below needs lots of memory will fail after a while with 14 mill rows but ok with 1 mill
#var ndf9 = createDataFrame(filename = "OrderBook20130206.csv",cols = 8,rows = 1_000_000,sep = ',',hasheader = true)  # abt 14 million rows

# try different widths and colors as desired
var testcolwd = @[6,25,25,9,9,6,4,10]
var testcolcolors = @[truetomato,slategray,randcol(),randcol(),randcol()]
var testsortcolumn = 4  # we sort on the fourth column

# we also can write the testcolwd and testcolcolors into the dataframe then they will alkso be shown in the dataframe inspection part
ndf9.colColors = testcolcolors
ndf9.colWidths = testcolwd


showdf(ndf9,                        # returns 
              rows = 10 , #ndf9.rowcount,  # no need to show all
              cols = toSeq(1..ndf9.colcount),
              colwd = testcolwd,
              colcolors = testcolcolors,
              showframe = true,
              framecolor = gold,
              showHeader = true,
              headertext = ndf9.colHeaders,
              leftalignflag = true,
              xpos = 3)
showDataframeInfo(ndf9)


var ndf10 = sortDf(ndf9,testsortcolumn,"asc")     
showdf(ndf10,                        # returns 
              rows = 10,  #ndf10.rowcount,  # no need to show all
              cols = toSeq(1..ndf10.colcount),
              colwd = testcolwd,
              colcolors = testcolcolors,
              showframe = true,
              framecolor = gold,
              showHeader = true,
              headertext = ndf10.colHeaders,  # <---- needs this to tell showdf where this col headers are from
              leftalignflag = true,
              xpos = 3)           
showDataframeInfo(ndf10)

doFinish()
