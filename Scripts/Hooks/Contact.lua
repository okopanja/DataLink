local DCSTimer = require("DCSTimer")
local Logging = require("Utils.Logging").new("DataLink.log")
local MAXIMAL_ALLOWED_AGE = 20
local UnitData = require("UnitData")
local Contact = {}

function Contact:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.id = o.id
	o.age_timer = DCSTimer:new(MAXIMAL_ALLOWED_AGE)
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
	o.donor = nil
	o.contact_source = nil
	o.flags = 0
	o.iff = UnitData.IFF.UNKNOWN

	return o
end

function Contact:getHeading()
	return self.heading
end

function Contact:setHeading(heading)
	self.heading = heading
end

function Contact:getBearing()
	return self.bearing
end

function Contact:setBearing(bearing)
	self.bearing = bearing
end

function Contact:getRange()
	return self.range
end

function Contact:setRange(range)
	self.range = range
end

function Contact:getPosition()
	return self.position
end

function Contact:setPosition(position)
	self.position = position
end

function Contact:getSpeed()
	return self.speed
end

function Contact:setSpeed(speed)
	self.speed = speed
end

function Contact:getAltitude()
	self:ensurePosition()
	return self.position.alt
end

function Contact:setAltitude(altitude)
	self:ensurePosition()
	self.position.alt = altitude
end

function Contact:getX()
	self:ensurePosition()
	return self.position.x
end

function Contact:getAlt()
	self:ensurePosition()
	return self.position.alt
end

function Contact:getZ()
	self:ensurePosition()
	return self.position.z
end

function Contact:getSide()
	return self.side
end

function Contact:setSide(side)
	self.side = side
end

function Contact:getType()
	return self.type
end

function Contact:setType(type)
	self.type = type
end

function Contact:getID()
	return self.id
end

function Contact:setID(id)
	self.id = id
end

function Contact:getIFF()
	return self.iff
end

function Contact:setIFF(iff)
	self.iff = iff
end

function Contact:getDonor()
	return self.donor
end

function Contact:setDonor(donor)
	self.donor = donor
end

function Contact:getFlags()
	return self.flags
end

function Contact:setFlags(flags)
	self.flags = flags
end

-- function Contact:getPreviousPosition()
-- 	return self.previous_position
-- end

function Contact:getMaximalSpeedInKMH()
	return 2700
end

function Contact:setContactSource(contact_source)
	self.contact_source = contact_source
end

function Contact:getContactSource()
	return self.contact_source
end

function Contact:getLastSeen()
	return self.age_timer:getLastTime()
end

function Contact:setLastSeen(lastSeen)
	self.age_timer:setLastTime(lastSeen)
end

function Contact:getAgeTimer()
	return self.age_timer
end

function Contact:ensurePosition()
	if self.position == nil then
		self.position = {
			x = 0,
			alt = 0,
			z = 0
		}
	end
end

--- Function updates the position of the contact
-- it tracks the previous position as well, as well as it uses own timer (type: DCSTimer, methods intervalHasElapsed, reset) to track the elapsed time between position updates.
-- if the position is updated and calculation conditions are met, it calculates the speed and heading based on the previous position and current position and elapsed time
-- Conditions:
-- 1. previous position is not nil
-- 2. previous position is not equal to current position
-- 3. elapsed time is lesser than maximal allowed time meassured between the previous position and current position update
-- 4. if speed does not exceed the maximum speed of the contact.
-- Failures of conditions 3 and 4 results in previous position being invalidated, it this case speed and heading are not updated
function Contact:updatePosition(new_position)
	local elapsed_time = self.age_timer:getElapsedTime()

	-- Only calculate speed/heading if we have a previous position to compare against
	if self.previous_position and (self.previous_position.x ~= new_position.x and self.previous_position.z ~= new_position.z) then
		if elapsed_time < MAXIMAL_ALLOWED_CALCULATION_TIME then
			local dx = new_position.x - self.previous_position.x
			local dz = new_position.z - self.previous_position.z
			local distance = math.sqrt((dx * dx) + (dz * dz))
			local speed_mps = distance / elapsed_time
			local speed_kmh = speed_mps * 3.6
			self.speed = speed_mps * 3.6 -- convert to km/h
			self.heading = math.deg(math.atan2(dz, dx)) % 360
			if self.speed > self:getMaximalSpeedInKMH() then
				Logging:info("Contact ID "..self.id.." exceeded maximal speed. Invalidating previous position.")
				self.previous_position = nil
				self.speed = nil
				self.heading = nil
			else
				Logging:info("Contact ID "..self.id.." updated position. Speed: "..tostring(self.speed).." km/h, Heading: "..tostring(self.heading).." degrees.")
				self.previous_position = self.position
			end
		else
			Logging:info("Contact ID "..self.id.." exceeded maximal allowed calculation time of "..MAXIMAL_ALLOWED_CALCULATION_TIME.." with elapsed time of "..elapsed_time..". Invalidating previous position.")
			self.previous_position = nil
		end
	else
		self.previous_position = self.position
	end
	self.position = new_position
	self.age_timer:reset()
end

function Contact:getBearingToContact(other_contact)
	if not self.position or not other_contact.position then
		Logging:info("getBearingToContact: one of the contacts has no position. self.position="..tostring(self.position)..", other_contact.position="..tostring(other_contact.position))
		return nil
	end
	local dx = other_contact.position.x - self.position.x
	local dz = other_contact.position.z - self.position.z
	local bearing = math.deg(math.atan2(dz, dx)) % 360
	return bearing
end

function Contact:getRangeToContact(other_contact)
	if not self.position or not other_contact.position then
		Logging:info("getRangeToContact: one of the contacts has no position. self.position="..tostring(self.position)..", other_contact.position="..tostring(other_contact.position))
		return nil
	end
	local dx = other_contact.position.x - self.position.x
	local dz = other_contact.position.z - self.position.z
	local distance = math.sqrt((dx * dx) + (dz * dz))
	return distance / 1000 -- convert to kilometers
end

-- Calculates the radial speed of another contact relative to this contact.
-- it utilizes the bearing to the other contact to determine the radial component of the other aircaft's speed.
function Contact:getRadialSpeedOfContact(other_contact)
	if not self.position or not other_contact.position then
		Logging:info("getRadialSpeed: one of the contacts has no position. self.position="..tostring(self.position)..", other_contact.position="..tostring(other_contact.position))
		return nil
	end
	local bearing_to_other = self:getBearingToContact(other_contact)
	if not bearing_to_other then
		Logging:info("getRadialSpeed: could not calculate bearing to other contact.")
		return nil
	end
	local relative_bearing = (bearing_to_other - self.heading + 360) % 360
	local radial_speed = other_contact:getSpeed() * math.cos(math.rad(relative_bearing))
	return radial_speed
end

function Contact:hasLineOfSightToContact(other_contact)
	if not self.position or not other_contact.position then
		return false
	end
	-- check with terraing function if there is a line of sight between the two contacts using terrain.isVisible()
	return terrain.isVisible(self.position.x, self.position.alt, self.position.z, other_contact.position.x, other_contact.position.alt, other_contact.position.z)
end

function Contact:updateFrom(other_contact)
	self:setID(other_contact:getID())
	-- store the current position as the previous position before updating it
	self.previous_position = self.position
	-- TODO: consider performing extrapolation based on actual passed time
	self.position = {
		x = other_contact.position.x, 
		alt = other_contact.position.alt, 
		z = other_contact.position.z
	}
	self.heading = other_contact.heading
	self.speed = other_contact.speed
	self.side = other_contact.side
	self.flags  = other_contact.flags
	self.bearing = other_contact.bearing
	self.range = other_contact.range
	self:setLastSeen(other_contact:getLastSeen())
end

function Contact:pack()
	return {
		id = self:getID(),
		x = self:getX(),
		alt = self:getAlt(),
		z = self:getZ(),
		heading = self:getHeading(),
		speed = self:getSpeed(),
		side = self:getSide(),
		flags = self:getFlags(),
		lastSeen = self:getLastSeen(),
	}
end

function Contact:unpack(data)
	self.id = data.id
	self.position = { x = data.x, alt = data.alt, z = data.z }
	self.heading = data.heading
	self.speed = data.speed
	self.side = data.side
	self.flags = data.flags
	self:setLastSeen(data.lastSeen)
end

return Contact