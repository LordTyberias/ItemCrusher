-- Debug.lua
local IC = ItemCrusher

IC.Debug = {
  enabled = false, -- default off
  prefix = "|cFF33FF99ItemCrusher|r",
}

-- Toggle debug printing (and optionally set explicitly)
function IC.Debug:SetEnabled(state)
  if state == nil then
    self.enabled = not self.enabled
  else
    self.enabled = state and true or false
  end
  self:Print("Debug " .. (self.enabled and "enabled" or "disabled") .. ".")
end

-- Debug print (safe, minimal)
function IC.Debug:Print(...)
  if not self.enabled then return end
  local msg = {}
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    msg[#msg + 1] = tostring(v)
  end
  print(self.prefix .. " " .. table.concat(msg, " "))
end

-- Convenience: toggle via slash command handler
function IC.Debug:Toggle()
  self:SetEnabled(nil)
end