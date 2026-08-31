-- ======================================================================
-- DataLink plugin – device_init.lua
-- Runs inside the Flanker's cockpit script context via add_plugin_systems.
-- ======================================================================

-- Mount the DCS-common avionics textures so that shared font atlases
-- (e.g. Fonts/font_RWR.tga) are accessible inside the VFS.

dofile(LockOn_Options.script_path.."common.lua")
if not SUPPORTED_AIRCRAFT[get_aircraft_type()] then
	print_message_to_user("DataLink: unsupported aircraft type "..get_aircraft_type()..". Overlay disabled.")
	return
end

mount_vfs_texture_archives("Bazar/Textures/AvionicsCommon")
dofile(LockOn_Options.script_path.."devices.lua")

-- TODO: do we need this?
-- Font registration
-- Load the common RWR font descriptor from the shared DCS script path.
-- font_RWR.lua defines `fontdescription_RWR` with A-Z, 0-9 and space.
dofile(LockOn_Options.common_script_path.."Fonts/symbols_locale.lua")
dofile(LockOn_Options.common_script_path.."Fonts/font_RWR.lua")

-- `fonts` is the DCS cockpit-global table that maps material names to
-- font descriptors. The page file references these by name.
if fonts == nil then fonts = {} end
fonts["font_datalink_green"] = {fontdescription_RWR, {0, 220, 0, 255}}  -- bright green text

-- Device registration
creators  = {}
indicators = {}

-- The DATALINK device handles overaying the contacts over HDD.
creators[devices.DATALINK] = {
	"avLuaDevice",
	LockOn_Options.script_path.."DataLink/datalink_device.lua",
	{}
}

-- Crete the indicator
-- ccIndicator is a built-in DCS class. No custom binary required.
-- The init file controls viewport position; the page file draws content.
indicators[#indicators + 1] = {
	"ccIndicator",
	LockOn_Options.script_path.."DataLink/DATALINK_indicator_init.lua"
}

-- TODO: this is likely incorrect options path
indicators[#indicators + 1] =  {"ccChart",LockOn_Options.common_script_path.."dbg_chart.lua"  ,nil,{{}, {sw = LockOn_Options.screen.aspect - 0.01,sh = 0.5 - 0.01}}}
