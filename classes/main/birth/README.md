# ***Class birth***

## ***Description***
the birth class is a wrapper for the DCS SSE API coalition.addGroup, providing the ability to birth unlimited groups
dynamically from singular templates set to be late activated via the mission editor. These templates will carry over
all the data related to it, including individual units/payloads/liveries/routes/tasks/etc. These templates can be
changed further by the methods provided in the class, with methods such as birthFromAirbase you can alter which
airbase an AI Aircraft will be born at along with unique parking spots and takeoff methods without even having
the template placed there.

## ***Features***
- birth unlimted groups from a single late activated template group
- birth a group with a unique alias
- birth a group keeping the orignal group and unit names
- birth new groups on a repeating schedule
- birth from the original late activated group template
- birth from a vec3 point on the map
- birth from airbases at specific parking spots and taking off hot, cold, air, or from the runway
- birth from a circle or quad trigger zone
- automated rebirth on crashing, dying, landing, or shutting down engines
- birth group methods to get the current groups status

## ***Configuration***
```lua
local viperBirth = birth:new("Alpha - F-16C")
viperBirth:keepTemplateName(true)
viperBirth:limitActiveGroups(1)
viperBirth:rebirthOnCrash()
viperBirth:rebirthOnEngineShutdown()
viperBirth:birthScheduled(1800)
viperBirth:birthFromVec3(trigger.misc.getZone("Alpha Birth Zone").point)
```
## ***Fields & Methods***
---
### create a new instance of a birth object
> &rarr; @param #birth self  
> &rarr; @param #string groupName [the late activated template groups name]  
> &larr; @return #birth self
```lua
function birth:new(groupName)
```
---
### keep the group and unit template names for the birth object
> &rarr; @param #birth self  
> &rarr; @param #boolean enabled [if true, keep the late activated template groups name, default: false]  
> &larr; @return #birth self
```lua
function birth:keepTemplateName(enabled)
```
---
### set the group name alias for a birth object
- ***note: units will have a "-" after the group name followed by each units Id as seen in game***
- ***eg: a set alias: "CAP F-16" will have units followed by: CAP F-16-1" "CAP F-16-2"***
> &rarr; @param #birth self  
> &rarr; @param #string alias [the new group name of the birth object]  
> &larr; @return #birth self
```lua
function birth:setAlias(alias)
```
---
### set a limit for how many groups can be alive at any given time
> &rarr; @param #birth self  
> &rarr; @param #number maxLimit [the maximum amount of groups that can be alive at any given time]  
> &larr; @return #birth self
```lua
function birth:limitActiveGroups(maxLimit)
```
---
### set the payload for a specifc unit within the birth group
- ***note: this function can only be used before a birth object has been born. if it happens to be reborn the payload will be loaded at that point.***
> &rarr; @param #birth self  
> &rarr; @param #number unitId [the unitId within the group to set the payload for]  
> &rarr; @param #string unitName [the unit name to obtain the payload from]  
> &larr; @return #birth self
```lua
function birth:setPayload(unitId, unitName)
```
---
### set a units heading in degrees
> &rarr; @param #birth self  
> &rarr; @param #number unitId [the unitId within the group to set the heading for]  
> &rarr; @param #number heading [the heading to set in degrees]  
> &larr; @return #birth self
```lua
function birth:setHeading(unitId, heading)
```
---
### set the birth object to have a scheduled birth
> &rarr; @param #birth self  
> &rarr; @param #number scheduleTime [the time in seconds for which a new group will be born]  
> &larr; @return #birth self
```lua
function birth:birthScheduled(scheduleTime)
```
---
### birth the object to the world from its orignal template
> &rarr; @param #birth self  
> &larr; @return #birth self
```lua
function birth:birthToWorld()
```
---
### birth the object from a vec3 point located on the map
> &rarr; @param #birth self  
> &rarr; @param #table vec3 [table of vec3 points to be born at]  
> &larr; @return #birth self
```lua
function birth:birthFromVec3(vec3, alt)
```
---
### birth the object from an airbase
- ***note: this function can only be used on aircraft***
> &rarr; @param #birth self  
> &rarr; @param #string airbaseName [the airbase name to be born from]  
> &rarr; @param #array parkingSpots [the parking spots to be born at]  
> &rarr; @param #enum takeoffType [the takeoff type to be born with. options are: runway, hot, cold, air]  
> &larr; @return #birth self
```lua
function birth:birthFromAirbase(airbaseName, parkingSpots, takeoffType)
```
---
### birth the object from a circle or quad trigger zone
> &rarr; @param #birth self  
> &rarr; @param #string zoneName [the trigger zone to be born in]  
> &rarr; @param #number alt [the trigger zone to be born at]  
> &larr; @return #birth self
```lua
function birth:birthFromZone(zoneName, alt)
```
---
### automated rebirth of the object upon landing
> &rarr; @param #birth self  
> &rarr; @param #boolean groupLanded [if true, the entire group must be landed before rebirth]  
> &larr; @return #birth self
```lua
function birth:rebirthOnLanding(groupLanded)
```
---
### automated rebirth of the object upon crashing
- ***note: this should only be used on aircraft not ships or ground vehicle types***
> &rarr; @param #birth self  
> &rarr; @param #boolean groupCrashed [if true, the entire group must be crashed(dead) before rebirth]  
> &larr; @return #birth self
```lua
function birth:rebirthOnCrash(groupCrashed)
```
---
### automated rebirth of the object upon becoming dead
- ***note: this should only be used for ships and ground vehicle types not aircraft***
> &rarr; @param #birth self  
> &rarr; @param #boolean groupDead [if true, the entire group must be dead before rebirth]  
> &larr; @return #birth self
```lua
function birth:rebirthOnDead(groupDead)
```
---
### automated rebirth of the object upon shutting down its engines
- ***note: this is for aircraft only***
> &rarr; @param #birth self  
> &rarr; @param #boolean groupShutdown [if true, the entire group must be shutdown before rebirth]  
> &larr; @return #birth self
```lua
function birth:rebirthOnEngineShutdown(groupShutdown)
```
---
### internal function to initialize the group for birth
> &rarr; @param #birth self  
> &larr; @return #birth self
```lua
function birth:_initializeGroup()
```
---
### internal function to add a group into the world
> &rarr; @param #birth self  
> &larr; @return #birth self
```lua
function birth:_addGroup()
```
---
### internal function that returns free (available) parking spot data from an airbase including the parking spot ID & vec3 point
> &rarr; @param #birth self  
> &rarr; @param #string airbaseName [the airbase name to get parking spots from]  
> &rarr; @param #array parkingSpots [the parking spots to check for]  
> &larr; @return #array parkingSpots [the free parking spots]
```lua
function birth:_getParkingData(airbaseName, parkingSpots)
```
---
### interal function to update the currently existing birthed groups
> &rarr; @param #birth self  
> &larr; @return #birth self
```lua
function birth:_updateActiveGroups()
```
---