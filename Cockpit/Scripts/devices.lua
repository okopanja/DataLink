-- Device ID registry for the DataLink plugin.
-- IDs must be unique integers. Add more devices here as the plugin grows.
dofile(LockOn_Options.script_path.."common.lua")

-- by default it should be 0 for plugin which automatically relocated the number to 256, to start emediatly after cockput range [0-255]
local start_device_number = 0
if get_param_handle("NS430"):get() == "enabled" then
	-- if NS430 is enabled, cockpit takes 0, both NS430 and DataLink get pushed to [256-511].
	-- This creates a conflict when receiving commands and results in invalid values.
	-- Therefore we need to start our plugin's device numbering from 256 to avoid collision with NS430, which means DataLink device addres space will be [512-767]
	start_device_number = 512
end
local count = start_device_number
local function counter()
	count = count + 1
	return count
end

devices = {}
devices["DATALINK"] = counter()
