local Logging = require("Utils.Logging").new("DataLink.log")
local EventSource = require("EventSource")
local Table = require("Utils.Table")
local Contact = require("Contact")
dofile(lfs.writedir() .. [[Mods\tech\DataLink\Cockpit\Scripts\common.lua]])
local ContactEventSource = EventSource:new()
local UnitData = require("UnitData")
local GlobalData = require("GlobalData")
local EventTypes = {
    Activated = 1,
    Deactivated = 2,
    ContactsReceived = 3,
}

function ContactEventSource:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.EventTypes = EventTypes
    o.eventHandlers = {
        [EventTypes.Activated] = {},
        [EventTypes.Deactivated] = {},
        [EventTypes.ContactsReceived] = {},
    }
    o.active = false
    return o
end

function ContactEventSource:initialize()
    -- Initialization logic for the base contact source
end

function ContactEventSource:setActive(active)
    self.active = active
end

function ContactEventSource:getActive()
    return self.active
end

function ContactEventSource:updateOwnPlayerContact(playerID)
    if not self.current_player_contact then        
        self.current_player_contact = Contact:new({id = playerID })
    end
    if self.current_player_contact:getID() == nil and playerID ~= nil then
        self.current_player_contact:setID(playerID)
    end
    local selfData = Export.LoGetSelfData()
    if selfData == nil then
        Logging:info("Deactivated: selfData is nil")
        self:setActive(false)
        return
    end
    self.current_player_contact:setSide(GlobalData:getCoalitionByCountry(selfData.Country))
    self.current_player_contact:setPosition({
      x = selfData.Position.x,
      alt = selfData.Position.y,
      z = selfData.Position.z
    })
    self.current_player_contact:setHeading(math.deg(selfData.Heading))
    self.current_player_contact:setType(selfData.name)
    self.current_player_contact:setSpeed(Export.LoGetTrueAirSpeed() * 3.6)
    self.current_player_contact:setIFF(UnitData.IFF.FRIENDLY)

    self:setActive(Table.is_in_keys(SUPPORTED_AIRCRAFT, selfData.Name))
    Logging:info("updateOwnPlayerContact: self.active = " .. tostring(self.active))
    Logging:info("selfData.name: "..tostring(selfData.Name))
end

function ContactEventSource:deactivate()
    self:setActive(false)
end

return ContactEventSource