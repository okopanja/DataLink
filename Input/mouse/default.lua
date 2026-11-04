dofile(current_mod_path..[[Cockpit/Scripts/devices.lua]])
dofile(current_mod_path..[[Cockpit/Scripts/device_commands.lua]])

return {
    keyCommands = {
        {
            down = Keys.KP_VEDUS_VEDOM_CW,
            name = _("DataLink Role Selector - CW"),
            category = {
                _('Instrument Panel'),
            }
        },
        {
            down = Keys.KP_VEDUS_VEDOM_CCW,
            name = _("DataLink Role Selector - CCW"),
            category = {
                _('Instrument Panel'),
            }
        },
        {
            down = Keys.PARA2_PARA1_GD_OTKL_CW,
            name = _("DataLink Para2/Para1/GD/Otkl Selector - CW"),
            category = {
                _('Instrument Panel'),
            }
        },
        {
            down = Keys.PARA2_PARA1_GD_OTKL_CCW,
            name = _("DataLink Para2/Para1/GD/Otkl Selector - CCW"),
            category = {
                _('Instrument Panel'),
            }
        },
    },
    axisCommands = {        
    }
}
