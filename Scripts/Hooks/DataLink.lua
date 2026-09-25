package.path = package.path .. 
	lfs.writedir() .. [[Mods\tech\DataLink\Scripts\Hooks\?.lua;]] ..
	lfs.writedir() .. [[Mods\tech\DataLink\Scripts\Hooks\External\?.lua;]] .. -- added for regular external modules
	lfs.writedir() .. [[Mods\tech\DataLink\Scripts\Hooks\External\?\init.lua;]] -- added for uuid funky dependancy declaration

-- make sure the random seed is initialized for any random operations early on
math.randomseed(os.time())

local Logging = require("Utils.Logging").new("DataLink.log")
local ScriptedEWRContactSource = require("ScriptedEWRContactSource")
-- local DCSContactSource = require("DCSContactSource")
local RadarContactSource = require("RadarContactSource")
local DataLinkTransiever = require("DataLinkTransiever")
local DataLinkDeviceConnector = require("DataLinkDeviceConnector")
local ContactProcessor = require("ContactProcessor")

-- used to interact with DataLink device
local dataLinkDeviceConnector = DataLinkDeviceConnector:new()
-- Used to communicate with other players via the data link
local dataLinkTransiever = DataLinkTransiever:new()
-- Used to receive contacts from EWR sources
local ewrContactSource = ScriptedEWRContactSource:new()
-- disabled until LOS (line of sight respecting aspect/terrain filtering) is implemented
-- local contactSource = DCSContactSource:new()
-- Used to receive contacts from radar
local radarContactSource = RadarContactSource:new()
-- Used for processing of contacts (e.g., filtering, merging, and prioritizing)
local contactProcessor = ContactProcessor:new()

contactProcessor:setDataLinkConnector(dataLinkDeviceConnector)
contactProcessor:setDataLinkTransiever(dataLinkTransiever)

ewrContactSource:addEventHandler(ewrContactSource.EventTypes.ContactsReceived, contactProcessor, contactProcessor.onEWRContactsUpdate)
dataLinkTransiever:addEventHandler(dataLinkTransiever.EventTypes.ContactsReceived, contactProcessor, contactProcessor.onFigherToFighterContactsUpdate)
radarContactSource:addEventHandler(radarContactSource.EventTypes.ContactsReceived, contactProcessor, contactProcessor.onRadarContactsUpdate)

dataLinkDeviceConnector:initialize()
ewrContactSource:initialize()
radarContactSource:initialize()
dataLinkTransiever:initialize("demo.nats.io", 4222, true)
