local Logging = require("Utils.Logging").new("DataLink.log")
local Contact = require("Contact")
local net = require("net")
local UnitData = require("UnitData")

local GlobalData = {}

function GlobalData:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.country_coalition_map = {}
    return o
end

function GlobalData:updateCountryCoalitionMap()
    Logging:info("GlobalData:updateCountryCoalitionMap")
    self.currentMission = DCS.getCurrentMission().mission
    -- Map country IDs to their respective coalitions
    self.coalitions_by_country_id = {
    }  
    for coalition_name, coalition_countries in pairs(self.currentMission.coalitions) do
        for i, country in ipairs(coalition_countries) do
            Logging:info("Mapping country ID "..tostring(country).." to coalition "..tostring(coalition_name))
        self.coalitions_by_country_id[country] = coalition_name
        end
    end
end

function GlobalData:getCountryCoalitionMap()
    return self.country_coalition_map
end

function GlobalData:getCoalitionByCountry(country_id)
    if not self.coalitions_by_country_id then
        self:updateCountryCoalitionMap()
    end
    return self.coalitions_by_country_id[country_id]
end

local singleton = GlobalData:new()
return singleton