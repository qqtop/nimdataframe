
# nimdataframe

[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://github.com/yglukhov/nimble-tag)


Dataframe for Nim 
==========================


| Library      | Status      | Version | License        | OS     | Compiler       |
|--------------|-------------|---------|----------------|--------|----------------|
| nimdataframe | Development | 0.0.2.x | MIT opensource | Linux  | Nim >= 0.17.2  |


 Attempt of using csv data from the net, locally or generated to implement
 display,handling,sorting and data extraction. 
 
 
 Work in progress
 
 
Requirements
------------
```nimrod
                  
        nimble install nimcx
 
```

              
API Docs
--------
```nimrod

        http://qqtop.github.io/nimdataframe.html

```

Installation
------------
```nimrod

        nimble install https://github.com/qqtop/nimdataframe.git

```
     
Example Code 
 
```nimrod
## nimdfT13.nim
## 
## Testing nimdataframe
## 
## 
#  October data from http://www.imf.org/external/np/fin/data/rms_mth.aspx?reportType=CVSDR 
#  slightly processed to shorten header (only data of first table imported here) and saved into file rms.csv


import nimcx , nimdataframe

let ufo = "rms.csv"   

var ndf9 = createDataFrame(ufo,cols = 12,sep = ',',hasHeader = true)  # load locally from rms.csv also give state the number of cols in csv

if ndf9.hasHeader == true:
   for x in 0..<ndf9.colcount: ndf9.colheaders.add(ndf9.df[0][x])   # row 0 col x
for x in 0..<ndf9.colcount: ndf9.colcolors.add(rndcol())            # create some fun colors and add to df
for x in 0..<ndf9.colcount: ndf9.colwidths.add(9)                   # create a colwidths for each column default here is 9
ndf9.colwidths[0] = 15                                              # change first column width to 15
printLnBiCol("Data Source : " & ufo,xpos = 3)
echo()
showDf(ndf9,                                                        # display df
   rows = 1500,     
   cols = toNimis(toSeq(1..ndf9.colCount)),                           
   colwd = ndf9.colwidths,
   colcolors = ndf9.colcolors,
   showFrame = true,
   framecolor = dodgerblue,
   showHeader = true,
   xpos = 3) 
decho(3)

echo()

# now we want to display row statistics on this df
  
var xpos = 2   
var startrow = 0
if ndf9.hasHeader == true :  # donot read to run stats on the header
       startrow = 1
else : startrow = 0
for row in startrow..<ndf9.rowcount:
    printLn(fmtx(["<20"],$(ndf9.df[row][0])),zippi,styled={stylereverse},xpos = xpos)
    
    var x = dfRowStats(ndf9,row)   # x now contains a runningstats instance for one row
    # display stats for all rows
    let n = 3       # decimals
    let sep = ":"
    
    printLnBiCol("Mean  : " & ff(x.mean,n),yellowgreen,white,sep,xpos = xpos,false,{})
    printLnBiCol("Var   : " & ff(x.variance,n),yellowgreen,white,sep,xpos = xpos,false,{})
    printLnBiCol("Min   : " & ff(x.min,n),yellowgreen,white,sep,xpos = xpos,false,{})
    printLnBiCol("Max   : " & ff(x.max,n),yellowgreen,white,sep,xpos = xpos,false,{})
    curup(5)
    xpos += 21
    if xpos > tw - 30:
       curdn(13)
       xpos = 2
       echo()
       
decho(6)
showDataframeInfo(ndf9)
doFinish()


```

Example screenshots of nimdfT13 

![Image](http://qqtop.github.io/nimdfT13-1.png?raw=true)

![Image](http://qqtop.github.io/nimdfT13-2.png?raw=true)


NOTE : 
  
     Improvements may be made at any time and without warning.
     Examples may break occasionally ... nevertheless we hope you have a nice day !
     
     Forking , testing,suggestions , ideas are welcome.
     This is development code hence use at your own risk.
     
                   
![Image](http://qqtop.github.io/qqtop-small.png?raw=true)
