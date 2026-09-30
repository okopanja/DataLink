-- placeholder for cjson replacement with JSON module
local JSON = require("JSON")

local function encode(value)
    return JSON:encode(value)
end

local function decode(value)
    return JSON:decode(value)
end

return {
    encode = encode,
    decode = decode
}