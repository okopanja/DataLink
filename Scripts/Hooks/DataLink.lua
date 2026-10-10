-- If the user Disabled the mod, log a message and return early without initializing the plugin.
local Options = require('optionsEditor')
if Options.getOption("plugins.DataLink.generalEnabled") == false then
	log.info("DataLink plugin is disabled via options. To enable it, visit the Options -> Special -> DataLink menu.")
	return
end

log.info("Initializing DataLink plugin...")

package.path = package.path .. 
	lfs.writedir() .. [[Mods\tech\DataLink\Scripts\Hooks\?.lua;]] .. -- needed for lest of lua modules to load
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
contactProcessor:setRadarContactSource(radarContactSource)

ewrContactSource:addEventHandler(ewrContactSource.EventTypes.ContactsReceived, contactProcessor, contactProcessor.onEWRContactsUpdate)
dataLinkTransiever:addEventHandler(dataLinkTransiever.EventTypes.ContactsReceived, contactProcessor, contactProcessor.onFigherToFighterContactsUpdate)
radarContactSource:addEventHandler(radarContactSource.EventTypes.ContactsReceived, contactProcessor, contactProcessor.onRadarContactsUpdate)

dataLinkDeviceConnector:initialize()
ewrContactSource:initialize()
radarContactSource:initialize()
dataLinkTransiever:initialize()
contactProcessor:initialize()

log.info("DataLink MOD export hook initialization completed.")
