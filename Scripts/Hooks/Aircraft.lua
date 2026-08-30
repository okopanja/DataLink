local DCSTimer = require("DCSTimer")
local Logging = require("Utils.Logging").new("DataLink.log")
local MAXIMAL_ALLOWED_CALCULATION_TIME = 20

local Aircraft = {}

function Aircraft:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.id = o.id
	o.timer = DCSTimer:new(MAXIMAL_ALLOWED_CALCULATION_TIME)
	o.x = nil
	o.z = nil
	o.alt = nil
	o.previous_position = nil
	o.bearing = nil
	o.heading = nil
	o.range = nil
	o.speed = nil
	o.side = nil
	o.type = nil
	return o
end

function Aircraft:getHeading()
	return self.heading
end

function Aircraft:setHeading(heading)
	self.heading = heading
end

function Aircraft:getBearing()
	return self.bearing
end

function Aircraft:setBearing(bearing)
	self.bearing = bearing
end

function Aircraft:getBearingToAircraft(other_aircraft)
	if not self.position or not other_aircraft.position then
		Logging:info("getBearingToAircraft: one of the aircrafts has no position. self.position="..tostring(self.position)..", other_aircraft.position="..tostring(other_aircraft.position))
		return nil
	end
	local dx = other_aircraft.position.x - self.position.x
	local dz = other_aircraft.position.z - self.position.z
	local bearing = math.deg(math.atan2(dz, dx)) % 360
	return bearing
end

function Aircraft:getRangeToAircraft(other_aircraft)
	if not self.position or not other_aircraft.position then
		Logging:info("getRangeToAircraft: one of the aircrafts has no position. self.position="..tostring(self.position)..", other_aircraft.position="..tostring(other_aircraft.position))
		return nil
	end
	local dx = other_aircraft.position.x - self.position.x
	local dz = other_aircraft.position.z - self.position.z
	local distance = math.sqrt((dx * dx) + (dz * dz))
	return distance / 1000 -- convert to kilometers
end


-- Calculates the radial speed of another aircraft relative to this aircraft.
-- it utilizes the bearing to the other aircraft to determine the radial component of the other aircaft's speed.
function Aircraft:getRadialSpeedOfAircraft(other_aircraft)
	if not self.position or not other_aircraft.position then
		Logging:info("getRadialSpeed: one of the aircrafts has no position. self.position="..tostring(self.position)..", other_aircraft.position="..tostring(other_aircraft.position))
		return nil
	end
	local bearing_to_other = self:getBearingToAircraft(other_aircraft)
	if not bearing_to_other then
		Logging:info("getRadialSpeed: could not calculate bearing to other aircraft.")
		return nil
	end
	local relative_bearing = (bearing_to_other - self.heading + 360) % 360
	local radial_speed = other_aircraft:getSpeed() * math.cos(math.rad(relative_bearing))
	return radial_speed
end

function Aircraft:hasLineOfSightToAircraft(other_aircraft)
	if not self.position or not other_aircraft.position then
		return false
	end
	-- check with terraing function if there is a line of sight between the two aircrafts using terrain.isVisible()
	return terrain.isVisible(self.position.x, self.position.alt, self.position.z, other_aircraft.position.x, other_aircraft.position.alt, other_aircraft.position.z)
end

function Aircraft:getRange()
	return self.range
end

function Aircraft:setRange(range)
	self.range = range
end

function Aircraft:getPosition()
	return self.position
end

function Aircraft:setPosition(position)
	self.position = position
end

function Aircraft:getSpeed()
	return self.speed
end

function Aircraft:setSpeed(speed)
	self.speed = speed
end

function Aircraft:getAltitude()
	self:ensurePosition()
	return self.position.alt
end

function Aircraft:setAltitude(altitude)
	self:ensurePosition()
	self.position.alt = altitude
end

function Aircraft:getSide()
	return self.side
end

function Aircraft:setSide(side)
	self.side = side
end

function Aircraft:getType()
	return self.type
end

function Aircraft:setType(type)
	self.type = type
end

function Aircraft:getPreviousPosition()
	return self.previous_position
end

function Aircraft:getMaximalSpeedInKMH()
	return 2700
end

function Aircraft:ensurePosition()
	if self.position == nil then
		self.position = {
			x = 0,
			alt = 0,
			z = 0
		}
	end
end

--- Function updates the position of the aircraft
-- it tracks the previous position as well, as well as it uses own timer (type: DCSTimer, methods intervalHasElapsed, reset) to track the elapsed time between position updates.
-- if the position is updated and calculation conditions are met, it calculates the speed and heading based on the previous position and current position and elapsed time
-- Conditions:
-- 1. previous position is not nil
-- 2. previous position is not equal to current position
-- 3. elapsed time is lesser than maximal allowed time meassured between the previous position and current position update
-- 4. if speed does not exceed the maximum speed of the aircraft.
-- Failures of conditions 3 and 4 results in previous position being invalidated, it this case speed and heading are not updated
function Aircraft:updatePosition(new_position)
	local elapsed_time = self.timer:getElapsedTime()

	-- Only calculate speed/heading if we have a previous position to compare against
	if self.previous_position and (self.previous_position.x ~= new_position.x or self.previous_position.z ~= new_position.z) then
		if elapsed_time < MAXIMAL_ALLOWED_CALCULATION_TIME then
			local dx = new_position.x - self.previous_position.x
			local dz = new_position.z - self.previous_position.z
			local distance = math.sqrt((dx * dx) + (dz * dz))
			local speed_mps = distance / elapsed_time
			local speed_kmh = speed_mps * 3.6
			self.speed = speed_mps * 3.6 -- convert to km/h
			self.heading = math.deg(math.atan2(dz, dx)) % 360
			if self.speed > self:getMaximalSpeedInKMH() then
				Logging:info("Aircraft ID "..self.id.." exceeded maximal speed. Invalidating previous position.")
				self.previous_position = nil
				self.speed = nil
				self.heading = nil
			else
				Logging:info("Aircraft ID "..self.id.." updated position. Speed: "..tostring(self.speed).." km/h, Heading: "..tostring(self.heading).." degrees.")
				self.previous_position = self.position
			end
		else
			Logging:info("Aircraft ID "..self.id.." exceeded maximal allowed calculation time of "..MAXIMAL_ALLOWED_CALCULATION_TIME.." with elapsed time of "..elapsed_time..". Invalidating previous position.")
			self.previous_position = nil
		end
	else
		self.previous_position = self.position
	end
	self.position = new_position
	self.timer:reset()
end

return Aircraft