local nats = require("Hooks.External.nats")
local uuid = require("Hooks.External.uuid")
local cjson = require("Hooks.External.cjson")
local bitand = require("Hooks.External.bitand")
return {
  nats = nats,
  uuid = uuid,
  cjson = cjson,
  bitand = bitand,
}
