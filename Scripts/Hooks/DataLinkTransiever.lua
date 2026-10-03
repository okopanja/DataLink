local Logging = require("Utils.Logging").new("DataLink.log")
local BaseContactSource = require("BaseContactSource")
local DataLinkTransiever = BaseContactSource:new()
local DCSTimer = require("DCSTimer")
local UnitData = require("UnitData")
local GlobalData = require("GlobalData")
local JSON = require("JSON")
local Player = require("Player")
local uuid = require("uuid")
local Contact = require("Contact")
local Options = require('optionsEditor')

package.path = package.path .. lfs.writedir() .. [[Mods\tech\DataLink\Scripts\Hooks\External\ssl\lua\?.lua]]
package.cpath = package.cpath .. lfs.writedir() .. [[Mods\tech\DataLink\Scripts\Hooks\External\ssl\dll\?.dll]]

-- make sure SSL library is loaded before nats get used
require("ssl")

-- funky uuid requires custom random byte generator on Windows
uuid.set_rng(
    -- takes bytes_number as input and binary string of random bytes
    function(bytes_number)
        local bytes = {}
        for i = 1, bytes_number do
            bytes[i] = math.random(0, 255)
        end
        return string.char(unpack(bytes))
    end
)
local nats = require("External.nats")

local Sides = UnitData.Sides
local sideID = UnitData.sideID

dofile(lfs.writedir() .. [[Mods\tech\DataLink\Cockpit\Scripts\common.lua]])

local CONNECTION_STATUS = {
    NOT_CONNECTED = 1,
    CONNECTING = 2,
    CONNECTED = 3,
    FAILED = 4,
}

function DataLinkTransiever:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    self.timer = DCSTimer:new(1) -- Set the timer interval to 1 second
    self.connection_status = CONNECTION_STATUS.NOT_CONNECTED
    return obj
end

function DataLinkTransiever:initialize()
    self:configure()
    DCS.setUserCallbacks({
        onNetMissionChanged = function(missionName)
            self:onNetMissionChanged(missionName)
        end,
        onPlayerChangeSlot = function(playerID)
            if self.enabled == false then return end
            self:onPlayerChangeSlot(playerID)
        end,
        onSimulationFrame = function()
        if self.enabled == false then return end
          if self:getActive() then
            self:onSimulationFrame()
          end
        end,
        onActivatePlane = function(airplaneID)
          if self.enabled == false then return end
          Logging:info("DataLinkTransiever:onActivatePlane called with airplaneID: " .. tostring(airplaneID))
          self:updateOwnPlayerContact()
        end,
        onNetDisconnect = function(arg1, arg2)
            if self.enabled == false then return end
            if self.client then
                Logging:info("Disconnecting from NATS server...")
                self.client:shutdown()
                self.connection_status = CONNECTION_STATUS.NOT_CONNECTED
                self.client = nil
                Logging:info("Disconnected from NATS server.")
            end
        end,
    })
    Logging:info("DataLinkTransiever initialized")
end

function DataLinkTransiever:configure()
    self.enabled = Options.getOption("plugins.DataLink.generalEnabled") and
                   Options.getOption("plugins.DataLink.generalEnabledFighterToFighterDatalink")
    if self.enabled == false then return end
    self.host = Options.getOption("plugins.DataLink.networkNatsHostname")
    self.port = Options.getOption("plugins.DataLink.networkNatsPort")
    self.tls = Options.getOption("plugins.DataLink.networkNatsEnableSsl")
    self.connection_settings =
        {
            host = self.host,
            port = self.port,
            timeout = 20, -- general timeout for connection attempts
        }
    self.timeouts = {
        send_timeout = 0.100, -- send timeout
        receive_timeout = 0.005, -- receive needs to return fast
    }
    if self.tls then
        self.connection_settings.tls = true
        self.connection_settings.tls_ca_file = lfs.writedir() .. [[Mods\tech\DataLink\Scripts\Hooks\External\ssl\certs\ca-certificates.crt]]
    end
    Logging:info("TLS_CA_FILE: "..tostring(self.connection_settings.tls_ca_file))
end

function DataLinkTransiever:onNetMissionChanged(missionName)
    Logging:info("Net mission changed: " .. tostring(missionName))
    self.currentMissionName = missionName
    self:configure()
    if self.enabled == false then return end
    Logging:info("Connecting to: " .. tostring(self.host) .. ":" .. tostring(self.port))
    -- Connect to the NATS server with provided host and port.
    self.client = nats.connect(self.connection_settings)
    -- connection_settings/parameters is reused across (re)connects, so reset
    -- the fast post-connect timeouts left over from a previous session before
    -- the handshake, otherwise reading the server's INFO banner times out.
    self.client.parameters.receive_timeout = self.client.parameters.timeout
    self.client.parameters.send_timeout = self.client.parameters.timeout

    self.connection_status = CONNECTION_STATUS.CONNECTING
    local status, err = pcall(function() self.client:connect() end)

    if status then
        Logging:info("Connected to NATS server at " .. tostring(self.host) .. ":" .. tostring(self.port))
        self.connection_status = CONNECTION_STATUS.CONNECTED
        self.client.parameters.receive_timeout = self.timeouts.receive_timeout
        self.client.parameters.send_timeout = self.timeouts.send_timeout -- send timeout
    else
        Logging:error("Failed to connect to NATS server at " .. tostring(self.host) .. ":" .. tostring(self.port))
        Logging:error("Error: " .. tostring(err))
        self.connection_status = CONNECTION_STATUS.FAILED
    end
end

function DataLinkTransiever:onPlayerChangeSlot(playerID)
    if net.get_my_player_id() ~= playerID then
        return
    end

    Logging:info("Player changed slot: " .. tostring(playerID))
    self.timer:reset()
    -- Handle player change slot logic here
    local player_info = net.get_player_info(playerID)
    self.player = Player:new(player_info)
    self:updateOwnPlayerContact(playerID)

    Logging:info("Subscribing to NATS subject: " .. self:getNATSSubject())
    self.subscription_id = self.client:subscribe(self:getNATSSubject(), 
        function(message)
            self:handleIncomingMessage(message)
        end
    )
    -- self.client:publish(self:getNATSSubject(), "Subscribed: "..self.player:getName()) -- TODO: do we want to announce this?
    Logging:info("Subscribed to NATS subject: " .. self:getNATSSubject() .. " with subscription ID: " .. tostring(self.subscription_id))
    self.sender_uuid = uuid() -- generate a new sender UUID for this subscription
end

function DataLinkTransiever:onSimulationFrame()
    local elapsed, elapsedTime = self.timer:intervalHasElapsed()
    if not elapsed then
        return
    end    
    if self.connection_status ~= CONNECTION_STATUS.CONNECTED or self.connection_status == CONNECTION_STATUS.FAILED then
        return
    end
    Logging:info("Simulation frame update, elapsed time: " .. tostring(elapsedTime) .. " seconds")
    self:handleConnection()
    self.timer:reset()
    Logging:info("Waiting")
    local status, err = pcall(function() self.client:wait() end)
    -- timeout is not aa connection error
    if status == nil then
        if err ~= 'timeout' then
            Logging:error("Error while waiting for messages: " .. tostring(err))
            self.connection_status = CONNECTION_STATUS.FAILED
        else
            Logging:info("Wait timed out, no messages received in this interval.")
        end
    end
    Logging:info("Finished waiting")
end

function DataLinkTransiever:handleConnection()
    if self.connection_status == CONNECTION_STATUS.FAILED then
        self.client = nats.connect(self.connection_settings)
        Logging:info("Reconnecting to NATS server...")
        self.connection_status = CONNECTION_STATUS.CONNECTING
        self.client.parameters.receive_timeout = self.client.parameters.timeout
        self.client.parameters.send_timeout = self.client.parameters.timeout

        local status, err = pcall(function() self.client:connect() end)
        if status then
            Logging:info("Reconnected to NATS server at " .. tostring(self.host) .. ":" .. tostring(self.port))
            self.connection_status = CONNECTION_STATUS.CONNECTED
            self.client.parameters.receive_timeout = self.timeouts.receive_timeout -- receive needs to return fast
            self.client.parameters.send_timeout = self.timeouts.send_timeout -- send timeout
        else
            Logging:error("Failed to reconnect to NATS server at " .. tostring(self.host) .. ":" .. tostring(self.port))
            Logging:error("Error: " .. tostring(err))
            self.connection_status = CONNECTION_STATUS.FAILED
        end
    end
end

function DataLinkTransiever:handleIncomingMessage(message)
    local decodedMessage = JSON:decode(message)    
    if decodedMessage.sender == self.sender_uuid then
        Logging:debug("Ignoring message from self, sender ID: " .. tostring(decodedMessage.sender))
        return
    end
    Logging:info("Received message: " .. tostring(message) .. " from sender: " .. tostring(decodedMessage.sender))

    local contacts = {}
    for i, raw_contact in ipairs(decodedMessage.contacts) do
        Logging:info("Processing raw contact: " .. tostring(i))
        local contact = Contact:new()
        contact:unpack(raw_contact)
        Logging:info("Created contact")
        contact:setContactSource(CONTACT_SOURCES.K_DLAE) -- mark the contact as received from the К-ДлАЭ source
        Logging:info("Set contact source")
        contact:setDonor(decodedMessage.sender) -- mark the contact as received from the specified donor
        Logging:info("Set donor")
        contacts[#contacts + 1] = contact
        Logging:info("Added contact to contacts list")
    end

    -- add sender as contact to the contacts by filling in all things from unpack
    local sender_contact = Contact:new()
    sender_contact:unpack({
        id = sender_contact.sender,
        x = decodedMessage.x,
        alt = decodedMessage.alt,
        z = decodedMessage.z,
        heading = decodedMessage.heading,
        speed = decodedMessage.speed,
        -- flags = decodedMessage.flags,
        lastSeen = decodedMessage.time,
        side = decodedMessage.side,
        -- iff = UnitData.IFF.FRIENDLY,
        -- iff = decodedMessage.iff,
    })
    sender_contact:setDonor(decodedMessage.sender)
    sender_contact:setContactSource(CONTACT_SOURCES.K_DLAE) -- mark the sender as received from the К-ДлАЭ source
    contacts[#contacts + 1] = sender_contact

    -- add sender information to the contacts before dispatching the event
    for i, contact in ipairs(contacts) do
        contact:setDonor(decodedMessage.sender)
    end
    Logging:info("Finished processing all raw contacts: "..tostring(#contacts))
    self:dispatchEvent(self.EventTypes.ContactsReceived, contacts)
end

function DataLinkTransiever:transfer(contacts)
    if self.enabled == false then return end
    if self.connection_status ~= CONNECTION_STATUS.CONNECTED then
        Logging:warning("Cannot transfer contacts, not connected to NATS server.")
        return
    end
    self:updateOwnPlayerContact()
    Logging:info("Transmitting " .. tostring(#contacts) .. " contacts")
    local message = {
        sender = self.sender_uuid, -- used to filter out own messsages
        x = self.current_player_contact:getX(), -- TODO: is it wise to transmit own exact coordinatess?
        alt = self.current_player_contact:getAltitude(),
        z = self.current_player_contact:getZ(),
        speed = self.current_player_contact:getSpeed(),
        heading = self.current_player_contact:getHeading(),
        -- iff = self.current_player_contact:getIFF(),
        side = self.current_player_contact:getSide(),
        time = DCS.getModelTime(),
        contacts = {},
    }

    for i, contact in ipairs(contacts) do
        Logging:info("Preparing contact ID: " .. contact:getID() .. " for transmission")
        message.contacts[#message.contacts + 1] = contact:pack()
    end

    local message_text = JSON:encode(message)
    Logging:info("Transmitting message: " .. tostring(message_text))
    local status, err = pcall(function()
        self.client:publish(self:getNATSSubject(), message_text)
    end)
    if not status then
        Logging:error("Failed to publish message: " .. tostring(err))
        self.connection_status = CONNECTION_STATUS.FAILED
    end
    Logging:info("Message transmitted successfully")
end

function DataLinkTransiever:getNATSSubject()
    -- return "DCSWorld.DataLink."..self.currentMissionName.."."..tostring(self.current_player_contact:getSide())
    return "DCSWorld.DataLink."..self.currentMissionName
end

return DataLinkTransiever
