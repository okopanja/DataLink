local Contact = require("Contact")

local SUV27 = {}

function SUV27:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    return instance
end
-- singleton instance
local suv27 = SUV27:new()

return suv27