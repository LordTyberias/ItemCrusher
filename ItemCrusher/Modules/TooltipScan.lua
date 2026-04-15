-- TooltipScan.lua
local IC = ItemCrusher
IC.TooltipScan = IC.TooltipScan or {}

-- Hidden tooltip for fallback scanning (only used if C_TooltipInfo is unavailable)
local scanTip = CreateFrame("GameTooltip", "ItemCrusherScanTooltip", UIParent, "GameTooltipTemplate")
scanTip:SetOwner(UIParent, "ANCHOR_NONE")

-- Cache: itemID -> boolean (known)  (nil = unknown/unscanned)
-- This avoids repeated tooltip scans during refreshes/scrolling.
local knownCacheByItemID = {}

function IC.TooltipScan:ClearCache()
  for k in pairs(knownCacheByItemID) do
    knownCacheByItemID[k] = nil
  end
end

local function Normalize(s)
  if not s then return nil end
  s = tostring(s)
  s = s:gsub("|c%x%x%x%x%x%x%x%x", "")
  s = s:gsub("|r", "")
  s = s:gsub("|T.-|t", "")
  s = s:gsub("%s+", " ")
  s = s:match("^%s*(.-)%s*$")
  return s and string.lower(s) or nil
end

local function ContainsAny(haystack, needles)
  if not haystack or haystack == "" then return false end
  for i = 1, #needles do
    local n = needles[i]
    if n and n ~= "" and string.find(haystack, n, 1, true) then
      return true
    end
  end
  return false
end

-- Build a list of "known/learned/collected" phrases from Blizzard localized globals.
local function BuildKnownNeedles()
  local needles = {}
  local function add(s)
    s = Normalize(s)
    if s and s ~= "" then needles[#needles + 1] = s end
  end

  add(_G.ITEM_SPELL_KNOWN)
  add(_G.TOY_ALREADY_KNOWN)
  add(_G.MOUNT_ALREADY_KNOWN)
  add(_G.PET_ALREADY_KNOWN)
  add(_G.APPEARANCE_ALREADY_KNOWN)
  add(_G.ITEM_PET_KNOWN)
  add(_G.LEARNED)
  add(_G.COLLECTED)

  return needles
end

local FALLBACK_KNOWN = {
  "already known", "already learned", "already collected",
  "bereits bekannt", "bereits erlernt", "bereits gesammelt",
  "уже известно", "вже відомо",
  "이미 배웠", "이미 수집", "이미 알고",
  "已知", "已经学会", "已收集",
}

local KNOWN_NEEDLES = nil
local function GetKnownNeedles()
  if not KNOWN_NEEDLES then
    KNOWN_NEEDLES = BuildKnownNeedles()
    for i = 1, #FALLBACK_KNOWN do
      KNOWN_NEEDLES[#KNOWN_NEEDLES + 1] = Normalize(FALLBACK_KNOWN[i])
    end
  end
  return KNOWN_NEEDLES
end

-- Primary path: use C_TooltipInfo (no UI, no anchors, no BattlePetTooltip issues)
local function BagTooltipHasKnownText_CTooltipInfo(bag, slot, needles)
  if not (C_TooltipInfo and C_TooltipInfo.GetBagItem) then
    return nil -- signal: not available
  end

  local data = C_TooltipInfo.GetBagItem(bag, slot)
  if not data or not data.lines then
    return false
  end

  for i = 1, #data.lines do
    local line = data.lines[i]
    local left = line and (line.leftText or line.leftTextString)
    local t = Normalize(left)
    if t and t ~= "" and ContainsAny(t, needles) then
      return true
    end
  end

  return false
end

-- Fallback path: GameTooltip scan, but protected (never throw errors)
local function BagTooltipHasKnownText_GameTooltip(bag, slot, needles)
  scanTip:ClearLines()
  scanTip:SetOwner(UIParent, "ANCHOR_NONE")

  local ok = pcall(function()
    if scanTip.SetBagItem then
      scanTip:SetBagItem(bag, slot)
    else
      local info = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(bag, slot)
      if info and info.hyperlink then
        scanTip:SetHyperlink(info.hyperlink)
      end
    end
  end)

  if not ok then
    scanTip:ClearLines()
    return false
  end

  local n = scanTip:NumLines() or 0
  for i = 1, n do
    local line = _G["ItemCrusherScanTooltipTextLeft" .. i]
    local text = line and line:GetText()
    local t = Normalize(text)
    if t and t ~= "" and ContainsAny(t, needles) then
      return true
    end
  end

  return false
end

-- Public API
function IC.TooltipScan:HasKnownText(bag, slot)
  local needles = GetKnownNeedles()

  -- Cache by itemID if possible
  local itemID
  if C_Container and C_Container.GetContainerItemInfo then
    local info = C_Container.GetContainerItemInfo(bag, slot)
    itemID = info and info.itemID
  end

  if itemID and knownCacheByItemID[itemID] ~= nil then
    return knownCacheByItemID[itemID] and true or false
  end

  local res = BagTooltipHasKnownText_CTooltipInfo(bag, slot, needles)
  if res == nil then
    res = BagTooltipHasKnownText_GameTooltip(bag, slot, needles)
  end

  if itemID then
    knownCacheByItemID[itemID] = res and true or false
  end

  return res and true or false
end