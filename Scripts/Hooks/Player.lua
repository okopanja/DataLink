--- The Player class represents a player in the game.
-- Each Player object has an id, name, side, slot, ping, ipaddr, and ucid.
local Player = {}

--- Creates a new Player object.
-- @param o An optional table to use as the base for the Player object.
-- @return A new Player object.
function Player:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.id = o.id
    o.name = o.name
    o.side = o.side
    o.slot = o.slot
    o.ping = o.ping
    o.ipaddr = o.ipaddr
    o.ucid = o.ucid
    return o
end



--- Returns a string representation of the Player object.
-- The string includes the id, name, slot, ping, ipaddr, and ucid of the player if they are available.
-- @return A string representation of the Player object.
function Player:getText()
  local result = "id: "..tostring(self.id)..", "
  if self.name then result = result.."name: "..tostring(self.name)..", " end
  if self.slot then result = result.."slot: "..tostring(self.slot)..", " end
  if self.ping then result = result.."ping: "..tostring(self.ping)..", " end
  if self.ipaddr then result = result.."ping: "..tostring(self.ipaddr)..", " end
  if self.ucid then result = result.."ucid: "..tostring(self.ucid) end
  return result
end

--- Returns the name of the player.
-- @return The name of the player.
function Player:getName()
  return self.name
end

function Player:isCurrentPlayer()
  return self.id == net.get_my_player_id()
end

return Player