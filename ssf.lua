--[[

@Simple Scripting Framework

@authors Wizard#5064

@description
Simple  Scripting Framework is as the title suggests, is as the title suggests,
a simplified framework comprised of pre-made scripted solutions using Object
Orientated Lua Scripting for DCS World Mission Creators.

@github: https://github.com/Wizxrd/SSF/tree/main

@created Jan 30, 2022

@version 0.3.0

@todo

]]

ssf = {}

function ssf:initialize()
    ssf = util:inheritParent(self, logger)
    ssf.version = "v0.3.0"
    ssf.source = "ssf.lua"
    ssf.level = 5
    ssf:initializeDatabases()
end

--
--
-- ** database initialization **
--
--

local groupsByName = {}
local unitsByName = {}
local staticsByName = {}
local airbasesByName = {}
local zonesByName = {}
local payloadsByUnitName = {}
local liverysByUnitName = {}

function ssf:initializeDatabases()

    local categories = {
        ["plane"] = 0,
        ["helicopter"] = 1,
        ["vehicle"] = 2,
        ["ship"] = 3,
    }

    local coalitions = {
        ["neutral"] = 0,
        ["red"] = 1,
        ["blue"] = 2
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
                                    if groupData.lateActivation then
                                        groupData.lateActivation = false
                                    end
                                    groupsByName[groupData.name] = util:deepCopy(groupData)
                                    groupsByName[groupData.name].coalition = coalitions[coaSide]
                                    groupsByName[groupData.name].countryId = ctryData.id
                                    groupsByName[groupData.name].category = categories[objType]
                                   self:debug("ssf:initializeDatabases(): group database registered group %s into groupsByName", groupData.name)
                                end
                            end
                        elseif objType == "static" then
                            for _, staticData in pairs(objData.group) do
                                staticsByName[staticData.name] = util:deepCopy(staticData)
                               self:debug("ssf:initializeDatabases(): static database registered static %s into staticsByName", staticData.name)
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
            ["coalition"] = airdrome:getCoalition(),
            ["countryId"] = airdrome:getCountry(),
        }
        if Airbase.getUnit(airdrome) then
            airbasesByName[airbaseName].unitId = Airbase.getUnit(airdrome):getID()
           self:debug("ssf:initializeDatabases(): airbase database registered airbase *unit* %s into airbasesByName", airbaseName)
        else
           self:debug("ssf:initializeDatabases(): airbase database registered airbase %s into airbasesByName", airbaseName)
        end
    end

    for _, zones in pairs(env.mission.triggers) do
        for _, zoneData in pairs(zones) do
            zonesByName[zoneData.name] = util:deepCopy(zoneData)
            self:debug("ssf:initializeDatabases(): zone database registered trigger zone %s into zonesByName", zoneData.name)
        end
    end

    for _, groupData in pairs(groupsByName) do
        for _, unitData in pairs(groupData.units) do
            if unitData.skill ~= "Client" or unitData.skill ~= "Player" then -- this exception still collects them, it makes no sense
                unitsByName[unitData.name] = util:deepCopy(unitData)
                self:debug("ssf:initializeDatabases(): unit database registered unit %s into unitsByName", unitData.name)
                if unitData.payload then
                    payloadsByUnitName[unitData.name] = util:deepCopy(unitData.payload)
                    self:debug("ssf:initializeDatabases(): payload database registered unit %s into payloadsByUnitName", unitData.name)
                end
                if unitData.livery_id then
                    liverysByUnitName[unitData.name] = util:deepCopy(unitData.livery_id)
                    self:debug("ssf:initializeDatabases(): livery database registered unit %s into liverysByUnitName", unitData.name)
                end
            end
        end
    end

    groupsByName = util:deepCopy(groupsByName)
    unitsByName = util:deepCopy(unitsByName)
    staticsByName = util:deepCopy(staticsByName)
    airbasesByName = util:deepCopy(airbasesByName)
    zonesByName = util:deepCopy(zonesByName)
	payloadsByUnitName = util:deepCopy(payloadsByUnitName)
	liverysByUnitName = util:deepCopy(liverysByUnitName)

    self:debug("ssf:initializeDatabases(): databases successfully built")
end

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
    ["level"] = 6,
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

logger.callbacks = {
    {["method"] = "alert",   ["enum"] = "ALERT"},
    {["method"] = "error",   ["enum"] = "ERROR"},
    {["method"] = "warning", ["enum"] = "WARNING"},
    {["method"] = "info",    ["enum"] = "INFO"},
    {["method"] = "debug",   ["enum"] = "DEBUG"},
    {["method"] = "trace",   ["enum"] = "TRACE"},
}

do
    local logwrite = log.write
    local format = string.format
    local osdate
    if os then osdate = os.date end
    for i, callback in ipairs(logger.callbacks) do
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
    local self = setmetatable({}, {__index = logger})
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
    local self = util:inheritParent(self, fsm)
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
            ssf:error("fsm:callHandler(): Error in scheduled function:" .. errmsg)
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
    if not success then ssf:error("handler:onEvent(): ERROR IN onEvent : %s", tostring(err)) end
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
    if not groupsByName[groupName] then ssf:error("birth:new(): could not find %s in groupsByName", groupName) return end
    local self = util:inheritParents(self, {handler:new(), group})
    self.templateName = groupName
    self.template = util:deepCopy(groupsByName[groupName])
    self.groupTemplate = util:deepCopy(self.template)
    self.countryId = self.groupTemplate.countryId
    self.category = self.groupTemplate.category
    self.coalition = self.groupTemplate.coalition
    self.count = 0

    self.keepGroupName = nil
    self.keepUnitNames = nil
    self.alias = nil
    self.groupLimit = nil
    self.unitLimit = nil
    self.groupName = nil

    self.groupTemplate.countryId = nil
    self.groupTemplate.category = nil
    self.groupTemplate.coalition = nil

    self.bornGroups = {}
    self.bornUnits = {}

    return self
end

function birth:handleEvent(event)
    ssf:debug("birth:handleEvent(): handling event %s", event.name)
    self:handleGroupEvent(self, event, self.templateName or self.alias)
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
    if not payloadsByUnitName[unitName] then ssf:error("birth:setPayload(): could not find %s in payloadsByUnitName", unitName) return end
    local unitPayload = util:deepCopy(payloadsByUnitName[unitName])
    self.template.units[unitId].payload = unitPayload
    return self
end

function birth:setLivery(unitId, unitName)
    if not liverysByUnitName[unitName] then ssf:error("birth:setPayload(): could not find %s in liverysByUnitName", unitName) return end
    local unitLivery = util:deepCopy(liverysByUnitName[unitName])
    self.template.units[unitId].livery_id = unitLivery
    return self
end

function birth:setCountry(countryName)
    if not country.id[countryName] then ssf:error("birth:setCountry(): couldnt find country.id.%s", countryName) return end
    self.countryId = country.id[countryName]
    return self
end

function birth:birthToWorld()
    ssf:debug("birth:birthToWorld(): preparing template %s for birth", self.templateName)
    self:_initialize()
    return self
end

function birth:birthScheduled(scheduleTime)
    ssf:debug("birth:birthScheduled(): preparing template %s for birth on a scheduler", self.templateName)
    self.scheduleTime = scheduleTime
    self:_initialize()
    return self
end

function birth:birthFromVec3(vec3, alt)
    ssf:debug("birth:birthFromVec3(): preparing template %s for birth from a vec3", self.templateName)
    if self.category == Group.Category.GROUND or self.category == Group.Category.TRIAN then
        alt = land.getHeight({["x"] = vec3.x, ["y"] = vec3.z})
    elseif self.category == Group.Category.SHIP then
        alt = 0
    elseif self.category == Group.Category.AIRPLANE or self.category == Group.Category.HELICOPTER then
        if not alt then
            ssf:error("birth:birthFromVec3(): %s requires an altitude to be born from a vec3", self.templateName)
            return self
        end
        alt = alt
    end

    for _, unitData in pairs(self.groupTemplate.units) do
        local sX = unitData.x or 0
        local sY = unitData.y  or 0
        local bX = self.groupTemplate.route.points[1].x
        local bY = self.groupTemplate.route.points[1].y
        local tX = vec3.x + (sX - bX)
        local tY = vec3.z + (sY - bY)
        unitData.alt = alt
        unitData.x = tX
        unitData.y = tY
    end

    self.groupTemplate.route.points[1].alt = alt
    self.groupTemplate.route.points[1].x = vec3.x
    self.groupTemplate.route.points[1].y = vec3.z

    self:_initialize()
    return self
end

function birth:_updateActiveGroups()
    ssf:debug("birth:_updateActiveGroups(): updating active groups for template %s", self.templateName)
    self.activeGroups = {}
    for _, groupName in pairs(self.bornGroups) do
        if group:getByName(groupName) then
            if group:getByName(groupName):isAlive() then
                self.activeGroups[#self.activeGroups+1] = groupName
            else
                ssf:debug("birth:_updateActiveGroups(): group %s not alive", groupName)
            end
        else
            ssf:debug("birth:_updateActiveGroups(): cant find group %s in database?", groupName)
        end
    end
    return self
end

function birth:_updateActiveUnits()
    ssf:debug("birth:_updateActiveUnits(): updating active units for template %s", self.templateName)
    self.activeUnits = {}
    for _, unitName in pairs(self.bornUnits) do
        if unit:getByName(unitName) then
            if unit:getByName(unitName):isAlive() then
                self.activeUnits[#self.activeUnits+1] = unitName
            else
                ssf:debug("birth:_updateActiveUnits(): unit %s not alive", unitName)
            end
        else
            ssf:debug("birth:_updateActiveUnits(): cant find unit %s in database?", unitName)
        end
    end
    return self
end

function birth:_witihinGroupLimit()
    ssf:debug("birth:_witihinGroupLimit(): comparing active groups against the groupLimit for template %s", self.templateName)
    self:_updateActiveGroups()
    if #self.activeGroups < self.groupLimit then
        ssf:debug("birth:_witihinGroupLimit(): returning true, template %s has less active groups than the groupLimit", self.templateName)
        return true
    end
    ssf:debug("birth:_witihinGroupLimit(): returning false, template %s active groups are greater than or equal to the groupLimit", self.templateName)
    return false
end

function birth:_withinUnitLimit()
    ssf:debug("birth:_withinUnitLimit(): comparing active units against the unitLimit for template %s", self.templateName)
    self:_updateActiveUnits()
    if #self.activeUnits + #self.groupTemplate.units <= self.unitLimit then
        ssf:debug("birth:_withinUnitLimit(): returning true, template %s has less active units than the unitLimit", self.templateName)
        return true
    end
    ssf:debug("birth:_withinUnitLimit(): returning false, template %s active units are greater than or equal to the unitLimit", self.templateName)
    return false
end

function birth:_initialize()
    ssf:debug("birth:_initialize(): initializing template %s", self.templateName)
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
    ssf:debug("birth:_addGroup(): adding template %s into the world", self.templateName)
    if self.schedulerId then self.schedulerId = nil end
    if not self.keepGroupName then
        if self.alias then
            self.groupName = self.alias
            self.groupTemplate.name = self.groupName
        else
            self.groupName = self.template.name.." #"..self.count + 1
            self.groupTemplate.name = self.groupName
        end
    end
    if not self.keepUnitNames then
        for unitId = 1, #self.groupTemplate.units do
            self.groupTemplate.units[unitId].name = self.groupTemplate.name.."-"..unitId
        end
    end
    coalition.addGroup(self.countryId, self.category, self.groupTemplate)
    self.count = self.count + 1
    self.bornGroups[#self.bornGroups+1] = self.groupName
    groupsByName[self.groupTemplate.name] = util:deepCopy(self.groupTemplate)
    for _, unitData in pairs(self.groupTemplate.units) do
        unitsByName[unitData.name] = util:deepCopy(unitData)
        if unitData.payload then
            payloadsByUnitName[unitData.name] = util:deepCopy(unitData.payload)
            self.bornUnits[#self.bornUnits+1] = unitData.name
        end
    end
    if self.scheduleTime then
        local scheduleBirth = scheduler:new(birth.initialize, self, self.scheduleTime)
        self.schedulerId = scheduleBirth.functionId
    end
    ssf:debug("birth:_addGroup(): %s has been born into the world", self.groupName)
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

--[[ create a new instance of a search object
- @param #search self
- @return #search self
]]
function search:new()
    local self = util:inheritParent(self, handler:new())
    self.database = nil
    self.filters = {}
    return self
end

function search:searchByCoalition(coalition)
    self.filters.coalition = coalition
    return self
end

function search:searchByCategory(category)
    self.filters.category = category
    return self
end

function search:searchByCountry(countryId)
    self.filters.countryId = countryId
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

function search:searchOnce()
    local objects = {}
    local filterHit
    for objectName, objectData in pairs(self.database) do
        filterHit = true
        if self.subString then
            if not string.find(objectName, self.subString) then
                filterHit = false
            end
        end

        if self.prefix then
            local pfx = string.find(objectName, self.prefix, 1, true)
            if pfx ~= 1 then
                filterHit = false
            end
        end

        for filterType, filterValue in pairs(self.filters) do
            local fieldValue = objectData[filterType]
            if fieldValue ~= filterValue then
                filterHit = false
            end
        end

        if filterHit then
            objects[#objects+1] = group:getByName(objectName)
        end
    end
    return objects
end

searchGroup = {}

function searchGroup:new()
    local self = util:inheritParent(self, search:new())
    self.database = util:deepCopy(groupsByName)
    return self
end

searchUnit = {}

function searchUnit:new()
    local self = util:inheritParent(self, search:new())
    self.database = util:deepCopy(unitsByName)
    return self
end

searchStatic = {}

function searchStatic:new()
    local self = util:inheritParent(self, search:new())
    self.database = util:deepCopy(staticsByName)
    return self
end

searchAirbase = {}

function searchAirbase:new()
    local self = util:inheritParent(self, search:new())
    self.database = util:deepCopy(airbasesByName)
    return self
end

--[[

@class #zone

@authors Wizard

@description

@features

@created Apr 26, 2022

]]

zone = {}

function zone:getByName(zoneName)
    if zonesByName[zoneName] then
        local self = util:inheritParent(self, fsm:new())
        self.zoneName = zoneName
        self.zoneData = util:deepCopy(zonesByName[zoneName])
        return self
    end
end

function zone:getVec2()
    local vec2 = {}
    vec2.x = self.zoneData.x
    vec2.y = self.zoneData.y
    return vec2
end

function zone:getVec3()
    local vec3 = {}
    vec3.x = self.zoneData.x
    vec3.y = 0
    vec3.z = self.zoneData.y
    return vec3
end

function zone:getRadius()
    return self.zoneData.radius
end

function zone:getID()
    return self.zoneData.id
end

function zone:getColor()
    return self.zoneData.color
end

function zone:getProperties()
    return self.zoneData.properties
end

function zone:isHidden()
    return self.zoneData.hidden
end

function zone:getName()
    return self.zoneName
end

function zone:getType()
    return self.zoneData.type
end

function zone:inZone(vec3)
    local zoneVec3 = self:getVec3()
    if ((vec3.x - zoneVec3.x)^2 + (vec3.z - zoneVec3.z)^2)^0.5 <= self.zoneData.radius then
        return true
    end
    return false
end

-- needs to generate a completely unique id
function zone:draw(coalition, lineColor, fillColor, lineType, readOnly, message)
    --local drawingId = generateMarkId()
    if self.drawingId then -- undraw an existing one
        self:undraw()
    end
    --self.drawingId = drawingId -- storing for later when it comes time to undraw
    if self.zoneData.type == 2 then
        local quad = {}
        quad[#quad+1] = coalition
        quad[#quad+1] = 1 --drawingId
        quad[#quad+1] = self.zoneData.verticies[1]
        quad[#quad+1] = self.zoneData.verticies[2]
        quad[#quad+1] = self.zoneData.verticies[3]
        quad[#quad+1] = self.zoneData.verticies[4]
        quad[#quad+1] = lineColor
        quad[#quad+1] = fillColor
        quad[#quad+1] = lineType
        quad[#quad+1] = readOnly or false
        quad[#quad+1] = message or nil
        trigger.action.quadToAll(unpack(quad))
    else
        local circle = {}
        local center = self:getVec3()
        circle[#circle+1] = coalition
        circle[#circle+1] = 1 --drawingId
        circle[#circle+1] = center
        circle[#circle+1] = self.zoneData.radius
        circle[#circle+1] = lineColor
        circle[#circle+1] = fillColor
        circle[#circle+1] = lineType
        circle[#circle+1] = readOnly or false
        circle[#circle+1] = message or nil
        trigger.action.circleToAll(unpack(circle))
    end
    return self
end

function zone:undraw()
    if self.drawingId then
        trigger.action.removeMark(self.drawingId)
        self.drawingId = nil
    end
    return self
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
        local self = util:inheritParent(self, handler:new())
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
    self:handleUnitEvent(self, event, self:getName())
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
    if self:isActive() and self:isExist() and self:getLife() > 0 then
        return true
    end
    return false
end

--[[ return a boolean the #group object is in a zone
- @param #group self
- @param #string zoneName [the name of the zone to check if the #group object is inside]
- @param #boolean allOfGroupInZone [if true, the entire group must be in the zone to return true]
- @return #boolean
]]
function unit:inZone(zoneName)
    local triggerZone = zone:getByName(zoneName)
    if triggerZone then
        local inZone = triggerZone:inZone(self:getPoint())
        return inZone
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
        local self = util:inheritParent(self, handler:new())
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
        local self = util:inheritParent(self, handler:new())
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

--[[ create a new instance of a group object
- returns any object that has been placed in the mission or dynamically born
- @param #group self
- @param #string groupName
- @return #group self
]]
function group:getByName(groupName)
    if groupsByName[groupName] ~= nil then
        local self = util:inheritParent(self, handler:new())
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
    self:handleGroupEvent(self, event, self.groupName)
    return self
end

--[[ return a #unit object within the #group object by its current index or name
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

--[[ return an array of #unit objects within the #group object
- @param #group self
- @return #array #units [array of unit objects]
]]
function group:getUnits()
    local units = {}
    if self.groupTemplate then
        for _, u in pairs(self.groupTemplate.units) do
            units[#units+1] = unit:getByName(u.name)
        end
    end
    return units
end

--[[ return a deep copy of the #group object template
- @param #group self
- @return #table groupTemplate
]]
function group:getTemplate()
    return util:deepCopy(self.groupTemplate)
end

--[[ return the average speed of the #group object in kilometers per hour
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

--[[ return the average vec3 point from the #group object
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

--[[ return the average amount of fuel remaining for the #group object
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

--[[ return the average percentage of health for the #group object
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

--[[ get targets detected by the #group object
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

--[[ return a boolean if the #group object is alive
- @param #group self
- @return #boolean [true if at least one unit is still alive]
]]
function group:isAlive()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        for _, unit in pairs(self:getDCSUnits()) do
            if unit:isActive() and unit:isExist() and unit:getLife() > 0 then
                return true
            end
        end
    end
    return false
end

--[[ return a boolean if the #group object is in air
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

--[[ return a boolean the #group object is in a zone
- @param #group self
- @param #string zoneName [the name of the zone to check if the #group object is inside]
- @param #boolean allOfGroupInZone [if true, the entire group must be in the zone to return true]
- @return #boolean
]]
function group:inZone(zoneName, allOfGroupInZone)
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        local units = self:getUnits()
        local inZoneCount = 0
        for _, _unit in pairs(units) do
            if _unit:inZone(zoneName) then
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
    return false
end

-- ** dcs class #Group Wrapper Methods ** --

--[[ return the DCS Class Group from the #group object
- @param #group self
- @return DCS#Group
]]
function group:getDCSGroup()
    local dcsGroup = Group.getByName(self.groupName)
    if dcsGroup then
        return dcsGroup
    end
    return nil
end

--[[ return the category from the #group object
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

--[[ return the coalition from the #group object
-- coalition.side enums found here: https://wiki.hoggitworld.com/view/DCS_singleton_coalition
- @param #group self
- @return #number groupCoalition
]]
function group:getCoalition()
    local dcsGroup = self:getDCSGroup()
    if dcsGroup then
        return dcsGroup:getCoalition()
    end
    return nil
end

--[[ return the group name from the #group object
- @param #group self
- @return #string groupName
]]
function group:getName()
    return self.groupName or nil
end

--[[ return the unique object identifier given to the #group object
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

--[[ get a dcs class #Unit from the #group object
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

--[[ get all the DCS#Units from the #group object
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

--[[ return the current size of the #group object
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

--[[ return the inital size of the #group object
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

--[[ return the DCS#Controller for the #group object
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

--[[ return a boolean if the #group object exists currently
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

--[[ destroy the #group object with no explosion
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

--[[ enable the #group object to have its radar emitters on or off
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

ssf:initialize()
ssf:info("Simple Scripting Framework %s Loaded Successfully", ssf.version)