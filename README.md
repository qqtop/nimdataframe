# nimdataframe

[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://github.com/yglukhov/nimble-tag)


Dataframe for Nim 
==========================


| Library      | Status      | Version | License        | OS     | Compiler       |
|--------------|-------------|---------|----------------|--------|----------------|
| nimdataframe | Development | 0.0.1   | MIT opensource | Linux  | Nim >= 0.14.3  |


 Early attempt of using csv data from the net or locally to implement
 display,handling,sorting and data extraction.
 
 
Requirements
 
          nimble install random
          
          nimble install https://github.com/qqtop/NimCx.git
 

              
API Docs
--------

        http://qqtop.github.io/nimdataframe.html


Installation
------------
```nimrod

        nimble install https://github.com/qqtop/nimdataframe.git

```
     
Example Code 
 
```nimrod

## nimdfT1.nim 
## Testing nimdataframe

var ufo =  "http://bit.ly/uforeports"    # data used in pandas documentation
var ndf:nimdf                            # define a nim dataframe
 
ndf = createDataFrame(ufo)
printLnBiCol("Data Source : " & ufo)
echo()
showDf(ndf, cols = 6 ,rows = 10,colwd = 15,showframe = true,header = true) 
showDataframeInfo(ndf)
doFinish()


```
![Image](http://qqtop.github.io/nimdataframe1.png?raw=true width = 150 height = 150)






NOTE : 
  
     Improvements may be made at any time.              
     Forking ,testing, suggestions , ideas are welcome.
     This is development code , hence use at your own risk.
     
     Tested  openSuse 13.2 , openSuse Leap42.1 , openSuse TumbleWeed
              
![Image](http://qqtop.github.io/qqtop.png?raw=true)