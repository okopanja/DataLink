local Logging = require("Utils.Logging").new("DataLink.log")
local Contact = require("Contact")
local net = require("net")
local UnitData = require("UnitData")
local DCSTimer = require("DCSTimer")
local GlobalData = {}

function GlobalData:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.country_coalition_map = {}
    o.sensor_export_allowed = false
    o.ownship_export_allowed = false
    o.lastServerExportUpdate = DCSTimer:new(3, true)
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

function GlobalData:updateServerExportSettings()
    local elapsed, elapsedTime = self.lastServerExportUpdate:intervalHasElapsed()
    if elapsed then
        Logging:info("GlobalData: updating server export settings.")
        self.lastServerExportUpdate:reset()
        self.sensor_export_allowed = Export.LoIsSensorExportAllowed()
        self.ownship_export_allowed = Export.LoIsOwnshipExportAllowed()
        -- TODO: considere this DCS bug, nothing is wrong with this code.
        -- DCS client which hosts the server will return result of LoIsOwnshipExportAllowed as true even if ownship was disabled.
        -- Undesired side effect is that server keeps sending own location, but clients do not make attempts to read so.
        -- Unlike the LoIsOwnshipExportAllowed check, the LoIsSensorExportAllowed check behaves correctly and obeys the actual export settings.
        -- DCS clients not runing servers work correctly with both checks.
        -- End conclusion: not an issue for true clients connecting to remote server, they get proper values and will remain inactive.
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

function GlobalData:isSensorExportAllowed()
    return self.sensor_export_allowed
end

function GlobalData:isOwnshipExportAllowed()
    return self.ownship_export_allowed
end

local singleton = GlobalData:new()
return singleton