local Logging = require("Utils.Logging").new("DataLink.log")

local DataLinkDeviceConnector = {}

local MAX_CONTACTS = 20
local ARGS_PER_CTX = 5
local DL_COMMAND_ID = 123456
local DL_COMMAND_ARG = 123456
local ARG_SEQ      = DL_COMMAND_ID + 1
local ARG_COUNT    = ARG_SEQ + 1
local ARG_BASE     = ARG_COUNT + 1         -- contact slots start here
local ARG_EXPERIMENT = ARG_BASE + MAX_CONTACTS * ARGS_PER_CTX  -- used for testing / experimentation
-- Draw argument used for device discovery handshake.
-- After sending DL_COMMAND_ID to a device, the DataLink device responds by writing
-- DL_DISCOVERY_VALUE to DL_DISCOVERY_ARG via draw_argument_value().
-- The hook confirms discovery by reading Export.LoGetAircraftDrawArgumentValue(DL_DISCOVERY_ARG).
local DL_DISCOVERY_ARG   = 512
local DL_DISCOVERY_VALUE = 1.0

function DataLinkDeviceConnector:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.contacts = {}
  o.datalink_device = nil
  o.dl_seq = 0
  return o
end

function DataLinkDeviceConnector:initialize()
  Logging:info("DataLinkDeviceConnector:initialize: Initializing DataLinkDeviceSink")
  -- register callbacks which will pass the the events to the object method handlers
  DCS.setUserCallbacks({
    onNetMissionChanged = function(missionName)
      self:onNetMissionChanged(missionName)
    end,
    onPlayerChangeSlot = function(playerID)
      self:onPlayerChangeSlot(playerID)
    end,
  })
end

function DataLinkDeviceConnector:onNetMissionChanged(missionName)
  Logging:info("DataLinkDeviceConnector:onNetMissionChanged: "..missionName)
  -- Handle mission change logic here
end

function DataLinkDeviceConnector:onPlayerChangeSlot(playerID)
  Logging:info("DataLinkDeviceConnector:onPlayerChangeSlot: "..playerID)
  if net.get_my_player_id() == playerID then
    Logging:info("Player changed slot to "..playerID)    
    self.datalink_device = self:findDataLinkDevice()
    if self.datalink_device then
      Logging:info("DataLink device found and initialized.")
    else
      Logging:info("DataLink device not found.")
    end
  end
end

function DataLinkDeviceConnector:findDataLinkDevice()
	for i = 0, 1200 do
		local dev = Export.GetDevice(i)
		if dev then
			dev:SetCommand(DL_COMMAND_ID, DL_COMMAND_ARG)
			if Export.LoGetAircraftDrawArgumentValue(DL_DISCOVERY_ARG) == DL_DISCOVERY_VALUE then
				Logging:info("Found DataLink device at index "..i)
				return dev
			end
		end
	end
	return nil
end

function DataLinkDeviceConnector:transfer(contacts)	
	if not self.datalink_device then
		self.datalink_device = self:findDataLinkDevice()
	end

	if not self.datalink_device then 
		Logging:info("transfer: no DataLink device found.")
		return 
	end

	self.dl_seq = (self.dl_seq + 1) % 1000
	if not self.dl_seq then
		self.dl_seq = 0
	end

  Logging:info("Transferring "..#contacts.." contacts to DataLink device")
  self.datalink_device:SetCommand(ARG_COUNT, #contacts)
  Logging:info("Looping through contacts to set arguments")
  for i, aircraft in ipairs(contacts) do
    Logging:info("Transferring contact "..i..": brg="..tostring(aircraft:getBearing()).." rng="..tostring(aircraft:getRange()).." alt="..tostring(aircraft:getAltitude()).." spd="..tostring(aircraft:getSpeed()).." hdg="..tostring(aircraft:getHeading()))
    local b = ARG_BASE + (i - 1) * ARGS_PER_CTX
    self.datalink_device:SetCommand(b + 0, aircraft:getBearing())
    self.datalink_device:SetCommand(b + 1, aircraft:getRange())
    self.datalink_device:SetCommand(b + 2, aircraft:getAltitude())
    self.datalink_device:SetCommand(b + 3, aircraft:getSpeed())
    self.datalink_device:SetCommand(b + 4, aircraft:getHeading())
  end

  -- Write sequence counter LAST so the device/page sees a consistent snapshot
  self.datalink_device:SetCommand(ARG_SEQ, self.dl_seq)
end

return DataLinkDeviceConnector