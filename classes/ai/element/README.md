# ***Class element***

## ***Description***
the element class is an essential peice to any air war, consisiting of 1-4 units each of the same kind and have its own unique
deployment airbase and patrol area to perform CAP duties. utilizing fsm based events the element will be automated to pushed through
a series of states that help with tasking it to start its patrol, engage targets, go back to patrolling after killing detected targets,
return to base after reaching its threshold, etc. all of these events can also be called upon by users to help with the mission enhancements.

## ***Features***
- automated deployment
- automated engagements
- automated RTB
- automated redeployment
- unique home airbase
- unique parking spots at home airbase for hot and cold starts
- unique takeoff for hot, cold, runway, and air starts at home airbase
- unique patrol area (zone or airbase)
- dynamic patrolling altitudes
- dynamic patrolling speeds
- dynamic patrol ranges (distance from center of patrol)
- dynamic engage altitudes
- dynamic enage speeds
- dynamic engage ranges (distance from element)
- unique patrol shapes
- unique detection types

## ***Configuration***

```lua
local viperBirth = birth:new("Alpha - F-16C")
viperBirth:keepTemplateName(true)

local viperElement = element:new("Alpha", viperBirth)
viperElement:setDetection(element.detectionTypes.radar, element.detectionTypes.datalink, element.detectionTypes.rwr)
viperElement:setAirbase("Gudauta")
viperElement:setPatrol("Sochi-Adler", element.patrolShapes.triangle)
viperElement:setResources(5)
viperElement:setFuelThreshold(0.7)
viperElement:setPatrolAlt(6000, 8000)
viperElement:setPatrolSpeed(260, 290)
viperElement:setPatrolRange(23000, 32000)
viperElement:setEngageAlt(8000, 1000)
viperElement:setEngageSpeed(310, 410)
viperElement:setEngageRange(46300, 74080)
viperElement:setTakeoffHot()
viperElement:__Start(5)
```

## ***Fields & Methods***
---
### enable or disable writing to dcs.log
> &rarr; #element self  
> &rarr; #boolean bool [default true, false to disable writing to dcs.log]  
> &larr; #element self
```lua
function element:log(bool)
```
---
### create a new instance of an element object
> &rarr; @param #element self  
> &rarr; @param #string elementName [the name of the element]  
> &rarr; @param #string birthGroup [the birth group object to be controlled as an element object]  
> &larr; @return #element self
```lua
function element:new(elementName, birthGroup)
```
---
### set the detection types for how the element finds targets
- ***note: you can only have up to 3 detection types per limit of DCS***
> &rarr; @param #element self  
> &rarr; @param #enum type1 [detectionType eg: element.detectionTypes.datalink]  
> &larr; @return #element self 
```lua
function element:setDetection(type1, type2, type3)
```
---
### set the airbase that the element will depart from always
> &rarr; @param #element self  
> &larr; @return #element self  
```lua
function element:setAirbase(airbaseName)
```
---
### set the airbase that the element will depart from always
> &rarr; @param #element self  
> &larr; @return #element self  
```lua
function element:setParkingSpots(parkingSpots)
```
---
### ***set the elements patrol to a airbase or trigger zone
> &rarr; @param #element self  
> &rarr; @param #string patrolName [the name of the airbase or trigger zone]  
> &rarr; @param #enum patrolShape [the patrol shape, eg: element.patrolShape.diamond]  
> &larr; @return #element self  
```lua
function element:setPatrol(patrolName, patrolShape)
```
---
### set the amount of resources the element has available
- ***note: if the element dies, the current resources will be subtracted by 1.***
- ***note: if the element successfully lands and parks, the current resources will be added back by 1.***
> &rarr; @param #element self  
> &rarr; @param #number resources [this is the amount of groups the element has]  
> &larr; @return #element self
```lua
function element:setResources(resources)
```
---
### set the RTB fuel threshold for the element
> &rarr; @param #element self  
> &rarr; @param #number threshold [once the element reaches this combined fuel amount, they will RTB]  
> &larr; @return #element self
```lua
function element:setFuelThreshold(threshold)
```
---
### set the min and max patrol alt for the element
- ***note: for each point in the patrol, a random alt between the min and max will be chosen to patrol from***
> &rarr; @param #element self  
> &rarr; @param #number minAlt [the minimum alt in meters]  
> &rarr; @param #number maxAlt [the maximum alt in meters]  
> &larr; @return #element self
```lua
function element:setPatrolAlt(minAlt, maxAlt)
```
---
### set the min and max patrol speed for the element
- ***note: for each point in the patrol, a random speed between the min and max will be chosen to patrol at***
> &rarr; @param #element self  
> &rarr; @param #number minSpeed [the minimum speed in meters]  
> &rarr; @param #number maxSpeed [the maximum speed in meters]  
> &larr; @return #element self
```lua
function element:setPatrolSpeed(minSpeed, maxSpeed)
```
---
### set the min and max patrol range for the element
- ***note: for each point in the patrol, a random distance from the patrol airbase/zone center will be chosen***
> &rarr; @param #element self  
> &rarr; @param #number minRange [the minimum range in meters]  
> &rarr; @param #number maxRange [the maximum range in meters]  
> &larr; @return #element self
```lua
function element:setPatrolRange(minRange, maxRange)
```
---
### set the min and max engage alt for the element
- ***note: each time an engagement occurs, a random alt between the min and max will be chosen to engage from***
> &rarr; @param #element self  
> &rarr; @param #number minAlt [the minimum alt in meters]  
> &rarr; @param #number maxAlt [the maximum alt in meters]  
> &larr; @return #element self
```lua
function element:setEngageAlt(minAlt, maxAlt)
```
---
### set the min and max engage speed for the element
- ***note: each time an engagement occurs, a random speed between the min and max will be chosen to engage at***
> &rarr; @param #element self  
> &rarr; @param #number minSpeed [the minimum speed in meters]  
> &rarr; @param #number maxSpeed [the maximum speed in meters]  
> &larr; @return #element self
```lua
function element:setEngageSpeed(minSped, maxSpeed)
```
---
### set the min and max engage range for the element
- ***note: for any detected target a random range between the min and max is selected to check if the target is within that range.***
> &rarr; @param #element self  
> &rarr; @param #number minRange [the minimum range in meters]  
> &rarr; @param #number maxRange [the maximum range in meters]  
> &larr; @return #element self
```lua
function element:setEngageRange(minRange, maxRange)
```
---
### set the element to takeoff from parking hot
> &rarr; @param #element self  
> &larr; @return #element self
```lua
function element:setTakeoffHot()
```
---
### set the element to takeoff from parking cold
> &rarr; @param #element self  
> &larr; @return #element self
```lua
function element:setTakeoffCold()
```
---
### set the element to takeoff from parking air
> &rarr; @param #element self  
> &larr; @return #element self
```lua
function element:setTakeoffAir()
```
---
### set the element to takeoff from runway
> &rarr; @param #element self  
> &larr; @return #element self
```lua
function element:setTakeoffRunway()
```
---
## ***FSM Events***
---
### ***on After "Start" event***
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterStart(from, event, to)
```
---
### on After "Birth" event
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterBirth(from, event, to)
```
---
### on After "ElementDead" event
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterElementDead(from, event, to)
```
---
### on After "TaxiToRunway" event
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterTaxiToRunway(from, event, to)
```
---
### on After "Takeoff" event
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterTakeoff(from, event, to)
```
---
### on After "PatrolStart" event
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterPatrolStart(from, event, to)
```
---
### on After "OnPatrol" event
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterOnPatrol(from, event, to)
```
---
### on After "EngageTarget" event
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterEngageTarget(from, event, to)
```
---
### on After "TargetDead" event
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterTargetDead(from, event, to)
```
---
### on After "RTB" event
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterRTB(from, event, to)
```
---
### on After "Landing" event
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterLanding(from, event, to)
```
---
### on After "TaxiToParking" event
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterTaxiToParking(from, event, to)
```
---
### on After "Parked" event
> &rarr; @param #element self  
> &rarr; @param #string from  
> &rarr; @param #string event  
> &rarr; @param #string to
```lua
function element:onAfterParked(from, event, to)
```
---