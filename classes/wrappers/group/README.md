# ***Class group***

## ***Description***
wrapper functions for DCS Class Group with additional methods available.

## ***Features***
- wrapped methods for DCS Class Group
- extra methods not available in DCS Class Group

## ***Fields & Methods***
---
### get a new instance of a group object by name
> &rarr; @param #group self  
> &rarr; @param #string groupName  
> &larr; @return #group self
```lua
function group:getByName(groupName)
```
---
### get the template of the group object if it exists in the database
> &rarr; @param #group self  
> &larr; @return #table groupTemplate
```lua
function group:getTemplate()
```
---
### return the DCS Class Group from the group object
> &rarr; @param #group self  
> &larr; @return DCS#Group
```lua
function group:getDCSGroup()
```
---
### return a boolean if the group object is alive
> &rarr; @param #group self  
> &larr; @return #boolean groupAlive [true if any unit is determined to be alive]
```lua
function group:isAlive()
```
---
### return the average speed of the group object in kilometers per hour
> &rarr; @param #group self  
> &larr; @return #number avgVelocityKMH
```lua
function group:getAvgVelocityKMH()
```
---
### return a boolean if the group object exists currently
> &rarr; @param #groups self  
> &larr; @return #boolean groupExist
```lua
function group:isExist()
```
---
### return a boolean if the group object is in air
> &rarr; @param #group self  
> &larr; @return #boolean groupInAir [false if any unit is determined to be not in air]
```lua
function group:inAir()
```
---
### get the average vec3 point from the group object
> &rarr; @param #group self  
> &larr; @return #table avgVec3 [table of x, y, and z coordinates from the average point of the group]
```lua
function group:getPoint()
```
---
### return a table needed for a units payload
- ***note: this function does not obtain a *current* payload, only what is set via the mission editor***
> &rarr; @param #group self  
> &rarr; @param #string unitName [the unit name to get the payload from]  
> &larr; @return #table payload
```lua
function group:getPayload(unitName)
```
---
### get the average amount of fuel remaining for the group object
> &rarr; @param #group self  
> &larr; @rreturn #number avgFuel
```lua
function group:getAvgFuel()
```
---
### destroy the group object with no explosion
> &rarr; @param #group self  
> &larr; @return #group self
```lua
function group:destroy()
```
---
### get the category from the group object
- ***Group.Category enums found here: https://wiki.hoggitworld.com/view/DCS_Class_Group***
> &rarr; @param #group self  
> &larr; @return #enum groupCategory
```lua
function group:getCategory() 
```
---
### get the coalition from the group object
- ***coalition.side enums found here: https://wiki.hoggitworld.com/view/DCS_singleton_coalition***
> &rarr; @param #group self  
> &larr; @return #number groupCoalition
```lua
function group:getCoalition()
```
---
### get the group name from the group object
> &rarr; @param #group self  
> &larr; @return #string groupName
```lua
function group:getName()
```
---
### get the DCS#Group ID from the group object
> &rarr; @param #group self  
> &larr; @return #number groupId
```lua
function group:getID()
```
---
### get a DCS Class #Unit from the group object
> &rarr; @param #group self  
> &rarr; @param #number unitId [the unitId within the group to obtain]  
> &larr; @return DCS#Unit dcsUnit
```lua
function group:getDCSUnit(unitId)
```
---
### get all the DCS#Units from the group object
> &rarr; @param #group self  
> &larr; @return DCS#Units units
```lua
function group:getDCSUnits()
```
---
### get the current size of the group object
> &rarr; @param #group self  
> &larr; @return #number groupSize
```lua
function group:getSize()
```
---
### get the inital size of the group object
- ***this does not return the current size but the size of group template***
> &rarr; @param #group self  
> &larr; @return #number initGroupSize
```lua
function group:getInitialSize()
```
---
### get the DCS#Controller for the group object
> &rarr; @param #group self  
> &larr; @return DCS#GroupController
```lua
function group:getController()
```
---
### enable the group object to have its radar emitters on or off
> &rarr; @param #group self  
> &rarr; @param #boolean emission [if true the group will enable its radars]  
> &larr; @return #group self
```lua
function group:enableEmission(emission)
```

### get targets detected by the group object
> &rarr; @param #group self  
> &rarr; @param #table targets [array of detectionTypes]  
> &larr; @return #table detectedTargets
```lua
function group:getDetectedTargets(targets)
```
---