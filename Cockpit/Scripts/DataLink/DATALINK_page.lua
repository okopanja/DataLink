
-- ======================================================================
-- DataLink plugin – DATALINK_page.lua
-- Visual layout for the overlay panel.
--
-- Coordinate system (SetScale(FOV)):
--   X: -1.0 (left edge) → +1.0 (right edge)
--   Y: -asp (bottom)    → +asp (top)   where asp = VP_H / VP_W
--
-- With VP_W=320, VP_H=240: asp = 0.75
--
-- All drawable elements are children of a central ceSimple anchor.
-- Move the whole panel by changing anchor.init_pos.
-- ======================================================================

dofile(LockOn_Options.common_script_path.."elements_defs.lua")
-- dofile(LockOn_Options.script_path.."common.lua")
-- for some reason gets wrong script_path when called from DATALINK_indicator_init.lua, but works fine when called from datalink_device.lua
-- instead this ugly non portable hack is used to get the correct path
dofile(lfs.writedir()..[[Mods/tech/DataLink/Cockpit/Scripts/common.lua]])
dofile(lfs.writedir()..[[Mods/tech/DataLink/Cockpit/Scripts/Datalink/definitions.lua]])

SetScale(FOV)
-- local DEBUG = false
-- Central anchor
local anchor      = CreateElement "ceSimple"
anchor.name       = "dl_anchor"
anchor.init_pos   = {2.548, -3.33, -2.49} -- (x, y, z)
anchor.init_rot   = {0, 3.2, 17.0}

Add(anchor)

local parent = anchor

-- Panel extents
local aspect = 6/5     -- panel width-to-height ratio
local bw = 0.56        -- panel half-width (0.58)
local bh = bw / aspect -- panel half-height

-- ── Contact constants ─────────────────────────────────────────────────
local MAX_CONTACTS     = 80
local maxSpeed         = 6372   -- km/h  — maps to full CONTACT_SPD_MAX line
local maxAltitude      = 15000  -- m     — maps to full CONTACT_ALT_MAX bar

local CONTACT_SPD_MIN  = bw * 0.015  -- min speed-line length at minSpeed (panel units)
local CONTACT_SPD_MAX  = bw * 0.080  -- max speed-line length at maxSpeed (panel units)
local CONTACT_ALT_MAX  = bh * 0.010  -- max altitude bar half-extent at maxAltitude
local CONTACT_ALT_MIN  = bh * 0.020  -- min altitude bar half-extent at minAltitude
local CONTACT_TAIL_LEN = bw * 0.06  -- fixed rear tail line length
local CONTACT_THICK    = 0.0025     -- line half-thickness


-- -- If DEBUG is true, then we wish to skip the clipping rectangle so we can see the whole panel in the 3D cockpit.
if not DEBUG then
	log.info("DATALINK: clipping rectangle enabled")
	local clip_rect = CreateElement "ceMeshPoly"
	clip_rect.name            = "dl_clip_rect"
	clip_rect.primitivetype   = "triangles"
	clip_rect.vertices        = {{-bw, -bh}, {bw, -bh}, {bw, bh}, {-bw, bh}}
	clip_rect.indices         = {0, 1, 2, 0, 2, 3}
	clip_rect.h_clip_relation = h_clip_relations.REWRITE_LEVEL
	clip_rect.level           = DEFAULT_LEVEL
	clip_rect.blend_mode      = blend_mode.IBM_NO_WRITECOLOR
	clip_rect.parent_element  = anchor.name
	clip_rect.material = MakeMaterial("", {255,255,255,255})
	Add(clip_rect)
	parent = clip_rect
end

-- Ownship
-- Positioned at the horizontal centre, 1/4 from the bottom of the panel.
-- Panel y-range: [-bh, +bh].  y = -bh/2
local ownship = CreateElement "ceSimple"
ownship.name = "ownship"
ownship.init_pos = {0, -bh/2, 0}
ownship.init_rot = {0, 0, 0}
ownship.parent_element = parent.name

Add(ownship)


local FONT = "font_datalink_green"

-- ── Materials palette ─────────────────────────────────────────────────
local MAT_BG        = MakeMaterial("", {  0,   0,   0, 210})
local MAT_BORDER    = MakeMaterial("", {  0, 210,   0, 255})
local MAT_TITLE     = MakeMaterial("", {  0, 130,   0, 220})
local MAT_SEPARATOR = MakeMaterial("", {  0, 180,   0, 255})
-- local MAT_CROSS     = MakeMaterial("", {  0, 210,   0, 180})
local MAT_CROSS     = MakeMaterial("", { 210, 0,   0, 180})
local MAT_CROSS_2     = MakeMaterial("", { 0, 0,   255, 255})
-- local MAT_ENEMY       = MakeMaterial("", {210, 0,     0, 255})  -- enemy contact
local MAT_ENEMY       = MakeMaterial("", {0, 210,     0, 255})  -- enemy contact

-- ── Helper: solid-colour filled quad, child of anchor ─────────────────
local function solid_quad(parent, name_, x1, y1, x2, y2, mat, level_)
	local q               = CreateElement "ceMeshPoly"
	q.name                = name_
	q.primitivetype       = "triangles"
	q.vertices            = {{x1, y2}, {x2, y2}, {x2, y1}, {x1, y1}}
	q.indices             = {0, 1, 2, 0, 2, 3}
	q.material            = mat
	q.h_clip_relation     = h_clip_relations.COMPARE
	q.level               = level_
	q.isdraw              = true
	q.parent_element      = parent.name
	Add(q)
end

-- ── Helper: thick line between two arbitrary points ───────────────────
-- Builds a quad whose long axis runs from (x1,y1) to (x2,y2).
local function line_quad(parent, name_, x1, y1, x2, y2, thick, mat, level_)
	local dx  = x2 - x1
	local dy  = y2 - y1
	local len = math.sqrt(dx*dx + dy*dy)
	if len == 0 then return end
	local px  = (-dy / len) * thick   -- perpendicular offset x
	local py  = ( dx / len) * thick   -- perpendicular offset y
	local q               = CreateElement "ceMeshPoly"
	q.name                = name_
	q.primitivetype       = "triangles"
	q.vertices            = {
		{x1 + px, y1 + py},
		{x1 - px, y1 - py},
		{x2 - px, y2 - py},
		{x2 + px, y2 + py},
	}
	q.indices             = {0, 1, 2, 0, 2, 3}
	q.material            = mat
	q.h_clip_relation     = h_clip_relations.COMPARE
	q.level               = level_
	q.isdraw              = true
	q.parent_element      = parent.name
	Add(q)
end

-- ── Enemy datalink contact symbol (argument-driven, polar coordinates) ────
-- Position is expressed in polar form: the bearing rotator ceSimple turns
-- the child coordinate system so that its +Y axis points along the bearing,
-- then the range arm child slides along that +Y axis by RANGE km.
-- No sin/cos needed in Lua — the element hierarchy performs the conversion.
--
-- Visibility is controlled by the VISIBLE argument (0 = hidden, 1 = shown).
-- All three rotations (bearing, heading-compensation, heading) are stacked
-- via multiple rotate_using_parameter controllers.
--
-- Parameters:
--   parent_elem  anchor element (typically 'ownship')
--   name         unique string prefix for element names
--   args         one entry from EnemyContactArguments: {BEARING, RANGE, …}
--   mat          material (colour)
--   level        draw level
-- Returns the root bearing-rotator ceSimple.
local function create_enemy_contact(parent_elem, contact_parameters, mat, level)
	local DEG2RAD = math.rad(1)
	local SPD2PAN = CONTACT_SPD_MAX / maxSpeed
	local ALT2PAN = CONTACT_ALT_MAX / maxAltitude
	local fx      = math.sin(math.rad(30)) * CONTACT_TAIL_LEN
	local fy      = math.cos(math.rad(30)) * CONTACT_TAIL_LEN
	local clip_relation = h_clip_relations.COMPARE  -- all contact elements are clipped by the parent (ownship) rectangle
	-- ── 1. Bearing rotator — hidden by default ────────────────────────
	-- VISIBLE arg gates the whole subtree via parameter_in_range.
	-- BEARING (degrees CW) drives a CCW rotation so +Y → bearing direction.
	local brg            = CreateElement "ceSimple"
	brg.name			 = contact_parameters.NAME .. "_brg"
	brg.init_pos         = {0, 0, 0}
	brg.parent_element   = parent_elem.name
	brg.h_clip_relation = clip_relation
	brg.element_params = {
		contact_parameters.VISIBLE,
		contact_parameters.BEARING,
		CommonParameterNames.TRUE_HEADING,
	}
	brg.controllers      = {
		{"parameter_in_range",     0, 0.5, 1.5},  -- show only when VISIBLE ≈ 1
		{"rotate_using_parameter", 1, -DEG2RAD},  -- CW degrees → −rad
		{"rotate_using_parameter", 2, 1},  -- CW degrees → −rad (cancels ownship heading)
	}
	Add(brg)


	-- ── 2. Range arm — slides along bearing-rotated +Y axis ────────────
	-- RANGE is pre-scaled by the device (contact.RANGE / ZoomLevels[zoom_level]),
	-- so 1.0 == full visible range and KM2PAN is a fixed panel-height factor.
	local KM2PAN = (bh * 3/2) / 70
	local rng            = CreateElement "ceSimple"
	rng.name             = contact_parameters.NAME .. "_rng"
	rng.init_pos         = {0, 0, 0}
	rng.parent_element   = brg.name
	rng.h_clip_relation = clip_relation
	rng.element_params = {
		contact_parameters.RANGE,
	}
	rng.controllers      = {{"move_up_down_using_parameter", 0, KM2PAN}}
	Add(rng)

	-- ── 3. Heading rotator — contact faces its absolute heading ─────────
	local sym            = CreateElement "ceSimple"
	sym.name             = contact_parameters.NAME .. "_sym"
	sym.init_pos         = {0, 0, 0}
	sym.parent_element   = rng.name
	sym.h_clip_relation = clip_relation
	sym.element_params   = {
		contact_parameters.BEARING,
		contact_parameters.HEADING,
	}
	sym.controllers      = {
		{"rotate_using_parameter", 0,  DEG2RAD},  -- +bearing (cancels parent)
		{"rotate_using_parameter", 1, -DEG2RAD},  -- −heading (applies heading)
	}
	Add(sym)

	-- ── 4. Speed bar — ceSimpleLineObject; point 0 fixed, point 1 driven by SPEED ──
	local min_spd_line           = CreateElement "ceSimpleLineObject"
	min_spd_line.name            = contact_parameters.NAME .. "_min_spd"
	min_spd_line.material        = mat
	min_spd_line.init_pos        = {0, 0, 0}
	min_spd_line.vertices        = {{0, 0}, {0, CONTACT_SPD_MIN}}
	min_spd_line.indices         = {0, 1}
	min_spd_line.width           = CONTACT_THICK
	min_spd_line.parent_element  = sym.name
	min_spd_line.h_clip_relation = clip_relation
	min_spd_line.level           = level
	-- min_spd_line.element_params  = {contact_parameters["SPEED"]}
	-- min_spd_line.controllers     = {{"line_object_set_point_using_parameters", 1, 0, 0, 0, SPD2PAN}}
	Add(min_spd_line)

	local spd_line           = CreateElement "ceSimpleLineObject"
	spd_line.name            = contact_parameters.NAME .. "_spd"
	spd_line.material        = mat
	spd_line.init_pos        = {0, 0, 0}
	spd_line.vertices        = {{0, 0}, {0, CONTACT_SPD_MAX}}
	spd_line.indices         = {0, 1}
	spd_line.width           = CONTACT_THICK
	spd_line.parent_element  = sym.name
	spd_line.h_clip_relation = clip_relation
	spd_line.level           = level
	spd_line.element_params  = {contact_parameters.SPEED}
	spd_line.controllers     = {{"line_object_set_point_using_parameters", 1, 0, 0, 0, SPD2PAN}}
	Add(spd_line)



	-- ── 5. Altitude bar — two ceSimpleLineObject arms, symmetric on ±X ──
	local min_alt_l              = CreateElement "ceSimpleLineObject"
	min_alt_l.name               = contact_parameters.NAME .. "_min_alt_l"
	min_alt_l.material           = mat
	min_alt_l.init_pos           = {0, 0, 0}
	min_alt_l.vertices           = {{0, 0}, {-CONTACT_ALT_MIN, 0}}
	min_alt_l.indices            = {0, 1}
	min_alt_l.width              = CONTACT_THICK
	min_alt_l.parent_element     = sym.name
	min_alt_l.h_clip_relation    = clip_relation
	min_alt_l.level              = level
	-- min_alt_l.element_params     = {contact_parameters.ALTITUDE}
	-- min_alt_l.controllers        = {{"line_object_set_point_using_parameters", 1, 0, 0, -ALT2PAN, 0}}
	Add(min_alt_l)

	local min_alt_r              = CreateElement "ceSimpleLineObject"
	min_alt_r.name               = contact_parameters.NAME .. "_min_alt_r"
	min_alt_r.material           = mat
	min_alt_r.init_pos           = {0, 0, 0}
	min_alt_r.vertices           = {{0, 0}, {CONTACT_ALT_MIN, 0}}
	min_alt_r.indices            = {0, 1}
	min_alt_r.width              = CONTACT_THICK
	min_alt_r.parent_element     = sym.name
	min_alt_r.h_clip_relation    = clip_relation
	min_alt_r.level              = level
	-- min_alt_r.element_params     = {contact_parameters.ALTITUDE}
	-- min_alt_r.controllers        = {{"line_object_set_point_using_parameters", 1, 0, 0, ALT2PAN, 0}}
	Add(min_alt_r)

	local alt_l              = CreateElement "ceSimpleLineObject"
	alt_l.name               = contact_parameters.NAME .. "_alt_l"
	alt_l.material           = mat
	alt_l.init_pos           = {0, 0, 0}
	alt_l.vertices           = {{0, 0}, {-CONTACT_ALT_MAX, 0}}
	alt_l.indices            = {0, 1}
	alt_l.width              = CONTACT_THICK
	alt_l.parent_element     = sym.name
	alt_l.h_clip_relation    = clip_relation
	alt_l.level              = level
	alt_l.element_params     = {contact_parameters.ALTITUDE}
	alt_l.controllers        = {{"line_object_set_point_using_parameters", 1, 0, 0, -ALT2PAN, 0}}
	Add(alt_l)

	local alt_r              = CreateElement "ceSimpleLineObject"
	alt_r.name               = contact_parameters.NAME .. "_alt_r"
	alt_r.material           = mat
	alt_r.init_pos           = {0, 0, 0}
	alt_r.vertices           = {{0, 0}, {CONTACT_ALT_MAX, 0}}
	alt_r.indices            = {0, 1}
	alt_r.width              = CONTACT_THICK
	alt_r.parent_element     = sym.name
	alt_r.h_clip_relation    = clip_relation
	alt_r.level              = level
	alt_r.element_params     = {contact_parameters.ALTITUDE}
	alt_r.controllers        = {{"line_object_set_point_using_parameters", 1, 0, 0, ALT2PAN, 0}}
	Add(alt_r)

	-- ── 6. Fins — fixed tail lines at ±30° off −Y (canonical up) ────────
	line_quad(sym, contact_parameters.NAME .. "_fin_l", 0, 0, -fx, -fy, CONTACT_THICK, mat, level)
	line_quad(sym, contact_parameters.NAME .. "_fin_r", 0, 0,  fx, -fy, CONTACT_THICK, mat, level)

	return brg
end

-- ── Helper: hollow border as four edge bars ───────────────────────────
local function outline_rect(parent, name_, ox, oy, thick, mat, level_)
	solid_quad(parent, name_.."_t",  -ox,  oy-thick,  ox,  oy,            mat, level_)
	solid_quad(parent, name_.."_b",  -ox, -oy,        ox, -oy+thick,      mat, level_)
	solid_quad(parent, name_.."_l",  -ox, -oy+thick, -ox+thick, oy-thick, mat, level_)
	solid_quad(parent, name_.."_r",   ox-thick, -oy+thick, ox, oy-thick,  mat, level_)
end


if DEBUG then
	-- DEBUG ownship position, represented as small cross 1/10 of bw
	local CROSS_THICK = 0.002
	solid_quad(ownship, "dl_ownship_cross_h", -0.1 * bw, -CROSS_THICK, 0.1 * bw, CROSS_THICK, MAT_CROSS_2, DEFAULT_LEVEL + 6)
	solid_quad(ownship, "dl_ownship_cross_v", -CROSS_THICK, -0.1 * bh, CROSS_THICK, 0.1 * bh, MAT_CROSS_2, DEFAULT_LEVEL + 6)
end

-- ── Toggle-visibility test rectangle ────────────────────────────────
local toggle_rect             = CreateElement "ceMeshPoly"
toggle_rect.name              = "dl_toggle_rect"
toggle_rect.primitivetype     = "triangles"
toggle_rect.vertices          = {{-0.025, -0.025}, {0.025, -0.025}, {0.025, 0.025}, {-0.025, 0.025}}
toggle_rect.indices           = {0, 1, 2, 0, 2, 3}
toggle_rect.material          = MAT_BORDER
toggle_rect.h_clip_relation   = h_clip_relations.REWRITE_LEVEL
toggle_rect.level             = DEFAULT_LEVEL
toggle_rect.isdraw            = false
toggle_rect.parent_element    = parent.name
toggle_rect.element_params    = {CommonParameterNames.DATALINK_TOGGLE_VISIBILITY}
toggle_rect.controllers       = {{"parameter_in_range", 0, 0.5, 1.5}}
Add(toggle_rect)

-- ── Argument-driven enemy contacts (polar, hidden by default) ─────────
-- Contacts are children of ownship so range/bearing are ownship-relative.
-- The device enables each slot by setting EnemyContactArguments[i].VISIBLE = 1.
for i = 1, #EnemyContactParameterNames do
	create_enemy_contact(ownship, EnemyContactParameterNames[i], MAT_ENEMY, DEFAULT_LEVEL)
end

if DEBUG then
	local BORDER_THICK = 0.004
	-- ── Border ────────────────────────────────────────────────────────────
	outline_rect(parent, "dl_border", bw, bh, BORDER_THICK,   MAT_BORDER,    DEFAULT_LEVEL + 2)
end

-- if DEBUG then

-- 	-- Background
-- 	solid_quad(parent, "dl_bg", -bw, -bh, bw, bh,   MAT_BG,        DEFAULT_LEVEL + 1)


-- 	-- ── Title bar ─────────────────────────────────────────────────────────
-- 	local TITLE_H   = 0.13
-- 	local TITLE_TOP = bh - BORDER_THICK
-- 	local TITLE_BOT = TITLE_TOP - TITLE_H

-- 	-- DEBUG Center cross 
-- 	solid_quad(parent, "dl_cross_h", -bw, -CROSS_THICK, bw,         CROSS_THICK,           MAT_CROSS, DEFAULT_LEVEL + 5)
-- 	solid_quad(parent, "dl_cross_v", -CROSS_THICK, -bh + BORDER_THICK, CROSS_THICK, TITLE_BOT, MAT_CROSS, DEFAULT_LEVEL + 5)



-- 	-- ── Title text ────────────────────────────────────────────────────────
-- 	local txt_title          = CreateElement "ceStringPoly"
-- 	txt_title.name           = "dl_txt_title"
-- 	txt_title.material       = FONT
-- 	txt_title.init_pos       = {0, TITLE_BOT + TITLE_H * 0.5 - 0.02, 0}
-- 	txt_title.alignment      = "CenterCenter"
-- 	txt_title.stringdefs     = {0.005, 0.006, 0.0003, 0}
-- 	txt_title.value          = "DATALINK"
-- 	txt_title.level          = DEFAULT_LEVEL + 5
-- 	txt_title.parent_element = parent.name
-- 	Add(txt_title)

-- 	-- ── Main text 1 ────────────────────────────────────────────────────────
-- 	local txt_main_1           = CreateElement "ceStringPoly"
-- 	txt_main_1.name            = "dl_txt_hello-1"
-- 	txt_main_1.material        = FONT
-- 	txt_main_1.init_pos        = {0, 0.06, 0}
-- 	txt_main_1.alignment       = "CenterCenter"
-- 	txt_main_1.stringdefs      = {0.007, 0.009, 0.0005, 0}
-- 	txt_main_1.value           = "HELLO WORLD"
-- 	txt_main_1.level           = DEFAULT_LEVEL + 5
-- 	txt_main_1.parent_element  = parent.name
-- 	Add(txt_main_1)

-- 	-- ── Main text 2 ────────────────────────────────────────────────────────
-- 	local txt_main_2           = CreateElement "ceStringPoly"
-- 	txt_main_2.name            = "dl_txt_hello_2"
-- 	txt_main_2.material        = FONT
-- 	txt_main_2.init_pos        = {0, -0.06, 0}
-- 	txt_main_2.alignment       = "CenterCenter"
-- 	txt_main_2.stringdefs      = {0.007, 0.009, 0.0005, 0}
-- 	txt_main_2.value           = "CONTENTION"
-- 	txt_main_2.level           = DEFAULT_LEVEL + 5
-- 	txt_main_2.parent_element  = parent.name
-- 	Add(txt_main_2)

-- 	local txt_status          = CreateElement "ceStringPoly"
-- 	txt_status.name           = "dl_txt_status"
-- 	txt_status.material       = FONT
-- 	txt_status.init_pos       = {0, -bh + BORDER_THICK + 0.07, 0}
-- 	txt_status.alignment      = "CenterCenter"
-- 	txt_status.stringdefs     = {0.004, 0.005, 0.0003, 0}
-- 	txt_status.value          = "DEMO MODE"
-- 	txt_status.level          = DEFAULT_LEVEL + 5
-- 	txt_status.parent_element = parent.name
-- 	Add(txt_status)

-- 	-- ── Status text ───────────────────────────────────────────────────────
-- 	local txt_status_clipping_off          = CreateElement "ceStringPoly"
-- 	txt_status_clipping_off.name           = "dl_txt_clipping_off"
-- 	txt_status_clipping_off.material       = FONT
-- 	txt_status_clipping_off.init_pos       = {0, 2.2 * bh + BORDER_THICK + 0.07, 0}
-- 	txt_status_clipping_off.alignment      = "CenterCenter"
-- 	txt_status_clipping_off.stringdefs     = {0.004, 0.005, 0.0003, 0}
-- 	txt_status_clipping_off.value          = "DEBUG: CLIPPING OFF!"
-- 	txt_status_clipping_off.level          = DEFAULT_LEVEL + 5
-- 	txt_status_clipping_off.parent_element = parent.name
-- 	Add(txt_status_clipping_off)

-- end


if DEBUG then
	saveInspect("_G_page", _G, true)
end
