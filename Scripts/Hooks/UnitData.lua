local UNIT_PROPERTIES = {
	UNIT_RUNTIME_ID = DCS.UNIT_RUNTIME_ID, 
	UNIT_MISSION_ID = DCS.UNIT_MISSION_ID, -- slot ID
	UNIT_NAME = DCS.UNIT_NAME, -- Palmachim_C-130J-30_4333-1
	UNIT_TYPE = DCS.UNIT_TYPE,
	UNIT_CATEGORY = DCS.UNIT_CATEGORY, -- nil/empty?
	UNIT_GROUP_MISSION_ID = DCS.UNIT_GROUP_MISSION_ID, -- 1004292
	UNIT_GROUPNAME = DCS.UNIT_GROUPNAME, -- King Hussein Air College_F-16CM bl.50_4292, Hama_F-14B(U)_4298, Virtual unit
	UNIT_GROUPCATEGORY = DCS.UNIT_GROUPCATEGORY, -- plane, helicopter, nil, ""
	UNIT_CALLSIGN = DCS.UNIT_CALLSIGN,
	UNIT_HIDDEN = DCS.UNIT_HIDDEN, -- true/false
	UNIT_COALITION = DCS.UNIT_COALITION, -- red/blue/nil
	UNIT_COUNTRY_ID = DCS.UNIT_COUNTRY_ID, -- 18, 21, nil	
	UNIT_TASK = DCS.UNIT_TASK, -- CAS, CAP, SEAD, nil
	UNIT_PLAYER_NAME = DCS.UNIT_PLAYER_NAME, -- nickname
	UNIT_ROLE = DCS.UNIT_ROLE, -- artillery_commander/Pilot
	UNIT_INVISIBLE_MAP_ICON = DCS.UNIT_INVISIBLE_MAP_ICON, -- true/false
	UNIT_INVISIBLE_MAP_LABEL = DCS.UNIT_INVISIBLE_MAP_LABEL, -- Client/empty
	UNKNOWN_18 = 18,
	UNKNOWN_19 = 19, -- true/false
}

local Sides = {
  [0] = "spectators",
  [1] = "blue",
  [2] = "red",
}

-- define target flags as part of 32 bit bitfield
local TARGET_FLAGS = {
  UNKNOWN_1 = 0x0001,         -- 0
  RADAR_SEARCH = 0x0002,      -- 1
  EOS_VIEW = 0x0004,          -- 2
  RADAR_LOCK = 0x0008,        -- 3
  EOS_LOCK = 0x0010,          -- 4
  RADAR_TWS = 0x0020,         -- 5
  UNKNOWN_6 = 0x0040,         -- 6
  UNKNOWN_7 = 0x0080,         -- 7
  UNKNOWN_8 = 0x0100,         -- 8
  NET_HUMAN_PLANE = 0x0200,   -- 9 does not get flagged in multiplayer!?, likely wrong flag
  AUTO_LOCK_ON = 0x0400,      -- 10
  LOCK_ON_JAMMER = 0x0800,    -- 11
  UNKNOWN_10 = 0x1000,        -- 12
  UNKNOWN_11 = 0x2000,        -- 13
  UNKNOWN_12 = 0x4000,        -- 14
  UNKNOWN_13 = 0x8000,        -- 15
  UNKNOWN_14 = 0x10000,       -- 16
  UNKNOWN_15 = 0x20000,       -- 17
  UNKNOWN_16 = 0x40000,       -- 18
  UNKNOWN_17 = 0x80000,       -- 19
  UNKNOWN_18 = 0x100000,      -- 20
  UNKNOWN_19 = 0x200000,      -- 21
  UNKNOWN_20 = 0x400000,      -- 22
  UNKNOWN_21 = 0x800000,      -- 23
  UNKNOWN_22 = 0x1000000,     -- 24
  UNKNOWN_23 = 0x2000000,     -- 25
  UNKNOWN_24 = 0x4000000,     -- 26
  UNKNOWN_25 = 0x8000000,     -- 27
  UNKNOWN_26 = 0x10000000,    -- 28
  UNKNOWN_27 = 0x20000000,    -- 29
  UNKNOWN_28 = 0x40000000,    -- 30
  UNKNOWN_29 = 0x80000000,    -- 31
}

local function sideID(sidename)
  for id, name in pairs(Sides) do
    if name == sidename then
      return id
    end
  end
  return nil
end


return {
	UNIT_PROPERTIES	= UNIT_PROPERTIES,
	TARGET_FLAGS = TARGET_FLAGS,
	Sides = Sides,
	sideID = sideID,
}