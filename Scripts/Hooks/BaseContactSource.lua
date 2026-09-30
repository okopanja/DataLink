local Logging = require("Utils.Logging").new("DataLink.log")
local EventSource = require("EventSource")
local Table = require("Utils.Table")
local Aircraft = require("Aircraft")
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

function ContactEventSource:updateOwnPlayerAircraft(playerID)
    if not self.current_player_aircraft then        
        self.current_player_aircraft = Aircraft:new({id = playerID })
    end
    if self.current_player_aircraft:getID() == nil and playerID ~= nil then
        self.current_player_aircraft:setID(playerID)
    end
    local selfData = Export.LoGetSelfData()
    if selfData == nil then
        Logging:info("Deactivated: selfData is nil")
        self:setActive(false)
        return
    end
    self.current_player_aircraft:setSide(GlobalData:getCoalitionByCountry(selfData.Country))
    self.current_player_aircraft:setPosition({
      x = selfData.Position.x,
      alt = selfData.Position.y,
      z = selfData.Position.z
    })
    self.current_player_aircraft:setHeading(math.deg(selfData.Heading))
    self.current_player_aircraft:setType(selfData.name)
    self.current_player_aircraft:setSpeed(Export.LoGetTrueAirSpeed() * 3.6)
    self.current_player_aircraft:setIFF(UnitData.IFF.FRIENDLY)

    self:setActive(Table.is_in_keys(SUPPORTED_AIRCRAFT, selfData.Name))
    Logging:info("updateOwnPlayerAircraft: self.active = " .. tostring(self.active))
    Logging:info("selfData.name: "..tostring(selfData.Name))
end


return ContactEventSource