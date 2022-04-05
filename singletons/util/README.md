# ***Singleton utils***

## ***Description***
useful utility functions that help with logging, messages, conversions, table manipulation, etc.

## ***Features***
- info message logging
- error message logging
- messages to all, a coalition, or a group
- deepCopy objects
- serialize variables into strings
- show tables as messages in game
- class inheritance
- save tables to file
- load tables from file
- scheduled functions
- getting unit velocitys in mps/mph/kmh
- mark parking spots at airbases

## **Functions**
---
### send a message to dcs.log under the prefix of "SSF INFO"
> &rarr; @param #string msg [the message to send]  
> &rarr; @param #args [any arguments to be formatted into the message]  
> &larr; @return none
```lua
function utils.logInfo(msg,...)
```
---
### send a message to dcs.log under the prefix of "SSF ERROR"
> &rarr; @param #string msg [the message to send]  
> &rarr; @param #args [any arguments to be formatted into the message]  
> &larr; @return none
```lua
function utils.logError(msg,...)
```
---
### send a message to all players
> &rarr; @param #number time [the amount of time to display the message]  
> &rarr; @param #string msg [the message to send]  
> &rarr; @param #args [any arguments to be formatted into the message]  
> &larr; @return none
```lua
function utils.msgToAll(time, msg, ...)
```
---
### send a message to players of a specific coalition
> &rarr; @param #number time [the amount of time to display the message]  
> &rarr; @param #enum coalition [the coalition the message will be displayed for, eg: coalition.side.RED]  
> &rarr; @param #string msg [the message to send]  
> &rarr; @param #args [any arguments to be formatted into the message]  
> &larr; @return none
```lua
function utils.msgToCoalition(time, coalition, msg, ...)
```
---
### send a message to players of a specific group
> &rarr; @param #number time [the amount of time to display the message]  
> &rarr; @param #number groupId [the groupId the message will be displayed for]  
> &rarr; @param #string msg [the message to send]  
> &rarr; @param #args [any arguments to be formatted into the message]  
> &larr; @return none
```lua
function utils.msgToGroup(time, groupId, msg, ...)
```
---
### return the current time of the mission in seconds to 3 decimal places
- accounts for time passed even when the mission is paused
> &rarr; @param none  
> &larr; @return #number time
```lua
function utils.getSimTime()
```
---
### schedule a function to be ran at a later time in seconds
> &rarr; @param #function f [the function to be ran]  
> &rarr; @param #table args [the args if any, to be passed to the function]  
> &rarr; @param #number time [the time in seconds for the next time to run the function]  
> &larr; @return #number schedulerId [the function id of the running scheduler]
```lua
function utils.scheduleFunction(func, args, time)
```
---
### remove a scheduled function by it
> &rarr; @param #function f [the function to be ran]  
> &larr; @return #number schedulerId [the function id of the removed scheduler]
```lua
function utils.removeFunction(funcId)
```
---
### inherit the methods from one class to another
> &rarr; @param #table child [the child, the class to be inherited to]  
> &rarr; @param #table parent [the parent, the class to be inherited from]  
> &larr; @return #table Child [the child with inheritance from the parent]
```lua
function utils.inherit(child, parent)
```
---
### deep copy a table recursively through all levels of the table.
- this is a mist function reused and can be referenced here: https://wiki.hoggitworld.com/view/MIST_deepCopy
> &rarr; @param #table object  
> &larr; @return #table object
```lua
function utils.deepCopy(object)
```
---
### returns the string value of a variable
- this is a mist function reused and can be referenced here: https://wiki.hoggitworld.com/view/MIST_basicSerialize
> &rarr; @param #any var  
> &larr; @return #any var
```lua
function utils.basicSerialize(var)
```
---
### return a table non-serialized table made into a string for saving or printing
> &rarr; @param #table tbl [the table to show]  
> &larr; @return #string tableString [the table formated to a string]
```lua
function utils.tableWriteStr(tableName, tbl)
```
---
### write a table to a lua file
> &rarr; @param #string file  
> &rarr; @param #table _table  
> &rarr; @param #boolean overwrite [overwrites the file with the new table]
```lua
function utils.tableSave(file, _table, overwrite)
```
---
### load a file from inside Saved Games/DCS/
> &rarr; @param #string file
```lua
function utils.loadFile(file)
```
---
### round number to a specific decimal place
> &rarr; @param #number num  
> &rarr; @param #number idp  
> &larr; @return #number roundedNum
```lua
function utils.round(num, idp)
```
---
### returns the point projected from the passed point at the passed distance along a given angle
> &rarr; @param #table point  
> &rarr; @param #number dist  
> &rarr; @param #number theta  
> &larr; @return #table newPoint
```lua
function utils.projectPoint(point, dist, theta)
```
---
### get the 2D distance between two points in meters
> &rarr; @param #table fromVec3  
> &rarr; @param #table toVec3  
> &larr; @return #number distance
```lua
function utils.getDistance(fromVec3, toVec3)
```
---
### get the velocity of a unit in meters per second
> &rarr; @param DCS#Unit [the DCS Unit Object to get the velocity for]  
> &larr; @return #number velocityMPS
```lua
function utils.getVelocityMPS(unit)
```
---
### get the velocity of a unit in kilometers per hour
> &rarr; @param DCS#Unit [the DCS Unit Object to get the velocity for]  
> &larr; @return #number velocityKMH
```lua
function utils.getVelocityKMH(unit)
```
---
### get the velocity of a unit in miles per hour
> &rarr; @param DCS#Unit [the DCS Unit Object to get the velocity for]  
> &larr; @return #number velocityMPH
```lua
function utils.getVelocityMPH(unit)
```
---
### mark all the parking spots for an airbase
> &rarr; @param #string airbaseName [the airbase to mark the parking spots for  
> &larr; @return none
```lua
function utils.markParkingSpots(airbaseName)
```
---