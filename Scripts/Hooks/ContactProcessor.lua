local ContactProcessor = {}
local Logging = require("Utils.Logging").new("DataLink.log")

function ContactProcessor:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.contacts = {}
    return o
end

function ContactProcessor:setDataLinkConnector(dataLinkConnector)
    self.dataLinkConnector = dataLinkConnector
end

function ContactProcessor:setDataLinkTransiever(dataLinkTransiever)
    self.dataLinkTransiever = dataLinkTransiever
end

function ContactProcessor:onRadarContactsUpdate(contacts)
    -- Implement radar contacts update logic here
	Logging:info("onRadarContactsReceived: "..tostring(#contacts).." contacts")
	-- pipe to our own for testing

	-- for now take just contacts belonging to blue side
	-- TODO: add support for displaying friendly/netural forcess
	local blueContacts = {}
	for i, contact in ipairs(contacts) do
		if contact.side == "blue" then
			blueContacts[#blueContacts + 1] = contact
		end
	end
	contacts = blueContacts
	-- transmit contacts to other players@J
	self.dataLinkTransiever:transfer(contacts)
	-- -- TODO: remove the self-feed used for testing purposes
	-- self.dataLinkConnector:transfer(contacts)
end

function ContactProcessor:onFigherToFighterContactsUpdate(contacts)
    -- Implement fighter-to-fighter contacts update logic here
    Logging:info("onFigherToFighterContactsUpdate: "..tostring(#contacts).." contacts")
end

function ContactProcessor:onEWRContactsUpdate(contacts)
    -- Implement EWR contacts update logic here
    Logging:info("onEWRContactsUpdate: "..tostring(#contacts).." contacts")
	self.dataLinkConnector:transfer(contacts)
end

function ContactProcessor:reset()
    -- Implement reset logic here
    self.contacts = {}
end

function ContactProcessor:getExistingContact(contact)
    for i, current_contact in ipairs(self.contacts) do
        if current_contact.id == contact.id then
            return current_contact
        end
    end
    return nil
end

return ContactProcessor