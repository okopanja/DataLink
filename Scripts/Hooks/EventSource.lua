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
        -- any of the handlers may error out, and block the further dispatching of event to other handlers
        local status, err = pcall(eventHandlerInfo.eventHandler, eventHandlerInfo.object, eventArg)
        if not status then
            Logging:error("Error dispatching event: " .. tostring(err) ..
                " for event type: " .. tostring(eventType) ..
                " for object: " .. tostring(eventHandlerInfo.object) ..
                ":" .. tostring(type(eventHandlerInfo.object)) ..
                " to event handler: " .. tostring(eventHandlerInfo.eventHandler)
            )
        end
    end
end

return EventSource