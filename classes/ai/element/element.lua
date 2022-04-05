local viperBirth = birth:new("Alpha - F-16C")
viperBirth:keepTemplateName(true)

local alphaElement = element:new("Alpha", viperBirth)
alphaElement:setDetection(element.detectionTypes.radar, element.detectionTypes.datalink, element.detectionTypes.rwr)
alphaElement:setAirbase("Sukhumi-Babushara")
alphaElement:setPatrol("Gudauta", element.patrolShapes.star)
alphaElement:setResources(2)
alphaElement:setFuelThreshold(0.3)
alphaElement:setHealthThreshold(0.7)
alphaElement:setAmmoThreshold(1)
alphaElement:setPatrolAlt(5000, 7000)
alphaElement:setPatrolSpeed(260, 290)
alphaElement:setPatrolRange(25000, 35000)
alphaElement:setEngageAlt(8000, 10000)
alphaElement:setEngageSpeed(310, 410)
alphaElement:setEngageRange(46300, 74080)
alphaElement:setTakeoffHot()
alphaElement:__Start(5)

function alphaElement:onAfterDeploy()
    util:msgToAll(false, 600, "%s has deployed from %s", self.elementName, self.airbaseName)
end

function alphaElement:onAfterTakeoff(from, event, to, eventData)
    util:msgToAll(false, 600, "%s has taken off from %s", eventData.initUnitName, eventData.placeName)
end

function alphaElement:onAfterRTB()
    util:msgToAll(false, 600, "%s is RTB to %s", self.elementName, self.airbaseName)
end

function alphaElement:onAfterLand(from, event, to, eventData)
    util:msgToAll(false, 600, "%s has landed at %s", eventData.initUnitName, eventData.placeName)
end

local birthMig29s = birth:new("Omega - MiG-29S-1")
birthMig29s:keepTemplateName(true)
birthMig29s:birthScheduled(1200)
birthMig29s:birthToWorld()