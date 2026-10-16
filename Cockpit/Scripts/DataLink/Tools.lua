local Tools = {}

function Tools:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function Tools:determine_coalition_and_country()
	-- Implementation for determining coalition and country goes here
	self.aircraft_type = get_aircraft_type()
	self.base_data = get_base_data()
	log.info("retrieved base data")
	do_mission_file("mission")
	do_mission_file("warehouses")
	log.info("loaded data from mission and warehouses")
	local x, alt, z = self.base_data:getSelfCoordinates()
	local results = {}

	-- iterate over coalition
	for coalition, coalition_data in pairs(mission.coalition) do
		log.info("Coalition: " .. tostring(coalition))
		for _, country_data in pairs(coalition_data.country) do
			log.info("  Country: " .. tostring(country_data.name))
			for _, group in ipairs(country_data.plane.group) do
				-- skip dynamically spawned groups
				if group.dynSpawnTemplate == false then
					log.info("    Group: " .. tostring(group.groupId))
					for _, unit in ipairs(group.units) do
						if unit.type == self.aircraft_type then
							log.info("      Unit: " .. tostring(unit.unitId))
							log.info("        Unit coordinates: x=" .. tostring(unit.x) .. ", alt=" .. tostring(unit.alt) .. ", y=" .. tostring(unit.y))
							log.info("        Self coordinates: x=" .. tostring(x) .. ", alt=" .. tostring(alt) .. ", y=" .. tostring(z))
							local delta_x = math.abs(unit.x - x)
							local delta_alt = math.abs(unit.alt - alt)
							local delta_y = math.abs(unit.y - z)
							if delta_x < 1 and delta_alt < 1 and delta_y < 1 then
								log.info("        This unit matches the self coordinates.")
								local distance = math.sqrt(delta_x^2 + delta_alt^2 + delta_y^2)
								local result = {
									distance = distance ,
									coalition = coalition,
									country = country_data.name,
									country_id = country_data.id,									
								}
								-- if the result has distance less than any previous result, insert it into the results table
								if #results == 0 then
									results[#results + 1] = result
								else
									for pos, current_result in ipairs(results) do
										if result.distance < current_result.distance then
											table.insert(results, pos, result)
											break
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	log.info("Results count: " .. tostring(#results))
	if #results > 0 then
		local best_result = results[1]
		return best_result.coalition, best_result.country, best_result.country_id
	end
	-- Example return values, replace with actual logic
	return nil, nil, nil
end


-- singleton instance of Tools
local tools = Tools:new()
return tools