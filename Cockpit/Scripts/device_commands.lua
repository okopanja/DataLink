
local count = 4000
local function counter()
	count = count + 1
	return count
end

if device_commands == nil then
    -- mark start of device commands range
    data_link_command_first = count    
	device_commands = {}

    -- Target commands
    device_commands.TARGET_01 = counter()
    device_commands.TARGET_02 = counter()
    device_commands.TARGET_03 = counter()
    device_commands.TARGET_04 = counter()
    device_commands.TARGET_05 = counter()
    device_commands.TARGET_06 = counter()
    device_commands.TARGET_07 = counter()
    device_commands.TARGET_08 = counter()
    device_commands.TARGET_09 = counter()
    device_commands.TARGET_10 = counter()
    device_commands.VVOD = counter()
    device_commands.SBROS = counter()

    -- Wingman commands
    device_commands.FIGHTER_01 = counter()
    device_commands.FIGHTER_02 = counter()
    device_commands.FIGHTER_03 = counter()
    device_commands.FIGHTER_04 = counter()
    device_commands.FIGHTER_GROUP = counter()

    -- Rotary switches
    device_commands.KP_VEDUS_VEDOM = counter()
    device_commands.PARA2_PARA1_GD_OTKL = counter()

    -- conclude the device commands range
    data_link_command_last = count    
end

