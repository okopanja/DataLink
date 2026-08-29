-- ======================================================================
-- DataLink plugin – DATALINK_indicator_init.lua
-- Configures the ccIndicator: render type, viewport position, and pages.
--
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(lfs.writedir().."Mods/tech/DataLink/Cockpit/Scripts/common.lua")
print_message_to_user(current_mod_path)

indicator_type = indicator_types.COMMON
purposes       = {render_purpose.GENERAL}

local VP_X = 800   -- pixels from left edge of screen
local VP_Y = 620   -- pixels from top  edge of screen
local VP_W = 320   -- panel width  in pixels
local VP_H = 240   -- panel height in pixels

local scale_x = LockOn_Options.screen.width  / 1920
local scale_y = LockOn_Options.screen.height / 1080
dedicated_viewport = {
	math.floor(VP_X * scale_x),
	math.floor(VP_Y * scale_y),
	math.floor(VP_W * scale_x),
	math.floor(VP_H * scale_y),
}

-- ── Pages ────────────────────────────────────────────────────────────
page_subsets = {
	[1] = LockOn_Options.script_path.."DataLink/DATALINK_page.lua",
}
pages       = { [1] = {1} }
init_pageID = 1
if DEBUG then
	saveInspect("_G_indicator", _G, true)
end