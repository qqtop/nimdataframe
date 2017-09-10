
# nimdataframe

[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://github.com/yglukhov/nimble-tag)


Dataframe for Nim 
==========================


| Library      | Status      | Version | License        | OS     | Compiler       |
|--------------|-------------|---------|----------------|--------|----------------|
| nimdataframe | Development | 0.0.1.x | MIT opensource | Linux  | Nim >= 0.17.1  |


 Attempt of using csv data from the net, locally or generated to implement
 display,handling,sorting and data extraction.
 
 
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

## nimdfT1.nim
## Testing nimdataframe
## compile with : nim c -d:ssl -d:release -r nimdfT1

import nimcx , nimdataframe 

var ufo =  "http://bit.ly/uforeports"    # data used in pandas documentation
var ndf:nimdf                            # define a nim dataframe
 
ndf = createDataFrame(ufo)
printLnBiCol("Data Source : " & ufo)
echo()
showDf(ndf, rows = 15,cols = @[1,2,3,4,5],colwd = @[15,7,14,6,15],colcolors = @[pastelgreen,pastelpink,peru,gold],showFrame = true,framecolor = dodgerblue,showHeader = true) 
echo()
showDataframeInfo(ndf)
doFinish()


```
![Image](http://qqtop.github.io/nimdataframe1.png?raw=true)


 Tests with StockData

![Image](http://qqtop.github.io/nimdataframe2a.png?raw=true)
![Image](http://qqtop.github.io/nimdataframe3.png?raw=true)



NOTE : 
  
     Improvements may be made at any time.              
     Forking ,testing, suggestions , ideas are welcome.
     This is development code , hence use at your own risk.
     
     Tested on  openSuse TumbleWeed
              
![Image](http://qqtop.github.io/qqtop-small.png?raw=true)
