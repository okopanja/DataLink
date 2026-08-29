local lfs = require('lfs')
dofile(LockOn_Options.script_path.."common.lua")
dofile(LockOn_Options.script_path..[[Datalink\definitions.lua]])
-- ======================================================================
-- DataLink plugin – datalink_device.lua  (avLuaDevice backend)
--
-- Argument layout (shared with DataLink_hook.lua and DATALINK_page.lua):
--   arg[ARG_SEQ]             sequence counter — incremented by hook on each new picture
--   arg[ARG_COUNT]           number of valid contacts in current picture
--   arg[ARG_BASE + i*5 + 0]  BRG  (degrees)
--   arg[ARG_BASE + i*5 + 1]  RNG  (km, float)
--   arg[ARG_BASE + i*5 + 2]  ALT  (meter)
--   arg[ARG_BASE + i*5 + 3]  SPD  (km/h)
--   arg[ARG_BASE + i*5 + 4]  HDG  (degrees)
--   i = 0 .. MAX_CONTACTS-1
-- ======================================================================

print_message_to_user("DataLink: device loaded for "..get_aircraft_type())
print_message_to_user("Username: "..get_aircraft_property("MY_PROPERTY"))
require("terrain")
-- require("net")
local dev = GetSelf()
make_default_activity(0.1)

local ARGS_PER_CTX = 5
local DL_COMMAND_ID = 123456
local DL_COMMAND_ARG = 123456
local DL_COMMAND_SEQ      = DL_COMMAND_ID + 1
local DL_COMMAND_COUNT    = DL_COMMAND_SEQ + 1
local DL_COMMAND_BASE     = DL_COMMAND_COUNT + 1         -- contact slots start here
-- Draw argument used for device discovery handshake.
-- The hook iterates all devices, sends DL_COMMAND_ID, and confirms the device is present
-- by reading Export.LoGetAircraftDrawArgumentValue(DL_DISCOVERY_ARG) == DL_DISCOVERY_VALUE.
local DL_DISCOVERY_ARG   = 512
local DL_DISCOVERY_VALUE = 1.0

local iCommandPlaneZoomIn  = 103
local iCommandPlaneZoomOut = 104
local iCommandPlaneModeNAV = 105;
local iCommandPlaneModeBVR = 106;
local iCommandPlaneModeVS = 107;
local iCommandPlaneModeBore = 108;
local iCommandPlaneModeHelmet = 109;
local iCommandPlaneModeFI0 = 110;
local iCommandPlaneModeGround = 111;
local iCommandPlaneModeGrid = 112;
local iCommandPowerOnOff = 315;
local iCommandPlayerToPlayer = 1001;
local last_mode = iCommandPlaneModeNAV
local DEFAULT_ZOOM_LEVEL = 4
local zoom_level = DEFAULT_ZOOM_LEVEL

print_message_to_user("DataLink: "..tostring(DEBUG))

function post_initialize()
	print_message_to_user("DataLink: initialized")
	-- Register all command IDs so the C++ routing layer delivers them to SetCommand.
	-- Without listen_command(), SetCommand() is never called and pushes are silently dropped.
	dev:listen_command(DL_COMMAND_ID)
	dev:listen_command(DL_COMMAND_SEQ)
	dev:listen_command(DL_COMMAND_COUNT)
	-- following are tracked in order to track zoom level so proper range scalling is applied to the contacts and those too far away are filtered out
	dev:listen_command(iCommandPlaneZoomIn)
	dev:listen_command(iCommandPlaneZoomOut)
	dev:listen_command(iCommandPlaneModeNAV)
	dev:listen_command(iCommandPlaneModeBVR)
	dev:listen_command(iCommandPlaneModeVS)
	dev:listen_command(iCommandPlaneModeBore)
	dev:listen_command(iCommandPlaneModeHelmet)
	dev:listen_command(iCommandPlaneModeFI0)
	dev:listen_command(iCommandPlaneModeGround)
	dev:listen_command(iCommandPlaneModeGrid)
	dev:listen_command(iCommandPowerOnOff)
	dev:listen_command(iCommandPlayerToPlayer)
	for i = 0, MAX_CONTACTS - 1 do
		for f = 0, ARGS_PER_CTX - 1 do
			dev:listen_command(DL_COMMAND_BASE + i * ARGS_PER_CTX + f)
		end
	end
	-- register Events to listen to
	for event_key, event_name in pairs(EVENTS) do
		dev:listen_event(event_name)
	end
	if DEBUG then
		show_dummy_targets()
		show_param_handles_list()		
	end
end

-- State

local last_seq  = -1
local new_contacts = {} -- contacts being received
local received_contacts  = {}   -- current picture: list of {brg, rng, alt, spd, hdg}

-- ── Update loop ───────────────────────────────────────────────────────

local toggle_visibility_handle = get_param_handle(CommonParameterNames.DATALINK_TOGGLE_VISIBILITY)
toggle_visibility_handle:set(0.0)

local base_data = get_base_data()
local EnemyContactParameterHandles = {}
for i = 1, #EnemyContactParameterNames do
  EnemyContactParameterHandles[i] = {
    BEARING  = get_param_handle(EnemyContactParameterNames[i].BEARING),
    RANGE    = get_param_handle(EnemyContactParameterNames[i].RANGE),
    ALTITUDE = get_param_handle(EnemyContactParameterNames[i].ALTITUDE),
    SPEED    = get_param_handle(EnemyContactParameterNames[i].SPEED),
    HEADING  = get_param_handle(EnemyContactParameterNames[i].HEADING),
    VISIBLE  = get_param_handle(EnemyContactParameterNames[i].VISIBLE),
  }
end

local true_heading_handle = get_param_handle(CommonParameterNames.TRUE_HEADING)
local full_circle_radian = 2 * math.pi
function update()
	local heading = base_data:getHeading()
	true_heading_handle:set(full_circle_radian - heading)
end

function update_contacts(contacts)
	log.info("Zoom level: "..tostring(zoom_level))
	local scale = HDDScales[zoom_level]

	for i, contact in ipairs(contacts) do	
		if contact.BEARING and contact.RANGE and contact.ALTITUDE and contact.SPEED and contact.HEADING then
			local contact_parameters = EnemyContactParameterHandles[i]
			for key, value in pairs(contact) do
				if key == "RANGE" then
					contact_parameters[key]:set(value / scale)
				else
					contact_parameters[key]:set(value)
				end
			end
			contact_parameters["VISIBLE"]:set(1.0)
		end
	end
	for i = #contacts + 1, MAX_CONTACTS do
		local contact_parameters = EnemyContactParameterHandles[i]
		contact_parameters["VISIBLE"]:set(0.0)
	end
end

-- ── Cockpit events ────────────────────────────────────────────────────

function CockpitEvent(event, value)
	log.info("DataLink: CockpitEvent: event="..tostring(event).." value="..tostring(value))
end

-- ── Commands ──────────────────────────────────────────────────────────

function SetCommand(command, value)
	if command == iCommandPlaneZoomIn then
		zoom_level = math.max(zoom_level - 1, 1)
		update_contacts(received_contacts)
		return 0
	elseif command == iCommandPlaneZoomOut then
		zoom_level = math.min(zoom_level + 1, #HDDScales)
		update_contacts(received_contacts)
		return 0
	elseif command == iCommandPlaneModeNAV then
		zoom_level = DEFAULT_ZOOM_LEVEL
		last_mode = iCommandPlaneModeNAV
		update_contacts(received_contacts)
		return 0
	elseif command == iCommandPlaneModeBVR then
		last_mode = iCommandPlaneModeBVR
		zoom_level = DEFAULT_ZOOM_LEVEL
		update_contacts(received_contacts)
		return 0
	elseif command == iCommandPlaneModeVS then
		zoom_level = 2
		last_mode = iCommandPlaneModeVS
		update_contacts(received_contacts)
		return 0
	elseif command == iCommandPlaneModeBore then
		if last_mode == iCommandPlaneModeBVR then
			zoom_level = 2
			update_contacts(received_contacts)
		end
		last_mode = iCommandPlaneModeBore
		return 0
	elseif command == iCommandPlaneModeHelmet then
		if last_mode == iCommandPlaneModeBVR then
			zoom_level = 2
			update_contacts(received_contacts)
		end
		last_mode = iCommandPlaneModeHelmet
		return 0
	elseif command == iCommandPlaneModeFI0 then
		last_mode = iCommandPlaneModeFI0
		return 0
	elseif command == iCommandPlaneModeGround then
		zoom_level = 3
		update_contacts(received_contacts)
		last_mode = iCommandPlaneModeGround
		return 0
	elseif command == iCommandPlaneModeGrid then
		last_mode = iCommandPlaneModeGrid
		return 0
	elseif command == iCommandPowerOnOff then
		last_mode = iCommandPowerOnOff
		zoom_level = DEFAULT_ZOOM_LEVEL
		update_contacts(received_contacts)
		return 0
	elseif command == DL_COMMAND_ID and value == DL_COMMAND_ARG then
		-- Respond to discovery handshake: write a known draw argument so the hook
		-- can confirm this is the DataLink device via Export.LoGetAircraftDrawArgumentValue.
		log.info("Recognized discovery probe")
		set_aircraft_draw_argument_value(DL_DISCOVERY_ARG, DL_DISCOVERY_VALUE)
		log.info("Draw argument flagged")
		return 0
	elseif command == DL_COMMAND_SEQ then
		return last_seq
	elseif command == DL_COMMAND_COUNT then
		log.info("Number of contacts to be received: "..tostring(value))
		new_contacts = {}
		for i = 1, value do
			new_contacts[i] = {}
		end
		return #new_contacts
	elseif command == iCommandPlayerToPlayer then
		log.info("DataLink: Player-to-Player command received with value "..tostring(value))
	elseif command >= DL_COMMAND_BASE and command then
		-- log.info("Received contact data: command="..tostring(command).." value="..tostring(value))
		local idx = math.floor((command - DL_COMMAND_BASE) / ARGS_PER_CTX) + 1
		log.info("Contact index: "..tostring(idx))
		local field = (command - DL_COMMAND_BASE) % ARGS_PER_CTX
		local contact = new_contacts[idx]
		if field == 0 then 
			log.info("BRG: "..tostring(value))
			contact.BEARING = value
		elseif field == 1 then
			log.info("RNG: "..tostring(value))
			contact.RANGE = value			
		elseif field == 2 then
			log.info("ALT: "..tostring(value))
			contact.ALTITUDE = value
		elseif field == 3 then
			log.info("SPD: "..tostring(value))
			contact.SPEED = value
		elseif field == 4 then
			log.info("HDG: "..tostring(value))
			contact.HEADING = value
		end
		if idx == #new_contacts and field == 4 then
			log.info("All contacts received, updating last_seq")
			last_seq = last_seq + 1
			received_contacts = new_contacts
			update_contacts(received_contacts)
		end
	elseif command == DL_COMMAND_ID - 1 then
		log.info("DataLink: received command 123559 with value "..tostring(value))
		toggle_visibility_handle:set(toggle_visibility_handle:get() > 0.5 and 0.0 or 1.0)
		-- me_script = [[
		-- 	local r={}
		-- 	for _,m in pairs(trigger.misc.getMarkPanels()) do 
		-- 		r[#r+1]={time=timer.getTime(),coordinates=m.pos,text=m.text}
		-- 	end
		-- 	return #r, r
		-- ]]
		-- a, b = a_do_script(me_script)
		-- log.info("DataLink: Markers: "..tostring(a))
		-- log.info("DataLink: Markers: "..inspect(b))
	else
		log.info("DataLink: received unhandled command "..tostring(command).." with value "..tostring(value))
	end

	return 0
end

function show_dummy_targets()
	received_contacts = {}
	received_contacts[1] =
	{
		BEARING = 30,
		RANGE = 30,
		ALTITUDE = 12500,
		SPEED = 2588,
		HEADING = 240,
	}
	received_contacts[2] =
	{
		BEARING = 30,
		RANGE = 20,
		ALTITUDE = 0,
		SPEED = 0,
		HEADING = 240,
	}
	received_contacts[3] =
	{
		BEARING = 0,
		RANGE = 10,
		ALTITUDE = 100,
		SPEED = 250,
		HEADING = 240,
	}
	received_contacts[4] =
	{
		BEARING = 0,
		RANGE = 70,
		ALTITUDE = 100,
		SPEED = 250,
		HEADING = 240,
	}
	received_contacts[5] =
	{
		BEARING = 0,
		RANGE = 140,
		ALTITUDE = 100,
		SPEED = 250,
		HEADING = 240,
	}
	update_contacts(received_contacts)
end

if DEBUG then
	saveInspect("_G_device", _G, true)
	saveInspect("device", dev)
	saveInspect("list_cockpit_params", list_cockpit_params())
	saveInspect("list_indication", list_indication())
	saveInspect("RPC", RPC)
	saveInspect("get_base_data", get_base_data())
end

-- must be false in order to receive updates.
need_to_be_closed = false