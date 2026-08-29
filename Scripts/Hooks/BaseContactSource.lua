local EventSource = require("EventSource")

local ContactEventSource = EventSource:new()

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
    return o
end

function ContactEventSource:initialize()
    -- Initialization logic for the base contact source
end

return ContactEventSource