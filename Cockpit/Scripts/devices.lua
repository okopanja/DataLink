-- Device ID registry for the DataLink plugin.
-- IDs must be unique integers. Add more devices here as the plugin grows.
dofile(LockOn_Options.script_path.."common.lua")

local count = 0
local function counter()
	count = count + 1
	return count
end

devices = {}
devices["DATALINK"] = counter()
