-- TooltipScan.lua
local IC = ItemCrusher
IC.TooltipScan = IC.TooltipScan or {}

-- Hidden tooltip for scanning bag items
local scanTip = CreateFrame("GameTooltip", "ItemCrusherScanTooltip", UIParent, "GameTooltipTemplate")
scanTip:SetOwner(UIParent, "ANCHOR_NONE")

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
    if n and n ~= "" then
      if string.find(haystack, n, 1, true) then
        return true
      end
    end
  end
  return false
end

-- Build a list of "known/learned/collected" phrases from Blizzard's localized globals.
-- These exist in many clients and automatically match the user's game language.
local function BuildKnownNeedles()
  local needles = {}

  local function add(s)
    s = Normalize(s)
    if s and s ~= "" then
      needles[#needles + 1] = s
    end
  end

  -- Common localized lines used in tooltips for recipes/toys/mounts/pets/appearances etc.
  -- Not all exist in every version, hence checks + fallback below.
  add(_G.ITEM_SPELL_KNOWN)               -- e.g. "Already known"
  add(_G.TOY_ALREADY_KNOWN)              -- e.g. "You have already collected this toy."
  add(_G.MOUNT_ALREADY_KNOWN)            -- e.g. "You have already collected this mount."
  add(_G.PET_ALREADY_KNOWN)              -- e.g. "You have already collected this pet."
  add(_G.APPEARANCE_ALREADY_KNOWN)       -- transmog appearance known
  add(_G.ITEM_PET_KNOWN)                 -- some clients use this for pets
  add(_G.LEARNED)                        -- sometimes shown as "Learned" (varies)
  add(_G.COLLECTED)                      -- sometimes shown as "Collected" (varies)

  -- Some strings are format strings. We still add them (normalized),
  -- because they may appear literally in tooltip output in some contexts.
  add(_G.ITEM_SET_NAME)                  -- not known-related (ignore if you want)
  -- (We intentionally do not add overly generic strings to avoid false positives)

  return needles
end

-- Small, conservative fallback list for cases where Blizzard globals are missing
-- or where tooltip uses a slightly different phrase.
local FALLBACK_KNOWN = {
  -- EN / DE minimal (safe)
  "already known",
  "already learned",
  "already collected",
  "bereits bekannt",
  "bereits erlernt",
  "bereits gesammelt",

  -- RU / UK / KO / zhCN common short forms (still fairly specific)
  "уже известно",
  "вже відомо",
  "이미 배웠",
  "이미 수집",
  "已知",
  "제작법을 이미 알고",
  "이미 알고",
  "已经学会",
  "已收集",
}

-- Cache needles once (rebuild if needed later)
local KNOWN_NEEDLES = nil
local function GetKnownNeedles()
  if not KNOWN_NEEDLES then
    KNOWN_NEEDLES = BuildKnownNeedles()
    -- Always append fallback
    for i = 1, #FALLBACK_KNOWN do
      KNOWN_NEEDLES[#KNOWN_NEEDLES + 1] = Normalize(FALLBACK_KNOWN[i])
    end
  end
  return KNOWN_NEEDLES
end

-- Returns true if the tooltip contains a "known/learned/collected" marker line.
function IC.TooltipScan:HasKnownText(bag, slot)
  scanTip:ClearLines()

  -- Bag tooltip (Retail)
  if scanTip.SetBagItem then
    scanTip:SetBagItem(bag, slot)
  else
    -- Fallback: item link
    local info = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(bag, slot)
    if info and info.hyperlink then
      scanTip:SetHyperlink(info.hyperlink)
    else
      return false
    end
  end

  local needles = GetKnownNeedles()
  local n = scanTip:NumLines() or 0
  for i = 1, n do
    local line = _G["ItemCrusherScanTooltipTextLeft" .. i]
    local text = line and line:GetText()
    local t = Normalize(text)
    if t and t ~= "" then
      if ContainsAny(t, needles) then
        return true
      end
    end
  end

  return false
end