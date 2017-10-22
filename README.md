
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

## compile with : nim c  -d:ssl -r nimdfT1

import nimcx , nimdataframe 

let ufo =  "http://bit.ly/uforeports"    # data used in pandas documentation
 
var ndf = createDataFrame(ufo)
printLnBiCol("Data Source : " & ufo)
echo()
showDf(ndf,
   rows = 15,
   cols = @[1,2,3,4,5],
   colwd = @[15,7,14,6,15],
   colcolors = @[pastelgreen,pastelpink,peru,gold],
   showFrame = true,
   framecolor = dodgerblue,
   showHeader = true,
   xpos = 3) 
decho(3)

showDataframeInfo(ndf)
dfSave(ndf,"uforeports.csv")

doFinish()


```

![Image](http://qqtop.github.io/nimdataframe1.png?raw=true)


Example screenshots of nimdfT13 

![Image](http://qqtop.github.io/nimdfT13-1.png?raw=true)

![Image](http://qqtop.github.io/nimdfT13-2.png?raw=true)


NOTE : 
  
     Improvements may be made at any time.              
     Forking ,testing, suggestions , ideas are welcome.
     This is development code , hence use at your own risk.
     
     Tested on  openSuse TumbleWeed
              
![Image](http://qqtop.github.io/qqtop-small.png?raw=true)
