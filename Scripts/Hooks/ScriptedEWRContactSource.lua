local Logging = require("Utils.Logging").new("DataLink.log")
local BaseContactSource = require("BaseContactSource")
local Player = require("Player")
local Contact = require("Contact")
local UnitData = require("UnitData")
local ScriptedEWRContactSource = BaseContactSource:new()
local net = require("net")
local Options = require('optionsEditor')

local Sides = {
  [0] = "spectators",
  [1] = "red",
  [2] = "blue",
}

local function sideID(sidename)
  for id, name in pairs(Sides) do
    if name == sidename then
      return id
    end
  end
  return nil
end

function ScriptedEWRContactSource:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.EventHandlers = {}
  -- Contains all players in the game
  o.players = {}
  -- Contains all blue players in the game
  o.blue_players = {}
  -- Contains all red players in the game
  o.red_players = {}
  return o
end

function ScriptedEWRContactSource:initialize()
  self:configure()
  -- register callbacks which will pass the the events to the object method handlers
  DCS.setUserCallbacks({
    onNetMissionChanged = function(missionName)
      if self.enabled == false then return end
      self:onNetMissionChanged(missionName)
    end,
    onTriggerMessage = function(message, clearView)
      if self.enabled == false then return end
      if self:getActive() then
        self:onTriggerMessage(message, clearView)
      end
    end,
    onPlayerChangeSlot = function(playerID)
      if self.enabled == false then return end
      self:onPlayerChangeSlot(playerID)
    end,
    onActivatePlane = function(airplaneID)
      if self.enabled == false then return end
      Logging:info("onActivatePlane called with airplaneID: " .. tostring(airplaneID))
      self:updateOwnPlayerContact()
    end,

  })
  Logging:info("ScriptedEWRContactSource: "..tostring(self.enabled))
end

function ScriptedEWRContactSource:configure()
  self.enabled = Options.getOption("plugins.DataLink.generalEnabled") and
                 Options.getOption("plugins.DataLink.generalEnabledScriptedEwr")
end

function ScriptedEWRContactSource:onTriggerMessage(message, clearView)
	Logging:info("ScriptedEWRContactSource:onTriggerMessage: "..message)
  local contacts = self:parseEWR(message)
	if contacts then
    Logging:info("Dispatching ContactsReceived event with "..(#contacts).." contacts")
    self:dispatchEvent(self.EventTypes.ContactsReceived, contacts)
	else
		Logging:info("onTriggerMessage: no contacts parsed")
	end
end

function ScriptedEWRContactSource:onNetMissionChanged(missionName)
    Logging:info("ScriptedEWRContactSource:onNetMissionChanged: "..missionName)
    self:updateAvailableCoalitionsAndSlots()
    Logging:info("Coalitions: "..net.lua2json(self.availableCoalitions))
    self.airports = nil
end

function ScriptedEWRContactSource:onPlayerChangeSlot(playerID)
  if playerID == nil then return end
  -- Ignore own slot changes, but reset datalink device and sequence counter
  if net.get_my_player_id() == playerID then
    self:updateOwnPlayerContact(playerID)
    return 
  end
  -- Create a new Player object for the player who changed slots
  Logging:info("ScriptedEWRContactSource:onPlayerChangeSlot: playerID="..tostring(playerID))
  local player_info = net.get_player_info(playerID)
  if not player_info then
	  Logging:info("onPlayerChangeSlot: no player info found for playerID="..tostring(playerID))
	return
  end
  local player = Player:new(player_info)
  self.players[playerID] = player
  
  if player.side == sideID("blue") then
	self.blue_players[playerID] = player
  elseif player.side == sideID("red") then
	self.red_players[playerID] = player
  end

  local side = Sides[player.side]
  local airport = "Unknown"
  if side == "blue" or side == "red" then
    local slots = self.availableCoalitions[side].availableSlots
    for i, slot in ipairs(slots) do
      if slot.unitId == player.slot then
        player.slotInfo = slot
      end
    end
    if player.slotInfo ~= nil then
      if player.slotInfo.airdrome then
        if player.slotInfo.airdrome.display_name ~= nil then
          airport = player.slotInfo.airdrome.display_name
        end
      else
        if player.slotInfo.groupName ~= nil then
          airport = player.slotInfo.groupName
        end
      end
    end
  end
  Logging:info("onPlayerChangeSlot: "..player:getText().." at "..airport)
end

function ScriptedEWRContactSource:updateAvailableCoalitionsAndSlots()
  self.availableCoalitions = DCS.getAvailableCoalitions()
  for coalitionID, coalition in pairs(self.availableCoalitions) do
    coalition.availableSlots = DCS.getAvailableSlots(coalition.name)
  end
end

function ScriptedEWRContactSource:parseEWR(msg)
	local ewr_type = self:recognizeEWRType(msg)
	if not ewr_type then
		Logging:info("parseEWR: unrecognized or non-EWR message")
		return nil
	end
	Logging:info("parseEWR: EWR type = " .. ewr_type)

  -- TODO: add support for opt-in servers
  Logging.info("NO servers are supported at this moment.")

	Logging:info("parse_ewr: no parser registered for type " .. ewr_type)
	return nil
end

function ScriptedEWRContactSource:recognizeEWRType(msg)
	local first_line = msg:match("^[^\n]*")
	if not first_line then return nil end

  -- TODO: add recognition logic for different EWR types based on the first line of the message
  -- Reserved for opt-in servers
  Logging.info("No servers are supported at this moment.")

	return nil
end

return ScriptedEWRContactSource