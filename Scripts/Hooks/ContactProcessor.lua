local ContactProcessor = {}
local Logging = require("Utils.Logging").new("DataLink.log")
local Contact = require("Contact")
local net = require("net")
local UnitData = require("UnitData")
local GlobalData = require("GlobalData")
local Options = require('optionsEditor')
local DCSTimer = require("DCSTimer")
local Table = require("Utils.Table")
dofile(lfs.writedir() .. [[Mods\tech\DataLink\Cockpit\Scripts\common.lua]])

function ContactProcessor:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.contacts = {}
    self.timer = DCSTimer:new(1)
    self.active = false
    return o
end

function ContactProcessor:initialize()
    self:configure()
    DCS.setUserCallbacks({
        onNetMissionChanged = function(missionName)
            self:configure()
            if self.enabled == false then return end
            self:onNetMissionChanged(missionName)
        end,
        onSimulationFrame = function()
            if self.enabled == false then return end
            if self.active then
                self:onSimulationFrame()
            end
        end,
        onActivatePlane = function(airplaneID)
            if self.enabled == false then return end
            self:onActivatePlane(airplaneID)
        end,
        onNetDisconnect = function(arg1, arg2)
            if self.enabled == false then return end
            Logging:info("ContactProcessor:onNetDisconnect")
            self.active = false
        end,
    })
    Logging:info("ContactProcessor: "..tostring(self.enabled))
end

function ContactProcessor:configure()
    GlobalData:updateServerExportSettings()
    self.enabled = Options.getOption("plugins.DataLink.generalEnabled") and GlobalData:isOwnshipExportAllowed()
    Logging:info("ContactProcessor.enabled: "..tostring(self.enabled))
end

function ContactProcessor:onNetMissionChanged(missionName)
    Logging:info("ContactProcessor:onNetMissionChanged: "..missionName)
    Logging:info("Updating country coalition map")
    GlobalData:updateCountryCoalitionMap()
end

function ContactProcessor:onActivatePlane(airplaneID)
    Logging:info("ContactProcessor:onActivatePlane called with airplaneID: " .. tostring(airplaneID))
    if Table.is_in_keys(SUPPORTED_AIRCRAFT, airplaneID) then
        self.active = true
        self:updateOwnContact()
        self:updateIFF(self.ownContact)
    else
        self.active = false
    end
end

function ContactProcessor:onSimulationFrame()
    local elapsed, elaspedTime = self.timer:intervalHasElapsed()
    if not elapsed then return end
    self.timer:reset()
    -- if the sensor export is not allowed, transfer own contacts with no other targets
    if (GlobalData:isSensorExportAllowed() == false) and (GlobalData:isOwnshipExportAllowed()) == true then
        Logging:info("ContactProcessor:onSimulationFrame: Ownship export allowed but sensor export not allowed, transferring own contact only")
        self:updateOwnContact()
        self:updateIFF(self.ownContact)
        self.dataLinkTransiever:transfer({})
    end
end

function ContactProcessor:setDataLinkConnector(dataLinkConnector)
    self.dataLinkConnector = dataLinkConnector
end

function ContactProcessor:setDataLinkTransiever(dataLinkTransiever)
    self.dataLinkTransiever = dataLinkTransiever
end

function ContactProcessor:setRadarContactSource(radarContactSource)
    self.radarContactSource = radarContactSource
end

function ContactProcessor:onRadarContactsUpdate(contacts)
    -- if disabled, do not receive updates
    if self.enabled == false then return end
    -- Implement radar contacts update logic here
	Logging:info("onRadarContactsReceived: "..tostring(#contacts).." contacts")
	self.dataLinkTransiever:transfer(contacts)
end

function ContactProcessor:calculateBearingAndRange(contact)
    Logging:info("Calculating bearing")
    contact:setBearing(self.ownContact:getBearingToContact(contact))
    Logging:info("Calculating range")
    contact:setRange(self.ownContact:getRangeToContact(contact))
end

function ContactProcessor:onFigherToFighterContactsUpdate(contacts)
    -- if disabled, do not receive updates
    if self.enabled == false then return end
    Logging:info("onFigherToFighterContactsUpdate: "..tostring(#contacts).." contacts")
    -- Update the own contact information before processing contacts
    self:updateOwnContact()
    for i, contact in ipairs(contacts) do
        self:updateIFF(contact)
        self:calculateBearingAndRange(contact)
        Logging:info("Correlating contact: "..tostring(contact.id))
        local corellated_contact = self:corellateContact(contact)
        if corellated_contact ~= nil then
            Logging:info("Found correlated contact: "..tostring(corellated_contact.id))
            if contact:getLastSeen() > corellated_contact:getLastSeen() then
                Logging:info("Updating correlated contact with newer information from contact: "..tostring(contact.id))
                corellated_contact:updateFrom(contact)
                Logging:info("Updated correlated contact with information from contact: "..tostring(contact.id))
            end
        else
            Logging:info("Adding new contact with ID: "..tostring(contact.id))
            self.contacts[#self.contacts + 1] = contact
        end
    end
    Logging:info("Cleaning up stale contacts")
    self:cleanupStaleContacts()
    Logging:info("Transferring updated contacts to DataLinkConnector")
    self.dataLinkConnector:transfer(self.contacts)
end

function ContactProcessor:onEWRContactsUpdate(contacts)
    -- if disabled, do not receive updates
    if self.enabled == false then return end
    -- Implement EWR contacts update logic here
    Logging:info("onEWRContactsUpdate: "..tostring(#contacts).." contacts")
	self.dataLinkConnector:transfer(contacts)
end

function ContactProcessor:reset()
    -- Implement reset logic here
    self.contacts = {}
end

function ContactProcessor:cleanupStaleContacts()
    local current_time = os.time()
    local stale_threshold = 60 -- seconds, adjust as needed
    local i = 1
    while i <= #self.contacts do
        local contact = self.contacts[i]
        local is_elapsed, elapsed = contact:getAgeTimer():intervalHasElapsed()
        if is_elapsed then
            Logging:info("Removing stale contact with ID: "..tostring(contact.id).. " after "..tostring(elapsed).." seconds.")
            table.remove(self.contacts, i)
        else
            i = i + 1
        end
    end
end

-- Corellation is done based on game object ID (contact.id)
function ContactProcessor:getExistingContact(contact)
    for i, current_contact in ipairs(self.contacts) do
        if current_contact.id == contact.id then
            return current_contact
        end
    end
    return nil
end

-- Corellation is done based on game object ID (contact.id) but for more realism
-- Correlation by position and expected movement should be done.
-- This however may result in multiple contacts being correlated, among which only one should be selected
-- Therefore they should be ranked likely by their probability of being the same contact.
function ContactProcessor:corellateContact(contact)
    -- Implement correlation logic based on position and expected movement here
    -- This is a placeholder function and should be properly implemented
    return self:getExistingContact(contact)
end

function ContactProcessor:updateOwnContact()
    self.ownContact = Contact:new({id = net.get_my_player_id()})
    local selfData = Export.LoGetSelfData()
    if selfData == nil then
        return nil
    end
    self.ownContact:setSide(GlobalData:getCoalitionByCountry(selfData.Country))
    self.ownContact:setPosition({
      x = selfData.Position.x,
      alt = selfData.Position.y,
      z = selfData.Position.z
    })
    self.ownContact:setType(selfData.name)
end

function ContactProcessor:updateIFF(contact)
    local side = contact:getSide()
    Logging:info("Updating IFF for contact with ID: "..tostring(contact.id).." with side: "..tostring(side))
    Logging:info("Own contact side: "..tostring(self.ownContact:getSide()))
    if side == "red" or side == "blue" then
        if side == self.ownContact:getSide() then
            Logging:info("It's friendly")
            contact:setIFF(UnitData.IFF.FRIENDLY)
        else
            Logging:info("It's hostile")
            contact:setIFF(UnitData.IFF.HOSTILE)
        end
    else
        if side == "neutral" or side == "spectator" then
            Logging:info("It's neutral")
            contact:setIFF(UnitData.IFF.NEUTRAL)
        else
            Logging:info("It's unknown")
            contact:setIFF(UnitData.IFF.UNKNOWN)
        end
    end
    Logging:info("Updated IFF for contact with ID: "..tostring(contact.id).." to "..tostring(contact:getIFF()))
end

return ContactProcessor