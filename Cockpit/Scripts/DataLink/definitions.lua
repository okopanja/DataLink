MAX_CONTACTS = 80

local count = 512 - 1
local function counter()
	count = count + 1
	return count
end

CommonArguments = {
	DISCOVERY  = counter(),
	ZOOM_LEVEL = counter(),
	ACTIVE     = counter(),
}

count = 10000
TARGET_COUNT = counter()
TARGET_ARGS = {
	TARGET_COUNT = counter(),
	TARGET_01 = counter(),
	TARGET_02 = counter(),
	TARGET_03 = counter(),
	TARGET_04 = counter(),
	TARGET_05 = counter(),
	TARGET_06 = counter(),
	TARGET_07 = counter(),
	TARGET_08 = counter(),
	TARGET_09 = counter(),
	TARGET_10 = counter(),
}

HDDScales = {
	[1] = 1,
	[2] = 2,
	[3] = 5,
	[4] = 10,
	[5] = 20,
	[6] = 50,
	[7] = 100,
}

EVENTS = {
	-- Rearm/Refuel events
	WeaponRearmComplete = "WeaponRearmComplete",
	WeaponRearmFirstStep = "WeaponRearmFirstStep",
	WeaponRearmSingleStepComplete = "WeaponRearmSingleStepComplete",
	ReloadDone = "ReloadDone",
	RefuelDone = "RefuelDone",
	Repair = "repair",
	Refuel = "refuel",
	RefuelComplete = "refuelcomplete",
	RefuelDone = "refueldone",
	UnlimitedWeaponStationRestore = "UnlimitedWeaponStationRestore",
	InitChaffFlarePayload = "initChaffFlarePayload",

	-- Ground Power
	GroundPowerOn = "GroundPowerOn",
	GroundPowerOff = "GroundPowerOff",

	-- Ground Air
	GroundAirOff = "GroundAirOff",
	GroundAirOn = "GroundAirOn",
	GroundAirFailure = "GroundAirFailure",
	GroundAirApplyOn = "GroundAirApplyOn",
	GroundAirApplyOff = "GroundAirApplyOff",
	GroundAirApplyFailure = "GroundAirApplyFailure",

	-- Wheel Chocks
	WheelChocksOn = "WheelChocksOn",
	WheelChocksOff = "WheelChocksOff",

	-- Misc Ground Crew
	CanopyOpen = "CanopyOpen",
	CanopyClose = "CanopyClose",
	setup_HMS = "setup_HMS",
	setup_NVG = "setup_NVG",

	-- Works the same as release() function as shown in the example device
	cockpit_release = "cockpit_release",

	-- Unknown
	DisableTurboGear = "DisableTurboGear",
	EnableTurboGear = "EnableTurboGear",
	switch_datalink = "switch_datalink",
	LinkNOPtoNet = "LinkNOPtoNet",
	UnlinkNOPfromNet = "UnlinkNOPfromNet",
	EGI_TurnOff = "EGI_TurnOff",
	EGI_TurnOn = "EGI_TurnOn",
	RestoreEGIoperation = "RestoreEGIoperation",
	TISLmodeChange = "TISLmodeChange",
	OnNewNetPlane = "OnNewNetPlane",
}

CommonParameterNames = {}
CommonParameterNames["DATALINK_TOGGLE_VISIBILITY"] = "DATALINK_TOGGLE_VISIBILITY"
CommonParameterNames["DATALINK_SCALE"] = "DATALINK_SCALE"
CommonParameterNames["TRUE_HEADING"] = "TRUE_HEADING"

EnemyContactParameterNames = {}
for i = 1, MAX_CONTACTS do
  EnemyContactParameterNames[i] = {
    NAME     = string.format("DATALINK_ENEMY_CONTACT_%02d", i),
    BEARING  = string.format("DATALINK_ENEMY_CONTACT_%02d_BEARING", i),
    RANGE    = string.format("DATALINK_ENEMY_CONTACT_%02d_RANGE", i),
    ALTITUDE = string.format("DATALINK_ENEMY_CONTACT_%02d_ALTITUDE", i),
    SPEED    = string.format("DATALINK_ENEMY_CONTACT_%02d_SPEED", i),
    HEADING  = string.format("DATALINK_ENEMY_CONTACT_%02d_HEADING", i),
    VISIBLE  = string.format("DATALINK_ENEMY_CONTACT_%02d_VISIBLE", i),
  }
end


