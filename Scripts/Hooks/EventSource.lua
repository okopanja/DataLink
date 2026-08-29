local EventSource = {}

local EventTypes = {
    Activated = 1,
    Deactivated = 2,
    ContactsReceived = 3,
}

function EventSource:new()
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

function EventSource:initialize()
    -- Initialization logic for the base contact source
end

function EventSource:addEventHandler(eventType, object, eventHandler)
    self.eventHandlers[eventType][#self.eventHandlers[eventType] + 1] = { object = object, eventHandler = eventHandler }
end

function EventSource:dispatchEvent(eventType, eventArg)
    for k, eventHandlerInfo in pairs(self.eventHandlers[eventType]) do        
        eventHandlerInfo.eventHandler(eventHandlerInfo.object, eventArg)
    end
end

return EventSource