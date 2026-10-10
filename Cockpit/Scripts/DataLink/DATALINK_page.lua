
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

-- Contact constants -------------------------------------------------
local MAX_CONTACTS     = 80
local maxSpeed         = 6372   -- km/h  - maps to full CONTACT_SPD_MAX line
local maxAltitude      = 15000  -- m     - maps to full CONTACT_ALT_MAX bar

local CONTACT_SPD_MIN  = bw * 0.015  -- min speed-line length at minSpeed (panel units)
local CONTACT_SPD_MAX  = bw * 0.080  -- max speed-line length at maxSpeed (panel units)
local CONTACT_ALT_MAX  = bh * 0.010  -- max altitude bar half-extent at maxAltitude
local CONTACT_ALT_MIN  = bh * 0.020  -- min altitude bar half-extent at minAltitude
local CONTACT_TAIL_LEN = bw * 0.06  -- fixed rear tail line length
local CONTACT_THICK    = 0.0025     -- line half-thickness
local CONTACT_RADIUS = bw * 0.025  -- contact circle radius (panel units)

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

-- Materials palette -------------------------------------------------
local MAT_BG        = MakeMaterial("", {  0,   0,   0, 210})
local MAT_BORDER    = MakeMaterial("", {  0, 210,   0, 255})
local MAT_TITLE     = MakeMaterial("", {  0, 130,   0, 220})
local MAT_SEPARATOR = MakeMaterial("", {  0, 180,   0, 255})
-- local MAT_CROSS     = MakeMaterial("", {  0, 210,   0, 180})
local MAT_CROSS     = MakeMaterial("", { 210, 0,   0, 180})
local MAT_CROSS_2     = MakeMaterial("", { 0, 0,   255, 255})
local MAT_DEFAULT    = MakeMaterial("", {  0, 255, 0, 255})  -- default contact is green
-- local MAT_ENEMY       = MakeMaterial("", {210, 0,     0, 255})  -- enemy contact RED
-- local MAT_FRIENDLY       = MakeMaterial("", {0, 0,     210, 255})  -- friendly contact BLUE
-- local MAT_ENEMY       = MakeMaterial("", {0, 210,     0, 255})  -- enemy contact

local function normalize_color(color)
	return {color[1]/255, color[2]/255, color[3]/255}
end

local coalition_color_filters = {
	FRIENDLY = {0, 210, 0, 255},
	NEUTRAL = {210, 210, 210, 255},
	UNKNOWN = {210, 210, 0, 255},
	HOSTILE = {210, 0, 0, 255},
}

coalition_color_filters = {
	FRIENDLY = {0, 210, 0, 255},
	NEUTRAL = {0, 210, 0, 255},
	UNKNOWN = {0, 210, 0, 255},
	HOSTILE = {0, 210, 0, 255},
}

local normalized_coalition_color_filters = {
	FRIENDLY = normalize_color(coalition_color_filters.FRIENDLY),
	NEUTRAL = normalize_color(coalition_color_filters.NEUTRAL),
	UNKNOWN = normalize_color(coalition_color_filters.UNKNOWN),
	HOSTILE = normalize_color(coalition_color_filters.HOSTILE),
}

-- -- Helper: solid-colour filled quad, child of anchor -----------------
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

-- -- Helper: thick line between two arbitrary points -------------------
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

-- Position is expressed in polar form: the bearing rotator ceSimple turns
-- the child coordinate system so that its +Y axis points along the bearing,
-- then the range arm child slides along that +Y axis by RANGE km.
-- No sin/cos needed in Lua - the element hierarchy performs the conversion.
--
-- Visibility is controlled by the VISIBLE argument (0 = hidden, 1 = shown).
-- All three rotations (bearing, heading-compensation, heading) are stacked
-- via multiple rotate_using_parameter controllers.
--
-- Parameters:
--   parent_elem  anchor element (typically 'ownship')
--   name         unique string prefix for element names
--   args         one entry from ContactArguments: {BEARING, RANGE, …}
--   mat          material (colour)
--   level        draw level
-- Returns the root bearing-rotator ceSimple.
local function create_contact(parent_elem, contact_parameters, mat, level)
	local DEG2RAD = math.rad(1)
	local SPD2PAN = CONTACT_SPD_MAX / maxSpeed
	local ALT2PAN = CONTACT_ALT_MAX / maxAltitude
	local enemy_tail_x      = math.sin(math.rad(30)) * CONTACT_TAIL_LEN
	local enemy_tail_y      = math.cos(math.rad(30)) * CONTACT_TAIL_LEN
	local clip_relation = h_clip_relations.COMPARE  -- all contact elements are clipped by the parent (ownship) rectangle
	
	log.info("Creating contact: " .. contact_parameters.NAME)
	-- 1. Bearing rotation - created as ceSimple (not visible)
	local brg            = CreateElement "ceSimple"
	brg.name			 = contact_parameters.NAME .. "_brg"
	brg.init_pos         = {0, 0, 0}
	brg.parent_element   = parent_elem.name
	brg.h_clip_relation = clip_relation
	brg.element_params = {
		contact_parameters.VISIBLE, -- controls visibility of object and its children
		contact_parameters.BEARING, -- bearing to the contact
		CommonParameterNames.TRUE_HEADING, -- true heading of ownship
	}
	brg.controllers      = {
		{"parameter_in_range",     0, 0.5, 1.5},  -- show only when VISIBLE ≈ 1
		{"rotate_using_parameter", 1, -DEG2RAD},  -- convert parameter expressed into degrees into negative radians
		{"rotate_using_parameter", 2, 1},  -- rotate element by ownship true heading, so that contacts is displayed correctly on the screen
	}
	Add(brg)
	log.info("Created bearing rotator for contact: " .. contact_parameters.NAME)

	-- 2. Range arm - moves the contact along the bearing line by RANGE
	-- RANGE is pre-scaled by the device (contact.RANGE / ZoomLevels[zoom_level]),
	-- so 1.0 == full visible range and KM2PAN is a fixed panel-height factor.
	local KM2PAN = (bh * 3/2) / 70
	local rng            = CreateElement "ceSimple"
	rng.name             = contact_parameters.NAME .. "_rng"
	rng.init_pos         = {0, 0, 0}
	rng.parent_element   = brg.name
	rng.h_clip_relation = clip_relation
	rng.element_params = {
		contact_parameters.RANGE, -- range to the contact, in km
	}
	rng.controllers      = {{"move_up_down_using_parameter", 0, KM2PAN}} -- move along the bearing and scale km to panel units
	Add(rng)
	log.info("Created range arm for contact: " .. contact_parameters.NAME)

	-- 3. Heading rotation of the contact itself
	local sym            = CreateElement "ceSimple"
	sym.name             = contact_parameters.NAME .. "_sym"
	sym.init_pos         = {0, 0, 0}
	sym.parent_element   = rng.name
	sym.h_clip_relation = clip_relation
	sym.element_params   = {
		contact_parameters.BEARING, -- cancels the parent
		contact_parameters.HEADING, -- applies the contact's own heading
	}
	sym.controllers      = {
		{"rotate_using_parameter", 0,  DEG2RAD},  -- +bearing (cancels parent)
		{"rotate_using_parameter", 1, -DEG2RAD},  -- −heading (applies heading)
	}
	Add(sym)
	log.info("Created heading rotator for contact: " .. contact_parameters.NAME)

	-- TODO: objects 5 and 6 should be refactored and merged into a single object.
	-- 5. Speed bar - ceSimpleLineObject; point 0 fixed, point 1 is fixed.
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
	log.info("Created minimum speed bar for contact: " .. contact_parameters.NAME)

	-- 6. Speed bar - ceSimpleLineObject; point 0 fixed, point 1 scaled by SPEED parameter. The line is drawn along own heading.
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
	spd_line.element_params  = {
		contact_parameters.SPEED
		-- contact_parameters.IFF,
	}
	spd_line.controllers     = {
		{"line_object_set_point_using_parameters", 1, 0, 0, 0, SPD2PAN} -- point number 1, param X, param Y, scale X, scale Y)
		-- {"change_color_when_parameter_equal_to_number", 1, 1, normalized_coalition_color_filters.FRIENDLY[1], normalized_coalition_color_filters.FRIENDLY[2], normalized_coalition_color_filters.FRIENDLY[3]},
		-- {"change_color_when_parameter_equal_to_number", 1, 2, normalized_coalition_color_filters.NEUTRAL[1], normalized_coalition_color_filters.NEUTRAL[2], normalized_coalition_color_filters.NEUTRAL[3]},
		-- {"change_color_when_parameter_equal_to_number", 1, 3, normalized_coalition_color_filters.UNKNOWN[1], normalized_coalition_color_filters.UNKNOWN[2], normalized_coalition_color_filters.UNKNOWN[3]},
		-- {"change_color_when_parameter_equal_to_number", 1, 4, normalized_coalition_color_filters.HOSTILE[1], normalized_coalition_color_filters.HOSTILE[2], normalized_coalition_color_filters.HOSTILE[3]}
	}
	Add(spd_line)
	log.info("Created speed bar for contact: " .. contact_parameters.NAME)

	-- 7. Altitude minimal bar
	local min_alt_line              = CreateElement "ceSimpleLineObject"
	min_alt_line.name               = contact_parameters.NAME .. "_min_alt"
	min_alt_line.material           = mat
	min_alt_line.init_pos           = {0, 0, 0}
	min_alt_line.vertices           = {{CONTACT_ALT_MIN, 0}, {-CONTACT_ALT_MIN, 0}}
	min_alt_line.indices            = {0, 1}
	min_alt_line.width              = CONTACT_THICK
	min_alt_line.parent_element     = sym.name
	min_alt_line.h_clip_relation    = clip_relation
	min_alt_line.level              = level
	Add(min_alt_line)
	log.info("Created minimum altitude bar for contact: " .. contact_parameters.NAME)

	-- 8. Altitude bar
	local alt_line              = CreateElement "ceSimpleLineObject"
	alt_line.name               = contact_parameters.NAME .. "_alt"
	alt_line.material           = mat
	alt_line.init_pos           = {0, 0, 0}
	alt_line.vertices           = {{CONTACT_ALT_MAX, 0}, {-CONTACT_ALT_MAX, 0}}
	alt_line.indices            = {0, 1}
	alt_line.width              = CONTACT_THICK
	alt_line.parent_element     = sym.name
	alt_line.h_clip_relation    = clip_relation
	alt_line.level              = level
	alt_line.element_params     = {contact_parameters.ALTITUDE}
	alt_line.controllers        = {
		{"line_object_set_point_using_parameters", 0, 0, 0, ALT2PAN, 0},
		{"line_object_set_point_using_parameters", 1, 0, 0, -ALT2PAN, 0}
	}
	Add(alt_line)
	log.info("Created altitude bar for contact: " .. contact_parameters.NAME)

	-- 9. Fins - fixed tail lines at +-30° toward rear of contact

	local enemy_fins = CreateElement "ceSimple"
	enemy_fins.name = contact_parameters.NAME .. "_enemy_fins"
	enemy_fins.init_pos = {0, 0, 0}
	enemy_fins.parent_element = sym.name
	enemy_fins.element_params = {contact_parameters.IFF}
	enemy_fins.controllers = {
		{"parameter_in_range", 0, 3.5, 4.5}
	}
	Add(enemy_fins)

	local enemy_fin_l          = CreateElement "ceSimpleLineObject"
	enemy_fin_l.name               = contact_parameters.NAME .. "_enemy_fin_l"
	enemy_fin_l.material           = mat
	enemy_fin_l.init_pos           = {0, 0, 0}
	enemy_fin_l.vertices           = {{0, 0}, {-enemy_tail_x, -enemy_tail_y}}
	enemy_fin_l.indices            = {0, 1}
	enemy_fin_l.width              = CONTACT_THICK
	enemy_fin_l.parent_element     = enemy_fins.name
	enemy_fin_l.h_clip_relation    = clip_relation
	enemy_fin_l.level              = level
	Add(enemy_fin_l)
	log.info("Created left fin for enemy contact: " .. contact_parameters.NAME)

	local enemy_fin_r          = CreateElement "ceSimpleLineObject"
	enemy_fin_r.name               = contact_parameters.NAME .. "_enemy_fin_r"
	enemy_fin_r.material           = mat
	enemy_fin_r.init_pos           = {0, 0, 0}
	enemy_fin_r.vertices           = {{0, 0}, {enemy_tail_x, -enemy_tail_y}}
	enemy_fin_r.indices            = {0, 1}
	enemy_fin_r.width              = CONTACT_THICK
	enemy_fin_r.parent_element     = enemy_fins.name
	enemy_fin_r.h_clip_relation    = clip_relation
	enemy_fin_r.level              = level
	Add(enemy_fin_r)
	log.info("Created right fin for enemy contact: " .. contact_parameters.NAME)

	-- -- 10. Friendly circle
	local friendly_circle          = CreateElement "ceCircle"
	friendly_circle.name               = contact_parameters.NAME .. "_friendly_circle"
	friendly_circle.material           = mat
	friendly_circle.init_pos           = {0, -CONTACT_RADIUS}
	friendly_circle.radius             = {CONTACT_RADIUS - (2 * CONTACT_THICK), CONTACT_RADIUS}
	friendly_circle.width              = CONTACT_THICK
	friendly_circle.parent_element     = sym.name
	friendly_circle.h_clip_relation    = clip_relation
	friendly_circle.level              = level
	friendly_circle.element_params     = {contact_parameters.IFF}
	friendly_circle.controllers        = {{"parameter_in_range", 0, -0.5, 3.5}}
	Add(friendly_circle)
	log.info("Created friendly circle for contact: " .. contact_parameters.NAME)

	return brg
end

-- hollow border as four edge bars
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

-- TODO: this is not really needed, it should be removed
-- Test of visibility toggle parameter.  A small square in the top-left corner of the panel.
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

-- Create the contact elements relative to the ownship elemnent
for i = 1, #ContactParameterNames do
	-- create contact and set material to default
	create_contact(ownship, ContactParameterNames[i], MAT_DEFAULT, DEFAULT_LEVEL)
end

if DEBUG then
	local BORDER_THICK = 0.004
	-- Border outline rectangle around the panel, drawn on top of all other elements.
	outline_rect(parent, "dl_border", bw, bh, BORDER_THICK,   MAT_BORDER,    DEFAULT_LEVEL + 2)
end

if DEBUG then
	saveInspect("_G_page", _G, true)
end
