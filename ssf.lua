--[[

@Simple Scripting Framework

@authors Wizard#5064

@description
Simple  Scripting Framework is as the title suggests, is as the title suggests,
a simplified framework comprised of pre-made scripted solutions using Object
Orientated Lua Scripting for DCS World Mission Creators.

@github: https://github.com/Wizxrd/SSF/tree/main

@created Jan 30, 2022

@version 0.0.12

@todo

]]

log.write("ssf.lua", log.INFO, "loading simple scripting framework")

local ssf = {}
ssf.version = "0.0.12"

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

@enum #weapon

@description
constant table of weaponFlags with corresponding values

@features
- coverage of all weapon flags

@created Feb 6, 2022

]]

enum.weapon = {
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

function util:makeVec3(vec, alt)
    if not vec.z then
        if vec.alt and not alt then
            alt = vec.alt
        elseif not alt then
            alt = 0
        end
        return {x = vec.x, y = alt, z = vec.y}
    else
        return {x = vec.x, y = vec.y, z = vec.z}	-- it was already Vec3, actually.
    end
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
base.source = "ssf.lua"
base.level = 5

function base:new()
    local self = util:inheritParent(base, logger:new())
    return self
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
    local self = util:inheritParent(database, base:new())
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
    local self = util:inheritParent(handler, base:new())
    self.events = {}
    world.addEventHandler(self)
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
            name = event.name,
            id = event.id
        }
    end
    return self
end

--[[ handler registration for #group event
- @param #handler self
- @param #group class self
- @param #enum event
- @param #groupName
- @return #handler self
]]
function handler:handleGroupEvent(event, groupName)
    if not self.events[event.id] then
        self.events[event.id] = {
            class = self,
            name = event.name,
            id = event.id,
            group = true,
            groupName = groupName or self.groupName
        }
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
function handler:handleUnitEvent(event, unitName)
    if not self.events[event.id] then
        self.events[event.id] = {
            class = self,
            name = event.name,
            id = event.id,
            unit = true,
            unitName = unitName or self.unitName
        }
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
- @param #handler self
- @param #dcsEvent event
- @return none
]]
function handler:onEvent(dcsEvent)
    local success, err = pcall(function()
        if self.events[dcsEvent.id] ~= nil then
            local event = self.events[dcsEvent.id]
            local eventData = {}
            if dcsEvent.initiator ~= nil then
                local dcsUnit = dcsEvent.initiator
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
            if dcsEvent.target ~= nil then
                local dcsUnit = dcsEvent.target
                eventData.tgtUnit = dcsUnit
                eventData.tgtUnitName = dcsUnit:getName()
                eventData.tgtGroup = dcsUnit:getGroup()
                eventData.tgtGroupName = dcsUnit:getGroup():getName()
                if dcsUnit:getPlayerName() then
                    eventData.tgtPlayerName = dcsUnit:getPlayerName()
                end
            end
            if dcsEvent.weapon ~= nil then
                local dcsWeapon = dcsEvent.weapon
                eventData.weapon = dcsWeapon
                eventData.weaponName = dcsWeapon:getName()
                eventData.weaponObjTypeName = dcsWeapon:getTypeName()
            end
            if dcsEvent.place ~= nil then
                local dcsAirbase = dcsEvent.place
                eventData.airbase = dcsAirbase
                eventData.airbaseName = dcsAirbase:getName()
                eventData.airbaseCoalition = dcsAirbase:getCoalition()
                eventData.airbaseVec3 = dcsAirbase:getPoint()
            end
            if dcsEvent.text ~= nil then
                eventData.markId = dcsEvent.idx
                eventData.markText = dcsEvent.text
                eventData.markVec3 = dcsEvent.pos
            end
            -- check if the event is for a group
            if event.group then
                    -- its for a group, now lets see if its for our group
                if eventData.initGroupName:find(event.groupName) then
                    -- its for our group, now lets return the unit in that group to the onafter/onAfter methods for the requesting class
                    local class = event.class -- the class that called the handler
                    local eventMethod = "onEvent"..event.name
                    class[eventMethod](class, eventData)
                end
            elseif event.unit then -- event is for a unit
                -- lets check to see if it matches our unit name
                env.error(event.unitName)
                if eventData.initUnitName:find(event.unitName) then
                    -- its for our unit, now lets return the eventData to the onafter/onAfter methods!
                    local class = event.class -- the class that called the handler
                    local eventMethod = "onEvent"..event.name
                    class[eventMethod](class, eventData)
                end
            else
                -- not a group or a unit handled event so lets just call an event method
                local class = event.class -- the class that called the handler
                local eventMethod = "onEvent"..event.name
                class[eventMethod](class, eventData)
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
}

--[[ create a new instance of a birth object
- @param #birth self
- @param #string groupName
- @return #birth self
]]

function birth:new(groupName)
    local self = util:inheritParents(self, {base:new(), handler:new()})
    local template = databases:getObject(groupName)
    if not template then
        self:error("birth:new(): group %s cannot be found in the database", groupName)
        return self
    end
    self.templateName = groupName
    self.template = template
    self.countryId = self.template.countryId
    self.categoryId = self.template.categoryId
    self.coalitionId = self.template.coalitionId
    self.count = 0

    self.keepGroupName = nil
    self.keepUnitNames = nil
    self.alias = nil
    self.groupLimit = nil
    self.unitLimit = nil
    self.groupName = nil
    self.payload = nil

    self.template.countryId = nil
    self.template.category = nil
    self.template.coalition = nil

    self.bornGroups = {}
    self.bornUnits = {}
    self.birthTemplate = {}

    return self
end

function birth:handleEvent(event)
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
    self.payload = util:deepCopy(databases.payloadsByUnitName[unitName])
    return self
end

function birth:setLivery(unitId, unitName)
    self.livery = util:deepCopy(databases.liverysByUnitName[unitName])
    return self
end

function birth:setCountry(countryName)
    if country.id[countryName] then
        self.countryId = country.id[countryName]
    end
    return self
end

function birth:birth()
    self.birthTemplate = util:deepCopy(self.template)
    self:_initialize()
    return self
end

function birth:birthScheduled(scheduleTime)
    self.birthTemplate = util:deepCopy(self.template)
    self.scheduleTime = scheduleTime
    self:_initialize()
    return self
end

function birth:birthFromVec3(vec3, alt)
    self:debug("birth:birthFromVec3(): preparing template %s for birth from a vec3", self.templateName)
    self.birthTemplate = util:deepCopy(self.template)
    if self.categoryId == Group.Category.GROUND then
        alt = land.getHeight({["x"] = vec3.x, ["y"] = vec3.z})
    elseif self.categoryId == Group.Category.SHIP then
        alt = 0
    elseif self.categoryId == Group.Category.AIRPLANE or self.categoryId == Group.Category.HELICOPTER then
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

    self.birthTemplate.route.points[1].alt = alt
    self.birthTemplate.route.points[1].x = vec3.x
    self.birthTemplate.route.points[1].y = vec3.z
    self:_initialize()
    return self
end

function birth:birthFromAirbase(airbaseName, takeoffType, parkingSpots)
    self.birthTemplate = util:deepCopy(self.template)
    local birthAirbase = airbase:getByName(airbaseName)
    if birthAirbase then
        local birthAirbaseVec3 = birthAirbase:getPoint()
        local birthAirbaseId = birthAirbase:getID()
        local birthAirbaseCategory = birthAirbase:getCategory()
        local birthWaypoint = self.birthTemplate.route.points[1]
        birthWaypoint.type = takeoffType.type
        birthWaypoint.action = takeoffType.action
        birthWaypoint.x = birthAirbaseVec3.x
        birthWaypoint.y = birthAirbaseVec3.z
        if birthAirbaseCategory == 0 then -- airbases
            birthWaypoint.airdromeId = birthAirbaseId
        elseif birthAirbaseCategory == 1 or birthAirbaseCategory == 2 then -- ships get named with this?
            birthWaypoint.helipadId = birthAirbaseId
        end
        if parkingSpots then
            if birthAirbaseCategory ~= 2 then
                local parkingData = birthAirbase:getTerminalData(parkingSpots)
                birthWaypoint.x = parkingData[1].termVec3.x
                birthWaypoint.y = parkingData[1].termVec3.z
                for unitId, unitData in ipairs(self.birthTemplate.units) do
                    unitData.parking = parkingData[unitId].termIndex
                    unitData.x = parkingData[unitId].termVec3.x
                    unitData.y = parkingData[unitId].termVec3.z
                end
            end
        end
        self:_initialize()
        return self
    end
end

function birth:birthFromZone(zoneName, alt)
    self.birthTemplate = util:deepCopy(self.template)
    local birthZone = zone:getByName(zoneName)
    if birthZone then
        local birthZoneVec3 = birthZone:getVec3()
        if self.categoryId == Group.Category.GROUND then
            alt = land.getHeight({["x"] = birthZoneVec3.x, ["y"] = birthZoneVec3.z})
        elseif self.categoryId == Group.Category.SHIP then
            alt = 0
        elseif self.categoryId == Group.Category.AIRPLANE or self.categoryId == Group.Category.HELICOPTER then
            if not alt then
                self:error("birth:birthFromVec3(): %s requires an altitude to be born from a vec3", self.templateName)
                return self
            end
            alt = alt
        end
        for _, unitData in pairs(self.birthTemplate.units) do
            local sX = unitData.x or 0
            local sY = unitData.y  or 0
            local bX = self.birthTemplate.route.points[1].x
            local bY = self.birthTemplate.route.points[1].y
            local tX = birthZoneVec3.x + (sX - bX)
            local tY = birthZoneVec3.z + (sY - bY)
            unitData.alt = alt
            unitData.x = tX
            unitData.y = tY
        end
        self.birthTemplate.route.points[1].alt = alt
        self.birthTemplate.route.points[1].x = birthZoneVec3.x
        self.birthTemplate.route.points[1].y = birthZoneVec3.z
        self:_initialize()
        return self
    end
end

function birth:_updateActiveGroups()
    self.activeGroups = {}
    for _, groupName in pairs(self.bornGroups) do
        if group:getByName(groupName) then
            if group:getByName(groupName):isAlive() then
                self.activeGroups[#self.activeGroups+1] = groupName
            end
        end
    end
    return self
end

function birth:_updateActiveUnits()
    self.activeUnits = {}
    for _, unitName in pairs(self.bornUnits) do
        if unit:getByName(unitName) then
            if unit:getByName(unitName):isAlive() then
                self.activeUnits[#self.activeUnits+1] = unitName
            end
        end
    end
    return self
end

function birth:_witihinGroupLimit()
    self:_updateActiveGroups()
    if #self.activeGroups < self.groupLimit then
        return true
    end
    return false
end

function birth:_withinUnitLimit()
    self:_updateActiveUnits()
    if #self.activeUnits + #self.template.units <= self.unitLimit then
        return true
    end
    return false
end

function birth:_initialize()
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
    if self.schedulerId then self.schedulerId = nil end
    if not self.keepGroupName then
        if self.alias then
            self.groupName = self.alias
            self.birthTemplate.name = self.groupName
        else
            self.groupName = self.template.name.." #"..self.count + 1
            self.birthTemplate.name = self.groupName
        end
    end
    if not self.keepUnitNames then
        for unitId = 1, #self.template.units do
            self.birthTemplate.units[unitId].name = self.birthTemplate.name.."-"..unitId
        end
    end
    if self.birthTemplate.lateActivation then
        self.birthTemplate.lateActivation = false
    end
    coalition.addGroup(self.countryId, self.categoryId, self.birthTemplate)
    self.count = self.count + 1
    self.bornGroups[#self.bornGroups+1] = self.groupName
    databases:addGroupObject(self.birthTemplate)
    for _, unitData in pairs(self.birthTemplate.units) do
        self.bornUnits[#self.bornUnits+1] = unitData.name
        databases:addUnitObject(unitData)
    end
    if self.scheduleTime then
        local scheduleBirth = scheduler:new(birth.initialize, self, self.scheduleTime)
        self.schedulerId = scheduleBirth.functionId
    end
    self:debug("birth:_addGroup(): %s has been born into the world", self.groupName)
    return self
end

zone = {}

function zone:new(zoneName, vec2, radius, vertices)
    local self = util:inheritParent(self, base:new())
    local zoneType = 0
    if vertices then zoneType = 2 end
    local zone = {
        ["name"] = zoneName,
        ["x"] = vec2.x,
        ["y"] = vec2.y,
        ["radius"] = radius,
        ["type"] = zoneType,
        ["vertices"] = vertices
    }
    databases:addZoneObject(zone)
    self.zone = databases:getZoneObject(zoneName)
    return self
end

function zone:getByName(zoneName)
    local self = util:inheritParent(self, base:new())
    local zone = databases:getZoneObject(zoneName)
    if not zone then
        return self
    end
    self.zone = zone
    return self
end

function zone:getVec2()
    local vec2 = {}
    vec2.x = self.zone.x
    vec2.y = self.zone.y
    return vec2
end

function zone:getVec3()
    local vec3 = {}
    vec3.x = self.zone.x
    vec3.z = self.zone.y
    vec3.y = land.getHeight({x = self.zone.x, y = self.zone.z})
    return vec3
end

function zone:getRadius()
    return self.zone.radius
end

function zone:getID()
    return self.zone.id
end

function zone:getProperties()
    return self.zone.properties
end

function zone:isHidden()
    return self.zone.hidden
end

function zone:getName()
    return self.zone
end

function zone:getType()
    return self.zone.type
end

function zone:pointInCircle(point)
    if self.zone.type == 0 then
        local vec3 = util:makeVec3(point)
        local zoneVec3 = self:getVec3()
        local radius = self.zone.radius
        radius = radius or self.zone.radius
        if ((vec3.x - zoneVec3.x)^2 + (vec3.z - zoneVec3.z)^2)^0.5 <= radius then
            return true
        end
    end
    return false
end

function zone:pointInPolygon(point)
    if self.zone.type == 2 then
        local vec3 = util:makeVec3(point)
        local vx = vec3.x
        local vz = vec3.z
        local count = 0
        local polygon = util:deepCopy(self.zone.vertices)

        polygon[#polygon+1] = polygon[1]
        polygon[1] = util:makeVec3(polygon[1])
        
        for i = 1, #polygon do
            polygon[i+1] = util:makeVec3(polygon[i+ 1])
            if (polygon[i].z <= vz and polygon[i+1].z > vz) or (polygon[i].z > vz and polygon[i+1] <= vz) then
                local vt = (vz - polygon[i].z) / (polygon[i+1].z - polygon[i].z)
                if (vx < polygon[i].x + vt*(polygon[i+1].x - polygon[i].x)) then
                    count = count + 1
                end
            end
        end
        return count%2 == 1
    end
end

--[[

@class #search

@authors Wizard

@description
search for a collection of objects to call functions on as a whole. you must use a searchBy method before using a searchFor method.

@features

@created Apr 5, 2022

]]

search = {}

--[[ create a new instance of a search object
- @param #search self
- @return #search self
]]
function search:new()
    local self = util:inheritParent(self, base:new())
    self.filters = {}
    return self
end

function search:searchBySubString(subString)
    self.subString = subString
    return self
end

function search:searchByPrefix(prefix)
    self.prefix = prefix
    return self
end

function search:searchByField(field, value)
    self.filters[field] = value
    return self
end

function search:searchByCoalition(coalition)
    self.filters.coalitionId = coalition
    return self
end

function search:searchByCategory(category)
    self.filters.categoryId = category
    return self
end

function search:searchByCountry(countryId)
    self.filters.countryId = countryId
    return self
end

function search:searchForUnits()
    local objects = {}
    for unitName, unitData in pairs(databases.unitsByName) do
        local filterHit = true
        if self.subString then
            if not string.find(unitName, self.subString) then
                filterHit = false
            end
        end

        if self.prefix then
            local pfx = string.find(unitName, self.prefix, 1, true)
            if pfx ~= 1 then
                filterHit = false
            end
        end

        for filterType, filterValue in pairs(self.filters) do
            if unitData[filterType] then
                local fieldValue = unitData[filterType]
                if fieldValue ~= filterValue then
                    filterHit = false
                    break
                end
            end
        end

        if filterHit then
            objects[#objects+1] = unit:getByName(unitName)
        end
    end
    return objects
end

function search:searchForStatics()
    local objects = {}
    for staticName, staticData in pairs(databases.staticsByName) do
        local filterHit = true
        if self.subString then
            if not string.find(staticName, self.subString) then
                filterHit = false
            end
        end

        if self.prefix then
            local pfx = string.find(staticName, self.prefix, 1, true)
            if pfx ~= 1 then
                filterHit = false
            end
        end

        for filterType, filterValue in pairs(self.filters) do
            if staticData[filterType] then
                local fieldValue = staticData[filterType]
                if fieldValue ~= filterValue then
                    filterHit = false
                    break
                end
            end
        end

        if filterHit then
            objects[#objects+1] = group:getByName(staticName)
        end
    end
    return objects
end

function search:searchForGroups()
    local objects = {}
    for groupName, groupData in pairs(databases.groupsByName) do
        local filterHit = true
        if self.subString then
            if not string.find(groupName, self.subString) then
                filterHit = false
            end
        end

        if self.prefix then
            local pfx = string.find(groupName, self.prefix, 1, true)
            if pfx ~= 1 then
                filterHit = false
            end
        end

        for filterType, filterValue in pairs(self.filters) do
            if groupData[filterType] then
                local fieldValue = groupData[filterType]
                if fieldValue ~= filterValue then
                    filterHit = false
                    break
                end
            end
        end

        if filterHit then
            objects[#objects+1] = group:getByName(groupName)
        end
    end
    return objects
end

--
--
-- ** classes : wrapper **
--
--

object = {}

function object:getByName(objectName)
    local self = util:inheritParents(self, {base:new(), handler:new()})
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
    local dcsObject = self:getDCSObject()
    if dcsObject then
        return Object.getCategory(dcsObject)
    end
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

unit = {}

function unit:getByName(unitName)
    local self = util:inheritParent(self, object:getByName(unitName))
    if not self.object then
        self:error("unit:getByName(): unit object %s could not be found in the database", unitName)
        return self
    end
    self.unitName = unitName
    return self
end

function unit:handleEvent(event)
    self:handleUnitEvent(event)
    return self
end

function unit:getDCSObject()
    local dcsUnit = Unit.getByName(self.unitName)
    if dcsUnit then
        return dcsUnit
    end
end

function unit:getDCSGroup()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getGroup()
    end
    return nil
end

function unit:getGroup()
    local groupName = self.object.group.name
    return util:deepCopy(group:getByName(groupName))
end

function unit:isAlive()
    local dcsUnit = Unit.getByName(self.unitName)
    if dcsUnit then
        if dcsUnit:isActive() and dcsUnit:isExist() and dcsUnit:getLife() ~= 0 then
            return true
        end
    end
    return false
end

--
-- **dcs unit wrapped methods **--
--

function unit:getDescByName(typeName)
    return Unit.getDescByName(typeName or self.object.typeName)
end

function unit:isActive()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:isActive()
    end
    return nil
end

function unit:getPlayerName()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        local playerName = unit:getPlayerName()
        if playerName then
            return playerName
        end
    end
    return nil
end

function unit:getID()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getID()
    end
    return nil
end

function unit:getNumber()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getNumber()
    end
    return nil
end

function unit:getController()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getController()
    end
    return nil
end

function unit:getCallsign()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getCallsign()
    end
    return nil
end

function unit:getLife()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getLife()
    end
    return nil
end

function unit:getLife0()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getLife0()
    end
    return nil
end

function unit:getFuel()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getFuel()
    end
    return nil
end

function unit:getAmmo()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getAmmo()
    end
    return nil
end

function unit:getSensors()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getSensors()
    end
    return nil
end

function unit:hasSensors()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:hasSensors()
    end
    return nil
end

function unit:getRadar()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getRadar()
    end
    return nil
end

function unit:getDrawArgumentValue()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getDrawArgumentValue()
    end
    return nil
end

function unit:getNearestCargos()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getNearestCargos()
    end
    return nil
end

function unit:enableEmission(bool)
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:enableEmission(bool)
    end
    return nil
end

function unit:getDescentCapacity()
    local dcsUnit = self:getDCSObject()
    if dcsUnit then
        return dcsUnit:getDescentCapacity()
    end
    return nil
end

airbase = {}

function airbase:getByName(airbaseName)
    local self = util:inheritParent(self, object:getByName(airbaseName))
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

function airbase:getTerminalData(parkingSpots)
    local parking = self:getParking()
    if type(parkingSpots) == "number" then
        parkingSpots = {parkingSpots}
    end
    if parking then
        local terminalData = {}
        for _, parkingData in pairs(parking) do
            for _, parkingSpot in pairs(parkingSpots) do
                if parkingData.Term_Index == parkingSpot then
                    terminalData[#terminalData+1] = {
                        ["termIndex"] = parkingSpot,
                        ["termVec3"] = parkingData.vTerminalPos
                    }
                end
            end
        end
        return terminalData
    end
end

--
-- **dcs airbase wrapped methods **--
--

function airbase:getDesc()
    local dcsAirbase = self:getDCSObject()
    if dcsAirbase then
        return dcsAirbase:getDesc()
    end
end

function airbase:getCallsign()
    local dcsAirbase = self:getDCSObject()
    if dcsAirbase then
        return dcsAirbase:getCallsign()
    end
end

function airbase:getDCSUnit()
    local dcsAirbase = self:getDCSObject()
    if dcsAirbase then
        return dcsAirbase:getDCSUnit()
    end
end

function airbase:getID()
    local dcsAirbase = self:getDCSObject()
    if dcsAirbase then
        return dcsAirbase:getID()
    end
end

function airbase:getParking()
    local dcsAirbase = self:getDCSObject()
    if dcsAirbase then
        return dcsAirbase:getParking()
    end
end

function airbase:getRunways()
    local dcsAirbase = self:getDCSObject()
    if dcsAirbase then
        return dcsAirbase:getRunways()
    end
end

function airbase:getTechObjectPos()
    local dcsAirbase = self:getDCSObject()
    if dcsAirbase then
        return dcsAirbase:getTechObjectPos()
    end
end

function airbase:getRadioSilentMode()
    local dcsAirbase = self:getDCSObject()
    if dcsAirbase then
        return dcsAirbase:getRadioSilentMode()
    end
end

function airbase:setRadioSilentMode(silent)
    local dcsAirbase = self:getDCSObject()
    if dcsAirbase then
        return dcsAirbase:setRadioSilentMode(silent or false)
    end
end

static = {}

function static:getByName(staticName)
    local self = util:inheritParent(self, object:getByName(staticName))
    if not self.object then
        self:error("static:getByName(): unit object %s could not be found in the database", staticName)
        return self
    end
    self.staticName = staticName
    return self
end

function static:getDCSObject()
    local dcsStatic = StaticObject.getByName(self.staticName)
    if dcsStatic then
        return dcsStatic
    end
end

function static:isAlive()
    local dcsStatic = self:getDCSObject()
    if dcsStatic then
        if dcsStatic:isExist() and dcsStatic:getLife() ~= 0 then
            return true
        end
    end
    return false
end

function static:getID()
    local dcsStatic = self:getDCSObject()
    if dcsStatic then
        return dcsStatic:getID()
    end
end

function static:getLife()
    local dcsStatic = self:getDCSObject()
    if dcsStatic then
        return dcsStatic:getLife()
    end
end

function static:getCargoDisplayName()
    local dcsStatic = self:getDCSObject()
    if dcsStatic then
        return dcsStatic:getCargoDisplayName()
    end
end

function static:getCargoWeight()
    local dcsStatic = self:getDCSObject()
    if dcsStatic then
        return dcsStatic:getCargoWeight()
    end
end

function static:getDrawArgumentValue()
    local dcsStatic = self:getDCSObject()
    if dcsStatic then
        return dcsStatic:getDrawArgumentValue()
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

function group:isAlive()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        local dcsUnit = self:getUnit(1)
        if dcsUnit then
            if dcsUnit:isActive() and dcsUnit:isExist() and dcsUnit:getLife() ~= 0 then
                return true
            end
        end
    end
    return false
end

function group:isExist()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:isExist()
    end
end

function group:activate()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:activate()
    end
end

function group:activate()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:activate()
    end
end

function group:destroy()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:destroy()
    end
end

function group:getCategory()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getCategory()
    end
end

function group:getCoalition()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getCoalition()
    end
end

function group:getName()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getName()
    end
end

function group:getID()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getID()
    end
end

function group:getUnit(unitId)
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getUnit(unitId)
    end
end

function group:getUnits()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getUnits()
    end
end

function group:getSize()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getSize()
    end
end

function group:getInitialSize()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getInitialSize()
    end
end

function group:getController()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getController()
    end
end

function group:enableEmission()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getController()
    end
end

-- ** initialization ** --

databases = database:new()
-- optional database registrations
databases:registerPayloads()
databases:registerLiverys()

log.write("ssf.lua", log.INFO, "simple scripting framework successfully loaded version "..ssf.version)