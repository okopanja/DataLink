local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

local function basename(filePath)
   return filePath:match("([^\\]+)$")
end

local function csplit(str,sep)
   local ret={}
   local n=1
   for w in str:gmatch("([^"..sep.."]*)") do
      ret[n] = ret[n] or w -- only set once (so the blank after a string is ignored)
      if w=="" then
         n = n + 1
      end -- step forwards on a blank but not a string
   end
   return ret
end

local function split(str, separator)
   local result = {}
   local start = 1
   while true do
      local sep_start, sep_end = string.find(str, separator, start, true)
      if sep_start == nil then
         table.insert(result, string.sub(str, start))
         break
      else
         table.insert(result, string.sub(str, start, sep_start - 1))
         start = sep_end + 1
      end
   end
   return result
end

return {
  starts_with = starts_with,
  ends_with = ends_with,
  basename = basename,
  csplit = csplit,
  split = split
}
