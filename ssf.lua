--[[

@Simple Scripting Framework

@authors Wizard#5064

@description
Simple  Scripting Framework is as the title suggests, a simplified framework comprised
of pre-made scripted solutions accomplishing most of the more complex tasks for DCS World Mission
Creators & Designers through simplified Object Orientated Lua Scripting. The classes available in
the framework will allow mission designers & creators to provide dynamic scenarios to their players
with little code written. At its core SSF is meant for all users looking to improve their
mission environments, although there is minimal Lua knowledge required, you do not have to be an
expert to take advantage of the classes within the framework.

@github: https://github.com/Wizxrd/SSF/tree/main

@created Jan 30, 2022

@version 0.1.6

@todo

]]

-- build information
local major   = 0
local minor   = 2
local patch   = 1
local debugger = true

--
--
-- ** local functions ** --
--
--

--[[ send a message to dcs.log under the prefix of "INFO SSF"
- @param #string msg [the message to send]
- @param #args [any arguments to be formatted into the message]
- @return none
]]
local function logInfo(debug, msg,...)
    if debug then
        log.write("SSF", log.INFO, string.format(msg, ...))
    end
end

--[[ send a message to dcs.log under the prefix of "WARNING SSF"
- @param #string msg [the message to send]
- @param #args [any arguments to be formatted into the message]
- @return none
]]
local function logWarning(debug, msg,...)
    if debug then
        log.write("SSF", log.WARNING, string.format(msg, ...))
    end
end

--[[ send a message to dcs.log under the prefix of "ERROR SSF"
- @param #string msg [the message to send]
- @param #args [any arguments to be formatted into the message]
- @return none
]]
local function logError(debug, msg,...)
    if debug then
        log.write("SSF", log.ERROR, string.format(msg, ...))
    end
end

--[[ deep copy a table recursively through all levels of the table.
- this is a mist function reused and can be referenced here: https://wiki.hoggitworld.com/view/MIST_deepCopy
- @param #table object
- @return #table object
]]
local function deepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--
--
-- ** database initialization **
--
--


-- the building blocks
local groupsByName = {}
local unitsByName = {}
local staticsByName = {}
local airbasesByName = {}
local zonesByName = {}
local payloadsByUnitName = {}

do

    local st = false

    if os then
        st = os.clock()
    end

    local categories = {
        ["plane"] = 0,
        ["helicopter"] = 1,
        ["vehicle"] = 2,
        ["ship"] = 3,
    }

    for coaSide, coaData in pairs(env.mission.coalition) do
        if coaSide == "neutrals" then coaSide = "neutral" end
        if type(coaData) == "table" then
            if coaData.country then -- country has data
                for _, ctryData in pairs(coaData.country) do
                    for objType, objData in pairs(ctryData) do
                        if objType == "plane" or objType == "helicopter" or objType == "vehicle" or objType == "ship" then
                            for _, groupData in pairs(objData.group) do
                                if groupData and type(groupData.units) == "table" and #groupData.units > 0 then
                                    local category = categories[objType]
                                    if groupData.lateActivation then
                                        groupData.lateActivation = false
                                    end

                                    groupsByName[groupData.name] = {
                                        ["name"] = groupData.name,
                                        ["task"] = groupData.task,
                                        ["start_time"] = groupData.start_time,
                                        ["hidden"] = groupData.hidden,
                                        ["route"] = groupData.route,
                                        ["uncontrolled"] = groupData.uncontrolled,
                                        ["modulation"] = groupData.modulation,
                                        ["frequency"] = groupData.frequency,
                                        ["communication"] = groupData.communication,
                                        ["visible"] = groupData.visible,
                                        ["units"] = groupData.units,
                                        ["coalition"] = coaSide,
                                        ["countryId"] = ctryData.id,
                                        ["category"] = category or false,
                                    }

                                    for _, unitData in pairs(groupsByName[groupData.name].units) do
                                        unitData.unitId = nil
                                        unitData.coalition = coaSide
                                    end

                                    logInfo(debugger, "group database registered group %s into groupsByName", groupData.name)
                                end
                            end
                        elseif objType == "static" then
                            for _, staticData in pairs(objData.group) do
                                staticsByName[staticData.name] = deepCopy(staticData.units[1])
                                logInfo(debugger, "static database registered static %s into staticsByName", staticData.name)
                            end
                        end
                    end
                end
            end
        end
    end

    for _, airdrome in pairs(world.getAirbases()) do
        local airbaseName = airdrome:getName()
        airbasesByName[airbaseName] = {
            ["name"] = airbaseName,
            ["desc"] = airdrome:getDesc(),
            ["id"] = airdrome:getID(),
            ["point"] = airdrome:getPoint(),
            ["category"] = airdrome:getDesc().category,
        }
        if Airbase.getUnit(airdrome) then
            airbasesByName[airbaseName].unitId = Airbase.getUnit(airdrome):getID()
            logInfo(debugger, "airbase database registered airbase *unit* %s into airbasesByName", airbaseName)
        end
        logInfo(debugger, "airbase database registered airbase unit %s into airbasesByName", airbaseName)
    end

    for _, zones in pairs(env.mission.triggers) do
        for _, zoneData in pairs(zones) do
            zonesByName[zoneData.name] = {
                ["radius"] = zoneData.radius,
                ["zoneId"] = zoneData.zoneId,
                ["color"] =
                {
                    [1] = zoneData.color[1],
                    [2] = zoneData.color[2],
                    [3] = zoneData.color[3],
                    [4] = zoneData.color[4],
                },
                ["properties"] = zoneData.properties,
                ["hidden"] = zoneData.hidden,
                ["y"] = zoneData.y,
                ["x"] = zoneData.x,
                ["name"] = zoneData.name,
                ["type"] = zoneData.type,
            }
            logInfo(debugger, "zone database registered trigger zone %s into zonesByName", zoneData.name)
            if zoneData.type == 2 then
                zonesByName[zoneData.name].verticies = zoneData.verticies
            end
        end
    end

    for _, groupData in pairs(groupsByName) do
        for _, unitData in pairs(groupData.units) do
            if unitData.skill ~= "Client" or unitData.skill ~= "Player" then -- this exception still collects them, it makes no sense
                unitsByName[unitData.name] = {
                    ["name"] = unitData.name,
                    ["type"] = unitData.type,
                    ["x"] = unitData.x,
                    ["y"] = unitData.y,
                    ["alt"] = unitData.alt,
                    ["alt_type"] = unitData.alt_type,
                    ["speed"] = unitData.speed,
                    ["payload"] = unitData.payload,
                    ["callsign"] = unitData.callsign,
                    ["heading"] = unitData.heading,
                    ["playerCanDrive"] = unitData.playerCanDrive,
                    ["skill"] = unitData.skill,
                    ["livery_id"] = unitData.livery_id,
                    ["psi"] = unitData.psi,
                    ["onboard_num"] = unitData.onboard_num,
                    ["ropeLength"] = unitData.ropeLength,
                    ["countryId"] = groupData.countryId,
                    ["coalition"] = groupData.coalition,
                    ["category"] = groupData.category,
                    ["groupName"] = groupData.name
                }
                logInfo(debugger, "unit database registered unit %s into unitsByName", unitData.name)
                if unitData.payload then
                    payloadsByUnitName[unitData.name] = deepCopy(unitData.payload)
                    logInfo(debugger, "payload database registered unit %s into payloadsByUnitName", unitData.name)
                end
            end
        end
    end

    groupsByName = deepCopy(groupsByName)
    unitsByName = deepCopy(unitsByName)
    staticsByName = deepCopy(staticsByName)
    airbasesByName = deepCopy(airbasesByName)
    zonesByName = deepCopy(zonesByName)
	payloadsByUnitName = deepCopy(payloadsByUnitName)

    if st then
        local et = os.clock() - st
        logInfo(debugger, "DATABASE INITIALIZATION COMPLETED AND TOOK %0.4f SECONDS", et)
    else
        logInfo(debugger, "DATABASE INITIALIZATION COMPLETED")
    end
end

--
--
-- ** enumerators **
--
--

--[[

@enum #waypoint

@description
constant table of waypoint options containting the corresponding type and action

@features
- coverage of all waypoint options

@created Feb 6, 2022

]]

waypoint = {
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

weaponFlag = {
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

event = {
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

smoke = {}
smoke.green = 0
smoke.red = 1
smoke.white = 2
smoke.orange = 3
smoke.blue = 4

--
--
-- ** classes : main **
--
--

--[[

@singleton #util

@authors Wizard

@description
useful utility functions that help with logging, messages, conversions, table manipulation, etc.

@features
- info message logging
- warning message logging
- error message logging
- messages to all, a coalition, or a group
- deepCopy objects
- serialize variables into strings
- show tables as messages in game
- class inheritance
- save tables to file
- load tables from file
- scheduled functions

@created Jan 30, 2022

]]

util = {}
util.__index = setmetatable({}, util)

--[[ send a message to dcs.log under the prefix of "INFO SSF"
- @param #boolean debug [if true the logging will execute]
- @param #string msg [the message to send]
- @param #args [any arguments to be formatted into the message]
- @return none
]]
function util:logInfo(debug, msg, ...)
    logInfo(debug, msg, ...)
end

--[[ send a message to dcs.log under the prefix of "WARNING SSF"
- @param #boolean debug [if true the logging will execute]
- @param #string msg [the message to send]
- @param #args [any arguments to be formatted into the message]
- @return none
]]
function util:logWarning(debug, msg, ...)
    logWarning(debug, msg, ...)
end

--[[ send a message to dcs.log under the prefix of "ERROR SSF"
- @param #boolean debug [if true the logging will execute]
- @param #string msg [the message to send]
- @param #args [any arguments to be formatted into the message]
- @return none
]]
function util:logError(debug, msg, ...)
    logError(debug, msg, ...)
end

--[[ send a message to all players
- @param #boolean clearview [if true new messages will over write previously displayed ones]
- @param #number time [the amount of time to display the message]
- @param #string msg [the message to send]
- @param #args [any arguments to be formatted into the message]
- @return none
]]
function util:messageToAll(clearview, time, msg, ...)
    trigger.action.outText(string.format(msg,...), time, clearview)
end

--[[ send a message to players of a specific coalition
- @param #boolean clearview [if true new messages will over write previously displayed ones]
- @param #number time [the amount of time to display the message]
- @param #enum coalition [the coalition the message will be displayed for, eg: coalition.side.RED]
- @param #string msg [the message to send]
- @param #args [any arguments to be formatted into the message]
- @return none
]]
function util:messageToCoalition(clearview, time, coalition, msg, ...)
    trigger.action.outTextForCoalition(coalition, string.format(msg,...), time, clearview)
end

--[[ send a message to players of a specific group
- @param #boolean clearview [if true new messages will over write previously displayed ones]
- @param #number time [the amount of time to display the message]
- @param #number groupId [the groupId the message will be displayed for]
- @param #string msg [the message to send]
- @param #args [any arguments to be formatted into the message]
- @return none
]]
function util:messageToGroup(clearview, time, groupId, msg, ...)
    trigger.action.outTextForGroup(groupId, string.format(msg,...), time, clearview)
end

--[[ return the current time of the mission in seconds to 3 decimal places
- accounts for time passed even when the mission is paused
- @param none
- @return #number time
]]
function util:getSimTime()
    return timer.getTime()
end

--[[ schedule a function to be ran at a later time in seconds
- @param #function f [the function to be ran]
- @param #table args [the args if any, to be passed to the function]
- @param #number time [the time in seconds for the next time to run the function]
- @return #number schedulerId [the function id of the running scheduler]
]]
function util:scheduleFunction(func, args, time)
    return timer.scheduleFunction(func, args or nil, util:getSimTime() + (time or 0))
end

--[[ remove a scheduled function by it
- @param #function f [the function to be ran]
- @return #number schedulerId [the function id of the removed scheduler]
]]
function util:removeFunction(funcId)
    return timer.removeFunction(funcId)
end

--[[ inherit the methods from one class to another
- @param #table child [the child, the class to be inherited to]
- @param #table parent [the parent, the class to be inherited from]
- @return #table Child [the child with inheritance from the parent]
]]
function util:inherit(child, parent)
    local Child = util:deepCopy(child)
    setmetatable(Child, {__index = parent})
    return Child
end

--[[ return the parent object ]]
function util:getParents(key, parents)
    for i = 1, #parents do
        if parents[i][key] then
            return parents[i][key]
        end
    end
end

function util:inheritParents(child, parents)
    local Child = util:deepCopy(child)
    local Parents = {
        __index = function(self, key)
            return util:getParents(key, parents)
        end
    }
    setmetatable(Child, Parents)
    return Child
end

--[[ deep copy a table recursively through all levels of the table.
- this is a mist function reused and can be referenced here: https://wiki.hoggitworld.com/view/MIST_deepCopy
- @param #table object
- @return #table object
]]
function util:deepCopy(object)
    return deepCopy(object)
end

--[[ returns the string value of a variable
- this is a mist function reused and can be referenced here: https://wiki.hoggitworld.com/view/MIST_basicSerialize
- @param #any var
- @return #any var
]]
function util:basicSerialize(var)
    if var == nil then
        return "\"\""
    else
        if ((type(var) == 'number') or (type(var) == 'boolean') or (type(var) == 'function') or (type(var) == 'table') or (type(var) == 'userdata')) then
            return tostring(var)
        elseif type(var) == 'string' then
            var = string.format('%q', var)
            return var
        end
    end
end

--[[ return a table non-serialized table made into a string for saving or printing
- @param #table tbl [the table to show]
- @return #string tableString [the table formated to a string]
]]
function util:tableWriteStr(tableName, tbl)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = tableName.." = {\n"

    while true do
        local size = 0
        for k,v in pairs(tbl) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(tbl) do
            if (cache[tbl] == nil) or (cur_index >= cache[tbl]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = '["'..tostring(k)..'"]'
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,tbl)
                    table.insert(stack,v)
                    cache[tbl] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. ' = "'..tostring(v)..'"'
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            tbl = stack[#stack]
            stack[#stack] = nil
            depth = cache[tbl] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    local tableEmpty = true

    for _ in pairs(tbl) do
        tableEmpty = false
        break
    end

    if tableEmpty then
        output_str = tableName.." = {}"
    end

    return output_str
end

--[[ return a boolean if a string is empty
- @param #string str
- @return #boolean [true if string is empty]
]]
function string.empty(str)
    if str == "" then
        return true
    end
    return false
end

function util:fileExist(pathToFile)
    if lfs.attributes(lfs.writedir() .. pathToFile) then
        return true
    end
    return false
end

--[[ write a table to a lua file inside Saved Games/DCS/
- @param #string file
- @param #table _table
- @param #boolean overwrite [overwrites the file with the new table]
]]
function util:tableSave(path, fileName, _table, overwrite)
    if overwrite then
        io.open(lfs.writedir() .. path .."\\" .. fileName .. ".lua", "w"):close()
    end
    local File = io.open(lfs.writedir() .. path.. "\\" .. fileName ..".lua", "all")
    File:write(util:tableWriteStr(fileName, _table))
    File:close()
end

--[[ load a file from inside Saved Games/DCS/
- @param #string file
]]
function util:loadFile(file)
    loadfile(lfs.writedir() .. file)()
end

--[[ round number to a specific decimal place
- @param #number num
- @param #number idp
- @return #number roundedNum
]]
function util:round(num, idp)
    local mult = 10^(idp or 0)
    local roundedNum = math.floor(num * mult + 0.5) / mult
    return roundedNum
end

--[[ returns the point projected from the passed point at the passed distance along a given angle
- @param #table point
- @param #number dist
- @param #number theta
- @return #table newPoint
]]
function util:projectPoint(point, dist, theta)
    local newPoint = {}
    if point.z then
        newPoint.z = util:round(math.sin(theta) * dist + point.z, 3)
        newPoint.y = util:deepCopy(point.y)
    else
        newPoint.y = util:round(math.sin(theta) * dist + point.y, 3)
    end
    newPoint.x = util:round(math.cos(theta) * dist + point.x, 3)
    return newPoint
end

--[[ return the 2D distance between two points in meters
- @param #table fromVec3
- @param #table toVec3
- @return #number distance
]]
function util:getDistance(fromVec3, toVec3)
    local dx = toVec3.x - fromVec3.x
    local dy = toVec3.z - fromVec3.z
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance
end

--[[ return the velocity of a unit in meters per second
- @param DCS#Unit [the DCS Unit Object to return the velocity for]
- @return #number velocityMPS
]]
function util:getVelocityMPS(unit)
    local velocityVec3 = unit:getVelocity()
    local velocityMPS = (velocityVec3.x^2 + velocityVec3.y^2 + velocityVec3.z^2)^0.5
    return velocityMPS
end

--[[ return the velocity of a unit in kilometers per hour
- @param DCS#Unit [the DCS Unit Object to return the velocity for]
- @return #number velocityKMH
]]
function util:getVelocityKMH(unit)
    local velocityMPS = util:getVelocityMPS(unit)
    local velocityKMH = velocityMPS * 3.6
    return velocityKMH
end

--[[ return the velocity of a unit in miles per hour
- @param DCS#Unit [the DCS Unit Object to return the velocity for]
- @return #number velocityMPH
]]
function util:getVelocityMPH(unit)
    local velocityMPS = util:getVelocityMPS(unit)
    local velocityMPH = velocityMPS * 2.237
    return velocityMPH
end

--[[ returns free (available) parking spot data from an airbase including the parking spot ID & vec3 point
- @param #util self
- @param #string airbaseName [the airbase name to get parking spots from]
- @param #array parkingSpots [the parking spots to check for]
- @return #array freeParking [the free parking spots]
]]
function util:getParkingData(airbaseName, parkingSpots)
    if Airbase.getByName(airbaseName) then
        local freeParking = {}
        local airbase = Airbase.getByName(airbaseName)
        for _, parkingData in pairs(Airbase.getParking(airbase)) do
            for _, parkingSpot in pairs(parkingSpots) do
                if not parkingData.TO_AC then
                    if parkingData.Term_Index == parkingSpot then
                        freeParking[#freeParking+1] = {
                            ["termIndex"] = parkingSpot,
                            ["termVec3"] = parkingData.vTerminalPos
                        }
                    end
                end
            end
        end
        return freeParking
    end
end

--[[ mark all the parking spots for an airbase
- @param #string airbaseName [the airbase to mark the parking spots for
- @return none
]]
function util:markParkingSpots(airbaseName)
    if Airbase.getByName(airbaseName) then
        local airbase = Airbase.getByName(airbaseName)
        for parkingId, parkingData in pairs(Airbase.getParking(airbase)) do
            local spotOpen
            if parkingData.TO_AC == false then
                spotOpen = "true"
            else
                spotOpen = "false"
            end
            trigger.action.markToAll(parkingId, string.format("Term_Index = %d | Open = %s", parkingData.Term_Index, spotOpen), parkingData.vTerminalPos)
        end
    end
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
    local self = util:inherit(self, fsm)
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
            env.info("Error in SCHEDULER function:" .. errmsg)
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
                    CallID = util:scheduleFunction(fsm._handler, {self, EventName, ...}, DelaySeconds or 1)
                    self._EventSchedules[EventName] = CallID
                end
            else
                CallID = util:scheduleFunction(fsm._handler, {self, EventName, ...}, DelaySeconds or 1)
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
handler.debug = true

--[[ create a new instance of a handler object
- @param #handler self
- @return #handler self
]]
function handler:new()
    local self = util:inherit(self, fsm:new())
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
function handler:onGroupEvent(class, event, groupName)
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
function handler:onUnitEvent(class, event, unitName)
    if not self.events[event.id] then
        self.events[event.id] = {
            class = class,
            event = event.name,
            id = event.id,
            unit = true,
            unitName = unitName
        }
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
        --util:logInfo(self.debug, "event %s is now handled", event.name)
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
        --util:logInfo(self.debug, "event %s is now unhandled", event.text)
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
                eventData.initUnit = event.initiator
                eventData.initUnitName = event.initiator:getName()
                eventData.initUnitVec3 = event.initiator:getPoint()
                if event.initiator:getGroup() then
                    eventData.initGroup = event.initiator:getGroup()
                    eventData.initGroupName = event.initiator:getGroup():getName()
                    eventData.initGroupId = event.initiator:getGroup():getID()
                end
                eventData.initUnitCoalition = event.initiator:getCoalition()
                eventData.initUnitCategory = event.initiator:getDesc().category
                eventData.initUnitTypeName = event.initiator:getTypeName()
                if event.initiator:getPlayerName() then
                    eventData.initPlayerUnit = event.initiator
                    eventData.initPlayerUnitName = event.initiator:getName()
                    eventData.initPlayerName = event.initiator:getPlayerName()
                    eventData.initPlayerCategory = event.initiator:getDesc().category
                    if event.initiator:getGroup() then
                        eventData.initPlayerGroup = event.initiator:getGroup()
                        eventData.initPlayerGroupId = event.initiator:getGroup():getID()
                        eventData.initPlayerGroupName = event.initiator:getGroup():getName()
                    end
                    eventData.initPlayerCoalition = event.initiator:getCoalition()
                    eventData.initPlayerUnitTypeName = event.initiator:getTypeName()
                end
            end
            if event.target ~= nil then
                eventData.tgtUnit = event.target
                eventData.tgtUnitName = event.target:getName()
                eventData.tgtGroup = event.target:getGroup()
                eventData.tgtGroupName = event.target:getGroup():getName()
                if event.target:getPlayerName() then
                    eventData.tgtPlayerName = event.target:getPlayerName()
                end
            end
            if event.weapon ~= nil then
                eventData.weapon = event.weapon
                eventData.weaponObjTypeName = event.weapon:getTypeName()
            end
            if event.place ~= nil then
                eventData.place = event.place
                eventData.placeName = event.place:getName()
            end
            if event.text ~= nil then
                eventData.markId = event.idx
                eventData.markText = event.text
                eventData.markVec3 = event.pos
            end

            -- check if the event is for a group
            if _event.group then
                    -- its for a group, now lets see if its for our group
                if eventData.initGroupName == _event.class.groupName then
                    -- its for our group, now lets return the unit in that group to the onafter/onAfter methods for the requesting class
                    local class = _event.class -- the class that called the handler
                    local eventMethod = _event.event -- the fsm method
                    class[eventMethod](class, eventData) -- call to the fsm event
                end
            elseif _event.unit then -- event is for a unit
                -- lets check to see if it matches our unit name
                if eventData.initUnitName == _event.unitName then
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
    if not success then util:logError(self.debug, "ERROR IN onEvent : %s", tostring(err)) end
end

--[[

@class #birth

@authors Wizard

@description
the birth class is a wrapper for the DCS SSE API coalition.addGroup, providing the ability to birth unlimited groups
dynamically from singular templates set to be late activated via the mission editor. These templates will carry over
all the data related to it, including individual units/payloads/liveries/routes/tasks/etc. These templates can be
changed further by the methods provided in the class, with methods such as birthFromAirbase you can alter which
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
birth.debug = true
birth.takeoff = {
    ["runway"] = {name = "Takeoff from runway",type = "TakeOff", action = "From Runway"},
    ["hot"] = {name = "Takeoff from parking hot", type = "TakeOffParkingHot", action = "From Parking Area Hot"},
    ["cold"] = {name = "Takeoff from parking",     type = "TakeOffParking",    action = "From Parking Area"},
    ["air"] = {name = "Turning point", type = "Turning Point", action = "Turning Point" }
}

--[[ create a new instance of a birth object
- @param #birth self
- @param #string groupName [the late activated template groups name]
- @return #birth self
]]
function birth:new(groupName)
    if groupsByName[groupName] then
        local self = util:inheritParents(self, {handler:new(), group})
        self.templateName = groupName
        self.groupName = groupName
        self._template = util:deepCopy(groupsByName[groupName])
        self.birthTemplate = util:deepCopy(self._template)
        self.groupTemplate = nil
        self.countryId = self.birthTemplate.countryId
        self.category = self.birthTemplate.category
        self.coalition = self.birthTemplate.coalition
        self.keepNames = nil
        self.birthCount = 0
        self.limitEnabled = nil
        self.activeGroupLimit = 0
        self.scheduledBirth = nil
        self.scheduleTime = nil
        self.alias = nil
        self.dcsBirthGroup = nil

        self.activeGroups = {} -- every born group by name
        self.bornGroups = {}

        --[[removal from the template
        self.birthTemplate.countryId = nil
        self.birthTemplate.category = nil
        self.birthTemplate.coalition = nil
        ]]
        return self
    end
end

--[[ register the birth object to a specific event
- @param #birth self
- @param #enum event
- return #birth self]]
function birth:handleEvent(event)
    self:onGroupEvent(self, event, self.groupName or self.alias)
    return self
end

--[[ keep the group and unit template names for the birth object
- @param #birth self
- @param #boolean enabled [if true, keep the late activated template groups name, default: false]
- @return #birth self
]]
function birth:keepTemplateName(enabled)
    if enabled then
        self.keepNames = true
        self.groupName = self.templateName
    else
        self.keepNames = false
    end
    return self
end

--[[ set the group name alias for a birth object
- units will have a "-" after the group name followed by each units Id as seen in game
- eg:
a set alias: "CAP F-16"
units followed: CAP F-16-1", "CAP F-16-2" etc
- @param #birth self
- @param #string alias [the new group name of the birth object]
- @return #birth self
]]
function birth:setAlias(alias)
    self.alias = alias
    return self
end

--[[ set a limit for how many groups can be alive at any given time
- @param #birth self
- @param #number maxLimit [the maximum amount of groups that can be alive at any given time]
- @return #birth self
]]
function birth:limitActiveGroups(maxLimit)
    self.limitEnabled = true
    self.activeGroupLimit = maxLimit
    return self
end

--[[ set the payload for a specifc unit within the birth group
- note: this function can only be used before a birth object has been born. if it happens to be reborn the payload will be loaded at that point.
- @param #birth self
- @param #number unitId [the unitId within the group to set the payload for]
- @param #string unitName [the unit name to obtain the payload from]
- @return #birth self
]]
function birth:setPayload(unitId, unitName)
    local _unit = unit:getByName(unitName)
    if _unit ~= nil then
        local payload = _unit:getPayload()
        self.birthTemplate.units[unitId].payload = payload
    end
    return self
end

--[[ set the livery for a specifc unit within the birth group
- note: this function can only be used before a birth object has been born. if it happens to be reborn the livery will be loaded at that point.
- @param #birth self
- @param #number unitId [the unitId within the group to set the livery for]
- @param #string unitName [the unit name to obtain the livery from]
- @return #birth self
]]
function birth:setLivery(unitId, unitName)
    local _unit = unit:getByName(unitName)
    if _unit ~= nil then
        local livery = _unit:getLivery()
        self.birthTemplate.units[unitId].livery_id = livery
    end
    return self
end

--[[ set the country of the birth group
- @param #birth self
- @param #string countryName
]]
function birth:setCountry(countryName)
    if country.id.countryName then
        self.countryId = country.id.countryName
    end
    return self
end

--[[ set a units heading in degrees
- @param #birth self
- @param #number unitId [the unitId within the group to set the heading for]
- @param #number heading [the heading to set in degrees]
- @return #birth self
]]
function birth:setHeading(unitId, heading)
    if self.birthTemplate.units[unitId] then
        self.birthTemplate.units[unitId].heading = heading * math.pi/180
    end
    return self
end

--[[ birth the object to the world from its orignal template
- @param #birth self
- @return #birth self
]]
function birth:birthToWorld()
    self:_initializeGroup()
    return self
end

--[[ set the birth object to have a scheduled birth
- @param #birth self
- @param #number scheduleTime [the time in seconds for which a new group will be born]
- @return #birth self
]]
function birth:birthScheduled(scheduleTime)
    self.scheduledBirth = true
    self.scheduleTime = scheduleTime
    return self
end

--[[ rebirth the birth object immediatley
- @param #birth self
- @return #birth self
]]
function birth:rebirth()
    self:birthToWorld()
    return self
end

--[[ birth the object from a vec3 point located on the map
- @param #birth self
- @param #table vec3 [table of vec3 points to be born at]
- @return #birth self
]]
function birth:birthFromVec3(vec3, alt)
    local _alt
    if self.category == Group.Category.GROUND or self.category == Group.Category.TRIAN then
        _alt = land.getHeight({["x"] = vec3.x, ["y"] = vec3.z})
    elseif self.category == Group.Category.SHIP then
        _alt = 0
    elseif self.category == Group.Category.AIRPLANE then
        _alt = alt
    end
    for unitId, unitData in pairs(self.birthTemplate.units) do
        local sX = unitData.x or 0
        local sY = unitData.y  or 0
        local bX = self.birthTemplate.route.points[1].x
        local bY = self.birthTemplate.route.points[1].y
        local tX = vec3.x + (sX - bX)
        local tY = vec3.z + (sY - bY)
        if alt then
            unitData.alt = _alt
        else
            unitData.alt = tY
        end
        unitData.x = tX
        unitData.y = tY
    end
    self.birthTemplate.route.points[1].alt = _alt
    self.birthTemplate.route.points[1].x = vec3.x
    self.birthTemplate.route.points[1].y = vec3.z

    self:_initializeGroup()
    return self
end

--[[ birth the object from an airbase
- this function can only be used on aircraft
- @param #birth self
- @param #string airbaseName [the airbase name to be born from]
- @param #array parkingSpots [the parking spots to be born at]
- @param #enum takeoffType [the takeoff type to be born with. options are: runway, hot, cold, air]
- @return #birth self
]]
function birth:birthFromAirbase(airbaseName, parkingSpots, takeoffType)
    local noSetSpots = false
    local birthAirbase = Airbase.getByName(airbaseName)
    if birthAirbase ~= nil then
        local birthAirbaseCategory = Airbase.getDesc(birthAirbase).category
        local birthAirbaseVec3 = Airbase.getPoint(birthAirbase)
        if type(parkingSpots) ~= "table" and type(parkingSpots) == "number" then
            parkingSpots = {parkingSpots}
        elseif type(parkingSpots) == "nil" or type(parkingSpots) == "boolean" then
            noSetSpots = true
        end
        if not noSetSpots then
            if parkingSpots and birthAirbaseCategory == 2 then
                util:logError(self.debug, "%s is unable to set parking spots on carrier, this is not an available option", self.templateName)
                return
            end
            local parkingData = util:getParkingData(airbaseName, parkingSpots)
            if #parkingSpots < #self.birthTemplate.units then
                util:logError(self.debug, "%s does not have enough given parking spots to be born from an airbase", self.templateName)
                return
            else
                if #parkingData == #parkingSpots then
                    local birthWaypoint = self.birthTemplate.route.points[1]
                    birthWaypoint.type = takeoffType.type
                    birthWaypoint.action = takeoffType.action
                    birthWaypoint.x = parkingData[1].termVec3.x
                    birthWaypoint.y = parkingData[1].termVec3.z
                    if birthAirbaseCategory == 0 then -- airbases
                        birthWaypoint.airdromeId = Airbase.getID(birthAirbase)
                    elseif birthAirbaseCategory == 2 then -- ships
                        birthWaypoint.helipadId = Airbase.getID(birthAirbase)
                    end
                    for id = 1, #self.birthTemplate.units do
                        self.birthTemplate.units[id].parking = parkingData[id].termIndex
                        self.birthTemplate.units[id].x = parkingData[id].termVec3.x
                        self.birthTemplate.units[id].y = parkingData[id].termVec3.z
                    end
                    --[[
                    if #self.birthTemplate.route.points == 1 then
                        self.birthTemplate.route.points[2] = util:deepCopy(self._template)
                        self.birthTemplate.route.points[2].x = birthAirbaseVec3.x
                        self.birthTemplate.route.points[2].y = birthAirbaseVec3.z
                    end
                    ]]
                    self:_initializeGroup()

                    return self
                else
                    util:logError(self.debug, "%s could not find enough valid/open parking spots", self.templateName)
                end
            end
        else
            local birthWaypoint = self.birthTemplate.route.points[1]
            birthWaypoint.type = takeoffType.type
            birthWaypoint.action = takeoffType.action
            birthWaypoint.x = birthAirbaseVec3.x
            birthWaypoint.y = birthAirbaseVec3.z
            if birthAirbaseCategory == 0 then -- airbases
                birthWaypoint.airdromeId = Airbase.getID(birthAirbase)
            elseif birthAirbaseCategory == 2 then -- ships
                birthWaypoint.helipadId = Airbase.getID(birthAirbase)
                birthWaypoint.helipadId = Airbase.getID(birthAirbase)
            end
            --[[
            if #self.birthTemplate.route.points == 1 then
                self.birthTemplate.route.points[2] = util:deepCopy(self._template)
                self.birthTemplate.route.points[2].x = birthAirbaseVec3.x
                self.birthTemplate.route.points[2].y = birthAirbaseVec3.z + 1000
                self.birthTemplate.route.points[2].alt = 5000
            end

            for id = 1, #self.birthTemplate.units do
                self.birthTemplate.units[id].parking = parkingData[id].termIndex
                --self.birthTemplate.units[id].x = parkingData[id].termVec3.x
                --self.birthTemplate.units[id].y = parkingData[id].termVec3.z
            end
            ]]
            self:_initializeGroup()

            return self
        end
    end
end

--[[ birth the object from a circle or quad trigger zone
- @param #birth self
- @param #string zoneName [the trigger zone to be born in]
- @param #number alt [the trigger zone to be born at]
- @return #birth self
]]
function birth:birthFromZone(zoneName, alt)
    if zonesByName[zoneName] then
        local _alt
        local vec3 = trigger.misc.getZone(zoneName).point
        if self.category == Group.Category.GROUND or self.category == Group.Category.TRIAN then
            _alt = land.getHeight({["x"] = vec3.x, ["y"] = vec3.z})
        elseif self.category == Group.Category.SHIP then
            _alt = 0
        elseif self.category == Group.Category.AIRPLANE then
            _alt = alt
        end
        for _, unitData in pairs(self.birthTemplate.units) do
            local sX = unitData.x or 0
            local sY = unitData.y  or 0
            local bX = self.birthTemplate.route.points[1].x
            local bY = self.birthTemplate.route.points[1].y
            local tX = vec3.x + (sX - bX)
            local tY = vec3.z + (sY - bY)
            if alt then
                unitData.alt = _alt
            else
                unitData.alt = tY
            end
            unitData.x = tX
            unitData.y = tY
        end
        self.birthTemplate.route.points[1].alt = _alt
        self.birthTemplate.route.points[1].x = vec3.x
        self.birthTemplate.route.points[1].y = vec3.z

        self:_initializeGroup()

        return self
    end
end

--[[ internal function to initialize the group for birth
- @param #birth self
- @return #birth self
]]
function birth:_initializeGroup()
    self:_updateActiveGroups()
    if self.limitEnabled then
        if #self.activeGroups < self.activeGroupLimit then
            self:_addGroup()
        end
    else
        self:_addGroup()
    end
    return self
end

--[[ internal function to add a group into the world
- @param #birth self
- @return #birth self
]]
function birth:_addGroup()
    -- remove any existing scheduler
    if self.schedulerId then
        self.schedulerId = nil
    end
    -- resolve naming convetion for the group
    if not self.keepNames then
        if type(self.alias) ~= "string" then
            self.groupName = self.templateName.." #"..self.birthCount + 1
        else
            self.groupName = self.alias
        end
        self.birthTemplate.name = self.groupName
        for unitId = 1, #self.birthTemplate.units do
            self.birthTemplate.units[unitId].name = self.birthTemplate.name.."-"..unitId
        end
    end

    -- send the birth object into the world
    self.dcsBirthGroup = coalition.addGroup(self.countryId, self.category, self.birthTemplate)
    self.birthCount = self.birthCount + 1
    self.bornGroups[#self.bornGroups+1] = self.groupName
    --util:logInfo(self.debug, "%s has been born into the world", self.groupName)
    if self.scheduledBirth then
        util:scheduleFunction(birth._initializeGroup, self, self.scheduleTime)
    end

    -- add this new group to the groupsByName db
    groupsByName[self.birthTemplate.name] = util:deepCopy(self.birthTemplate)
    self.groupTemplate = util:deepCopy(self.birthTemplate)
    -- add the units from the new group to unitsByName and payloadsByUnitName db's
    for unitId = 1, #self.birthTemplate.units do
        local unit = self.birthTemplate.units[unitId]
        unit.groupName = self.birthTemplate.name
        unitsByName[unit.name] = util:deepCopy(unit)
        payloadsByUnitName[unit.name] = util:deepCopy(unit.payload)
    end

    return self
end

--[[ interal function to update the currently existing born groups
- @param #birth self
- @return #birth self
]]
function birth:_updateActiveGroups()
    self.activeGroups = {}
    for _, groupName in pairs(self.bornGroups) do
        local group = group:getByName(groupName)
        if group then
            if group:isAlive() then
                self.activeGroups[#self.activeGroups+1] = groupName
            end
        end
    end
    return self
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
search.debug = true

--[[ create a new instance of a search object
- @param #search self
- @return #search self
]]
function search:new()
    local self = util:inherit(self, handler:new())
    self.groups = {}
    self.filter = {}
    return self
end

--[[ search for objects by a sub string
- can find a specific string at any location
- @param #search self
- @param #string subString [the sub string to search for]
- @return #search self
]]
function search:searchBySubString(subString)
    self.filter.subString = subString
    return self
end

--[[ search for objects by a starting prefix
- can only find stings at the start
- @param #search self
- @param #string prefix [the prefix to search for]
- @return #search self
]]
function search:searchByPrefix(prefix)
    self.filter.prefix = prefix
    return self
end

--[[ search for objects by coalition
- @param #search self
- @param #enum coalition [coalition side eg: 0 = neutral, 1 = red, 2 = blue]
- @return #search self
]]
function search:searchByCoalition(coalition)
    self.filter.coalition = coalition
    return self
end

--[[ search for objects by country
- @param #search self
- @param #enum country [countryId eg: country.id.USA = 2]
- @return #search self
]]
function search:searchByCountry(countryId)
    self.filter.country = countryId
    return self
end

--[[ search for objects by category
- @param #search self
- @param #enum country [category eg; Group.Category.AIRPLANE]
- @return #search self
]]
function search:searchByCategory(category)
    self.filter.category = category
    return self
end

--[[ search for units one time and return an array of unit objects
- @param #search self
- @return #array units
]]
function search:searchForUnitsOnce()
    local units = {}
    for unitName, unitData in pairs(unitsByName) do
        -- filter subStrings
        if self.filter.subString then
            if string.find(unitName, self.filter.subString) then
                units[#units+1] = unit:getByName(unitName)
            end
        end
        -- filter starts with prefix
        if self.filter.prefix then
            if string.find(unitName, self.filter.prefix, 1, true) == 1 then
                units[#units+1] = unit:getByName(unitName)
            end
        end
        -- filter coalitions
        if self.filter.coalition then
            if unitData.coalition == unitData.coalition then
                units[#units+1] = unit:getByName(unitName)
            end
        end
        -- filter categorys
        if self.filter.category then
            if unitData.category == self.filter.category then
                units[#units+1] = unit:getByName(unitName)
            end
        end
        -- filter countrys
        if self.filter.country then
            if unitData.countryId == self.filter.country then
                units[#units+1] = unit:getByName(unitName)
            end
        end
    end
    return units
end

--[[ search for statics one time and return an array of static objects
- @param #search self
- @return #array statics
]]
function search:searchForStaticsOnce()
    local statics = {}
    return statics
end

--[[ search for airbases one time and return an array of airbase objects
- @param #search self
- @return #array airbases
]]
function search:searchForAirbasesOnce()
    local airbases = {}
    return airbases
end

--[[ search for groups one time and return an array of group objects
- @param #search self
- @return #array groups
]]
function search:searchForGroupsOnce()
    local groups = {}
    for groupName, groupData in pairs(groupsByName) do
        -- filter subStrings
        if self.filter.subString then
            if string.find(groupName, self.filter.subString) then
                groups[#groups+1] = group:getByName(groupName)
            end
        end
        -- filter starts with prefix
        if self.filter.prefix then
            if string.find(groupName, self.filter.prefix, 1, true) == 1 then
                groups[#groups+1] = group:getByName(groupName)
            end
        end
        -- filter coalitions
        if self.filter.coalition then
            if groupData.coalition == self.filter.coalition then
                groups[#groups+1] = group:getByName(groupName)
            end
        end
        -- filter categorys
        if self.filter.category then
            if groupData.category == self.filter.category then
                groups[#groups+1] = group:getByName(groupName)
            end
        end
        -- filter countrys
        if self.filter.country then
            if groupData.countryId == self.filter.country then
                groups[#groups+1] = group:getByName(groupName)
            end
        end



    end
    return groups
end

--[[ search for zones one time and return an array of zone objects
- @param #search self
- @return #array zones
]]
function search:searchForZonesOnce()
    local zones = {}
    return zones
end

--
--
-- ** classes : ai **
--
--

--[[

@class #cap

@authors Wizard

@description
the cap class provides combat air patrol behaviors for a #birth group and its units. utilizing finite state machine events the cap object
will be automated to pushed through a series of states that help with tasking it to start its patrol, engage targets, go back to patrolling
after killing detected targets, return to base after reaching its RTB fuel threshold, etc. all of these events can also be called upon by
users to help with the mission enhancements.

@features
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
- dynamic engage ranges (distance from cap object)
- unique patrol shapes
- unique detection types
- inherited methods from #birth and #handler

@created Feb 5, 2022

]]

cap = {}
cap.debug = true

-- patrol shapes for how the patrol is created
cap.patrolShapes = {
    ["triangle"] = {["points"] = 3, ["degrees"] = 120},
    ["diamond"] = {["points"] = 4, ["degrees"] = 90},
    ["pentagon"] = {["points"] = 5, ["degrees"] = 72},
    ["hexaxagon"] = {["points"] = 6, ["degrees"] = 60},
    ["octogon"] = {["points"] = 8,  ["degrees"] = 45},
    ["star"] = {["points"] = 5, ["degrees"] = 144},
}

-- detection types for how the cap object finds targets
cap.detectionTypes = {
    ["visual"] = 1,
    ["optic"]  = 2,
    ["radar"]  = 4,
    ["irst"]   = 8,
    ["rwr"]    = 16,
    ["datalink"]  = 32
}

--[[ create a new instance of a cap object
- @param #cap self
- @param #string capName [the name of the cap object]
- @param #string birthGroup [the birth group object to be controlled as a cap object]
- @return #cap self
]]
function cap:new(capName, birthGroup)
    local self = util:inherit(self, birthGroup)
    self.capName = capName
    self.detection = {}
    self.airbaseName = nil
    self.parkingSpots = nil
    self.patrolName = nil
    self.patrolShape = nil
    self.resources = nil
    self.fuelThreshold = nil
    self.healthThreshold = nil
    self.ammoThreshold = nil
    self.minPatrolAlt = nil
    self.maxPatrolAlt = nil
    self.minPatrolSpeed = nil
    self.maxPatrolSpeed = nil
    self.minPatrolRange = nil
    self.maxPatrolRange = nil
    self.minEngageAlt = nil
    self.maxEngageAlt = nil
    self.minEngageSpeed = nil
    self.maxEngageSpeed = nil
    self.minEngageRange = nil
    self.maxEngageRange = nil
    self.takeoff = nil
    self.airstart = nil

    self.rtb = false
    self.attacking = false
    self.patrolling = false
    self.oldDilation = nil

    self.detectedTargets = {}
    self.engagedTargets = {}

    self:handleEvent(event.takeoff)
    self:handleEvent(event.land)
    self:handleEvent(event.engineShutdown)

    self:addTransition("*", "Start", "*")
    self:addTransition("*", "Status", "*")
    self:addTransition("*", "Deploy", "*")
    self:addTransition("*", "TaskPatrol", "*")
    self:addTransition("*", "AttackTargets", "*")
    self:addTransition("*", "RefreshTargets", "*")
    self:addTransition("*", "RTB", "*")

    return self
end

function cap:handleEvent(event)
    self:onGroupEvent(self, event, self.groupName)
    return self
end

--[[ set the detection types for how the cap object finds targets
- note: you can only have up to 3 detection types per limit of DCS
- @param #cap self
- @param #enum type1 [detectionType eg: cap.detectionTypes.datalink]
- @param #enum type2 [detectionType eg: cap.detectionTypes.rwr]
- @param #enum type3 [detectionType eg: cap.detectionTypes.radar]
- @return #cap self
]]
function cap:setDetection(type1, type2, type3)
    if type1 then
        self.detection[1] = type1
    end
    if type2 then
        self.detection[2] = type2
    end
    if type3 then
        self.detection[3] = type3
    end
    return self
end

--[[ set the airbase that the cap object will depart from
- @param #cap self
- @return #cap self
]]
function cap:setAirbase(airbaseName)
    self.airbaseName = airbaseName
    return self
end

--[[ set the airbase that the cap object will depart from
- @param #cap self
- @return #cap self
]]
function cap:setParkingSpots(parkingSpots)
    self.parkingSpots = parkingSpots
end

--[[ set the cap object to patrol a airbase or trigger zone
- @param #cap self
- @param #string patrolName [the name of the airbase or trigger zone]
- @param #enum patrolShape [the patrol shape, eg: cap.patrolShape.diamond]
- @return #cap self
]]
function cap:setPatrol(patrolName, patrolShape)
    self.patrolName = patrolName
    self.patrolShape = util:deepCopy(patrolShape)
    return self
end

--[[ set the amount of resources the cap object has available
- note: upon deployment, the current resources will be subtracted by the amount of units born
- 1 resource per unit landing will be given back
- @param #cap self
- @param #number resources [this is the amount of groups the cap object has]
- @return #cap self
]]
function cap:setResources(resources)
    self.resources = resources
    return self
end

--[[ set the RTB fuel threshold for the cap object
- @param #cap self
- @param #number threshold [once the cap object reaches this combined fuel amount, they will RTB]
- @return #cap self
]]
function cap:setFuelThreshold(threshold)
    self.fuelThreshold = threshold
    return self
end

--[[ set the RTB health threshold for the cap object
- @param #cap self
- @param #number threshold [once the cap object reaches this combined health ammount, they will RTB]
- @return #cap self
]]
function cap:setHealthThreshold(threshold)
    self.healthThreshold = threshold
    return self
end

--[[ set the RTB ammo threshold for the cap object
- @param #cap self
- @param #number threshold [once the cap object reaches this combined ammo ammount, they will RTB]
- @return #cap self
]]
function cap:setAmmoThreshold(threshold)
    self.ammoThreshold = threshold
    return self
end

--[[ set the min and max patrol alt for the cap object
- note: for each point in the patrol, a random alt between the min and max will be chosen to patrol from
- @param #cap self
- @param #number minAlt [the minimum alt in meters]
- @param #number maxAlt [the maximum alt in meters]
- @return #cap self
]]
function cap:setPatrolAlt(minAlt, maxAlt)
    self.minPatrolAlt = minAlt
    self.maxPatrolAlt = maxAlt
    return self
end

--[[ set the min and max patrol speed for the cap object
- note: for each point in the patrol, a random speed between the min and max will be chosen to patrol at
- @param #cap self
- @param #number minSpeed [the minimum speed in meters]
- @param #number maxSpeed [the maximum speed in meters]
- @return #cap self
]]
function cap:setPatrolSpeed(minSpeed, maxSpeed)
    self.minPatrolSpeed = minSpeed
    self.maxPatrolSpeed = maxSpeed
    return self
end

--[[ set the min and max patrol range for the cap object
- note: for each point in the patrol, a random distance from the patrol airbase/zone center will be chosen
- @param #cap self
- @param #number minRange [the minimum range in meters]
- @param #number maxRange [the maximum range in meters]
- @return #cap self
]]
function cap:setPatrolRange(minRange, maxRange)
    self.minPatrolRange = minRange
    self.maxPatrolRange = maxRange
    return self
end

--[[ set the min and max engage alt for the cap object
- note: each time an engagement occurs, a random alt between the min and max will be chosen to engage from
- @param #cap self
- @param #number minAlt [the minimum alt in meters]
- @param #number maxAlt [the maximum alt in meters]
- @return #cap self
]]
function cap:setEngageAlt(minAlt, maxAlt)
    self.minEngageAlt = minAlt
    self.maxEngageAlt = maxAlt
    return self
end

--[[ set the min and max engage speed for the cap object
- note: each time an engagement occurs, a random speed between the min and max will be chosen to engage at
- @param #cap self
- @param #number minSpeed [the minimum speed in meters]
- @param #number maxSpeed [the maximum speed in meters]
- @return #cap self
]]
function cap:setEngageSpeed(minSped, maxSpeed)
    self.minEngageSpeed = minSped
    self.maxEngageSpeed = maxSpeed
    return self
end

--[[ set the min and max engage range for the cap object
- note: for any detected target a random range between the min and max is selected to check if the target is within that range.
- @param #cap self
- @param #number minRange [the minimum range in meters]
- @param #number maxRange [the maximum range in meters]
- @return #cap self
]]
function cap:setEngageRange(minRange, maxRange)
    self.minEngageRange = minRange
    self.maxEngageRange = maxRange
    return self
end

--[[ set the cap object to takeoff from parking hot
- @param #cap self
- @return #cap self
]]
function cap:setTakeoffHot()
    self.takeoff = waypoint.takeoffParkingHot
    return self
end

--[[ set the cap object to takeoff from parking cold
- @param #cap self
- @return #cap self
]]
function cap:setTakeoffCold()
    self.takeoff = waypoint.takeoffParking
    return self
end

--[[ set the cap object to takeoff from parking air
- @param #cap self
- @return #cap self
]]
function cap:setTakeoffAir(alt)
    self.airstart = true
    self.takeoffAlt = alt
    return self
end

--[[ set the cap object to takeoff from runway
- @param #cap self
- @return #cap self
]]
function cap:setTakeoffRunway()
    self.takeoff = waypoint.takeoffRunway
    return self
end

function cap:onafterStart()
    --util:logInfo(self.debug, "onafter Start")
    self:__Status(1)
end

function cap:onafterStatus()
    --util:logInfo(self.debug, "onafter Status")
    if self:isAlive() then
        if self:inAir() == true then
            if not self.rtb then
                if self:getAvgFuel() > self.fuelThreshold then
                    if self:getAvgHealth() > self.healthThreshold then
                        if self:getAvgAmmo() > self.ammoThreshold then
                            if not self.attacking then
                                if self.patrolling then
                                    self.detectedTargets = self:getDetectedTargets(self.detection, {0, 1}, math.random(self.minEngageRange, self.maxEngageRange))
                                    if #self.detectedTargets > 0 then
                                        self.attacking = true
                                        self:__AttackTargets(1)
                                    end
                                else
                                    self:__TaskPatrol(1) -- we are not rtb, we are not attacking, and we are not patrolling. so, lets patrol.
                                end
                            else
                                -- attacking, checkup on the engaged targets
                                if #self.engagedTargets > 0 then
                                    self:__RefreshTargets(1)
                                else
                                    self.attacking = false
                                end
                            end
                        else
                            if not self.rtb then
                                --util:logInfo(self.debug, "low ammo count of %d, RTB!", self:getAvgAmmo())
                                self:__RTB(1)
                            end
                        end
                    else
                        if not self.rtb then
                            --util:logInfo(self.debug, "low health of %0.2f, RTB!", self:getAvgHealth())
                            self:__RTB(1)
                        end
                    end
                else
                    if not self.rtb then
                        --util:logInfo(self.debug, "low fuel state of %0.2f, RTB!", self:getAvgFuel())
                        self:__RTB(1)
                    end
                end
            end
    --[[ else
            if self:getAvgVelocityKMH() < 2 then
                -- we can do cleanup for inactive units here
            end
            ]]
        end
    else
        if self.resources ~= nil then
            if self.resources > 0 then
                self:__Deploy(1)
            else
                if not self.depleated then
                    --util:logInfo(self.debug, "%s has ran out of resources", self.capName)
                    self.depleated = true
                end
            end
        else
            self:__Deploy(1)
        end
    end
    if not self.depleated then
        self:__Status(5)
    end
end

function cap:onbeforeDeploy()
    self.rtb = false
    self.attacking = false
    self.patrolling = false
    self.detectedTargets = {}
    self.engagedTargets = {}
end

function cap:onafterDeploy()
    --util:logInfo(self.debug, "onafter Deploy")
    if self.airstart then
        self:birthFromVec3(Airbase.getByName(self.airbaseName):getPoint(), self.takeoffAlt)
        self.resources = self.resources - #self.birthTemplate.units
    else
        self:birthFromAirbase(self.airbaseName, self.parkingSpots, self.takeoff)
        self.resources = self.resources - #self.birthTemplate.units
    end
end

function cap:onafterTakeoff(from, event, to, eventData)
    --util:logInfo(self.debug, "onafter Takeoff")
    --util:logInfo(self.debug, "%s has taken off from %s", eventData.initUnitName, eventData.placeName)
end

function cap:onafterTaskPatrol()
    --util:logInfo(self.debug, "onafter TaskPatrol")
    local patrolPoint
    if Airbase.getByName(self.patrolName) then
        patrolPoint = Airbase.getByName(self.patrolName):getPoint()
    elseif zonesByName[self.patrolName] then
        local zone = util:deepCopy(zonesByName[self.patrolName])
        patrolPoint = {x = zone.x, y = zone.y, z = zone.y}
    end
    local taskMission = {
        id = 'Mission',
        params = {
            airborne = true,
            route = {
                points = {}
            }
        }
    }

    local randomNum = math.random(1, 100)
    local clockwise = false

    if randomNum <= 50 then
        clockwise = true
    end

    for wpId = 1, self.patrolShape.points do
        local degrees
        if not clockwise then
            degrees = self.patrolShape.degrees*2
        else
            degrees = self.patrolShape.degrees
        end
        local radius = math.random(self.minPatrolRange, self.maxPatrolRange)
        taskMission.params.route.points[wpId] = {
            type = "Turning Point",
            action = "Turning Point",
            x = util:projectPoint(patrolPoint, radius, math.rad(degrees*wpId)).x,
            y = util:projectPoint(patrolPoint, radius, math.rad(degrees*wpId)).z,
            alt = math.random(self.minPatrolAlt, self.maxPatrolAlt),
            alt_type = "BARO",
            speed = math.random(self.minPatrolSpeed, self.maxPatrolSpeed),
            speed_locked = true,
            ETA = 0,
            ETA_locked = false,
            task = {
                ["id"] = "ComboTask",
                ["params"] = {
                    ["tasks"] = {}
                }
            }
        }
    end
    taskMission.params.route.points[1].task.params.tasks = {
        [1] = {
            ["number"] = 1,
            ["auto"] = false,
            ["id"] = "WrappedAction",
            ["enabled"] = true,
            ["params"] = {
                ["action"] = {
                    ["id"] = "SwitchWaypoint",
                    ["params"] = {
                        ["goToWaypointIndex"] = 1,
                        ["fromWaypointIndex"] = #self.patrolShape.points
                    }
                }
            }
        }
    }
    self:getController():pushTask(taskMission)
    self.patrolling = true
    self.attacking = false
    self.rtb = false
    --util:logInfo(self.debug, "%s is enroute to patrol %s", self.capName, self.patrolName)
end

function cap:onafterAttackTargets()
    --util:logInfo(self.debug, "onafter AttackTargets")
    for i, unitName in pairs(self.detectedTargets) do
        if Unit.getByName(unitName) ~= nil then
            if Unit.getByName(unitName):getLife() >= 1 then
                local unit = Unit.getByName(unitName)
                local taskAttackUnit = {
                    id = 'AttackUnit',
                    params = {
                        unitId = unit:getID(),
                        weaponType = weaponFlag.AnyAAWeapon,
                        expend = "One",
                        directionEnabled = false,
                        direction = 0,
                        altitudeEnabled = true,
                        altitude = math.random(self.minEngageAlt, self.maxEngageAlt),
                        attackQtyLimit = true,
                        attackQty = 1,
                    }
                }
                self:getController():pushTask(taskAttackUnit)
                self.detectedTargets[i] = nil
                self.engagedTargets[#self.engagedTargets+1] = unitName
                break -- >.<
            end
        end
    end
end

function cap:onafterRefreshTargets()
    --util:logInfo(self.debug, "onafter RefreshTargets")
    for i, unitName in pairs(self.engagedTargets) do
        if Unit.getByName(unitName) == nil or Unit.getByName(unitName):isExist() == false then
            self.engagedTargets[i] = nil
        else
            if self.oldDilation then
                local newDilation = util:getSimTime()
                local timeDilation = newDilation - self.oldDilation
                if timeDilation > 180 then
                    self.oldDilation = nil
                    self:__AttackTargets(1)
                end
            else
                self.oldDilation = util:getSimTime()
            end
        end
    end
end

function cap:onafterRTB()
    --util:logInfo(self.debug, "onafter RTB")
    local landingAirbase = Airbase.getByName(self.airbaseName)
    local landingVec3 = landingAirbase:getPoint()
    local taskRTB = {
        id = 'Mission',
        params = {
            airborne = true,
            route = {
                points = {
                    [1] = {
                        type = "LandingReFuAr",
                        action = "LandingReFuAr",
                        --timeReFuAr = 7,
                        x = landingVec3.x,
                        y = landingVec3.z,
                        alt = math.random(self.minPatrolAlt, self.maxPatrolAlt),
                        alt_type = "BARO",
                        speed = math.random(self.minPatrolSpeed, self.maxPatrolSpeed),
                        speed_locked = true,
                        ETA = 0,
                        ETA_locked = false,
                        task = {
                            ["id"] = "ComboTask",
                            ["params"] = {
                                ["tasks"] = {}
                            }
                        }
                    }
                }
            }
        }
    }
    self:getController():setTask(taskRTB)
    self.rtb = true
end

function cap:onafterLand(from, event, to, eventData)
    --util:logInfo(self.debug, "onafter Land")
    self.resources = self.resources + 1
    --util:logInfo(self.debug, "%s has landed", eventData.initUnitName)
end

function cap:onafterEngineShutdown(from, event, to, eventData)
    --util:logInfo(self.debug, "onafter EngineShutdown")
    --util:logInfo(self.debug, "%s has shutdown its engines", eventData.initUnitName)
    util:scheduleFunction(Unit.destroy, eventData.initUnit, 15)
end

--
--
-- ** classes : wrapper **
--
--

--[[

@class #unit

@authors Wizard

@description
wrapper functions for DCS Class Unit with additional methods available.

@features

@todo
- document
- readme
- debugging

@created Feb 6, 2022

]]

unit = {}

--[[ create a new instance of a unit object
- @param #unit self
- @param #string unitName
- @return #unit self
]]
function unit:getByName(unitName)
    if unitsByName[unitName] then
        local self = util:inherit(self, handler:new())
        self.unitName = unitName
        self.unitTemplate = util:deepCopy(unitsByName[unitName])
        return self
    end
    return nil
end

--
--
-- ** ssf class #unit methods ** --
--
--
--[[ handle a specific event for the #unit object
- @param #unit self
- @param #enum event [the event that will be triggered for the #unit object]
- @return #unit self
]]
function unit:handleEvent(event)
    self:onUnitEvent(self, event, self:getName())
    return self
end

--[[ return the #group object that the #unit object is in
- @param #unit self
- @return #group self
]]
function unit:getGroup()
    local unitGroupName = self.unitTemplate.groupName
    local group = group:getByName(unitGroupName)
    if group then
        return group
    end
    return nil
end

--[[ return the #unit object payload table
- note: this function does not obtain a *current* payload, only what is set via the mission editor
- @param #unit self
- @param #string unitName (optional) [the unit name to return the payload from, if nil return for self]
- @return #table payload
]]
function unit:getPayload(unitName)
    local name = unitName or self.unitName
    if payloadsByUnitName[name] then
        local payload = util:deepCopy(payloadsByUnitName[unitName])
        return payload
    end
    return nil
end

--[[ return the current livery namne for the #unit object
- @param #unit self
- @return #string liveryName
]]
function unit:getLivery()
    local liveryName = self.unitTemplate.livery_id
    return liveryName
end

--[[ return the dcs class #Unit from the #unit object
- @param #unit self
- @return dcs class #Unit
]]
function unit:getDCSUnit()
    local dcsUnit = Unit.getByName(self.unitName)
    if dcsUnit then
        return dcsUnit
    end
    return nil
end

--[[ return the country of the #unit object
- @param #unit self
- @return #number countryId
]]
function unit:getCountry()
    local countryId = self.unitTemplate.countryId
    return countryId
end

--[[ return a boolean if the #unit object is alive or not
- @param #unit self
- @return #boolean alive [true if the #unit is alive]
]]
function unit:isAlive()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        if dcsUnit:isActive() then
            if dcsUnit:isExist() then
                if dcsUnit:getLife() >= 1 and dcsUnit:getFuel() == 0 then
                    return true
                end
            end
        end
    end
    return false
end

-- ** dcs class #Unit Wrapper Methods ** --

--[[ return a boolean if the #unit is currently activated or not
- @param #unit self
- @return #boolean [true if the #unit is now activated where it was previously late activated]
]]
function unit:isActive()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:isActive()
    end
    return nil
end

--[[ return the players name in control of the #unit
- @param #unit self
- @return #string playerName [returns the name of a player if they are occupied in the #unit
]]
function unit:getPlayerName()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        local playerName = unit:getPlayerName()
        if playerName then
            return playerName
        end
    end
    return nil
end

--[[ return the unique object identifier given to the #unit object
- @param #unit self
- @return #number
]]
function unit:getID()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getID()
    end
    return nil
end

--[[ return the default index of the #unit object within the group
- @param #unit self
- @return #number
]]
function unit:getNumber()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getNumber()
    end
    return nil
end

--[[ return the dcs class #Controller from the #unit object
- @param #unit self
- @return dcs class #Controller
]]
function unit:getController()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getController()
    end
    return nil
end

--[[ return the dcs class #Group from the #unit object
- @param #unit self
- @return dcs class #Group
]]
function unit:getDCSGroup()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getGroup()
    end
    return nil
end

--[[ return the callsign of the #unit object
- @param #unit self
- @return #string
]]
function unit:getCallsign()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getCallsign()
    end
    return nil
end

--[[ return the current life of the #unit object
-- less than 1 is considered dead
- @param #unit
- @return #number
]]
function unit:getLife()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getLife()
    end
    return nil
end

--[[ return the default max life value
- @param #unit self
- @return #number
]]
function unit:getLife0()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getLife0()
    end
    return nil
end

--[[ return the current fuel remaining as a percentage
- @param #unit self
- @return #number [eg; 0.55]
]]
function unit:getFuel()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getFuel()
    end
    return nil
end

--[[ return an ammo table containing a description table
- @param #unit self
- @return #table
]]
function unit:getAmmo()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getAmmo()
    end
    return nil
end

--[[ return a table containing the sesnors onboard
- @param #unit self
- @param #table
]]
function unit:getSensors()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getSensors()
    end
    return nil
end

--[[ return a boolean if the #unit has sensors
- @param #unit self
- @return #boolean [true if unit has sensors]
]]
function unit:hasSensors()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:hasSensors()
    end
    return nil
end

--[[ return a boolean if the #units radar is working as well as the actively tracked target dcs class #Object
- @param #unit self
- @return #boolean, dcs class #Object
example:
local ewrUnit = unit:getByName("EWR South")
local radarOnline, trackedUnit = ewrUnit:getRadar()
if radarOnline then
    local trackedUnitVec3 = trackedUnit:getPoint()
    if util:getDistance(playerVec3, trackedUnitVec3) <= 1500 then
        -- player is within 1500m, engage
    end
end
]]
function unit:getRadar()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getRadar()
    end
    return nil
end

--[[ return the current value for an animation argument for the external model of the #unit object
- @param #unit self
- @return #number [-1 to 1+]
]]
function unit:getDrawArgumentValue()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getDrawArgumentValue()
    end
    return nil
end

--[[ returns an array of friendly cargo objects sorted by distance from the #unit object
- only works for helicopters
- @param #unit self
- @return #array dcs class #Objects
]]
function unit:getNearestCargos()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getNearestCargos()
    end
    return nil
end

--[[ enable the radar emission for the #unit
- @param #unit self
- @param #boolean [true or false to toggle the emission of a radar]
- @return #unit self
]]
function unit:enableEmission(bool)
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:enableEmission(bool)
    end
    return nil
end

--[[ return the amount of infantry that can embark onto the #unit object
- only for airplanes and helopters
- @param #unit self
- @return #number
]]
function unit:getDescentCapacity()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getDescentCapacity()
    end
    return nil
end

--[[ return a boolean if the #unit object currently exists or not
- @param #unit self
- @return #boolean [true if currently exists]
]]
function unit:isExist()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:isExist()
    end
    return nil
end

--[[ destroy the #unit object with no explosion
- @param #unit self
- @return #unit self
]]
function unit:destroy()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        dcsUnit:destroy()
    end
    return self
end

--[[ return the category of the #unit object
- @param #unit self
- @return #enum [eg; 1 for airplane]
]]
function unit:getCategory()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getDesc().category
    end
    return nil
end

--[[ return the coalition of the #unit object
- @param #unit self
- @return #enum [eg; 1 for red, 2 for blue, 0 for neutral]
]]
function unit:getCoalition()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getCoalition()
    end
    return nil
end

--[[ return the type name from the #unit object
- @param #unit self
- @return #string [the #unit type name. eg; "Mi-8"]
]]
function unit:getTypeName()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getTypeName()
    end
    return nil
end

--[[ return the description table from the #unit object
- @param #unit self
- @return #array
]]
function unit:getDesc()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getDesc()
    end
    return nil
end

--[[ return a boolean if the #unit object has a specific attribute
- @param #unit self
- @param #string attribute [eg; "Planes"]
]]
function unit:hasAttribute(attribute)
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:hasAttribute(attribute)
    end
    return nil
end

--[[ return the name of the #unit object
- @param #unit self
- @return #string
]]
function unit:getName()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getName()
    end
    return nil
end

--[[ return the current vec3 of the #unit object
- @param #unit self
- @return #table
]]
function unit:getPoint()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getPoint()
    end
    return nil
end

--[[ return the current orientation vectors from the #unit object
- returns positional orientation in 3D space
- @param #unit self
- @return #table
]]
function unit:getPosition()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getPosition()
    end
    return nil
end

--[[ return the vec3 velocity vectors from the #unit object
- @param #unit self
- @return #table
]]
function unit:getVelocity()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:getVelocity()
    end
    return nil
end

--[[ return a #unit objects description table by type name
- @param #string unitTypeName
- @return #table
]]
function unit.getDescByName(unitTypeName)
    return Unit.getDescByName(unitTypeName) or nil
end

--[[ return a boolean if the #unit object is in air or not
- @param #unit self
- @return #boolean
]]
function unit:inAir()
    local dcsUnit = self:getDCSUnit()
    if dcsUnit then
        return dcsUnit:inAir()
    end
    return nil
end

--[[

@class #airbase

@authors Wizard

@description
wrapper functions for DCS Class Airbase with additional methods available.

@features

@todo

@created Apr 4, 2022

]]

airbase = {}

--[[ create a new instance of a airbase object
- @param #airbase self
- @param #string airbaseName [eg; "Sochi-Adler"]
- @return #airbase self
]]
function airbase:getByName(airbaseName)
    if airbasesByName[airbaseName] then
        local self = util:inherit(self, handler:new())
        self.airbaseName = airbaseName
        self.airbaseTemplate = util:deepCopy(airbasesByName[airbaseName])
        return self
    end
    return nil
end

-- ** ssf class #airbase methods ** --

--[[ return the #unit object if the airbase is a helipad or ship
- @param #airbase self
- @return #unit self
]]
function airbase:getUnit()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        local dcsAirbaseUnit = dcsAirbase:getUnit()
        if dcsAirbaseUnit then
            local dcsAirbaseUnitName = dcsAirbaseUnit:getName()
            local airbase_unit = unit:getByName(dcsAirbaseUnitName)
            if airbase_unit then
                return airbase_unit
            end
        end
    end
    return nil
end

--[[ return the dcs class #Airbase from the #airbase object
- @param #airbase self
- @return dcs class #Airbase
]]
function airbase:getDCSAirbase()
    local dcsAirbase = Airbase.getByName(self.airbaseName)
    if dcsAirbase then
        return dcsAirbase
    end
    return nil
end

-- ** dcs class #Airbase methods ** --

--[[ return the description table from the #airbase object
- @param #airbase self
- @return #array
]]
function airbase:getDesc()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getDesc()
    end
    return nil
end

--[[ return the callsign of the #airbase object
- airbase names are defined in game, while farps and ships can be configured via mission editor
- @param #airbase self
- @return #string
]]
function airbase:getCallsign()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getCallsign()
    end
    return nil
end

--[[ return the dcs class #Unit from the #airbase object
- @param #airbase self
- @return dcs class #Airbase]]
function airbase:getDCSUnit()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        local dcsAirbaseUnit = dcsAirbase:getUnit()
        if dcsAirbaseUnit then
            return dcsAirbaseUnit
        end
    end
    return nil
end

--[[ return the unique object identifier given to the #airbase object
- @param #airbase self
- @return #number
]]
function airbase:getID()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getID()
    end
    return nil
end

--[[ return a table of parking data for the #airbase object
- @param #airbase self
- @param #boolean [true for only availble parking spots]
]]
function airbase:getParking(available)
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getParking(available)
    end
    return nil
end

--[[ return a table with runway information for the #airbase object
- length, width, course, and name
- @param #airbase self
- @return #table
]]
function airbase:getRunways()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getRunways()
    end
    return nil
end

--[[ return a vec3 table from the objectType param for the #airbase object
- only returns the airbase "Tower"
- @param #airbase self
- @param #number or #string objectType
- @return #table
]]
function airbase:getTechObjectPos(objectType)
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getRunways()
    end
    return nil
end

--[[ return a boolean if the #airbase objects radio has been silenced
- @param #airbase self
- @return #boolean
]]
function airbase:getRadioSilentMode()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getRadioSilentMode()
    end
    return nil
end

--[[ set the ATC for the #airbase object to be silent
- stops atc from transmitting completely
- @param #airbase self
- @param #boolean silenced [ if true disabled atc communications]
- @return #boolean
]]
function airbase:setRadioSilentMode(silenced)
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:setRadioSilentMode(silenced)
    end
    return nil
end

--[[ return a boolean if the #airbase object currently exists or not
- @param #airbase self
- @return #boolean [true if currently exists]
]]
function airbase:isExist()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:isExist()
    end
    return nil
end

--[[ destroy the #airbase object with no explosion
- @param #airbase self
- @return #airbase self
]]
function airbase:destroy()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        dcsAirbase:destroy()
    end
    return self
end

--[[ return the category of the #airbase object
- @param #airbase self
- @return #enum [eg; 1 for airplane]
]]
function airbase:getCategory()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getDesc().category
    end
    return nil
end

--[[ return the coalition of the #airbase object
- @param #airbase self
- @return #enum [eg; 1 for red, 2 for blue, 0 for neutral]
]]
function airbase:getCoalition()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getCoalition()
    end
    return nil
end

--[[ return the type name from the #airbase object
- @param #airbase self
- @return #string [the #airbase type name. eg; "FARP"]
]]
function airbase:getTypeName()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getTypeName()
    end
    return nil
end

--[[ return the description table from the #airbase object
- @param #airbase self
- @return #array
]]
function airbase:getDesc()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getDesc()
    end
    return nil
end

--[[ return a boolean if the #airbase object has a specific attribute
- @param #airbase self
- @param #string attribute [eg; "Airfields"]
]]
function airbase:hasAttribute(attribute)
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:hasAttribute(attribute)
    end
    return nil
end

--[[ return the name of the #airbase object
- @param #airbase self
- @return #string
]]
function airbase:getName()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getName()
    end
    return nil
end

--[[ return the current vec3 of the #airbase object
- @param #airbase self
- @return #table
]]
function airbase:getPoint()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getPoint()
    end
    return nil
end

--[[ return the current orientation vectors from the #airbase object
- returns positional orientation in 3D space
- @param #airbase self
- @return #table
]]
function airbase:getPosition()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getPosition()
    end
    return nil
end

--[[ return the vec3 velocity vectors from the #airbase object
- @param #airbase self
- @return #table
]]
function airbase:getVelocity()
    local dcsAirbase = self:getDCSAirbase()
    if dcsAirbase then
        return dcsAirbase:getVelocity()
    end
    return nil
end

--[[ return a #airbase objects description table by type name
- @param #string airbaseTypeName
- @return #table
]]
function airbase.getDescByName(airbaseTypeName)
    return Airbase.getDescByName(airbaseTypeName) or nil
end

--[[

@class #static

@authors Wizard

@description
wrapper functions for DCS Class StaticObject with additional methods available.

@features

@todo
- document
- readme
- work on a isAlive bc statics are wack

@created Feb 6, 2022

]]

static = {}

--[[ create a new instance of a static object
- @param #group self
- @param #string groupName
- @return #group self
]]
function static:getByName(staticName)
    if staticsByName[staticName] then
        local self = util:inherit(self, handler:new())
        self.staticName = staticName
        self.staticTemplate = util:deepCopy(staticsByName[staticName])
        return self
    end
    return nil
end

-- ** ssf class #static methods** --
--[[ return a boolean if the #static object is alive or not
- @param #static self
- @return #boolean [true if alive]
]]
function static:isAlive()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        if static:isExist() then
            if static:getLife() >= 1 then
                return true
            end
        end
    end
    return false
end

--[[ return the dcs class #StaticObject from the #static object
- @param #static self
- @return dcs class #StaticObject
]]
function static:getDCSStaticObject()
    if StaticObject.getByName(self.staticName) ~= nil then
        return StaticObject.getByName(self.staticName)
    end
    return nil
end

-- ** dcs class #StaticObject Wrapper Methods ** --

--[[ return the unique object identifier given to the #static object
- @param #static self
- @return #number
]]
function static:getID()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:getID()
    end
    return nil
end

--[[ return the #static object cargo mass in kg
- @param #static self
- @return #string [eg; "1500 kg"]
]]
function static:getCargoDisplayName()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:getCargoDisplayName()
    end
    return nil
end

--[[ return the #static object cargo mass in kg
- @param #static self
- @return #number [eg; 900]
]]
function static:getCargoWeight()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:getCargoWeight()
    end
    return nil
end

--[[ return the current value for an animation argument for the external model of the staic object
- @param #static self
- @return #number [-1 to 1+]
]]
function static:getDrawArgumentValue()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:getDrawArgumentValue()
    end
    return nil
end

--[[ return a boolean if the #static object currently exists or not
- @param #static self
- @return #boolean [true if currently exists]
]]
function static:isExist()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:isExist()
    end
    return false
end

--[[ destroy the #static object with no explosion
- @param #static self
- @return #static self
]]
function static:destroy()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:destroy()
    end
    return self
end

--[[ return the category of the #static object
- @param #static self
- @return #enum [eg; 1 for unit]
]]
function static:getCategory()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:getDesc().category
    end
    return nil
end

--[[ return the type name from the #static object
- @param #static self
- @return #string [the #static type name. eg; "ammo_cargo"]
]]
function static:getTypeName()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:getTypeName()
    end
    return nil
end

--[[ return the description table from the #static object
- @param #static self
- @return #array
]]
function static:getDesc()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:getDesc()
    end
    return nil
end

--[[ return a boolean if the #static object has a specific attribute
- @param #static self
- @param #string attribute [eg; "Fortifications"]
]]
function static:hasAttribute()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:hasAttribute()
    end
    return nil
end

--[[ return the name of the #static object
- note this is the unit name
- @param #static self
- @return #string
]]
function static:getName()
    return self.staticName
end

--[[ return the current vec3 of the #static object
- @param #static self
- @return #table
]]
function static:getPoint()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:getPoint()
    end
    return nil
end

--[[ return the current orientation vectors from the #static object
- returns positional orientation in 3D space
- @param #static self
- @return #table
]]
function static:getPosition()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:getPosition()
    end
    return nil
end

--[[ return the coalition of the #static object
- @param #static self
- @return #enum [eg; 1 for red, 2 for blue, 0 for neutral]
]]
function static:getCoalition()
    if self:isExist() then
        return self.staticTemplate.coalition
    end
    return nil
end

--[[ return the country of the #static object
- @param #static self
- @return #number countryId
]]
function static:getCountry()
    local dcsStaticObject = self:getDCSStaticObject()
    if dcsStaticObject then
        return dcsStaticObject:getCountry()
    end
    return nil
end

--[[ return a #static objects description table by type name
- @param #string staticTypeName
- @return #table
]]
function static.getDescByName(staticTypeName)
    return StaticObject.getDescByName(staticTypeName) or nil
end

--[[

@class #group

@authors Wizard

@description
wrapper functions for DCS Class Group with additional methods available.

@features
- wrapped methods for DCS Group
- extra methods not available with DCS Group
- inherited methods from #handler

@todo
- redo documentation
- readme
- debugging

@created Feb 6, 2022

]]

group = {}
group.debug = true

--[[ create a new instance of a group object
- returns any object that has been placed in the mission or dynamically born
- @param #group self
- @param #string groupName
- @return #group self
]]
function group:getByName(groupName)
    if groupsByName[groupName] then
        local self = util:inherit(self, handler:new())
        self.groupName = groupName
        self.groupTemplate = util:deepCopy(groupsByName[groupName])
        return self
    end
    return nil
end

-- ** ssf class #group methods ** --

--[[ handle a specfic event for the units within the group
- @param #group self
- @param #enum event [the event that will be triggered for the units within the group, eg: event.land
- @return #group self]]
function group:handleEvent(event)
    self:onGroupEvent(self, event, self.groupName)
    return self
end

--[[ return a #unit object within the group object by its current index or name
- @param #group self
- @poram #variable unitVar [this can be the current index (id) of the #unit or its name]
- @return #unit self
]]
function group:getUnit(unitVar)
    if type(unitVar) == "string" then
        return unit:getByName(unitVar)
    elseif type(unitVar) == "number" then
        local unitName = self.groupTemplate.units[unitVar].name
        return unit:getByName(unitName)
    end
    return nil
end

--[[ return an array of #unit objects within the group object
- @param #group self
- @return #array #units [array of unit objects]
]]
function group:getUnits()
    local units = {}
    for _, unit in pairs(self.groupTemplate.units) do
        units[#units+1] = unit:getByName(unit.name)
    end
    return units
end

--[[ return a deep copy of the group object template
- @param #group self
- @return #table groupTemplate
]]
function group:getTemplate()
    return util:deepCopy(self.groupTemplate)
end

--[[ return the average speed of the group object in kilometers per hour
- @param #group self
- @return #number avgVelocityKMH
]]
function group:getAvgVelocityKMH()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        local avgVelocityKMH = 0
        local units = self:getUnits()
        for _, unit in pairs(units) do
            local unitVelocityKMH = util:getVelocityKMH(unit)
            avgVelocityKMH = avgVelocityKMH + unitVelocityKMH
        end
        return avgVelocityKMH / #units
    end
    return nil
end

--[[ return the average vec3 point from the group object
- @param #group self
- @return #table avgVec3 [table of x, y, and z coordinates from the average point of the group]
]]
function group:getPoint()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        local avgX, avgY, avgZ, count = 0, 0, 0, 0
        local units = self:getUnits()
        for _, unit in pairs(units) do
            local unitVec3 = unit:getPoint()
            avgX = avgX + unitVec3.x
            avgY = avgY + unitVec3.y
            avgZ = avgZ + unitVec3.z
            count = count + 1
        end
        if count ~= 0 then
            local avgVec3 = {
                ["x"] = avgX/count,
                ["y"] = avgY/count,
                ["z"] = avgZ/count
            }
            return avgVec3
        end
    end
    return nil
end

--[[ return the average amount of fuel remaining for the group object
- @param #group self
- @rreturn #number avgFuel
]]
function group:getAvgFuel()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        local totalFuel = 0
        local units = self:getUnits()
        for _, unit in pairs(units) do
            totalFuel = totalFuel + unit:getFuel()
        end
        local avgFuel = totalFuel / #units
        return avgFuel
    end
    return nil
end

--[[ return the average percentage of health for the group object
- @param #group self
- @return #number health [return example: ]
]]
function group:getAvgHealth()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        local units = self:getUnits()
        local totalHealth = 0
        for _, unit in pairs(units) do
            totalHealth = totalHealth + unit:getLife()/unit:getLife0()
        end
        local avgHealth = totalHealth / #units * 100
        return avgHealth
    end
    return nil
end

--[[ return the average ammount of ammo a group has
- note: the number returned will be a count of each weapon returned thats on a pylon (not included is gun rouunds)
- @param #group self
- @return #number avgAmmo
]]
function group:getAvgAmmo()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        local ammoCount = 0
        local units = self:getUnits()
        for _, unit in pairs(units) do
            local ammo = unit:getAmmo()
            for _, ammoData in pairs(ammo) do
                if ammoData.desc.category ~= 0 then -- missile, rocket, bomb
                    ammoCount = ammoCount + ammoData.count
                end
            end
        end
        return ammoCount
    end
    return nil
end

--[[ get targets detected by the group object
- @param #group self
- @param #table targets [array of detectionTypes]
- @param #table categories [array of unit categories to detect eg: {Unit.Category.AIRPLANE, Unit.Category.HELICOPTER]
- @param #number range [the max range that targets will be detected]
- @return #table detectedTargets
]]
function group:getDetectedTargets(detection, categories, range)
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        local dcsController = self:getController()
        local targetsInRange = {}
        local detectedTargets = dcsController:getDetectedTargets(detection[1] or nil, detection[2] or nil, detection[3] or nil)
        for _, targetData in pairs(detectedTargets) do
            local targetObject = targetData.object
            local targetName = targetObject:getName()
            local targetCategory = targetObject:getDesc().category
            if type(categories) ~= "table" then
                categories = {categories}
            end
            for _, category in pairs(categories) do
                if category == targetCategory then
                    local targetVec3 = targetObject:getPoint()
                    local selfVec3 = self:getPoint()
                    local seperation = util:getDistance(selfVec3, targetVec3)
                    if seperation <= range then
                        targetsInRange[#targetsInRange+1] = targetName
                    end
                end
            end
        end
        return targetsInRange
    end
    return nil
end

--[[ return a boolean if the group object is alive
- @param #group self
- @return #boolean [true if at least one unit is still alive]
]]
function group:isAlive(allOfGroupAlive)
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        local templateSize = #self.groupTemplate.units
        local aliveUnits = 0
        local units = self:getUnits()
        for _, unit in pairs(units) do
            if unit:isActive() then
                if unit:isExist() then
                    if unit:getLife() >= 1 then
                        aliveUnits = aliveUnits + 1
                    end
                end
            end
        end
        if allOfGroupAlive then
            if templateSize == aliveUnits then
                return true
            end
        else
            if aliveUnits > 0 then
                return true
            end
        end
    end
    return false
end

--[[ return a boolean if the group object is in air
- @param #group self
- @return #boolean groupInAir [true if at least one unit is in air]
]]
function group:inAir(allOfGroupInAir)
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        local inAirUnits = 0
        local units = self:getUnits()
        for _, unit in pairs(units) do
            if unit:inAir() then
                inAirUnits = inAirUnits + 1
            end
        end
        if allOfGroupInAir then
            if inAirUnits == #units then
                return true
            end
        else
            if inAirUnits > 0 then
                return true
            end
        end
    end
    return false
end

function group:inZone(zoneName, allOfGroupInZone)
    if zonesByName[zoneName] then
        local dcsGroup = self:getDCSGroup()
        if dcsGroup then
            local units = self:getDCSUnits()
            local triggerZone = util:deepCopy(zonesByName[zoneName])
            local zonePoint = {["x"] = triggerZone.x, ["z"] = triggerZone.y}
            local zoneRadius = triggerZone.radius
            local inZoneCount = 0
            for _, unit in pairs(units) do
                local unitPoint = unit:getPoint()
                if ((unitPoint.x - zonePoint.x)^2 + (unitPoint.z - zonePoint.z)^2)^0.5 >= zoneRadius then
                    inZoneCount = inZoneCount + 1
                end
            end

            if allOfGroupInZone then
                if inZoneCount == #units then
                    return true
                end
            else
                if inZoneCount > 0 then
                    return true
                end
            end
        end
    else
        util:logError(self.debug, "%s is not a trigger zone defined in the mission editor", zoneName)
    end
    return false
end

-- ** dcs class #Group Wrapper Methods ** --

--[[ return the DCS Class Group from the group object
- @param #group self
- @return DCS#Group
]]
function group:getDCSGroup()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup
    end
    return nil
end

--[[ return the category from the group object
- Group.Category enums found here: https://wiki.hoggitworld.com/view/DCS_Class_Group
- @param #group self
- @return #enum groupCategory
]]
function group:getCategory()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getDesc().category
    end
    return nil
end

--[[ return the coalition from the group object
-- coalition.side enums found here: https://wiki.hoggitworld.com/view/DCS_singleton_coalition
- @param #group self
- @return #number groupCoalition
]]
function group:getCoalition()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getCoalition()
    end
    return self
end

--[[ return the group name from the group object
- @param #group self
- @return #string groupName
]]
function group:getName()
    return self.groupTemplate.name
end

--[[ return the unique object identifier given to the group object
- @param #group self
- @return #number groupId
]]
function group:getID()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getID()
    end
    return nil
end

--[[ get a dcs class #Unit from the group object
- @param #group self
- @param #number unitId [the unitId within the group to obtain]
- @return DCS#Unit dcsUnit
]]
function group:getDCSUnit(unitId)
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getUnit(unitId)
    end
    return nil
end

--[[ get all the DCS#Units from the group object
- @param #group self
- #return DCS#Units units
]]
function group:getDCSUnits()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getUnits()
    end
    return nil
end

--[[ return the current size of the group object
- @param #group self
- @return #number groupSize
]]
function group:getSize()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getSize()
    end
    return 0
end

--[[ return the inital size of the group object
- this does not return the current size but the size of group template
- @param #group self
- @return #number initGroupSize
]]
function group:getInitialSize()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getInitialSize()
    end
    return nil
end

--[[ return the DCS#Controller for the group object
- @param #group self
- @return DCS#GroupController
]]
function group:getController()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getController()
    end
    return nil
end

--[[ return a boolean if the group object exists currently
- @param #groups self
- @return #boolean groupExist
]]
function group:isExist()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:isExist()
    end
    return false
end

--[[ activate a DCS Group of units
- @param #group self
- @return #group self
]]
function group:activate()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:isActive()
    end
    return self
end

--[[ destroy the group object with no explosion
- @param #group self
- @return #group self
]]
function group:destroy()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:destroy()
    end
    return self
end

--[[ enable the group object to have its radar emitters on or off
- @param #group self
- @param #boolean emission [if true the group will enable its radars]
- @return #group self
]]
function group:enableEmission(emission)
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        dcsGroup:enableEmission(emission)
        return self
    end
end

util:logInfo(debugger, "successfully loaded SSF v%d.%d.%d", major, minor, patch)

--[[ QUICK TESTING ARENA ]] -- REMOVE BEFORE PUSH