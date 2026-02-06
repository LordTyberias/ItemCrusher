-- Modules/Settings.lua
local IC = ItemCrusher

IC.Settings = { categoryId = nil }

function IC.Settings:Open()
  if Settings and self.categoryId and Settings.OpenToCategory then
    Settings.OpenToCategory(self.categoryId)
    return
  end
  if InterfaceOptionsFrame_OpenToCategory and _G.ItemCrusherOptionsPanel then
    InterfaceOptionsFrame_OpenToCategory(_G.ItemCrusherOptionsPanel)
    InterfaceOptionsFrame_OpenToCategory(_G.ItemCrusherOptionsPanel)
  end
end

local function SortedLangKeys(langNames)
  local keys = {}
  for k in pairs(langNames) do keys[#keys + 1] = k end
  table.sort(keys, function(a, b)
    return (langNames[a] or a) < (langNames[b] or b)
  end)
  return keys
end

function IC.Settings:Create(ui, minimapBtn)
  if _G.ItemCrusherOptionsPanel then return end

  local panel = CreateFrame("Frame", "ItemCrusherOptionsPanel", UIParent)
  panel.name = "ItemCrusher"

  local header = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  header:SetPoint("TOPLEFT", 16, -16)

  local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  sub:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)

  local hint = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
  hint:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -14)
  hint:SetWidth(560)
  hint:SetJustifyH("LEFT")

  -- Language label
  local langLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  langLabel:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -18)

  -- Dropdown
  local dd = CreateFrame("Frame", "ItemCrusherLangDropdown", panel, "UIDropDownMenuTemplate")
  dd:SetPoint("TOPLEFT", langLabel, "BOTTOMLEFT", -16, -8)

  local function SetLang(lang)
    IC.db.lang = lang
    IC.Locale:Apply()
    UIDropDownMenu_SetSelectedValue(dd, lang)
    UIDropDownMenu_SetText(dd, (IC.L.LANG_NAMES and IC.L.LANG_NAMES[lang]) or lang)
    if ui and ui:IsShown() then IC.Core:Refresh() end
  end

  local function InitDropdown()
    local L = IC.L
    local names = (L and L.LANG_NAMES) or {}
    local keys = SortedLangKeys(names)

    UIDropDownMenu_Initialize(dd, function(self, level)
      local info = UIDropDownMenu_CreateInfo()
      for _, lang in ipairs(keys) do
        info.text = names[lang] or lang
        info.value = lang
        info.func = function() SetLang(lang) end
        info.checked = (IC.db.lang == lang)
        UIDropDownMenu_AddButton(info, level)
      end
    end)

    UIDropDownMenu_SetWidth(dd, 180)
    UIDropDownMenu_SetSelectedValue(dd, IC.db.lang)
    UIDropDownMenu_SetText(dd, (names[IC.db.lang] or IC.db.lang))
  end

  -- Minimap header
  local mmHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  mmHeader:SetPoint("TOPLEFT", dd, "BOTTOMLEFT", 16, -22)

  local lockCB = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
  lockCB:SetPoint("TOPLEFT", mmHeader, "BOTTOMLEFT", 0, -10)
  lockCB.text = lockCB:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  lockCB.text:SetPoint("LEFT", lockCB, "RIGHT", 4, 1)

  lockCB:SetScript("OnClick", function(self)
    IC.db.minimap.locked = self:GetChecked() and true or false
    if minimapBtn and minimapBtn.UpdateLockState then
      minimapBtn:UpdateLockState()
    end
  end)

  panel:SetScript("OnShow", function()
    local L = IC.L
    header:SetText(L.OPT_TITLE)
    sub:SetText(L.OPT_SUB)
    hint:SetText(L.OPT_HINT)

    langLabel:SetText(L.OPT_LANG)
    InitDropdown()

    mmHeader:SetText(L.OPT_MINIMAP)
    lockCB.text:SetText(L.OPT_MINIMAP_LOCK)
    lockCB:SetChecked(IC.db.minimap.locked and true or false)
  end)

  if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panel, "ItemCrusher")
    self.categoryId = category:GetID()
    Settings.RegisterAddOnCategory(category)
  else
    if InterfaceOptions_AddCategory then InterfaceOptions_AddCategory(panel) end
  end
end