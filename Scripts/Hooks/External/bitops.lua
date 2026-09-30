-- Source - https://stackoverflow.com/a/32387452
-- Posted by ryanpattison, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-09-10, License - CC BY-SA 3.0

local function bitand(a, b)
    local result = 0
    local bitval = 1
    while a > 0 and b > 0 do
      if a % 2 == 1 and b % 2 == 1 then -- test the rightmost bits
          result = result + bitval      -- set the current bit
      end
      bitval = bitval * 2 -- shift left
      a = math.floor(a/2) -- shift right
      b = math.floor(b/2)
    end
    return result
end

return {
    bitand = bitand
}
