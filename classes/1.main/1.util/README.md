# ***classes : main : util***

## ***description***
useful utility functions that help with logging, messages, conversions, table manipulation, etc.

## ***features***

- info/warning/error message logging
- messages to all, a coalition, or a group
- deepCopy objects
- serialize variables into strings
- show tables as messages in game
- class inheritance
- save tables to file
- load tables from file
- scheduled functions


# **#util methods**

## ***`util:logInfo(debug, msg, ...)`***
### send a message to dcs.log under the prefix of "INFO SSF"
> &rarr; @param #boolean debug [if true the logging will execute]  
> &rarr; @param #string msg [the message to send]  
> &rarr; @param #args [any arguments to be formatted into the message]  
> &larr; @return none

## example:
log an info message if a player occupies a unit
```lua
local debug = true
local playerName = unit:getPlayerName()
if playerName then
    util:logInfo(doStuffDebug, "%s is the player name", playerName)
else
    util:logInfo(doStuffDebug, "there is no player occupying the unit")
end
```

---

## ***`util:logWarning(debug, msg, ...)`***
### send a message to dcs.log under the prefix of "WARNING SSF"
> &rarr; @param #boolean debug [if true the logging will execute]  
> &rarr; @param #string msg [the message to send]  
> &rarr; @param #args [any arguments to be formatted into the message]  
> &larr; @return none

## example:
log a warning message if a unit object has entered a zone
```lua
if unit:inZone() then
    util:logWarning(true, "%s has entered a no fly zone, take action!", unit:getName())
end
```

---

## ***`util:logError(debug, msg, ...)`***
### send a message to dcs.log under the prefix of "ERROR SSF"
> &rarr; @param #boolean debug [if true the logging will execute]  
> &rarr; @param #string msg [the message to send]  
> &rarr; @param #args [any arguments to be formatted into the message]  
> &larr; @return none

## example:
log an error message when something is nil
```lua
local debugErrors = true
if group == nil then
    util:logError(debugErrors, "group in checkGroup() is now nil")
end
```

---

## ***`util:messageToAll(clearview, time, msg, ...)`***
### send a message to all players
> &rarr; @param #boolean clearview [if true new messages will over write previously displayed ones]  
> &rarr; @param #number time [the amount of time to display the message]  
> &rarr; @param #string msg [the message to send]  
> &rarr; @param #args [any arguments to be formatted into the message]  
> &larr; @return none  

## example:
sends a new message to all for 15 seconds for when a bomber group has entered a zone
```lua
if bomberGroup:inZone("zone 1") then
    util:messageToAll(false, 15, "%s has entered zone 1", bomerGroup:getName())
end
```

---

## ***`util:messageToCoalition(clearview, time, coalition, msg, ...)`***
### send a message to players of a specific coalition
> &rarr; @param #boolean clearview [if true new messages will over write previously displayed ones]  
> &rarr; @param #number time [the amount of time to display the message]  
> &rarr; @param #enum coalition [the coalition the message will be displayed for, eg: coalition.side.RED]  
> &rarr; @param #string msg [the message to send]  
> &rarr; @param #args [any arguments to be formatted into the message]  
> &larr; @return none  

## example: 
```lua
if gudautaAirbase:getCoalition() == 2 then
    util:messageToCoalition(false, 10, 2, "Gudauta Airbase is owned by Blue")
elseif gudautaAirbase:getCoalition() == 1 then
    util:messageToCoalition(false, 10, 1, "Gudauta Airbase is owned by Red")
end
```

---

## ***`util:messageToGroup(clearview, time, groupId, msg, ...)`***
### send a message to players of a specific group
> &rarr; @param #boolean clearview [if true new messages will over write previously displayed ones]  
> &rarr; @param #number time [the amount of time to display the message]  
> &rarr; @param #number groupId [the groupId the message will be displayed for]  
> &rarr; @param #string msg [the message to send]  
> &rarr; @param #args [any arguments to be formatted into the message]  
> &larr; @return none  

## example:
send a message to a units group id when it has succesfully landed
```lua
if unit:inAir() == false then
    if unit:getVelocityKMH() < 2 then
        local groupId = unit:getGroup():getID()
        util:messageToGroup(false, 15, groupId, "%s has dropped its troops", unit:getName())
    end
end
```

---

## ***`util:getSimTime()`***
### return the current time of the mission in seconds to 3 decimal places
- accounts for time passed even when the mission is paused
> &rarr; @param none  
> &larr; @return #number time  

## example:
get the sim time and send a message if its been running for over an hour
```lua
local missionRunTime = util:getSimTime()
if missionRunTime >= 3600 then
    util:messageToAll(true, 15, "Mission has been running for over 1 hour")
end
```

---

## ***`util:scheduleFunction(func, args, time)`***
### schedule a function to be ran at a later time in seconds
> &rarr; @param #function f [the function to be ran]  
> &rarr; @param #table args [the args if any, to be passed to the function]  
> &rarr; @param #number time [the time in seconds for the next time to run the function]  
> &larr; @return #number schedulerId [the function id of the running scheduler]  

## example: 
run an updater function to keep track of active tank unit objects
```lua
local updateTime = 60
local activeTanks = {}
local function updateTankGroups(_, time)
    activeTanks = {}
    local tankSearch = search:new():searchBySubString("tank"):searchForUnitsOnce()
    for _, unit in pairs(tankSearch) do
        if unit:isAlive() then
            activeTanks[#activeTanks+1] = unit
        end
    end
    return time + updateTime
end

util:scheduleFunction(updateTankGroups, nil, 0) -- schedule the updater instantly
```

---
## ***`util:removeFunction(funcId)`***
### remove a scheduled function by it
> &rarr; @param #function f [the function to be ran]  
> &larr; @return #number schedulerId [the function id of the removed scheduler]  

## example:
schedule a function to run and then remove it
```lua
local schedulerId = nil
local function updater()
    if schedulerId then
        util:removeFunction(schedulerId)
    end
end

schedulerId = util:scheduleFunction(updater, nil, 10)
```
---

## ***`util:inherit(child, parent)`***
### inherit the methods from one class to another
> &rarr; @param #table child [the child, the class to be inherited to]  
> &rarr; @param #table parent [the parent, the class to be inherited from]  
> &larr; @return #table Child [the child with inheritance from the parent]  

## example:
```lua
local parent = {}
function parent:new()
    local self = util:inherit(self, parent)
    self.parentName = "parent"
    return self
end

function parent:getParentName()
    return self.parentName
end

local child = {}
function child:new()
    local self = util:inherit(self, parent)
    return self
end

local newChild = child:new()
local parentName = newChild:getParentName()
```