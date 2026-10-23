-- dofile(LockOn_Options.script_path.."clickable_defs.lua") 
dofile(LockOn_Options.script_path.."device_commands.lua")
dofile(LockOn_Options.script_path.."devices.lua")

local gettext = require("i_18n")
_ = gettext.translate

elements = {}

local function create_button(device, action, stop_action, class_types, hint)
    return {
		class         = class_types,
		hint          = hint,
		device        = device,
		action        = {action},
		stop_action   = {stop_action},
		arg           = {nil},
		arg_value     = {1},
		arg_lim       = {{-1, 1}},
	}
end

local device = devices.DATALINK
elements.PNT_TARGET_01 = create_button(device, device_commands.TARGET_01, device_commands.TARGET_01, {class_type.BTN}, _("Target 1"))
elements.PNT_TARGET_02 = create_button(device, device_commands.TARGET_02, device_commands.TARGET_02, {class_type.BTN}, _("Target 2"))
elements.PNT_TARGET_03 = create_button(device, device_commands.TARGET_03, device_commands.TARGET_03, {class_type.BTN}, _("Target 3"))
elements.PNT_TARGET_04 = create_button(device, device_commands.TARGET_04, device_commands.TARGET_04, {class_type.BTN}, _("Target 4"))
elements.PNT_TARGET_05 = create_button(device, device_commands.TARGET_05, device_commands.TARGET_05, {class_type.BTN}, _("Target 5"))
elements.PNT_TARGET_06 = create_button(device, device_commands.TARGET_06, device_commands.TARGET_06, {class_type.BTN}, _("Target 6"))
elements.PNT_TARGET_07 = create_button(device, device_commands.TARGET_07, device_commands.TARGET_07, {class_type.BTN}, _("Target 7"))
elements.PNT_TARGET_08 = create_button(device, device_commands.TARGET_08, device_commands.TARGET_08, {class_type.BTN}, _("Target 8"))
elements.PNT_TARGET_09 = create_button(device, device_commands.TARGET_09, device_commands.TARGET_09, {class_type.BTN}, _("Target 9"))
elements.PNT_TARGET_10 = create_button(device, device_commands.TARGET_10, device_commands.TARGET_10, {class_type.BTN}, _("Target 10"))
elements.PNT_VVOD = create_button(device, device_commands.VVOD, device_commands.VVOD, {class_type.BTN}, _("VVOD"))
elements.PNT_SBROS = create_button(device, device_commands.SBROS, device_commands.SBROS, {class_type.BTN}, _("SBROS"))
elements.PNT_FIGHTER_01 = create_button(device, device_commands.FIGHTER_01, device_commands.FIGHTER_01, {class_type.BTN}, _("Fighter 1"))
elements.PNT_FIGHTER_02 = create_button(device, device_commands.FIGHTER_02, device_commands.FIGHTER_02, {class_type.BTN}, _("Fighter 2"))
elements.PNT_FIGHTER_03 = create_button(device, device_commands.FIGHTER_03, device_commands.FIGHTER_03, {class_type.BTN}, _("Fighter 3"))
elements.PNT_FIGHTER_04 = create_button(device, device_commands.FIGHTER_04, device_commands.FIGHTER_04, {class_type.BTN}, _("Fighter 4"))
elements.PNT_FIGHTER_GROUP = create_button(device, device_commands.FIGHTER_GROUP, device_commands.FIGHTER_GROUP, {class_type.BTN}, _("Group"))

elements.PNT_KP_VEDUS_VEDOM =
{
    class = {class_type.TUMB, class_type.TUMB},
    hint = _("KP/VEDUS/VEDOM"),
    device = device,
    action = {
		device_commands.KP_VEDUS_VEDOM,
		device_commands.KP_VEDUS_VEDOM
	},
    arg = {
        ANIMATION_ARGS.ROT_KP_VEDUS_VEDOM,
        ANIMATION_ARGS.ROT_KP_VEDUS_VEDOM
    },
    arg_value = {0, 1},
    arg_lim = {
        {0, 0.1 * 2},
        {0, 0.1 * 2},
    },
    updatable = true,
    use_OBB = true,
    cycle = true,
	animated = {true, true},
	animation_speed = {16, 16},
}

elements.PNT_PARA2_PARA1_GD_OTKL =
{
    class = {class_type.TUMB, class_type.TUMB},
    hint = _("PARA2/PARA1/GD OTKL"),
    device = device,
    action = {
		device_commands.PARA2_PARA1_GD_OTKL,
		device_commands.PARA2_PARA1_GD_OTKL
	},
    arg = {
        ANIMATION_ARGS.ROT_PARA2_PARA1_GD_OTKL,
        ANIMATION_ARGS.ROT_PARA2_PARA1_GD_OTKL
    },
    arg_value = {0, 0.1},
    arg_lim = {
        {-1, 0.1 * 3},
        {-1, 0.1 * 3},
    },
    updatable = true,
    use_OBB = true,
    cycle = false,
	animated = {true, true},
	animation_speed = {16, 16},
}
