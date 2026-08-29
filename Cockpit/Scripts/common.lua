-- define here for which modules to enable the data link device.
SUPPORTED_AIRCRAFT = {
  ["Su-27"] = {},
  ["Su-33"] = {},
  ["J-11A"] = {},
  -- TODO: MiG-29 Fulcrum should not be supported
  -- ["MiG-29 Fulcrum"] = {},
}

-- Enable to activate debugging features
DEBUG=false

-- If inspect.lua is not present in the scripts folder, debugging will be disabled automatically.
DEBUG = DEBUG and lfs.attributes(lfs.writedir().."Mods/tech/DataLink/Cockpit/Scripts/inspect.lua") ~= nil
-- Debugging functions
if DEBUG then
  -- load inspect
  inspect = dofile(lfs.writedir().."Mods/tech/DataLink/Cockpit/Scripts/inspect.lua")  
  -- saveInspect: saves a Lua value to a file in the dumps folder for inspection
  function saveInspect(inspect_name, inspect_value, use_lfs_resolution)
    local folder_path
    if use_lfs_resolution then
      folder_path = lfs.writedir().."Mods/tech/DataLink/Cockpit/Scripts/dumps/"..get_aircraft_type()
    else
      folder_path = LockOn_Options.script_path..[[dumps\]]..get_aircraft_type()
    end
    lfs.mkdir(folder_path)
    local file = io.open(folder_path..[[\]]..inspect_name..".lua",'w')
    if file then
      file:write(inspect(inspect_value))
      file:close()
    end
  end
end