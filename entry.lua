dofile(current_mod_path..'/Cockpit/Scripts/common.lua')
declare_plugin("DataLink", {
	installed    = true,
	dirName      = current_mod_path,
	developerName = _("okopanja"),
	developerLink = _("https://github.com/okopanja"),
	displayName  = _("DataLink Overlay"),
	version      = "0.1.0.0",
	state        = "installed",
	info         = _("DataLink overlay panel for Flanker cockpit.\nDisplays a configurable overlay positioned over the cockpit centre display."),
	load_immediate = true,
})

local path = current_mod_path..'/Cockpit/Scripts/'

--  Each entry enables the plugin unconditionally for that aircraft type.
--  Add more types here as needed.
add_plugin_systems('DataLink', '*', path,
	SUPPORTED_AIRCRAFT
)

plugin_done()
