dofile(folder..[[../../Cockpit/Scripts/devices.lua]])
dofile(folder..[[../../Cockpit/Scripts/device_commands.lua]])
dofile(folder..[[../../Cockpit/Scripts/animation_defs.lua]])

return {
    keyCommands = {
        -- Start: KP_VEDUS_VEDOM
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
            down = device_commands.KP_VEDUS_VEDOM,
            value_down = KP_VEDUS_VEDOM_POSITIONS.KP / 10,
            cockpit_device_id = devices.DATALINK, 
            name = _("DataLink Role Selector - KP"),
            category = {
                _('Instrument Panel'),
            }
        },
        {
            down = device_commands.KP_VEDUS_VEDOM,
            value_down = KP_VEDUS_VEDOM_POSITIONS.VEDUS / 10,
            cockpit_device_id = devices.DATALINK, 
            name = _("DataLink Role Selector - VEDUS"),
            category = {
                _('Instrument Panel'),
            }
        },
        {
            down = device_commands.KP_VEDUS_VEDOM,
            value_down = KP_VEDUS_VEDOM_POSITIONS.VEDOM / 10,
            cockpit_device_id = devices.DATALINK, 
            name = _("DataLink Role Selector - VEDOM"),
            category = {
                _('Instrument Panel'),
            }
        },
        -- End: KP_VEDUS_VEDOM
        -- Start: PARA2_PARA1_GD_OTKL
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
        {
            down = device_commands.PARA2_PARA1_GD_OTKL,
            value_down = PARA2_PARA1_GD_OTKL_POSITIONS.PARA2 / 10,
            cockpit_device_id = devices.DATALINK, 
            name = _("DataLink Para2/Para1/GD/Otkl Selector - PARA2"),
            category = {
                _('Instrument Panel'),
            }
        },
        {
            down = device_commands.PARA2_PARA1_GD_OTKL,
            value_down = PARA2_PARA1_GD_OTKL_POSITIONS.PARA1 / 10,
            cockpit_device_id = devices.DATALINK, 
            name = _("DataLink Para2/Para1/GD/Otkl Selector - PARA1"),
            category = {
                _('Instrument Panel'),
            }
        },
        {
            down = device_commands.PARA2_PARA1_GD_OTKL,
            value_down = PARA2_PARA1_GD_OTKL_POSITIONS.GD / 10,
            cockpit_device_id = devices.DATALINK, 
            name = _("DataLink Para2/Para1/GD/Otkl Selector - GD"),
            category = {
                _('Instrument Panel'),
            }
        },
        {
            down = device_commands.PARA2_PARA1_GD_OTKL,
            value_down = PARA2_PARA1_GD_OTKL_POSITIONS.OTKL / 10,
            cockpit_device_id = devices.DATALINK, 
            name = _("DataLink Para2/Para1/GD/Otkl Selector - OTKL"),
            category = {
                _('Instrument Panel'),
            }
        },
        -- End: PARA2_PARA1_GD_OTKL
    },
    -- axisCommands = {        
    -- }
}
