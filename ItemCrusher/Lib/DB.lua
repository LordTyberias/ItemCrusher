-- Lib/DB.lua
local IC = ItemCrusher
IC.DB = {}

-- SavedVariables name from .toc:
-- ## SavedVariables: ItemCrusherDB

local DEFAULTS = {
  lang = nil,
  minimap = {
    position = 200,
    locked = false,
    hide = false,
  },
}

local function DeepCopy(src, dst)
  dst = dst or {}
  for k, v in pairs(src) do
    if type(v) == "table" then
      if type(dst[k]) ~= "table" then dst[k] = {} end
      DeepCopy(v, dst[k])
    elseif dst[k] == nil then
      dst[k] = v
    end
  end
  return dst
end

local function DetectDefaultLang()
  local loc = GetLocale()
  if loc == "deDE" then return "de" end
  if loc == "frFR" then return "fr" end
  if loc == "esES" or loc == "esMX" then return "es" end
  if loc == "ptBR" or loc == "ptPT" then return "pt" end
  if loc == "itIT" then return "it" end
  if loc == "ruRU" then return "ru" end
  if loc == "ukUA" then return "uk" end
  if loc == "koKR" then return "ko" end
  if loc == "zhCN" then return "zhCN" end
  return "en"
end

function IC.DB:Init()
  -- SavedVariables table exists after ADDON_LOADED
  ItemCrusherDB = ItemCrusherDB or {}

  -- Migration: old minimap.angle -> minimap.position
  ItemCrusherDB.minimap = ItemCrusherDB.minimap or {}
  if ItemCrusherDB.minimap.position == nil and ItemCrusherDB.minimap.angle ~= nil then
    ItemCrusherDB.minimap.position = ItemCrusherDB.minimap.angle
    ItemCrusherDB.minimap.angle = nil
  end

  -- Apply defaults (deep)
  DeepCopy(DEFAULTS, ItemCrusherDB)

  -- One-time default language
  if not ItemCrusherDB.lang then
    ItemCrusherDB.lang = DetectDefaultLang()
  end

  -- expose as single source of truth
  IC.db = ItemCrusherDB
end