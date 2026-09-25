local Logging = require("Utils.Logging").new("DataLink.log")
local BaseContactSource = require("BaseContactSource")
local Player = require("Player")
local Aircraft = require("Aircraft")
local DCSTimer = require("DCSTimer")
local UnitData = require("UnitData")
local bitops = require("External.bitops")
local UNIT_PROPERTIES = UnitData.UNIT_PROPERTIES
local TARGET_FLAGS = UnitData.TARGET_FLAGS
local Sides = UnitData.Sides
local sideID = UnitData.sideID
local RadarContactSource = BaseContactSource:new()

local DEBUG = true
if DEBUG then
  -- load inspect
  inspect = dofile(lfs.writedir().."Mods/tech/DataLink/Cockpit/Scripts/inspect.lua")  
  -- saveInspect: saves a Lua value to a file in the dumps folder for inspection
  function saveInspect(inspect_name, inspect_value, use_lfs_resolution)
    local folder_path
    if use_lfs_resolution then
      folder_path = lfs.writedir().."Mods/tech/DataLink/Cockpit/Scripts/dumps/Su-27"
    else
      folder_path = LockOn_Options.script_path..[[dumps\]]..get_aircraft_type()
    end
    lfs.mkdir(folder_path)
    local file = io.open(folder_path..[[\]]..inspect_name..".lua",'w')
    if file then
      file:write(inspect(inspect_value))
      file:close()
    end
  end  
end

-- define flags which will be used for radar tracked targets
local TARGET_RADAR_TRACKED = TARGET_FLAGS.RADAR_SEARCH + TARGET_FLAGS.RADAR_TWS + TARGET_FLAGS.RADAR_LOCK

function RadarContactSource:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.timer = DCSTimer:new(1)
  o.aircrafts = {}
  return o
end

function RadarContactSource:clearAllContacts()
  self.aircrafts = {}
end

function RadarContactSource:initialize()
  Logging:info("Initializing RadarContactSource")
  -- Add any additional initialization logic here
  if Export.LoIsSensorExportAllowed() then
    DCS.setUserCallbacks({
        onNetMissionChanged = function(missionName)
          self:onNetMissionChanged(missionName)
        end,
        onPlayerChangeSlot = function(playerID)
        self:onPlayerChangeSlot(playerID)
        end,
        onSimulationFrame = function()
          if self:getActive() then
            self:onSimulationFrame()
          end
        end,
        onActivatePlane = function(airplaneID)
          Logging:info("RadarContactSource:onActivatePlane called with airplaneID: " .. tostring(airplaneID))
          self:updateOwnPlayerAircraft()
        end,
        onNetDisconnect = function(arg1, arg2)
          Logging:info("RadarContactSource:onNetDisconnect called")
          self:clearAllContacts()
          self.active = false
        end
    })
  else
    Logging:warn("Sensor export is not allowed")
  end
end

function RadarContactSource:onNetMissionChanged(missionName)
  Logging:info("RadarContactSource:onNetMissionChanged: "..missionName)
  self.timer:reset()
  self.currentMission = DCS.getCurrentMission().mission
  saveInspect("currentMission", self.currentMission, true)
  -- Map country IDs to their respective coalitions
  self.coalitions_by_country_id = {
  }  
  for coalition_name, coalition_countries in pairs(self.currentMission.coalitions) do
    for i, country in ipairs(coalition_countries) do
      self.coalitions_by_country_id[country] = coalition_name
    end
  end
  -- Handle mission change logic here
end

function RadarContactSource:onPlayerChangeSlot(playerID)
  if net.get_my_player_id() == playerID then 
    Logging:info("RadarContactSource:onPlayerChangeSlot: "..playerID)
    -- Handle player change slot logic here
    local player_info = net.get_player_info(playerID)
    self.player = Player:new(player_info)
    self:updateOwnPlayerAircraft(playerID)
  end    
end

function RadarContactSource:onSimulationFrame()
  -- Handle simulation frame logic here
  local elapsed, elapsedTime = self.timer:intervalHasElapsed()
  if elapsed then
    Logging:info("RadarContactSource:onSimulationFrame")
    self:clearAllContacts()
    self.timer:reset()
    local targets = Export.LoGetTargetInformation() or {}
    local lockedTargets = Export.LoGetLockedTargetInformation()
    local twsInfo = Export.LoGetTWSInfo()    
    self:updateOwnPlayerAircraft()
    for i, target in ipairs(targets) do
        local aircraft = Aircraft:new({id = target.ID})
        -- TODO: these 2 method do not work with the ID I got, needs to process target country id (sigh...)
        -- aircraft:setType(DCS.getUnitProperty(target.ID, UNIT_PROPERTIES.UNIT_TYPE))
        -- aircraft:setSide(DCS.getUnitProperty(target.ID, UNIT_PROPERTIES.UNIT_COALITION))
        aircraft:setSide(self.coalitions_by_country_id[target.country])
        aircraft:setPosition({
          x = target.position.p.x,
          alt = target.position.p.y,
          z = target.position.p.z
        })
        local velocity = {
          x = target.velocity.x,
          y = target.velocity.y,
          z = target.velocity.z
        }
        -- calculate heading from velocity, by using x and z
        local heading = math.atan2(velocity.x, velocity.z)
        -- TODO: heading looks wrong
        -- calculated speed in km/h
        local trueAirSpeed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2) * 3.6
        aircraft:setSpeed(trueAirSpeed)
        aircraft:setHeading(heading)
        aircraft:setRange(target.distance / 1000)
        aircraft:setBearing(self.current_player_aircraft:getBearingToAircraft(aircraft))
        aircraft:setFlags(target.flags)
        Logging:info("Aircraft ID: " .. tostring(aircraft:getID()))
        Logging:info("Aircraft side: " .. tostring(aircraft:getSide()))
        Logging:info("Aircraft type: " .. tostring(aircraft:getType()))
        for key, value in pairs(TARGET_FLAGS) do
          local flag_is_set = bitops.bitand(value,target.flags) == value
          if flag_is_set then
            Logging:info(key..": "..tostring(flag_is_set))
          end
        end
        if bitops.bitand(target.flags, TARGET_RADAR_TRACKED) ~= 0 then
          Logging:info("Target is radar tracked")
          self.aircrafts[#self.aircrafts + 1] = aircraft
        end
    end
    self:dispatchEvent(self.EventTypes.ContactsReceived, self.aircrafts)
  end
end

function RadarContactSource:toArray(dictionary)
  local result = {}
  for _, value in pairs(dictionary) do
    result[#result + 1] = value
  end
  return result
end    

return RadarContactSource
