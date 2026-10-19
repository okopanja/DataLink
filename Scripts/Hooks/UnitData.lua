-- if DCS defined take values from DCS, otherwise fallback to hardcoded default values
local UNIT_PROPERTIES = {
  UNIT_RUNTIME_ID = DCS ~= nil and DCS.UNIT_RUNTIME_ID or 1, 
  UNIT_MISSION_ID = DCS ~= nil and DCS.UNIT_MISSION_ID or 2, -- slot ID
  UNIT_NAME = DCS ~= nil and DCS.UNIT_NAME or 3, -- Palmachim_C-130J-30_4333-1
  UNIT_TYPE = DCS ~= nil and DCS.UNIT_TYPE or 4,
  UNIT_CATEGORY = DCS ~= nil and DCS.UNIT_CATEGORY or 5, -- nil/empty?
  UNIT_GROUP_MISSION_ID = DCS ~= nil and DCS.UNIT_GROUP_MISSION_ID or 6, -- 1004292
  UNIT_GROUPNAME = DCS ~= nil and DCS.UNIT_GROUPNAME or 7, -- King Hussein Air College_F-16CM bl.50_4292, Hama_F-14B(U)_4298, Virtual unit
  UNIT_GROUPCATEGORY = DCS ~= nil and DCS.UNIT_GROUPCATEGORY or 8, -- plane, helicopter, nil, ""
  UNIT_CALLSIGN = DCS ~= nil and DCS.UNIT_CALLSIGN or 9,
  UNIT_HIDDEN = DCS ~= nil and DCS.UNIT_HIDDEN or 10, -- true/false
  UNIT_COALITION = DCS ~= nil and DCS.UNIT_COALITION or 11, -- red/blue/nil
  UNIT_COUNTRY_ID = DCS ~= nil and DCS.UNIT_COUNTRY_ID or 12, -- 18, 21, nil	
  UNIT_TASK = DCS ~= nil and DCS.UNIT_TASK or 13, -- CAS, CAP, SEAD, nil
  UNIT_PLAYER_NAME = DCS ~= nil and DCS.UNIT_PLAYER_NAME or 14, -- nickname
  UNIT_ROLE = DCS ~= nil and DCS.UNIT_ROLE or 15, -- artillery_commander/Pilot
  UNIT_INVISIBLE_MAP_ICON = DCS ~= nil and DCS.UNIT_INVISIBLE_MAP_ICON or 16, -- true/false
  UNIT_INVISIBLE_MAP_LABEL = DCS ~= nil and DCS.UNIT_INVISIBLE_MAP_LABEL or 17, -- Client/empty
  UNKNOWN_18 = 18,
  UNKNOWN_19 = 19, -- true/false
}

local Sides = {
  [0] = "spectators",
  [1] = "red",
  [2] = "blue",
  [3] = "neutral"
}

local IFF = {
  FRIENDLY = 1,
  NEUTRAL  = 2,
  UNKNOWN  = 3,
  HOSTILE  = 4,
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

CONTACT_SOURCES = {
  RLPK_27 = "RLPK-27",
  K_DLAE = "К-ДлАЭ",
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
	UNIT_PROPERTIES	= DCS ~= nil and UNIT_PROPERTIES or nil,
	TARGET_FLAGS = TARGET_FLAGS,
	Sides = Sides,
	sideID = sideID,
  IFF = IFF,
	CONTACT_SOURCES = CONTACT_SOURCES,
}