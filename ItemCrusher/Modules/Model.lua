-- Model.lua
local IC = ItemCrusher

IC.Model = {
  knownItems = {},
  itemsByRarity = {},
  rarityOrder = { 0, 1, 2, 3, 4, 5, 6, 7, -1 },
}

local function GetSlotData(bag, slot)
  local link = C_Container.GetContainerItemLink(bag, slot)
  if not link then return nil end

  local info = C_Container.GetContainerItemInfo(bag, slot)

  local name, _, qFromItemInfo, _, _, _, _, _, _, iconFromItemInfo = GetItemInfo(link)
  local icon = (info and info.iconFileID) or iconFromItemInfo or 134400
  local count = (info and info.stackCount) or 1
  local quality = (info and info.quality) or qFromItemInfo or -1
  local itemID = (info and info.itemID) or tonumber(link:match("item:(%d+)")) or nil

  return {
    bag = bag,
    slot = slot,
    link = link,
    name = name or link,
    icon = icon,
    count = count,
    quality = quality,
    itemID = itemID,
  }
end

function IC.Model:Clear()
  IC.Util.Wipe(self.knownItems)
  for _, q in ipairs(self.rarityOrder) do
    self.itemsByRarity[q] = self.itemsByRarity[q] or {}
    IC.Util.Wipe(self.itemsByRarity[q])
  end
end

function IC.Model:Scan()
  self:Clear()

  for bag = 0, 5 do
    local numSlots = C_Container.GetContainerNumSlots(bag)
    if numSlots and numSlots > 0 then
      for slot = 1, numSlots do
        local it = GetSlotData(bag, slot)
        if it then
          if not IC.Filters:IsHearthstoneItem(it.itemID, it.name) then
            if IC.TooltipScan:HasKnownText(bag, slot) then
              table.insert(self.knownItems, it)
            else
              self.itemsByRarity[it.quality] = self.itemsByRarity[it.quality] or {}
              table.insert(self.itemsByRarity[it.quality], it)
            end
          end
        end
      end
    end
  end

  if #self.knownItems > 1 then
    table.sort(self.knownItems, function(a, b) return (a.name or "") < (b.name or "") end)
  end

  for _, q in ipairs(self.rarityOrder) do
    local list = self.itemsByRarity[q]
    if list and #list > 1 then
      table.sort(list, function(a, b) return (a.name or "") < (b.name or "") end)
    end
  end
end