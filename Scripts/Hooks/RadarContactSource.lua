local Logging = require("Utils.Logging").new("DataLink.log")
local BaseContactSource = require("BaseContactSource")
local Player = require("Player")
local Contact = require("Contact")
local DCSTimer = require("DCSTimer")
local UnitData = require("UnitData")
local GlobalData = require("GlobalData")
local bitops = require("External.bitops")
local Options = require('optionsEditor')
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
      folder_path = LockOn_Options.script_path..[[dumps\]]..get_contact_type()
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
  o.contacts = {}
  return o
end

function RadarContactSource:clearAllContacts()
  self.contacts = {}
end

function RadarContactSource:initialize()
  self:configure()
  if Export.LoIsSensorExportAllowed() then
    DCS.setUserCallbacks({
        onNetMissionChanged = function(missionName)
          self:configure()
          if self.enabled == false then return end
          self:onNetMissionChanged(missionName)
        end,
        onPlayerChangeSlot = function(playerID)
          if self.enabled == false then return end
          self:onPlayerChangeSlot(playerID)
        end,
        onSimulationFrame = function()
          if self.enabled == false then return end
          if self:getActive() then
            self:onSimulationFrame()
          end
        end,
        onActivatePlane = function(airplaneID)
          if self.enabled == false then return end
          Logging:info("RadarContactSource:onActivatePlane called with airplaneID: " .. tostring(airplaneID))
          self:updateOwnPlayerContact()
        end,
        onNetDisconnect = function(arg1, arg2)
          if self.enabled == false then return end
          Logging:info("RadarContactSource:onNetDisconnect called")
          self:clearAllContacts()
          self.active = false
        end
    })
  else
    Logging:warn("Sensor export is not allowed")
  end
  Logging:info("RadarContactSource: "..tostring(self.enabled))
end

function RadarContactSource:configure()
  self.enabled = Options.getOption("plugins.DataLink.generalEnabled")
end

function RadarContactSource:onNetMissionChanged(missionName)
  Logging:info("RadarContactSource:onNetMissionChanged: "..missionName)
  self.timer:reset()
  self.currentMission = DCS.getCurrentMission().mission
  saveInspect("currentMission", self.currentMission, true)
  -- Handle mission change logic here
end

function RadarContactSource:onPlayerChangeSlot(playerID)
  if net.get_my_player_id() == playerID then 
    Logging:info("RadarContactSource:onPlayerChangeSlot: "..playerID)
    -- Handle player change slot logic here
    local player_info = net.get_player_info(playerID)
    self.player = Player:new(player_info)
    self:updateOwnPlayerContact(playerID)
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
    self:updateOwnPlayerContact()
    for i, target in ipairs(targets) do
        local contact = Contact:new({id = target.ID})
        -- country in target is actually coalitionID!
        contact:setSide(Sides[target.country])
        contact:setPosition({
          x = target.position.p.x,
          alt = target.position.p.y,
          z = target.position.p.z
        })
        local velocity = {
          x = target.velocity.x,
          y = target.velocity.y,
          z = target.velocity.z
        }
        
        local headingDegree = math.deg(math.atan2(velocity.z, velocity.x))
        -- calculated speed in km/h
        local trueAirSpeed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2) * 3.6
        contact:setSpeed(trueAirSpeed)
        contact:setHeading(headingDegree)
        contact:setRange(target.distance / 1000)
        contact:setBearing(self.current_player_contact:getBearingToContact(contact))
        contact:setFlags(target.flags)
        contact:setContactSource(CONTACT_SOURCES.RLPK_27)
        Logging:info("Contact ID: " .. tostring(contact:getID()))
        Logging:info("Contact side: " .. tostring(contact:getSide()))
        Logging:info("Contact country:"..tostring(target.country))
        Logging:info("Contact type: " .. tostring(contact:getType()))
        for key, value in pairs(TARGET_FLAGS) do
          local flag_is_set = bitops.bitand(value,target.flags) == value
          if flag_is_set then
            Logging:info(key..": "..tostring(flag_is_set))
          end
        end
        if bitops.bitand(target.flags, TARGET_RADAR_TRACKED) ~= 0 then
          Logging:info("Target is radar tracked")
          self.contacts[#self.contacts + 1] = contact
        end
    end
    self:dispatchEvent(self.EventTypes.ContactsReceived, self.contacts)
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
