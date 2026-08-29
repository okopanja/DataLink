local DCSTimer = {}

function DCSTimer:new(interval)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.last_time = DCS.getModelTime()
	o.interval = interval or 1 -- default interval of 1 second
	return o
end

function DCSTimer:getElapsedTime()
	local current_time = DCS.getModelTime()
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

function DCSTimer:reset()
	self.last_time = DCS.getModelTime()
end

return DCSTimer
