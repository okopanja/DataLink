shape_name = "DataLink"

dofile(LockOn_Options.script_path.."animation_defs.lua")

------------------------------------------------
-- Button gauges
------------------------------------------------
btn_target_01_gauge = CreateGauge("parameter")
btn_target_01_gauge.parameter_name = ANIMATION_PARAMS.BTN_TARGET_01
btn_target_01_gauge.arg_number = ANIMATION_ARGS.BTN_TARGET_01
btn_target_01_gauge.input = {-1, 1}
btn_target_01_gauge.output = {-1, 1}

btn_target_02_gauge = CreateGauge("parameter")
btn_target_02_gauge.parameter_name = ANIMATION_PARAMS.BTN_TARGET_02
btn_target_02_gauge.arg_number = ANIMATION_ARGS.BTN_TARGET_02
btn_target_02_gauge.input = {-1, 1}
btn_target_02_gauge.output = {0, 1}

btn_target_03_qauge = CreateGauge("parameter")
btn_target_03_qauge.parameter_name = ANIMATION_PARAMS.BTN_TARGET_03
btn_target_03_qauge.arg_number = ANIMATION_ARGS.BTN_TARGET_03
btn_target_03_qauge.input = {-1, 1}
btn_target_03_qauge.output = {0, 1}

btn_target_04_qauge = CreateGauge("parameter")
btn_target_04_qauge.parameter_name = ANIMATION_PARAMS.BTN_TARGET_04
btn_target_04_qauge.arg_number = ANIMATION_ARGS.BTN_TARGET_04
btn_target_04_qauge.input = {-1, 1}
btn_target_04_qauge.output = {0, 1}

btn_target_05_qauge = CreateGauge("parameter")
btn_target_05_qauge.parameter_name = ANIMATION_PARAMS.BTN_TARGET_05
btn_target_05_qauge.arg_number = ANIMATION_ARGS.BTN_TARGET_05
btn_target_05_qauge.input = {-1, 1}
btn_target_05_qauge.output = {0, 1}

btn_target_06_qauge = CreateGauge("parameter")
btn_target_06_qauge.parameter_name = ANIMATION_PARAMS.BTN_TARGET_06
btn_target_06_qauge.arg_number = ANIMATION_ARGS.BTN_TARGET_06
btn_target_06_qauge.input = {-1, 1}
btn_target_06_qauge.output = {0, 1}

btn_target_07_qauge = CreateGauge("parameter")
btn_target_07_qauge.parameter_name = ANIMATION_PARAMS.BTN_TARGET_07
btn_target_07_qauge.arg_number = ANIMATION_ARGS.BTN_TARGET_07
btn_target_07_qauge.input = {-1, 1}
btn_target_07_qauge.output = {0, 1}

btn_target_08_qauge = CreateGauge("parameter")
btn_target_08_qauge.parameter_name = ANIMATION_PARAMS.BTN_TARGET_08
btn_target_08_qauge.arg_number = ANIMATION_ARGS.BTN_TARGET_08
btn_target_08_qauge.input = {-1, 1}
btn_target_08_qauge.output = {0, 1}

btn_target_09_qauge = CreateGauge("parameter")
btn_target_09_qauge.parameter_name = ANIMATION_PARAMS.BTN_TARGET_09
btn_target_09_qauge.arg_number = ANIMATION_ARGS.BTN_TARGET_09
btn_target_09_qauge.input = {-1, 1}
btn_target_09_qauge.output = {0, 1}

btn_target_10_qauge = CreateGauge("parameter")
btn_target_10_qauge.parameter_name = ANIMATION_PARAMS.BTN_TARGET_10
btn_target_10_qauge.arg_number = ANIMATION_ARGS.BTN_TARGET_10
btn_target_10_qauge.input = {-1, 1}
btn_target_10_qauge.output = {0, 1}

btn_vvod_qauge = CreateGauge("parameter")
btn_vvod_qauge.parameter_name = ANIMATION_PARAMS.BTN_VVOD
btn_vvod_qauge.arg_number = ANIMATION_ARGS.BTN_VVOD
btn_vvod_qauge.input = {-1, 1}
btn_vvod_qauge.output = {0, 1}

btn_sbros_qauge = CreateGauge("parameter")
btn_sbros_qauge.parameter_name = ANIMATION_PARAMS.BTN_SBROS
btn_sbros_qauge.arg_number = ANIMATION_ARGS.BTN_SBROS
btn_sbros_qauge.input = {-1, 1}
btn_sbros_qauge.output = {0, 1}

btn_fighter_01_qauge = CreateGauge("parameter")
btn_fighter_01_qauge.parameter_name = ANIMATION_PARAMS.BTN_FIGHTER_01
btn_fighter_01_qauge.arg_number = ANIMATION_ARGS.BTN_FIGHTER_01
btn_fighter_01_qauge.input = {-1, 1}
btn_fighter_01_qauge.output = {0, 1}

btn_fighter_02_qauge = CreateGauge("parameter")
btn_fighter_02_qauge.parameter_name = ANIMATION_PARAMS.BTN_FIGHTER_02
btn_fighter_02_qauge.arg_number = ANIMATION_ARGS.BTN_FIGHTER_02
btn_fighter_02_qauge.input = {-1, 1}
btn_fighter_02_qauge.output = {0, 1}

btn_fighter_03_qauge = CreateGauge("parameter")
btn_fighter_03_qauge.parameter_name = ANIMATION_PARAMS.BTN_FIGHTER_03
btn_fighter_03_qauge.arg_number = ANIMATION_ARGS.BTN_FIGHTER_03
btn_fighter_03_qauge.input = {-1, 1}
btn_fighter_03_qauge.output = {0, 1}

btn_fighter_04_qauge = CreateGauge("parameter")
btn_fighter_04_qauge.parameter_name = ANIMATION_PARAMS.BTN_FIGHTER_04
btn_fighter_04_qauge.arg_number = ANIMATION_ARGS.BTN_FIGHTER_04
btn_fighter_04_qauge.input = {-1, 1}
btn_fighter_04_qauge.output = {0, 1}

btn_fighter_group_qauge = CreateGauge("parameter")
btn_fighter_group_qauge.parameter_name = ANIMATION_PARAMS.BTN_FIGHTER_GROUP
btn_fighter_group_qauge.arg_number = ANIMATION_ARGS.BTN_FIGHTER_GROUP
btn_fighter_group_qauge.input = {-1, 1}
btn_fighter_group_qauge.output = {0, 1}

------------------------------------------------
-- Light gauges
------------------------------------------------
light_target_01_gauge = CreateGauge("parameter")
light_target_01_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_TARGET_01
light_target_01_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_TARGET_01
light_target_01_gauge.input = {-1, 1}
light_target_01_gauge.output = {-1, 1}

light_target_02_gauge = CreateGauge("parameter")
light_target_02_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_TARGET_02
light_target_02_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_TARGET_02
light_target_02_gauge.input = {-1, 1}
light_target_02_gauge.output = {-1, 1}

light_target_03_gauge = CreateGauge("parameter")
light_target_03_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_TARGET_03
light_target_03_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_TARGET_03
light_target_03_gauge.input = {-1, 1}
light_target_03_gauge.output = {-1, 1}

light_target_04_gauge = CreateGauge("parameter")
light_target_04_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_TARGET_04
light_target_04_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_TARGET_04
light_target_04_gauge.input = {-1, 1}
light_target_04_gauge.output = {-1, 1}

light_target_05_gauge = CreateGauge("parameter")
light_target_05_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_TARGET_05
light_target_05_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_TARGET_05
light_target_05_gauge.input = {-1, 1}
light_target_05_gauge.output = {-1, 1}

light_target_06_gauge = CreateGauge("parameter")
light_target_06_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_TARGET_06
light_target_06_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_TARGET_06
light_target_06_gauge.input = {-1, 1}
light_target_06_gauge.output = {-1, 1}

light_target_07_gauge = CreateGauge("parameter")
light_target_07_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_TARGET_07
light_target_07_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_TARGET_07
light_target_07_gauge.input = {-1, 1}
light_target_07_gauge.output = {-1, 1}

light_target_08_gauge = CreateGauge("parameter")
light_target_08_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_TARGET_08
light_target_08_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_TARGET_08
light_target_08_gauge.input = {-1, 1}
light_target_08_gauge.output = {-1, 1}

light_target_09_gauge = CreateGauge("parameter")
light_target_09_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_TARGET_09
light_target_09_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_TARGET_09
light_target_09_gauge.input = {-1, 1}
light_target_09_gauge.output = {-1, 1}

light_target_10_gauge = CreateGauge("parameter")
light_target_10_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_TARGET_10
light_target_10_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_TARGET_10
light_target_10_gauge.input = {-1, 1}
light_target_10_gauge.output = {-1, 1}

light_vvod_gauge = CreateGauge("parameter")
light_vvod_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_VVOD
light_vvod_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_VVOD
light_vvod_gauge.input = {-1, 1}
light_vvod_gauge.output = {-1, 1}

light_sbros_gauge = CreateGauge("parameter")
light_sbros_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_SBROS
light_sbros_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_SBROS
light_sbros_gauge.input = {-1, 1}
light_sbros_gauge.output = {-1, 1}

light_fighter_01_gauge = CreateGauge("parameter")
light_fighter_01_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_FIGHTER_01
light_fighter_01_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_FIGHTER_01
light_fighter_01_gauge.input = {-1, 1}
light_fighter_01_gauge.output = {-1, 1}

light_fighter_02_gauge = CreateGauge("parameter")
light_fighter_02_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_FIGHTER_02
light_fighter_02_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_FIGHTER_02
light_fighter_02_gauge.input = {-1, 1}
light_fighter_02_gauge.output = {-1, 1}

light_fighter_03_gauge = CreateGauge("parameter")
light_fighter_03_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_FIGHTER_03
light_fighter_03_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_FIGHTER_03
light_fighter_03_gauge.input = {-1, 1}
light_fighter_03_gauge.output = {-1, 1}

light_fighter_04_gauge = CreateGauge("parameter")
light_fighter_04_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_FIGHTER_04
light_fighter_04_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_FIGHTER_04
light_fighter_04_gauge.input = {-1, 1}
light_fighter_04_gauge.output = {-1, 1}

light_fighter_group_gauge = CreateGauge("parameter")
light_fighter_group_gauge.parameter_name = LIGHT_ANIMATION_PARAMS.LIGHT_FIGHTER_GROUP
light_fighter_group_gauge.arg_number = LIGHT_ANIMATION_ARGS.LIGHT_FIGHTER_GROUP
light_fighter_group_gauge.input = {-1, 1}
light_fighter_group_gauge.output = {-1, 1}

need_to_be_closed = true