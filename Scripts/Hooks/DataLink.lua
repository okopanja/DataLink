package.path = package.path .. lfs.writedir() .. [[Mods\tech\DataLink\Scripts\Hooks\?.lua;]]
local Logging = require("Utils.Logging").new("DataLink.log")
local ScriptedEWRContactSource = require("ScriptedEWRContactSource")
-- local DCSContactSource = require("DCSContactSource")
local DataLinkDeviceConnector = require("DataLinkDeviceConnector")

local dataLinkDeviceConnector = DataLinkDeviceConnector:new()
dataLinkDeviceConnector:initialize()

local function onContactsReceived(object, contacts)
	Logging:info("onContactsReceived: "..tostring(#contacts).." contacts")
	dataLinkDeviceConnector:transfer(contacts)
end

local contactSource = ScriptedEWRContactSource:new()
-- disabled until LOS (line of sight respecting aspect/terrain filtering) is implemented
-- local contactSource = DCSContactSource:new()
contactSource:addEventHandler(contactSource.EventTypes.ContactsReceived, nil, onContactsReceived)
contactSource:initialize()
