local LOG_LEVELS = {
  INFO    = { name = "INFO",    value = 0 },
  WARNING = { name = "WARNING", value = 1 },
  ERROR   = { name = "ERROR",   value = 2 },
  DEBUG   = { name = "DEBUG",   value = 3 },
}

local Logger = {} 
function Logger:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.fp = nil
    o.verbosity = LOG_LEVELS.ERROR
    o:initialize(o.filename or "EventListener.log")
    return o
end

-- logs message into log file with info severity
function Logger:log(level, message)
  self.fp:write(os.date("%Y-%m-%d %H:%M:%S").." "..level.name.." "..message.."\n")
end

function Logger:initialize(log_filename)
  if self.fp == nil then
    self.filename = lfs.writedir()..[[Logs\]]..log_filename
    self.fp = io.open(self.filename, "w")
  end
end

function Logger:ensureInitialized()
  if self.fp == nil then
    self:initialize("EventListener.log")
  end
end

function Logger:info(message)
  -- self:ensureInitialized()
  if self.verbosity.value >= LOG_LEVELS.INFO.value then
    self:log(LOG_LEVELS.INFO, message)
  end
end

function Logger:warning(message)
  -- self:ensureInitialized()
  if self.verbosity.value >= LOG_LEVELS.WARNING.value then
    log(LOG_LEVELS.WARNING, message)
  end
end

function Logger:error(message)
  -- self:ensureInitialized()
  if self.verbosity.value >= LOG_LEVELS.ERROR.value then
    log(LOG_LEVELS.ERROR, message)
  end
end

function Logger:debug(message)
  -- self:ensureInitialized()
  if self.verbosity.value >= LOG_LEVELS.DEBUG.value then
    log(LOG_LEVELS.DEBUG, message)
  end
end

function Logger:setLogLevel(logLevel)
  -- self:ensureInitialized()
  info("Changing log level to: "..logLevel.name)
  verbosity = logLevel
end

function Logger:updateVerbosity(option, logLevelName)
  -- self:ensureInitialized()
  local logLevel = LOG_LEVELS[logLevelName]
  if logLevel ~= nil then
    self:setLogLevel(logLevel)
  end
end

local Loggers = {}

function new(filename)
  filename = filename or "EventListener.log"
  if Loggers[filename] == nil then
    Loggers[filename] = Logger:new{filename = filename}
  end
  return Loggers[filename]
end

return {
  new = new,
  -- initialize = initialize,
  -- log = log,
  -- info = info,
  -- warning = warning,
  -- error = error,
  -- debug = debug,
  -- setLogLevel = setLogLevel,
  -- updateVerbosity = updateVerbosity,
  -- LOG_LEVELS = LOG_LEVELS
}
