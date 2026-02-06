-- Filters.lua
local IC = ItemCrusher

IC.Filters = IC.Filters or {}

-- Common hearthstones & variants (not exhaustive, but good coverage).
IC.Filters.HEARTHSTONE_IDS = IC.Filters.HEARTHSTONE_IDS or {
  [6948] = true,    -- Hearthstone
  [110560] = true,  -- Garrison Hearthstone
  [140192] = true,  -- Dalaran Hearthstone
  [64488] = true,   -- The Innkeeper's Daughter (toy hearth)
  [93672] = true,   -- Dark Portal (toy hearth)
  [142542] = true,  -- Tome of Town Portal (toy hearth)
  [162973] = true,  -- Greatfather Winter's Hearthstone (toy hearth)
  [163045] = true,  -- Headless Horseman's Hearthstone (toy hearth)
  [165669] = true,  -- Lunar Elder's Hearthstone (toy hearth)
  [165670] = true,  -- Peddlefeet's Lovely Hearthstone (toy hearth)
  [166746] = true,  -- Fire Eater's Hearthstone (toy hearth)
  [166747] = true,  -- Brewfest Hearthstone (toy hearth)
  [168907] = true,  -- Holographic Digitalization Hearthstone (toy hearth)
  [172179] = true,  -- Eternal Traveler's Hearthstone (toy hearth)
  [180290] = true,  -- Night Fae Hearthstone (toy hearth)
  [182773] = true,  -- Necrolord Hearthstone (toy hearth)
  [183716] = true,  -- Venthyr Hearthstone (toy hearth)
  [184353] = true,  -- Kyrian Hearthstone (toy hearth)
  [188952] = true,  -- Dominated Hearthstone (toy hearth)
  [190196] = true,  -- Enlightened Hearthstone (toy hearth)
  [193588] = true,  -- Timewalker's Hearthstone (toy hearth)
  [200630] = true,  -- Ohn'ir Windsage's Hearthstone (toy hearth)
  [206195] = true,  -- (variant / may vary)
}

function IC.Filters:IsHearthstoneItem(itemID, name)
  if itemID and self.HEARTHSTONE_IDS[itemID] then
    return true
  end

  if name and name ~= "" then
    local n = string.lower(name)
    -- DE + EN fallback
    if string.find(n, "ruhestein", 1, true) then return true end
    if string.find(n, "hearthstone", 1, true) then return true end
  end

  return false
end