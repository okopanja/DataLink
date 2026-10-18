shape_name = "DataLink"

dofile(LockOn_Options.script_path.."animation_defs.lua")

-- create gauges by mapping ANIMATION_PARAMS and ANIMATION_ARGS from EDM
btn_target_01_guake = CreateGauge("parameter")
btn_target_01_guake.parameter_name = ANIMATION_PARAMS.BTN_TARGET_01
btn_target_01_guake.arg_number = ANIMATION_ARGS.BTN_TARGET_01
btn_target_01_guake.input = {-1, 1}
btn_target_01_guake.output = {0, 1}

btn_target_02_guake = CreateGauge("parameter")
btn_target_02_guake.parameter_name = ANIMATION_PARAMS.BTN_TARGET_02
btn_target_02_guake.arg_number = ANIMATION_ARGS.BTN_TARGET_02
btn_target_02_guake.input = {-1, 1}
btn_target_02_guake.output = {0, 1}

btn_target_03_guake = CreateGauge("parameter")
btn_target_03_guake.parameter_name = ANIMATION_PARAMS.BTN_TARGET_03
btn_target_03_guake.arg_number = ANIMATION_ARGS.BTN_TARGET_03
btn_target_03_guake.input = {-1, 1}
btn_target_03_guake.output = {0, 1}

btn_target_04_guake = CreateGauge("parameter")
btn_target_04_guake.parameter_name = ANIMATION_PARAMS.BTN_TARGET_04
btn_target_04_guake.arg_number = ANIMATION_ARGS.BTN_TARGET_04
btn_target_04_guake.input = {-1, 1}
btn_target_04_guake.output = {0, 1}

btn_target_05_guake = CreateGauge("parameter")
btn_target_05_guake.parameter_name = ANIMATION_PARAMS.BTN_TARGET_05
btn_target_05_guake.arg_number = ANIMATION_ARGS.BTN_TARGET_05
btn_target_05_guake.input = {-1, 1}
btn_target_05_guake.output = {0, 1}

btn_target_06_guake = CreateGauge("parameter")
btn_target_06_guake.parameter_name = ANIMATION_PARAMS.BTN_TARGET_06
btn_target_06_guake.arg_number = ANIMATION_ARGS.BTN_TARGET_06
btn_target_06_guake.input = {-1, 1}
btn_target_06_guake.output = {0, 1}

btn_target_07_guake = CreateGauge("parameter")
btn_target_07_guake.parameter_name = ANIMATION_PARAMS.BTN_TARGET_07
btn_target_07_guake.arg_number = ANIMATION_ARGS.BTN_TARGET_07
btn_target_07_guake.input = {-1, 1}
btn_target_07_guake.output = {0, 1}

btn_target_08_guake = CreateGauge("parameter")
btn_target_08_guake.parameter_name = ANIMATION_PARAMS.BTN_TARGET_08
btn_target_08_guake.arg_number = ANIMATION_ARGS.BTN_TARGET_08
btn_target_08_guake.input = {-1, 1}
btn_target_08_guake.output = {0, 1}

btn_target_09_guake = CreateGauge("parameter")
btn_target_09_guake.parameter_name = ANIMATION_PARAMS.BTN_TARGET_09
btn_target_09_guake.arg_number = ANIMATION_ARGS.BTN_TARGET_09
btn_target_09_guake.input = {-1, 1}
btn_target_09_guake.output = {0, 1}

btn_target_10_guake = CreateGauge("parameter")
btn_target_10_guake.parameter_name = ANIMATION_PARAMS.BTN_TARGET_10
btn_target_10_guake.arg_number = ANIMATION_ARGS.BTN_TARGET_10
btn_target_10_guake.input = {-1, 1}
btn_target_10_guake.output = {0, 1}

btn_vvod_guake = CreateGauge("parameter")
btn_vvod_guake.parameter_name = ANIMATION_PARAMS.BTN_VVOD
btn_vvod_guake.arg_number = ANIMATION_ARGS.BTN_VVOD
btn_vvod_guake.input = {-1, 1}
btn_vvod_guake.output = {0, 1}

btn_sbros_guake = CreateGauge("parameter")
btn_sbros_guake.parameter_name = ANIMATION_PARAMS.BTN_SBROS
btn_sbros_guake.arg_number = ANIMATION_ARGS.BTN_SBROS
btn_sbros_guake.input = {-1, 1}
btn_sbros_guake.output = {0, 1}

btn_fighter_01_guake = CreateGauge("parameter")
btn_fighter_01_guake.parameter_name = ANIMATION_PARAMS.BTN_FIGHTER_01
btn_fighter_01_guake.arg_number = ANIMATION_ARGS.BTN_FIGHTER_01
btn_fighter_01_guake.input = {-1, 1}
btn_fighter_01_guake.output = {0, 1}

btn_fighter_02_guake = CreateGauge("parameter")
btn_fighter_02_guake.parameter_name = ANIMATION_PARAMS.BTN_FIGHTER_02
btn_fighter_02_guake.arg_number = ANIMATION_ARGS.BTN_FIGHTER_02
btn_fighter_02_guake.input = {-1, 1}
btn_fighter_02_guake.output = {0, 1}

btn_fighter_03_guake = CreateGauge("parameter")
btn_fighter_03_guake.parameter_name = ANIMATION_PARAMS.BTN_FIGHTER_03
btn_fighter_03_guake.arg_number = ANIMATION_ARGS.BTN_FIGHTER_03
btn_fighter_03_guake.input = {-1, 1}
btn_fighter_03_guake.output = {0, 1}

btn_fighter_04_guake = CreateGauge("parameter")
btn_fighter_04_guake.parameter_name = ANIMATION_PARAMS.BTN_FIGHTER_04
btn_fighter_04_guake.arg_number = ANIMATION_ARGS.BTN_FIGHTER_04
btn_fighter_04_guake.input = {-1, 1}
btn_fighter_04_guake.output = {0, 1}

btn_fighter_group_guake = CreateGauge("parameter")
btn_fighter_group_guake.parameter_name = ANIMATION_PARAMS.BTN_FIGHTER_GROUP
btn_fighter_group_guake.arg_number = ANIMATION_ARGS.BTN_FIGHTER_GROUP
btn_fighter_group_guake.input = {-1, 1}
btn_fighter_group_guake.output = {0, 1}

need_to_be_closed = true