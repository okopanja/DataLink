local Logging = require("Utils.Logging").new("DataLink.log")
local BaseContactSource = require("BaseContactSource")
local Player = require("Player")
local Aircraft = require("Aircraft")
local ScriptedEWRContactSource = BaseContactSource:new()
local net = require("net")

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
  Logging:info("Initializing ScriptedEWRContactSource")
  -- register callbacks which will pass the the events to the object method handlers
  DCS.setUserCallbacks({
    onNetMissionChanged = function(missionName)
      self:onNetMissionChanged(missionName)
    end,
    onTriggerMessage = function(message, clearView)
      self:onTriggerMessage(message, clearView)
    end,
    onPlayerChangeSlot = function(playerID)
      self:onPlayerChangeSlot(playerID)
    end,
  })
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
  if net.get_my_player_id() == playerID then return end
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
	if ewr_type == "SPS" then
    local contacts = self:parseEWR_SPS(msg)
		return contacts
	end
	if ewr_type == "BLUEFLAG" then
		-- return parse_ewr_blueflag(msg)
    return nil
	end
	Logging:info("parse_ewr: no parser registered for type " .. ewr_type)
	return nil
end

function ScriptedEWRContactSource:recognizeEWRType(msg)
	local first_line = msg:match("^[^\n]*")
	if not first_line then return nil end
	if first_line:find("Contention EWR") then
		return "SPS"
	end
	if first_line:find("CURRENT PICTURE") then
		return "BLUEFLAG"
	end
	return nil
end

function ScriptedEWRContactSource:parseEWR_SPS(msg)
	local contacts = {}
	for line in msg:gmatch("[^\n]+") do
		-- TYPE  BRG  RNG_VAL RNG_UNIT  ALT_VAL ALT_UNIT  SPD_VAL SPD_UNIT  HDG  [Aspect]
		local brg, rng_val, rng_unit, alt_s, alt_unit, spd_val, spd_unit, hdg =
			line:match("^%S+%s+(%d+)%s+([%d%.]+)%s+([%a]+)%s+([%d,]+)%s+([%a]+)%s+([%d%.]+)%s+([%a/]+)%s+(%d+)")

		if brg then
			local rng = tonumber(rng_val)
			if rng_unit:lower() == "nm" then
				rng = rng * 1.852
			end

			local alt = tonumber((alt_s:gsub(",", "")))
			if alt_unit:lower() == "ft" then
				alt = alt * 0.3048
			end

			local spd = tonumber(spd_val)
			if spd_unit:lower() == "knts" or spd_unit:lower() == "kts" then
				spd = spd * 1.852
			end

      local aircraft = Aircraft:new()
      aircraft:setBearing(tonumber(brg))
      aircraft:setRange(rng)
      aircraft:setAltitude(alt)
      aircraft:setSpeed(spd)
      aircraft:setHeading(tonumber(hdg))

      contacts[#contacts + 1] = aircraft

			-- if #contacts >= MAX_CONTACTS then break end
		end
	end
	Logging:info("parseEWR_SPS: parsed "..#contacts.." contacts")
	return #contacts > 0 and contacts or nil
end

return ScriptedEWRContactSource