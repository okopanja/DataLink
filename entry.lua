local VERSION_INFO = dofile(current_mod_path..'/VersionInfo.lua')
dofile(current_mod_path..'/Cockpit/Scripts/common.lua')
declare_plugin("DataLink", {
	installed    = true,
	dirName      = current_mod_path,
	developerName = _("okopanja"),
	developerLink = _("https://github.com/okopanja"),
	displayName  = _("DataLink Overlay"),
	version      = VERSION_INFO.version,
	state        = "installed",
	info         = _("DataLink overlay panel for Flanker cockpit.\nDisplays a configurable overlay positioned over the cockpit centre display."),
	load_immediate = true,
	Options =
		{
			{
				name		= _("DataLink"),
				nameId		= "DataLink",
				dir			= "Options",
				CLSID		= "{DataLink options}"
			},
		},

}
)

local path = current_mod_path..'/Cockpit/Scripts/'

--  Each entry enables the plugin unconditionally for that aircraft type.
--  Add more types here as needed.
add_plugin_systems('DataLink', '*', path,
	SUPPORTED_AIRCRAFT
)

plugin_done()
