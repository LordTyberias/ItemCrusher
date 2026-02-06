-- TooltipScan.lua
local IC = ItemCrusher
IC.TooltipScan = IC.TooltipScan or {}

-- Hidden tooltip for scanning bag items
local scanTip = CreateFrame("GameTooltip", "ItemCrusherScanTooltip", UIParent, "GameTooltipTemplate")
scanTip:SetOwner(UIParent, "ANCHOR_NONE")

-- Returns true if the tooltip contains "Already known" (or DE variants).
function IC.TooltipScan:HasKnownText(bag, slot)
  scanTip:ClearLines()

  -- Retail bag tooltip
  if scanTip.SetBagItem then
    scanTip:SetBagItem(bag, slot)
  else
    -- ultra-fallback: try container item link
    local info = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(bag, slot)
    if info and info.hyperlink then
      scanTip:SetHyperlink(info.hyperlink)
    else
      return false
    end
  end

  local n = scanTip:NumLines() or 0
  for i = 1, n do
    local line = _G["ItemCrusherScanTooltipTextLeft" .. i]
    local text = line and line:GetText()
    if text and text ~= "" then
      local t = string.lower(text)
      -- EN / DE matches (keep simple, client-localized strings vary)
      if string.find(t, "already known", 1, true) then return true end
      if string.find(t, "bereits bekannt", 1, true) then return true end
      if string.find(t, "bereits erlernt", 1, true) then return true end
    end
  end

  return false
end