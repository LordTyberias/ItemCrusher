-- Core/Core.lua
local IC = ItemCrusher
IC.Core = IC.Core or {}

local function Trim(s)
  s = tostring(s or "")
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  return s
end

local function Lower(s)
  return string.lower(Trim(s))
end

function IC.Core:RegisterSlashCommands()
  if self._slashRegistered then return end
  self._slashRegistered = true

  SLASH_ITEMCRUSHER1 = "/itemcrusher"
  SLASH_ITEMCRUSHER2 = "/itc"

  SlashCmdList["ITEMCRUSHER"] = function(msg)
    msg = Lower(msg)

    if msg == "options" or msg == "option" or msg == "settings" then
      if IC.Settings and IC.Settings.Open then
        IC.Settings:Open()
      end
      return
    end

    -- default: toggle window
    if IC.UI and IC.UI.IsShown then
      if IC.UI:IsShown() then
        IC.UI:Hide()
      else
        IC.UI:Show()
        IC.Core:Refresh()
      end
    end
  end
end

function IC.Core:Init()
  -- 0) Slash commands
  self:RegisterSlashCommands()

  -- 1) SavedVariables + Defaults
  if IC.DB and IC.DB.Init then
    IC.DB:Init()
  end

  -- 2) Locale aus DB übernehmen
  if IC.Locale and IC.Locale.Apply then
    IC.Locale:Apply()
  end

  -- 3) UI einmal bauen
  if IC.UI and IC.UI.Init then
    IC.UI:Init()
    IC.UI:EnableEscClose()
    IC.UI:ApplyLocale()
  end

  -- 4) Minimap Button erstellen (nutzt IC.db.minimap.*)
  local mmBtn = nil
  if IC.Minimap and IC.Minimap.Create then
    mmBtn = IC.Minimap:Create()
  end

  -- 5) Settings Panel erstellen
  if IC.Settings and IC.Settings.Create then
    IC.Settings:Create(IC.UI, mmBtn)
  end

  -- 6) Popups ggf.
  if IC.Popups and IC.Popups.Setup then
    IC.Popups:Setup()
  end

  -- 7) Erste Anzeige/Initial-Refresh
  self:Refresh()
end

function IC.Core:Refresh()
  if not (IC.UI and IC.UI.Refresh and IC.Model and IC.Model.Scan) then return end

  -- Model neu scannen
  IC.Model:Scan()

  -- UI mit Model befüllen
  IC.UI:Refresh(IC.Model, function()
    -- onToggle (wenn man Items an/abwählt)
    if IC.Delete then
      IC.Delete.deleting = false
    end
    if IC.UI and IC.UI.UpdateStatusReady then
      IC.UI:UpdateStatusReady()
    end
  end)
end

-- === Events / Refresh Throttle ===
local refreshPending = false
local refreshAfter = 0

local function RequestRefresh(delay)
  delay = delay or 0
  refreshPending = true
  refreshAfter = math.max(refreshAfter, GetTime() + delay)
end

local function TryRefresh()
  if not refreshPending then return end
  if GetTime() < refreshAfter then return end
  refreshPending = false
  refreshAfter = 0
  IC.Core:Refresh()
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("BAG_UPDATE_DELAYED")
ev:RegisterEvent("DELETE_ITEM_CONFIRM")
ev:RegisterEvent("GET_ITEM_INFO_RECEIVED")

ev:SetScript("OnUpdate", function() TryRefresh() end)

ev:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == IC.addon then
    IC.Core:Init()
    return
  end

  if event == "BAG_UPDATE_DELAYED" then
    if IC.UI and IC.UI:IsShown() then
      RequestRefresh(0.05)
    end

  elseif event == "GET_ITEM_INFO_RECEIVED" then
    if IC.UI and IC.UI:IsShown() then
      RequestRefresh(0.15)
    end

  elseif event == "DELETE_ITEM_CONFIRM" then
    if IC.UI and IC.UI.status and IC.L then
      IC.UI.status:SetText(IC.L.STATUS_POPUP or "")
    end
  end
end)