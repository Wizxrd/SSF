--[[

@Simple Scripting Framework

@authors Wizard#5064

@description
Simple  Scripting Framework is as the title suggests, is as the title suggests,
a simplified framework comprised of pre-made scripted solutions using Object
Orientated Lua Scripting for DCS World Mission Creators.

@github: https://github.com/Wizxrd/SSF/tree/main

@created Jan 30, 2022

@version 0.0.1

@todo
- finish coalition objects and their member methods not inherited from object class
- finish group object wrapper member methods
- finish birth class methods
]]

log.write("ssf.lua", log.INFO, "loading simple scripting framework")

local ssf = {}
ssf.version = "0.0.1"

--
--
-- ** enumerators **
--
--

enum = {}

--[[

@enum #waypoint

@description
constant table of waypoint options containting the corresponding type and action

@features
- coverage of all waypoint options

@created Feb 6, 2022

]]

enum.waypoint = {
	["turningPoint"]      = {name = "Turning point",            type = "Turning Point",     action = "Turning Point" },
	["flyOverPoint"]      = {name = "Fly over point",           type = "Turning Point",     action = "Fly Over Point"},
	["finPoint"]          = {name = "Fin point N/A",            type = "Fin Point",         action = "Fin Point"},
	["takeoffRunway"]     = {name = "Takeoff from runway",      type = "TakeOff",           action = "From Runway"},
	["takeoffParking"]	  = {name = "Takeoff from parking",     type = "TakeOffParking",    action = "From Parking Area"},
	["takeoffParkingHot"] = {name = "Takeoff from parking hot", type = "TakeOffParkingHot", action = "From Parking Area Hot"},
	["LandingReFuAr"] 	  = {name = "LandingReFuAr",            type = "LandingReFuAr",     action = "LandingReFuAr"},

	["takeoffGround"]	  = {name = "Takeoff from ground", 	    type = "TakeOffGround",     action = "From Ground Area"},
	["takeoffGroundHot"]  = {name = "Takeoff from ground hot",  type = "TakeOffGroundHot",  action = "From Ground Area Hot"},

	["landing"] 		  = {name = "Landing",                  type = "Land",              action = "Landing"},
	["offRoad"] 		  = {name = "Offroad",                  type = "Turning Point",     action = "Off Road"},
	["onRoad"] 		      = {name = "On road",              	type = "Turning Point",     action = "On Road"},
	["rank"] 			  = {name = "Rank",                     type = "Turning Point",     action = "Rank"},
	["cone"] 			  = {name = "Cone",                     type = "Turning Point",     action = "Cone"},
	["vee"] 			  = {name = "Vee",                      type = "Turning Point",     action = "Vee"},
	["diamond"] 		  = {name = "Diamond",                  type = "Turning Point",     action = "Diamond"},
	["echelonL"] 		  = {name = "Echelon Left",             type = "Turning Point",     action = "EchelonL"},
	["echelonR"] 		  = {name = "Echelon Right",            type = "Turning Point",     action = "EchelonR"},
	["customForm"] 	      = {name = "Custom",                   type = "Turning Point",     action = "Custom"},
	["onRailroads"] 	  = {name = "On railroads",             type = "On Railroads",      action = "On Railroads"},
}

--[[

@enum #weaponFlag

@description
constant table of weaponFlags with corresponding values required for tasking

@features
- coverage of all weapon flags

@created Feb 6, 2022

]]

enum.weaponFlag = {
    ["NoWeapon"] = 0,

    -- Bombs
    ["LGB"] = 2,
    ["TvGB"] = 4,
    ["SNSGB"] = 8,
    ["GuidedBomb"] = 14, -- (LGB + TvGB + SNSGB)
    ["HEBomb"] = 16,
    ["Penetrator"] = 32,
    ["NapalmBomb"] = 64,
    ["FAEBomb"] = 128,
    ["ClusterBomb"] = 256,
    ["Dispencer"] = 512,
    ["CandleBomb"] = 1024,
    ["ParachuteBomb"] = 2147483648,
    ["AnyUnguidedBomb"] = 2147485680, -- (HeBomb + Penetrator + NapalmBomb + FAEBomb + ClusterBomb + Dispencer + CandleBomb + ParachuteBomb)
    ["AnyBomb"] = 2147485694, -- (GuidedBomb + AnyUnguidedBomb)

    -- Rockets
    ["LightRocket"] = 2048,
    ["MarkerRocket"] = 4096,
    ["CandleRocket"] = 8192,
    ["HeavyRocket"] = 16384,
    ["AnyRocket"] = 30720, -- (LightRocket + MarkerRocket + CandleRocket + HeavyRocket)

    -- Missiles
    ["AntiRadarMissile"] = 32768,
    ["AntiShipMissile"] = 65536,
    ["AntiTankMissile"] = 131072,
    ["FireAndForgetASM"] = 262144,
    ["LaserASM"] = 524288,
    ["TeleASM"] = 1048576,
    ["CruiseMissile"] = 2097152,
    ["AntiRadarMissile2"] = 1073741824,
    ["GuidedASM"] = 1572864, -- (LaserASM + TeleASM)
    ["TacticalASM"] = 1835008, -- (GuidedASM + FireAndForgetASM)
    ["AnyASM"] = 4161536, -- (AntiRadarMissile + AntiShipMissile + AntiTankMissile + FireAndForgetASM + GuidedASM + CruiseMissile)

    -- AAM
    ["SRAAM"] = 4194304,
    ["MRAAM"] = 8388608,
    ["LRAAM"] = 16777216,
    ["IR_AAM"] = 33554432,
    ["SAR_AAM"] = 67108864,
    ["AR_AAM"] = 134217728,
    ["AnyAMM"] = 264241152, -- (IR_AAM + SAR_AAM + AR_AAM + SRAAM + MRAAM + LRAAM)
    ["AnyMissile"] = 268402688, -- (ASM + AnyAAM)
    ["AnyAutonomousMissile"] = 36012032, -- (IR_AAM + AntiRadarMissile + AntiShipMissile + FireAndForgetASM + CruiseMissile)

    -- Guns
    ["GUN_POD"] = 268435456,
    ["BuiltInCannon"] = 536870912,
    ["Cannons"] = 805306368, -- (GUN_POD + BuiltInCannon)

    -- Torpedo
    ["Torpedo"] = 4294967296,

    -- Combinations
    ["AnyAGWeapon"] = 2956984318, -- (BuiltInCannon + GUN_POD + AnyBomb + AnyRocket + AnyASM)
    ["AnyAAWeapon"] = 264241152, -- (BuiltInCannon + GUN_POD + AnyAAM)
    ["UnguidedWeapon"] = 2952822768, -- (Cannons + BuiltInCannon + GUN_POD + AnyUnguidedBomb + AnyRocket)
    ["GuidedWeapon"] = 268402702, -- (GuidedBomb + AnyASM + AnyAAM)
    ["AnyWeapon"] = 3221225470, -- (AnyBomb + AnyRocket + AnyMissile + Cannons)
    ["MarkerWeapon"] = 13312, -- (MarkerRocket + CandleRocket + CandleBomb)
    ["ArmWeapon"] = 3221212158 -- (AnyWeapon - MarkerWeapon)
}

--[[

@enum event

@description
constant table for dcs world events. these enums are to be used for handling events with the #handler class

@features
- coverage of all dcs world events

@created Feb 6, 2022

]]

enum.event = {
    ["shot"] = {
        id = world.event.S_EVENT_SHOT,
        name = "Shot",
    },
    ["hit"] = {
        id = world.event.S_EVENT_HIT,
        name = "Hit",
    },
    ["takeoff"] = {
        id = world.event.S_EVENT_TAKEOFF,
        name = "Takeoff",
    },
    ["land"] = {
        id = world.event.S_EVENT_LAND,
        name = "Land",
    },
    ["crash"] = {
        id = world.event.S_EVENT_CRASH,
        name = "Crash",
    },
    ["ejection"] = {
        id = world.event.S_EVENT_EJECTION,
        name = "Ejection",
    },
    ["refueling"] = {
        id = world.event.S_EVENT_REFUELING,
        name = "Refueling",
    },
    ["dead"] = {
        id = world.event.S_EVENT_DEAD,
        name = "Dead",
    },
    ["pilotDead"] = {
        id = world.event.S_EVENT_PILOT_DEAD,
        name = "PilotDead",
    },
    ["baseCaptured"] = {
        id = world.event.S_EVENT_BASE_CAPTURED,
        name = "BaseCaptured",
    },
    ["missionStart"] = {
        id = world.event.S_EVENT_MISSION_START,
        name = "MissionStart",
    },
    ["missionEnd"] = {
        id = world.event.S_EVENT_MISSION_END,
        name = "MissionEnd",
    },
    ["tookControl"] = {
        id = world.event.S_EVENT_TOOK_CONTROL,
        name = "TookControl",
    },
    ["refuelingStop"] = {
        id = world.event.S_EVENT_REFUELING_STOP,
        name = "RefuelingStop",
    },
    ["birth"] = {
        id = world.event.S_EVENT_BIRTH,
        name = "Birth",
    },
    ["humanFailure"] = {
        id = world.event.S_EVENT_HUMAN_FAILURE,
        name = "HumanFailure",
    },
    ["detailedFailure"] = {
        id = world.event.S_EVENT_DETAILED_FAILURE,
        name = "DetailedFailure",
    },
    ["engineStartup"] = {
        id = world.event.S_EVENT_ENGINE_STARTUP,
        name = "EngineStartup",
    },
    ["engineShutdown"] = {
        id = world.event.S_EVENT_ENGINE_SHUTDOWN,
        name = "EngineShutdown",
    },
    ["playerEnterUnit"] = {
        id = world.event.S_EVENT_PLAYER_ENTER_UNIT,
        name = "PlayerEnterUnit",
    },
    ["playerLeaveUnit"] = {
        id = world.event.S_EVENT_PLAYER_LEAVE_UNIT,
        name = "PlayerLeaveUnit",
    },
    ["playerComment"] = {
        id = world.event.S_EVENT_player_comment,
        name = "PlayerComment",
    },
    ["shootingStart"] = {
        id = world.event.S_EVENT_SHOOTING_START,
        name = "ShootingStart",
    },
    ["shootingEnd"] = {
        id = world.event.S_EVENT_SHOOTING_END,
        name = "shootingEnd",
    },
    ["markAdded"] = {
        id = world.event.S_EVENT_MARK_ADDED,
        name = "MarkAdded",
    },
    ["markChanged"] = {
        id = world.event.S_EVENT_MARK_CHANGE,
        name = "MarkChanged",
    },
    ["markRemove"] = {
        id = world.event.S_EVENT_MARK_REMOVE,
        name = "MarkRemove",
    },
    ["kill"] = {
        id = world.event.S_EVENT_KILL,
        name = "Kill",
    },
    ["score"] = {
        id = world.event.S_EVENT_SCORE,
        name = "Score",
    },
    ["unitLost"] = {
        id = world.event.S_EVENT_UNIT_LOST,
        name = "UnitLost",
    },
    ["landingAfterEjection"] = {
        id = world.event.S_EVENT_LANDING_AFTER_EJECTION,
        name = "LandingAfterEjection",
    },
    ["discardChairAfterEjection"] = {
        id = world.event.S_EVENT_DISCARD_CHAIR_AFTER_EJECTION,
        name = "DiscardChairAfterEjection",
    },
    ["weaponAdd"] = {
        id = world.event.S_EVENT_WEAPON_ADD,
        name = "WeaponAdd",
    },
    ["landingQualityMark"] = {
        id = world.event.S_EVENT_LANDING_QUALITY_MARK,
        name = "LandingQualityMark",
    },
}

--[[

@enum smoke

@description
constant table for smoke marker colors

@features
- coverage of all 5 smoke colors >.<

@created Feb 20, 2022

]]

enum.smoke = {
    ["green"] = 0,
    ["red"] = 1,
    ["white"] = 2,
    ["orange"] = 3,
    ["blue"] = 4
}

--
--
-- ** classes : main **
--
--

--[[

@class #util

@authors Wizard

@description
useful utility functions

@features
- deep copy tables
- inheritance
- multiple inheritance
- vector math

@created May, 21, 2022

]]

util = {}

function util:deepCopy(object)
    local copies = {}
    local function recursiveCopy(object)
        if type(object) ~= "table" then return object end
        if copies[object] then return copies[object] end
        local copy = {}
        copies[object] = copy
        for key, value in pairs(object) do
            copy[recursiveCopy(key)] = recursiveCopy(value)
        end
        return setmetatable(copy, getmetatable(object))
    end
    return recursiveCopy(object)
end

function util:inheritParent(child, parent)
    local child = util:deepCopy(child)
    setmetatable(child, {__index = parent})
    return child
end

function util:inheritParents(child, parents)
    local child = util:deepCopy(child)
    local parents = {
        __index = function(_, key)
            for i = 1, #parents do
                local parent = parents[i]
                if parent[key] then
                    return parent[key]
                end
            end
        end
    }
    setmetatable(child, parents)
    return child
end

function util:projectPoint(point, distance, theta)
    local newPoint = {}
    if point.z then
        newPoint.z = util:round(math.sin(theta) * distance + point.z, 3)
        newPoint.y = util:deepCopy(point.y)
    else
        newPoint.y = util:round(math.sin(theta) * distance + point.y, 3)
    end
    return newPoint
end

function util:get2DDistance(fromVec3, toVec3)
    local distanceX = toVec3.x - fromVec3.x
    local distanceY = toVec3.z - fromVec3.z
    return math.sqrt(distanceX * distanceX + distanceY * distanceY)
end

function util:velocityToMPS(velocityVec3)
    return (velocityVec3.x^2 + velocityVec3.y^2 + velocityVec3.z^2)^0.5
end

function util:velocityToKMH(velocityVec3)
    return self:velocityToMPS(velocityVec3) * 3.6
end

function util:velocityToMPH(velocityVec3)
    return self:velocityToMPS(velocityVec3) * 2.237
end

--[[

@class #logger

@authors Wizard

@description
logger module for mission scripting environemt + hook environment

@features
- log levels
- custom log files

@created May 10, 2022

]]

logger = {
    ["openmode"] = "a",
    ["datetime"] = "%Y-%m-%d %H:%M:%S",
    ["level"] = 5,
}

logger.enum  = {
    ["none"]    = 0,
    ["alert"]   = 1,
    ["error"]   = 2,
    ["warning"] = 3,
    ["info"]    = 4,
    ["debug"]   = 5,
    ["trace"]   = 6
}

do
    local logwrite = log.write
    local format = string.format
    local osdate
    if os then osdate = os.date end
    local callbacks = {
        {["method"] = "alert",   ["enum"] = "ALERT"},
        {["method"] = "error",   ["enum"] = "ERROR"},
        {["method"] = "warning", ["enum"] = "WARNING"},
        {["method"] = "info",    ["enum"] = "INFO"},
        {["method"] = "debug",   ["enum"] = "DEBUG"},
        {["method"] = "trace",   ["enum"] = "TRACE"},
    }
    for i, callback in ipairs(callbacks) do
        logger[callback.method] = function(self, message, ...)
            if self.level < i then
                return
            end
            local logMessage = format(message, ...)
            if self.file then
                local fullMessage = format("%s %s\t%s: %s\n", osdate(self.datetime), callback.enum, self.source, logMessage)
                self.file:write(fullMessage)
                return
            end
            logwrite(self.source, log[callback.enum], logMessage)
        end
    end
end

function logger:new(source, level, file, openmode, datetime)
    local self = util:inheritParent(self, logger)
    self.source = source
    if type(level) == "number" then self.level = level end
    if type(level) == "string" then self.level = self.enum[level] end
    if file then
        if not openmode then openmode = logger.openmode end
        self.file = assert(io.open(file, openmode))
    end
    if datetime then self.datetime = datetime end
    return self
end

function logger:setSource(source)
    self.source = source
    return self
end

function logger:setLevel(level)
    if type(level) == "number" then self.level = level end
    if type(level) == "string" then self.level = self.enum[level] end
    return self
end

function logger:setFile(file, openmode)
    if self.file then self.file:close() end
    if not openmode then openmode = logger.openmode end
    self.file = assert(io.open(file, openmode))
    return self
end

function logger:setDateTime(datetime)
    self.datetime = datetime
    return self
end

--[[

@class #base

@authors Wizard

@description

@features

@created May 24, 2022

]]

base = {}
base.className = "base"
base.classId = 1
base.source = "ssf.lua"
base.level = 5

function base:new()
    local self = util:inheritParent(base, logger:new())
    base.classId = base.classId + 1
    self.classId = base.classId
    return self
end

function base:getClassName()
    return self.className
end

function base:getClassId()
    return self.classId
end

function base:getMethod(key)
    if self[key] and type(self[key]) == "function" then
        return self[key]
    end
end

--[[

@class #datbases

@authors Wizard

@description

@features

@created May 24, 2022

]]


database = {}

database.categoryId = {
    ["plane"] = Unit.Category.AIRPLANE,
    ["helicopter"] = Unit.Category.HELICOPTER,
    ["vehicle"] = Unit.Category.GROUND_UNIT,
    ["ship"] = Unit.Category.SHIP,
}

database.coalitionName = {
    [0] = "NEUTRAL",
    [1] = "RED",
    [2] = "BLUE"
}

function database:new()
    local self = util:inheritParent(self, base:new())
    self:registerGroups()
    self:registerUnits()
    self:registerStatics()
    self:registerAirbases()
    self:registerZones()
    self:registerPlayers()
    self:registerClients()
    --self:registerLiverys()
    --self:registerPayloads()
    return self
end

function database:getObject(objectName)
    for _, database in pairs(self) do
        if type(database) == "table" then
            if database[objectName] then
                return util:deepCopy(database[objectName])
            end
        end
    end
end

function database:getGroupObject(groupName)
    if self.groupsByName[groupName] then
        return util:deepCopy(self.groupsByName[groupName])
    end
end

function database:getUnitObject(unitName)
    if self.unitsByName[unitName] then
        return util:deepCopy(self.unitsByName[unitName])
    end
end

function database:getStaticObject(staticName)
    if self.staticsByName[staticName] then
        return util:deepCopy(self.staticsByName[staticName])
    end
end

function database:getAirbaseObject(airbaseName)
    if self.airbasesByName[airbaseName] then
        return util:deepCopy(self.airbasesByName[airbaseName])
    end
end

function database:getZoneObject(zoneName)
    if self.zonesByName[zoneName] then
        return util:deepCopy(self.zonesByName[zoneName])
    end
end

function database:getPlayerObject(unitName)
    if self.playersByUnitName[unitName] then
        return util:deepCopy(self.playersByUnitName[unitName])
    end
end

function database:getClientObject(unitName)
    if self.clientsByUnitName[unitName] then
        return util:deepCopy(self.clientsByUnitName[unitName])
    end
end

function database:addGroupObject(groupObject)
    self.groupsByName[groupObject.name] = util:deepCopy(groupObject)
    return self
end

function database:addUnitObject(unitObject)
    self.unitsByName[unitObject.name] = util:deepCopy(unitObject)
    return self
end

function database:addStaticObject(staticObject)
    self.staticsByName[staticObject.name] = util:deepCopy(staticObject)
    return self
end

function database:addAirbaseObject(airbaseObject)
    self.airbasesByName[airbaseObject.name] = util:deepCopy(airbaseObject)
    return self
end

function database:addZoneObject(zoneObject)
    self.zonesByName[zoneObject.name] = util:deepCopy(zoneObject)
    return self
end

function database:removeGroupObject(groupObject)
    self.groupsByName[groupObject.name] = nil
    return self
end

function database:removeUnitObject(unitObject)
    self.unitsByName[unitObject.name] = nil
    return self
end

function database:removeStaticObject(staticObject)
    self.staticsByName[staticObject.name] = nil
    return self
end

function database:removeAirbaseObject(airbaseObject)
    self.airbasesByName[airbaseObject.name] = nil
    return self
end

function database:removeZoneObject(zoneObject)
    self.zonesByName[zoneObject.name] = nil
    return self
end

function database:registerGroups()
    self.groupsByName = {}
    for sideName, coalitionData in pairs(env.mission.coalition) do
        if sideName == "neutrals" then sideName = "neutral" end
        if type(coalitionData) == "table" then
            if coalitionData.country then
                for _, countryData in pairs(coalitionData.country) do
                    for categoryName, objectData in pairs(countryData) do
                        if categoryName == "plane" or categoryName == "helicopter" or categoryName == "vehicle" or categoryName == "ship" then
                            for _, groupData in pairs(objectData.group) do
                                self.groupsByName[groupData.name] = util:deepCopy(groupData)
                                self.groupsByName[groupData.name].coalitionId = coalition.side[sideName:upper()]
                                self.groupsByName[groupData.name].coalitionName = sideName:upper()
                                self.groupsByName[groupData.name].countryId = countryData.id
                                self.groupsByName[groupData.name].countryName = countryData.name
                                self.groupsByName[groupData.name].categoryId = self.categoryId[categoryName]
                                self:info("database:registerGroups(): registered group %s", groupData.name)
                            end
                        end
                    end
                end
            end
        end
    end
    return self
end

function database:registerUnits()
    self.unitsByName = {}
    for sideName, coalitionData in pairs(env.mission.coalition) do
        if sideName == "neutrals" then sideName = "neutral" end
        if type(coalitionData) == "table" then
            if coalitionData.country then
                for _, countryData in pairs(coalitionData.country) do
                    for categoryName, objectData in pairs(countryData) do
                        if categoryName == "plane" or categoryName == "helicopter" or categoryName == "vehicle" or categoryName == "ship" then
                            for _, groupData in pairs(objectData.group) do
                                for _, unitData in pairs(groupData.units) do
                                    self.unitsByName[unitData.name] = util:deepCopy(unitData)
                                    self.unitsByName[unitData.name].group = util:deepCopy(groupData)
                                    self.unitsByName[unitData.name].typeName = unitData.type
                                    self.unitsByName[unitData.name].coalitionId = coalition.side[sideName:upper()]
                                    self.unitsByName[unitData.name].coalitionName = coalition.side[sideName:upper()]
                                    self.unitsByName[unitData.name].countryId = countryData.id
                                    self.unitsByName[unitData.name].countryName = countryData.name
                                    self.unitsByName[unitData.name].categoryId = self.categoryId[categoryName]
                                    self:info("database:registerUnits(): registered unit %s", unitData.name)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return self
end

function database:registerStatics()
    self.staticsByName = {}
    for sideName, coalitionData in pairs(env.mission.coalition) do
        if sideName == "neutrals" then sideName = "neutral" end
        if type(coalitionData) == "table" then
            if coalitionData.country then
                for _, countryData in pairs(coalitionData.country) do
                    for objectCategory, objectData in pairs(countryData) do
                        if objectCategory == "static" then
                            for _, staticData in pairs(objectData.group) do
                                local staticName = staticData.units[1].name
                                local staticCategory = StaticObject.getByName(staticName):getDesc().category
                                self.staticsByName[staticName] = util:deepCopy(staticData.units)
                                self.staticsByName[staticName].name = staticName
                                self.staticsByName[staticName].typeName = staticData.type
                                self.staticsByName[staticName].coalitionId = coalition.side[sideName:upper()]
                                self.staticsByName[staticName].coalitionName = sideName:upper()
                                self.staticsByName[staticName].countryId = countryData.id
                                self.staticsByName[staticName].countryName = countryData.name
                                self.staticsByName[staticName].categoryId = staticCategory
                                self:info("database:registerStatics(): registered static %s", staticName)
                            end
                        end
                    end
                end
            end
        end
    end
    return self
end

function database:registerAirbases()
    self.airbasesByName = {}
    for _, airdrome in pairs(world.getAirbases()) do
        local airbaseName = airdrome:getName()
        self.airbasesByName[airbaseName] = {
            ["name"] = airbaseName,
            ["typeName"] = airdrome:getTypeName(),
            ["desc"] = airdrome:getDesc(),
            ["id"] = airdrome:getID(),
            ["categoryId"] = airdrome:getDesc().category
        }
        self:info("database:registerAirbases(): registered airbase %s", airbaseName)
    end
    return self
end

function database:registerZones()
    self.zonesByName = {}
    for _, zones in pairs(env.mission.triggers) do
        for _, zoneData in pairs(zones) do
            self.zonesByName[zoneData.name] = util:deepCopy(zoneData)
            self:info("database:registerZones(): registered trigger zone %s", zoneData.name)
        end
    end
    return self
end

function database:registerPlayers()
    self.playersByUnitName = {}
    for _, unitData in pairs(self.unitsByName) do
        if unitData.skill == "Player" then
            self.playersByUnitName[unitData.name] = util:deepCopy(unitData)
            self:info("database:registerPlayers(): registered player unit %s", unitData.name)
        end
    end
    return self
end

function database:registerClients()
    self.clientsByUnitName = {}
    for _, unitData in pairs(self.unitsByName) do
        if unitData.skill == "Client" then
            self.clientsByUnitName[unitData.name] = util:deepCopy(unitData)
            self:info("database:registerClients(): registered client unit %s", unitData.name)
        end
    end
    return self
end

function database:registerPayloads()
    self.payloadsByUnitName = {}
    for _, unitData in pairs(self.unitsByName) do
        if unitData.payload then
            self.payloadsByUnitName[unitData.name] = util:deepCopy(unitData.payload)
            self:info("database:registerPayloads(): registered payload from unit %s", unitData.name)
        end
    end
    return self
end

function database:registerLiverys()
    self.liverysByUnitName = {}
    for _, unitData in pairs(self.unitsByName) do
        if unitData.livery_id then
            self.liverysByUnitName[unitData.name] = util:deepCopy(unitData.livery_id)
            self:info("database:registerLiverys(): registered livery from unit %s", unitData.name)
        end
    end
    return self
end

--[[

@class #message

@authors Wizard

@description
in game messaging functions

@features
- message to all
- message to red
- message to blue
- message to group
- message to unit
- message to country

@created May, 21, 2022

]]

message = {}

function message:new(msg, ...)
    local self = util:inheritParent(self, message)
    self.message = string.format(msg, ...)
    return self
end

function message:toAll(time, clearview)
    trigger.action.outText(self.message, time, clearview)
end

function message:toRed(time, clearview)
    trigger.action.outTextForCoalition(1, self.message, time, clearview)
end

function message:toBlue(time, clearview)
    trigger.action.outTextForCoalition(2, self.message, time, clearview)
end

function message:toGroup(groupId, time, clearview)
    trigger.action.outTextForGroup(groupId, self.message, time, clearview)
end

function message:toUnit(unitId, time, clearview)
    trigger.action.outTextForUnit(unitId, self.message, time, clearview)
end

function message:toCountry(countryId, time, clearview)
    trigger.action.outTextForCountry(countryId, self.message, time, clearview)
end

--[[

@class #scheduler

@authors Wizard

@description
schedule functions dynamically at a given time in the mission

@features
- scheduled functions
- removal of scheduled functions

@created May, 21, 2022

]]

scheduler = {}

function scheduler:new(func, args, time)
    local self = util:inheritParent(self, scheduler)
    self.functionId = timer.scheduleFunction(func, args, time)
    return self
end

function scheduler:remove(functionId)
    if functionId then
        timer.removeFunction(functionId)
    else
        if self.functionId then
            self.functionId = timer.removeFunction(self.functionId)
        end
    end
    return self
end

--[[

@class #fsm

@authors Wizard

@description
A Finite State Machine (fsm) models a process flow that transitions between various States through triggered events.

@features
- base class to model your own state machines.
- trigger events synchronously.
- trigger events asynchronously.
- handle events before or after the event was triggered.
- handle state transitions as a result of event before and after the state change.

@credit MOOSE
The developers of MOOSE have created this class, I take no credit for the hard work they did to create it. I've simply
reworked the code to be able to work without MOOSE. Many thanks to those that created it.

@created Feb 8, 2022

]]

fsm = {}

--[[ creates a new fsm object
- @param #fsm self
- @return #fsm
]]
function fsm:new()
    local self = util:inheritParent(self, base:new())
    self.options = {}
    self.options.subs = {}
    self.current = 'none'
    self.Events = {}
    self.subs = {}
    self.endstates = {}
    self.Scores = {}
    self._StartState = "none"
    self._Transitions = {}
    self._Processes = {}
    self._EndStates = {}
    self._Scores = {}
    self._EventSchedules = {}
    self.CallScheduler = nil
    return self
end


--[[ sets the start state of the fsm
- @param #fsm self
- @param #string State A string defining the start state
]]
function fsm:setStartState(State)
    self._StartState = State
    self.current = State
end


--[[ returns the start state of the fsm
- @param #fsm self
- @return #string A string containing the start state
]]
function fsm:getStartState()
    return self._StartState or {}
end

--[[ Add a new transition rule to the fsm
- note: A transition rule defines when and if the fsm can transition from a state towards another state upon a triggered event
- @param #fsm self
- @param #table From Can contain a string indicating the From state or a table of strings containing multiple From states
- @param #string Event The Event name
- @param #string To The To state
]]
function fsm:addTransition(From, Event, To)
    local Transition = {}
    Transition.From = From
    Transition.Event = Event
    Transition.To = To
    self._Transitions[Transition] = Transition
    self:eventMap(self.Events, Transition)
end


--[[ Returns a table of the transition rules defined within the fsm
- @param #fsm self
- @return #table Transitions
]]
function fsm:getTransitions()
  return self._Transitions or {}
end

--[[ Set the default @{Process} template with key ProcessName providing the ProcessClass and the process object when it is assigned to a @{Wrapper.Controllable} by the task.
- @param #fsm self
- @param #table From Can contain a string indicating the From state or a table of strings containing multiple From states.
- @param #string Event The Event name.
- @param Core.fsm#fsm_PROCESS Process An sub-process fsm.
- @param #table ReturnEvents A table indicating for which returned events of the Subfsm which Event must be triggered in the fsm.
- @return Core.fsm#fsm_PROCESS The Subfsm.
--
function fsm:addProcess(From, Event, Process, ReturnEvents)
    local Sub = {}
    Sub.From = From
    Sub.Event = Event
    Sub.fsm = Process
    Sub.StartEvent = "Start"
    Sub.ReturnEvents = ReturnEvents
    self._Processes[Sub] = Sub
    self:submap(self.subs, Sub, nil)
    self:addTransition(From, Event, From)
    return Process
end
]]

--[[ Returns a table of the Subfsm rules defined within the fsm
- @param #fsm self
- @return #table Sub processes
]]
function fsm:getProcesses()
    return self._Processes or {}
end

function fsm:getProcess(From, Event)
    for ProcessID, Process in pairs(self:getProcesses()) do
        if Process.From == From and Process.Event == Event then
        return Process.fsm
        end
    end
    error("Sub-Process from state " .. From .. " with event " .. Event .. " not found!")
end

function fsm:setProcess(From, Event, fsm)
    for ProcessID, Process in pairs(self:getProcesses()) do
        if Process.From == From and Process.Event == Event then
        Process.fsm = fsm
        return true
        end
    end
    error("Sub-Process from state " .. From .. " with event " .. Event .. " not found!")
end

--[[ Adds an End state
- @param #fsm self
- @param #string State The fsm state
]]
function fsm:addEndState(State)
    self._EndStates[State] = State
    self.endstates[State] = State
end

--[[ Returns the End states
- @param #fsm self
- @return #table End states
]]
function fsm:getEndStates()
    return self._EndStates or {}
end


--[[ Adds a score for the fsm to be achieved
- @param #fsm self
- @param #string State is the state of the process when the score needs to be given. (See the relevant state descriptions of the process)
- @param #string ScoreText is a text describing the score that is given according the status
- @param #number Score is a number providing the score of the status
- @return #fsm self
]]
function fsm:addScore(State, ScoreText, Score)
    self._Scores[State] = self._Scores[State] or {}
    self._Scores[State].ScoreText = ScoreText
    self._Scores[State].Score = Score
    return self
end

--[[ Adds a score for the fsm_PROCESS to be achieved
- @param #fsm self
- @param #string From is the From State of the main process
- @param #string Event is the Event of the main process
- @param #string State is the state of the process when the score needs to be given. (See the relevant state descriptions of the process)
- @param #string ScoreText is a text describing the score that is given according the status
- @param #number Score is a number providing the score of the status
- @return #fsm self
]]
function fsm:addScoreProcess(From, Event, State, ScoreText, Score)
    local Process = self:getProcess(From, Event)
    Process._Scores[State] = Process._Scores[State] or {}
    Process._Scores[State].ScoreText = ScoreText
    Process._Scores[State].Score = Score
    return Process
end

--[[ Returns a table with the scores defined
- @param #fsm self
- @return #table Scores
]]
function fsm:getScores()
    return self._Scores or {}
end

--[[ Returns a table with the Subs defined
- @param #fsm self
- @return #table Sub processes
]]
function fsm:getSubs()
    return self.options.subs
end

--[[ Load call backs
- @param #fsm self
- @param #table CallBackTable Table of call backs
]]
function fsm:loadCallBacks(CallBackTable)
    for name, callback in pairs(CallBackTable or {}) do
        self[name] = callback
    end
end

--[[ Event map
- @param #fsm self
- @param #table Events Events
- @param #table EventStructure Event structure
]]
function fsm:eventMap(Events, EventStructure)
    local Event = EventStructure.Event
    local __Event = "__" .. EventStructure.Event
    self[Event] = self[Event] or self:createTransition(Event)
    self[__Event] = self[__Event] or self:delayedTransition(Event)
    Events[Event] = self.Events[Event] or { map = {} }
    self:addToMap(Events[Event].map, EventStructure)
end

--[[ Sub maps
- @param #fsm self
- @param #table subs Subs
- @param #table sub Sub
- @param #string name Name
]]
function fsm:submap(subs, sub, name)
    subs[sub.From] = subs[sub.From] or {}
    subs[sub.From][sub.Event] = subs[sub.From][sub.Event] or {}
    subs[sub.From][sub.Event][sub] = {}
    subs[sub.From][sub.Event][sub].fsm = sub.fsm
    subs[sub.From][sub.Event][sub].StartEvent = sub.StartEvent
    subs[sub.From][sub.Event][sub].ReturnEvents = sub.ReturnEvents or {} -- these events need to be given to find the correct continue event ... if none given, the processing will stop
    subs[sub.From][sub.Event][sub].name = name
    subs[sub.From][sub.Event][sub].fsmparent = self
end

--[[ Call handler
- @param #fsm self
- @param #string step Step "onafter", "onbefore", "onenter", "onleave"
- @param #string trigger Trigger
- @param #table params Parameters
- @param #string EventName Event name
- @return Value
]]
function fsm:callHandler(step, trigger, params, EventName)
    local handler = step .. trigger
    if self[handler] then
        self._EventSchedules[EventName] = nil
        -- Error handler.
        local ErrorHandler = function(errmsg)
            self:error("fsm:callHandler(): Error in scheduled function:" .. errmsg)
            return errmsg
        end
        local Result, Value = xpcall(function() return self[handler](self, unpack(params)) end, ErrorHandler)
        return Value
    end
end

--[[ Handler
- @param #fsm self
- @param #string EventName Event name
- @param ... Arguments
]]
function fsm._handler(args)
    local self = args[1]
    local EventName = args[2]
    local _args = args[3]
    local Can, To = self:can(EventName)
    if To == "*" then
        To = self.current
    end
    if Can then
        local From = self.current
        local Params = { From, EventName, To, _args  }
        if self["onleave".. From] or
            self["onLeave".. From] or
            self["onbefore".. EventName] or
            self["onBefore".. EventName] or
            self["onafter".. EventName] or
            self["onAfter".. EventName] or
            self["onenter".. To] or
            self["onEnter".. To] then
            if self:callHandler("onbefore", EventName, Params, EventName) == false then
                return false
            else
                if self:callHandler("onBefore", EventName, Params, EventName) == false then
                    return false
                else
                    if self:callHandler("onleave", From, Params, EventName) == false then  
                        return false
                    else
                        if self:callHandler("onLeave", From, Params, EventName) == false then
                            return false
                        end
                    end
                end
            end
        end
        -- New current state
        self.current = To
        local execute = true
        local subtable = self:_gosub(From, EventName)
        for _, sub in pairs(subtable) do
            sub.fsm.fsmparent = self
            sub.fsm.ReturnEvents = sub.ReturnEvents
            sub.fsm[sub.StartEvent](sub.fsm)
            execute = false
        end
        local fsmparent, Event = self:_isendstate(To)
        if fsmparent and Event then
            self:callHandler("onenter", To, Params, EventName)
            self:callHandler("onEnter", To, Params, EventName)
            self:callHandler("onafter", EventName, Params, EventName)
            self:callHandler("onAfter", EventName, Params, EventName)
            self:callHandler("onstate", "change", Params, EventName)
            fsmparent[Event](fsmparent)
            execute = false
        end

        if execute then
            self:callHandler("onafter", EventName, Params, EventName)
            self:callHandler("onAfter", EventName, Params, EventName)
            self:callHandler("onenter", To, Params, EventName)
            self:callHandler("onEnter", To, Params, EventName)
            self:callHandler("onstate", "change", Params, EventName)
        end
    end

    return nil
end

--[[ Delayed transition
- @param #fsm self
- @param #string EventName Event name
- @return #function Function
]]
function fsm:delayedTransition(EventName)
    return function(self, DelaySeconds, ...)
        local CallID = 0
        if DelaySeconds ~= nil then
            if DelaySeconds < 0 then -- Only call the event ONCE!
                DelaySeconds = math.abs(DelaySeconds)
                if not self._EventSchedules[EventName] then
                    CallID = scheduler:new(fsm._handler, {self, EventName, ...}, DelaySeconds or 1)
                    self._EventSchedules[EventName] = CallID
                end
            else
                CallID = scheduler:new(fsm._handler, {self, EventName, ...}, DelaySeconds or 1)
            end
        else
            error("fsm: An asynchronous event trigger requires a DelaySeconds parameter!!! This can be positive or negative! Sorry, but will not process this.")
        end
    end
end

--[[ Create transition
- @param #fsm self
- @param #string EventName Event name
- @return #function Function
]]
function fsm:createTransition(EventName)
    return function(self, ...) return self._handler({ self,  EventName , ... }) end
end

--[[ Go sub
- @param #fsm self
- @param #string ParentFrom Parent from state
- @param #string ParentEvent Parent event name
- @return #table Subs
]]
function fsm:_gosub(ParentFrom, ParentEvent)
    local fsmtable = {}
    if self.subs[ParentFrom] and self.subs[ParentFrom][ParentEvent] then
        return self.subs[ParentFrom][ParentEvent]
    else
        return {}
    end
end

--[[ Is end state
- @param #fsm self
- @param #string Current Current state name
- @return #table fsm parent
- @return #string Event name
]]
function fsm:_isendstate(Current)
  local fsmParent = self.fsmparent
    if fsmParent and self.endstates[Current] then
        fsmParent.current = Current
        local ParentFrom = fsmParent.current
        local Event = self.ReturnEvents[Current]
        if Event then
            return fsmParent, Event
        end
    end

    return nil
end

--[[ Add to map
- @param #fsm self
- @param #table Map Map
- @param #table Event Event table
]]
function fsm:addToMap(Map, Event)
    if type(Event.From) == 'string' then
        Map[Event.From] = Event.To
    else
        for _, From in ipairs(Event.From) do
        Map[From] = Event.To
        end
    end
end

--[[ Get current state
- @param #fsm self
- @return #string Current fsm state
]]
function fsm:getState()
    return self.current
end

--[[ Get current state
- @param #fsm self
- @return #string Current fsm state
]]
function fsm:getCurrentState()
    return self.current
end

--[[ Check if fsm is in state
- @param #fsm self
- @param #string State State name
- @param #boolean If true, fsm is in this state
]]
function fsm:is(State)
    return self.current == State
end

--[[ Check if fsm is in state
- @param #fsm self
- @param #string State State name
- @param #boolean If true, fsm is in this state
]]
function fsm:_is(state)
    return self.current == state
end

--[[ Check if can do an event
- @param #fsm self
- @param #string e Event name
- @return #boolean If true, fsm can do the event
- @return #string To state
]]
function fsm:can(e)
    local Event = self.Events[e]
    local To = Event and Event.map[self.current] or Event.map['*']
    return To ~= nil, To
end

--[[ Check if cannot do an event
- @param #fsm self
- @param #string e Event name
- @return #boolean If true, fsm cannot do the event
]]
function fsm:cannot(e)
    return not self:can(e)
end

--[[

@class #handler

@authors Wizard

@description
Finite State Machine based event handling for DCS World Events

@features
- coverage of all dcs world events
- synchronously triggered events.
- handling of events before and after they are triggered.
- inherited methods from #fsm

@created Feb 13, 2022

]]

handler = {}

--[[ create a new instance of a handler object
- @param #handler self
- @return #handler self
]]
function handler:new()
    local self = util:inheritParent(self, fsm:new())
    self.events = {}
    world.addEventHandler(self)
    return self
end

--[[ handler registration for #group event
- @param #handler self
- @param #group class self
- @param #enum event
- @param #groupName
- @return #handler self
]]
function handler:handleGroupEvent(class, event, groupName)
    if not self.events[event.id] then
        self.events[event.id] = {
            class = class,
            event = event.name,
            id = event.id,
            group = true,
            groupName = groupName
        }
        self:addTransition("*", event.name, "*")
    end
    return self
end

--[[ handler registration for #unit event
- @param #handler self
- @param #unit class self
- @param #enum event
- @param #unitName
- @return #handler self
]]
function handler:handleUnitEvent(class, event, unitName)
    if not self.events[event.id] then
        self.events[event.id] = {
            class = class,
            event = event.name,
            id = event.id,
            unit = true,
            unitName = unitName
        }
        self:addTransition("*", event.name, "*")
    end
    return self
end

--[[ general handler registration for any event
- @param #handler self
- @param #enum event
- @return #handler self
]]
function handler:handleEvent(event)
    if not self.events[event.id] then
        self.events[event.id] = {
            class = self,
            event = event.name,
            id = event.id
        }
        self:addTransition("*", event.name, "*")
    end
    return self
end

--[[ unhandle any registered event
- @param #handler self
- @param #enum event
- @return #handler self
]]
function handler:unhandleEvent(event)
    if self.events[event.id] then
        self.events[event.id] = nil
    end
    return self
end

--[[ the dcs onEvent function where mass data collection takes place for any event
- this function should never be called for any reason by users!
- registed events will call the appropriate onAfterXx automatically for the calling class!
- @param #handler self
- @param #dcsEvent event
- @return none
]]
function handler:onEvent(event)
    local success, err = pcall(function()
        if self.events[event.id] ~= nil and event.id == self.events[event.id].id then
            local _event = self.events[event.id]
            local eventData = {}
            if event.initiator ~= nil then
                local dcsUnit = event.initiator
                eventData.initUnit = dcsUnit
                eventData.initUnitName = dcsUnit:getName()
                eventData.initUnitVec3 = dcsUnit:getPoint()
                if dcsUnit:getGroup() then
                    eventData.initGroup = dcsUnit:getGroup()
                    eventData.initGroupName = dcsUnit:getGroup():getName()
                    eventData.initGroupId = dcsUnit:getGroup():getID()
                end
                eventData.initUnitCoalition = dcsUnit:getCoalition()
                eventData.initUnitCategory = dcsUnit:getDesc().category
                eventData.initUnitTypeName = dcsUnit:getTypeName()
                if dcsUnit:getPlayerName() then
                    eventData.initPlayerUnit = dcsUnit
                    eventData.initPlayerUnitName = dcsUnit:getName()
                    eventData.initPlayerName = dcsUnit:getPlayerName()
                    eventData.initPlayerCategory = dcsUnit:getDesc().category
                    if dcsUnit:getGroup() then
                        eventData.initPlayerGroup = dcsUnit:getGroup()
                        eventData.initPlayerGroupId = dcsUnit:getGroup():getID()
                        eventData.initPlayerGroupName = dcsUnit:getGroup():getName()
                    end
                    eventData.initPlayerCoalition = dcsUnit:getCoalition()
                    eventData.initPlayerUnitTypeName = dcsUnit:getTypeName()
                end
            end
            if event.target ~= nil then
                local dcsUnit = event.target
                eventData.tgtUnit = dcsUnit
                eventData.tgtUnitName = dcsUnit:getName()
                eventData.tgtGroup = dcsUnit:getGroup()
                eventData.tgtGroupName = dcsUnit:getGroup():getName()
                if dcsUnit:getPlayerName() then
                    eventData.tgtPlayerName = dcsUnit:getPlayerName()
                end
            end
            if event.weapon ~= nil then
                local dcsWeapon = event.weapon
                eventData.weapon = dcsWeapon
                eventData.weaponName = dcsWeapon:getName()
                eventData.weaponObjTypeName = dcsWeapon:getTypeName()
            end
            if event.place ~= nil then
                local dcsAirbase = event.place
                eventData.airbase = dcsAirbase
                eventData.airbaseName = dcsAirbase:getName()
                eventData.airbaseCoalition = dcsAirbase:getCoalition()
                eventData.airbaseVec3 = dcsAirbase:getPoint()
            end
            if event.text ~= nil then
                eventData.markId = event.idx
                eventData.markText = event.text
                eventData.markVec3 = event.pos
            end

            -- check if the event is for a group
            if _event.group then
                    -- its for a group, now lets see if its for our group
                if eventData.initGroupName:find(_event.class.groupName) then
                    -- its for our group, now lets return the unit in that group to the onafter/onAfter methods for the requesting class
                    local class = _event.class -- the class that called the handler
                    local eventMethod = _event.event -- the fsm method
                    class[eventMethod](class, eventData) -- call to the fsm event
                end
            elseif _event.unit then -- event is for a unit
                -- lets check to see if it matches our unit name
                if eventData.initUnitName:find(_event.unitName) then
                    -- its for our unit, now lets return the eventData to the onafter/onAfter methods!
                    local class = _event.class -- the class that called the handler
                    local eventMethod = _event.event -- the fsm method
                    class[eventMethod](class, eventData) -- call to the fsm event
                end
            else
                -- not a group or a unit handled event so lets just call an event method
                local class = _event.class -- the class that called the handler
                local eventMethod = _event.event -- the fsm method
                class[eventMethod](class, eventData) -- call to the fsm event
            end
        end
    end)
    if not success then self:error("handler:onEvent(): ERROR IN onEvent : %s", tostring(err)) end
end

--[[

@class #birth

@authors Wizard

@description
the birth class is a wrapper for the DCS SSE API coalition.addGroup, providing the ability to birth unlimited groups
dynamically from singular templates set to be late activated via the mission editor. These templates will carry over
all the data related to it, including individual units/payloads/liveries/routes/tasks/etc. These templates can be
changed further by the methods provided in the class. with methods such as birthFromAirbase you can alter which
airbase an AI Aircraft will be born at along with unique parking spots and takeoff methods without even having
the template placed there.

@features
- birth unlimted groups from a single late activated template group
- birth a group with a unique alias
- birth a group keeping the orignal group and unit names
- birth new groups on a repeating schedule
- birth from the original late activated group template
- birth from a vec3 point on the map
- birth from airbases at specific parking spots and taking off hot, cold, air, or from the runway
- birth from a circle or quad trigger zone
- automated rebirth on crashing, dying, landing, or shutting down engines
- birth group methods to return the current groups status
- inherited methods from #handler & #group

@created Jan 30, 2022

]]

birth = {}
birth.takeoff = {
    ["runway"] = {name = "Takeoff from runway",      type = "TakeOff",           action = "From Runway"},
    ["hot"]    = {name = "Takeoff from parking hot", type = "TakeOffParkingHot", action = "From Parking Area Hot"},
    ["cold"]   = {name = "Takeoff from parking",     type = "TakeOffParking",    action = "From Parking Area"},
    ["air"]    = {name = "Turning point",            type = "Turning Point",     action = "Turning Point" }
}

--[[ create a new instance of a birth object
- @param #birth self
- @param #string groupName [the late activated template groups name]
- @return #birth self
]]

function birth:new(groupName)
    local self = util:inheritParents(self, {base:new(), handler:new()})
    local template = databases:getGroupObject(groupName)
    if not template then
        self:error("birth:new(): group %s cannot be found in the database", groupName)
        return self
    end
    self.templateName = groupName
    self.template = template
    self.countryId = self.template.countryId
    self.category = self.template.category
    self.coalition = self.template.coalition
    self.count = 0

    self.keepGroupName = nil
    self.keepUnitNames = nil
    self.alias = nil
    self.groupLimit = nil
    self.unitLimit = nil
    self.groupName = nil

    self.template.countryId = nil
    self.template.category = nil
    self.template.coalition = nil

    self.bornGroups = {}
    self.bornUnits = {}

    return self
end

function birth:handleEvent(event)
    self:debug("birth:handleEvent(): handling event %s", event.name)
    self:handleGroupEvent(self, event, self.alias or self.templateName)
    return self
end

function birth:keepName(keepGroupName, keepUnitNames)
    self.keepGroupName = keepGroupName
    self.keepUnitNames = keepUnitNames
    return self
end

function birth:setAlias(alias)
    self.alias = alias
    return self
end

function birth:setLimit(groupLimit, unitLimit)
    self.groupLimit = groupLimit
    self.unitLimit = unitLimit
    return self
end

function birth:setPayload(unitId, unitName)
    if not databases.payloadsByUnitName[unitName] then self:error("birth:setPayload(): could not find %s in database", unitName) return end
    local unitPayload = util:deepCopy(databases.payloadsByUnitName[unitName])
    self.template.units[unitId].payload = unitPayload
    return self
end

function birth:setLivery(unitId, unitName)
    if not databases.liverysByUnitName[unitName] then self:error("birth:setLivery(): could not find %s in database", unitName) return end
    local unitLivery = util:deepCopy(databases.liverysByUnitName[unitName])
    self.template.units[unitId].livery_id = unitLivery
    return self
end

function birth:setCountry(countryName)
    if not country.id[countryName] then self:error("birth:setCountry(): couldnt find country.id.%s", countryName) return end
    self.countryId = country.id[countryName]
    return self
end

function birth:birth()
    self:debug("birth:birth(): preparing template %s for birth", self.templateName)
    self:_initialize()
    return self
end

function birth:birthScheduled(scheduleTime)
    self:debug("birth:birthScheduled(): preparing template %s for birth on a scheduler", self.templateName)
    self.scheduleTime = scheduleTime
    self:_initialize()
    return self
end

function birth:birthFromVec3(vec3, alt)
    self:debug("birth:birthFromVec3(): preparing template %s for birth from a vec3", self.templateName)
    if self.category == Group.Category.GROUND or self.category == Group.Category.TRIAN then
        alt = land.getHeight({["x"] = vec3.x, ["y"] = vec3.z})
    elseif self.category == Group.Category.SHIP then
        alt = 0
    elseif self.category == Group.Category.AIRPLANE or self.category == Group.Category.HELICOPTER then
        if not alt then
            self:error("birth:birthFromVec3(): %s requires an altitude to be born from a vec3", self.templateName)
            return self
        end
        alt = alt
    end

    for _, unitData in pairs(self.template.units) do
        local sX = unitData.x or 0
        local sY = unitData.y  or 0
        local bX = self.template.route.points[1].x
        local bY = self.template.route.points[1].y
        local tX = vec3.x + (sX - bX)
        local tY = vec3.z + (sY - bY)
        unitData.alt = alt
        unitData.x = tX
        unitData.y = tY
    end

    self.template.route.points[1].alt = alt
    self.template.route.points[1].x = vec3.x
    self.template.route.points[1].y = vec3.z

    self:_initialize()
    return self
end

function birth:_updateActiveGroups()
    self:debug("birth:_updateActiveGroups(): updating active groups for template %s", self.templateName)
    self.activeGroups = {}
    for _, groupName in pairs(self.bornGroups) do
        if group:getByName(groupName) then
            if group:getByName(groupName):isAlive() then
                self.activeGroups[#self.activeGroups+1] = groupName
            else
                self:debug("birth:_updateActiveGroups(): group %s not alive", groupName)
            end
        else
            self:debug("birth:_updateActiveGroups(): cant find group %s in database?", groupName)
        end
    end
    return self
end

function birth:_updateActiveUnits()
    self:debug("birth:_updateActiveUnits(): updating active units for template %s", self.templateName)
    self.activeUnits = {}
    for _, unitName in pairs(self.bornUnits) do
        if unit:getByName(unitName) then
            if unit:getByName(unitName):isAlive() then
                self.activeUnits[#self.activeUnits+1] = unitName
            else
                self:debug("birth:_updateActiveUnits(): unit %s not alive", unitName)
            end
        else
            self:debug("birth:_updateActiveUnits(): cant find unit %s in database?", unitName)
        end
    end
    return self
end

function birth:_witihinGroupLimit()
    self:debug("birth:_witihinGroupLimit(): comparing active groups against the groupLimit for template %s", self.templateName)
    self:_updateActiveGroups()
    if #self.activeGroups < self.groupLimit then
        self:debug("birth:_witihinGroupLimit(): returning true, template %s has less active groups than the groupLimit", self.templateName)
        return true
    end
    self:debug("birth:_witihinGroupLimit(): returning false, template %s active groups are greater than or equal to the groupLimit", self.templateName)
    return false
end

function birth:_withinUnitLimit()
    self:debug("birth:_withinUnitLimit(): comparing active units against the unitLimit for template %s", self.templateName)
    self:_updateActiveUnits()
    if #self.activeUnits + #self.template.units <= self.unitLimit then
        self:debug("birth:_withinUnitLimit(): returning true, template %s has less active units than the unitLimit", self.templateName)
        return true
    end
    self:debug("birth:_withinUnitLimit(): returning false, template %s active units are greater than or equal to the unitLimit", self.templateName)
    return false
end

function birth:_initialize()
    self:debug("birth:_initialize(): initializing template %s", self.templateName)
    if not self.groupLimit and not self.unitLimit then
        -- not group limit and not unit limit
        self:_addGroup()
        return self
    elseif self.groupLimit and self.unitLimit then
        if self:_witihinGroupLimit() and self:_withinUnitLimit() then
            self:_addGroup()
            return self
        end
    elseif self.groupLimit and not self.unitLimit then
        if self:_witihinGroupLimit() then
            self:_addGroup()
            return self
        end
    elseif not self.groupLimit and self.unitLimit then
        if self:_withinUnitLimit() then
            self:_addGroup()
            return self
        end
    end
end

function birth:_addGroup()
    self:debug("birth:_addGroup(): adding template %s into the world", self.templateName)
    if self.schedulerId then self.schedulerId = nil end
    if not self.keepGroupName then
        if self.alias then
            self.groupName = self.alias
            self.template.name = self.groupName
        else
            self.groupName = self.template.name.." #"..self.count + 1
            self.template.name = self.groupName
        end
    end
    if not self.keepUnitNames then
        for unitId = 1, #self.template.units do
            self.template.units[unitId].name = self.template.name.."-"..unitId
        end
    end
    if self.template.lateActivation then
        self.template.lateActivation = false
    end
    coalition.addGroup(self.countryId, self.category, self.template)
    self.count = self.count + 1
    self.bornGroups[#self.bornGroups+1] = self.groupName
    databases:addObjectToDatabase("groupsByName", self.template)
    for _, unitData in pairs(self.template.units) do
        self.bornUnits[#self.bornUnits+1] = unitData.name
        databases:addObjectToDatabase("unitsByName", unitData)
        if unitData.payload then
            databases:addObjectToDatabase("payloadsByUnitName", unitData)
        end
        if unitData.livery_id then
            databases:addObjectToDatabase("liverysByUnitName", unitData)
        end
    end
    if self.scheduleTime then
        local scheduleBirth = scheduler:new(birth.initialize, self, self.scheduleTime)
        self.schedulerId = scheduleBirth.functionId
    end
    self:debug("birth:_addGroup(): %s has been born into the world", self.groupName)
    return self
end

--
--
-- ** classes : wrapper **
--
--

object = {}

function object:getByName(objectName)
    local self = util:inheritParent(self, base:new())
    local object = databases:getObject(objectName)
    if not object then
        self:error("object:new(): object %s could not be found in the database", objectName)
        return self
    end
    self.objectName = objectName
    self.object = object
    return self
end

function object:getCoalition()
    return self.object.coalitionId, self.object.coalitionName
end

function object:getCountry()
    return self.object.countryId, self.object.countryName
end

function object:getCategory()
    return self.object.categoryId
end

function object:getName()
    return self.objectName
end

function object:isExist()
    local dcsObject = self:getDCSObject()
    if dcsObject then
        return Object.isExist(dcsObject)
    end
end

function object:destroy()
    local dcsObject = self:getDCSObject()
    if dcsObject then
        return Object.destroy(dcsObject)
    end
end

function object:getTypeName()
    local dcsObject = self:getDCSObject()
    if dcsObject then
        return Object.getTypeName(dcsObject)
    end
end

function object:getDesc()
    local dcsObject = self:getDCSObject()
    if dcsObject then
        return Object.getDesc(dcsObject)
    end
end

function object:hasAttribute(attribute)
    local dcsObject = self:getDCSObject()
    if dcsObject then
        return Object.hasAttribute(attribute)
    end
end

function object:getPoint()
    local dcsObject = self:getDCSObject()
    if dcsObject then
        return Object.getPoint(dcsObject)
    end
end

function object:getPosition()
    local dcsObject = self:getDCSObject()
    if dcsObject then
        return Object.getPosition(dcsObject)
    end
end

function object:getVelocity()
    local dcsObject = self:getDCSObject()
    if dcsObject then
        return Object.getVelocity(dcsObject)
    end
end

function object:inAir()
    local dcsObject = self:getDCSObject()
    if dcsObject then
        return Object.inAir(dcsObject)
    end
end

scenery = {}

function scenery:getByName(sceneryName)
    local self = util:inheritParents(self, {base:new(), handler:new(), object})
    self.sceneryName = sceneryName
    self.dcsObject = {id_ = sceneryName}
    return self
end

function scenery:getDescByName()
    t = SceneryObject
    local typeName = SceneryObject.getTypeName(self.dcsObject)
    if typeName then
        local desc = SceneryObject.getDescByName(typeName)
        if desc then
            return desc
        end
    end
end

function scenery:getDCSObject()
    return self.dcsObject
end

function scenery:getLife()
    return SceneryObject.getLife(self.dcsObject)
end

function scenery:getCategory()
    return self:getDesc().category
end

function scenery:getName()
    return self.sceneryName
end

unit = {}

function unit:getByName(unitName)
    local self = util:inheritParents(self, {object:getByName(unitName), handler:new()})
    if not self.object then
        self:error("unit:getByName(): unit object %s could not be found in the database", unitName)
        return self
    end
    self.unitName = unitName
    return self
end

function unit:getDescByName()
    return Unit.getDescByName(self.object.typeName)
end

function unit:getDCSObject()
    local dcsUnit = Unit.getByName(self.unitName)
    if dcsUnit then
        return dcsUnit
    end
end

airbase = {}

function airbase:getByName(airbaseName)
    local self = util:inheritParents(self, {object:getByName(airbaseName), handler:new()})
    if not self.object then
        self:error("airbase:getByName(): unit object %s could not be found in the database", airbaseName)
        return self
    end
    self.airbaseName = airbaseName
    return self
end

function airbase:getDCSObject()
    local dcsObject = Airbase.getByName(self.airbaseName)
    if dcsObject then
        return dcsObject
    end
end

static = {}

function static:getByName(staticName)
    local self = util:inheritParents(self, {object:getByName(staticName), handler:new()})
    if not self.object then
        self:error("static:getByName(): unit object %s could not be found in the database", staticName)
        return self
    end
    self.staticName = staticName
    return self
end

function static:getDCSObject()
    local dcsObject = StaticObject.getByName(self.staticName)
    if dcsObject then
        return dcsObject
    end
end

group = {}

function group:getByName(groupName)
    local self = util:inheritParents(self, {base:new(), handler:new()})
    local group = databases:getGroupObject(groupName)
    if not group then
        self:error("group:getByName(): unit object %s could not be found in the database", groupName)
        return self
    end
    self.group = group
    self.groupName = groupName
    return self
end

function group:getDCSGroup()
    local dcsGroup = Group.getByName(self.groupName)
    if dcsGroup then
        return dcsGroup
    end
end

-- ** initialization ** --

databases = database:new()
-- optional database registrations
databases:registerPayloads()
databases:registerLiverys()

log.write("ssf.lua", log.INFO, "simple scripting framework successfully loaded version "..ssf.version)