-- Util.lua
local IC = ItemCrusher

IC.Util = {}

function IC.Util.Wipe(t)
  for k in pairs(t) do t[k] = nil end
end

function IC.Util.Key(bag, slot)
  return bag .. ":" .. slot
end
