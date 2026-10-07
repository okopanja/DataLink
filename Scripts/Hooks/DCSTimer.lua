local DCSTimer = {}

function DCSTimer:new(interval, real)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	if real == nil then
		real = false
	end
	if real then
		o.time_function = DCS.getRealTime
	else
		o.time_function = DCS.getModelTime
	end
	o.last_time = o.time_function()
	o.interval = interval or 1 -- default interval of 1 second
	return o
end

function DCSTimer:getElapsedTime()
	local current_time = self.time_function()
	return current_time - self.last_time
end

function DCSTimer:intervalHasElapsed()
	local elapsed_time = self:getElapsedTime()
	if elapsed_time >= self.interval then
		self:reset()
		return true, elapsed_time
	end
	return false, elapsed_time
end

function DCSTimer:getLastTime()
	return self.last_time
end

function DCSTimer:setLastTime(last_time)
	self.last_time = last_time
end

function DCSTimer:reset()
	self.last_time = self.time_function()
end

return DCSTimer
