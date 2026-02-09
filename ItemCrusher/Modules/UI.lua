-- UI.lua
local IC = ItemCrusher

IC.UI = {
  selected = {},
  buttons = {},
  headers = {},
  flatIndexToItem = {},

  ICON_SIZE = 40,
  PAD = 6,
  COLS = 10,
  HEADER_GAP_TOP = 10,
  HEADER_GAP_BOTTOM = 6,
}

-- quality border helper (MUST be defined before StyleButtonSelected uses it)
local function SetQualityBorder(b, quality)
  local r, g, bl, a = 0, 0, 0, 0.85

  if quality ~= nil and ITEM_QUALITY_COLORS then
    local c = ITEM_QUALITY_COLORS[quality]
    if c then
      r, g, bl, a = c.r, c.g, c.b, 1
    end
  end

  b:SetBackdropBorderColor(r, g, bl, a)
end

-- Blizzard-like enable/disable styling for UIPanelButtonTemplate
local function SetButtonEnabled(btn, enabled)
  if not btn then return end

  btn:SetEnabled(enabled and true or false)
  btn:SetAlpha(enabled and 1 or 0.45)

  local fs = btn.GetFontString and btn:GetFontString()
  if fs then
    if enabled then
      fs:SetTextColor(1, 0.82, 0)
    else
      fs:SetTextColor(0.5, 0.5, 0.5)
    end
  end

  if not enabled then
    if btn.SetButtonState then btn:SetButtonState("NORMAL") end
    if btn.UnlockHighlight then btn:UnlockHighlight() end
  end
end

-- Enable/disable bottom action buttons based on selection count
function IC.UI:UpdateActionButtons()
  local hasSelection = (self:CountSelected() > 0)
  SetButtonEnabled(self.clearBtn, hasSelection)
  SetButtonEnabled(self.deleteBtn, hasSelection)
end

function IC.UI:Init()
  if self.frame then return end

  -- Option 3A: Blizzard-like frame (template) with inset background
  local f = CreateFrame("Frame", "ItemCrusherFrame", UIParent, "BasicFrameTemplateWithInset")
  self.frame = f

  f:SetSize(560, 560)
  f:SetPoint("CENTER")
  f:Hide()

  -- Move / Drag
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)

  -- IMPORTANT: OnShow => only request Core refresh (no direct scan here)
  f:SetScript("OnShow", function()
    if IC and IC.Core and IC.Core.Refresh then
      IC.Core:Refresh()
    end
  end)

  -- Use template title text if present
  self.title = f.TitleText
  if self.title then
    self.title:SetText("ItemCrusher") -- overwritten by ApplyLocale()
  end

  if f.CloseButton then
    f.CloseButton:Show()
  end

  if f.Inset and f.Inset.Bg then
    f.Inset.Bg:SetVertexColor(0.95, 0.92, 0.85, 0.90)
  end

  local parchment = f:CreateTexture(nil, "BACKGROUND", nil, 0)
  parchment:SetAllPoints(f.Inset or f)
  parchment:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal")
  parchment:SetVertexColor(1, 1, 1, 0.10)

  -- HELP
  self.help = f:CreateFontString("ItemCrusherHelpText", "OVERLAY", "GameFontHighlightSmall")
  self.help:SetPoint("TOPLEFT", 18, -44)
  self.help:SetJustifyH("LEFT")

  -- Buttons
  self.clearBtn = CreateFrame("Button", "ItemCrusherClearBtn", f, "UIPanelButtonTemplate")
  self.clearBtn:SetSize(120, 28)
  self.clearBtn:SetPoint("BOTTOMLEFT", 18, 22)

  self.deleteBtn = CreateFrame("Button", "ItemCrusherDeleteBtn", f, "UIPanelButtonTemplate")
  self.deleteBtn:SetSize(180, 28)
  self.deleteBtn:SetPoint("BOTTOMRIGHT", -18, 22)

  -- Status text
  self.status = f:CreateFontString("ItemCrusherStatusText", "OVERLAY", "GameFontHighlightSmall")
  self.status:SetPoint("BOTTOMLEFT", 18, 56)
  self.status:SetPoint("BOTTOMRIGHT", -18, 56)
  self.status:SetJustifyH("CENTER")

  -- Scroll
  self.scroll = CreateFrame("ScrollFrame", "ItemCrusherScroll", f, "UIPanelScrollFrameTemplate")
  self.scroll:SetPoint("TOPLEFT", 18, -92)
  self.scroll:SetPoint("BOTTOMRIGHT", -32, 76)

  self.content = CreateFrame("Frame", nil, self.scroll)
  self.content:SetSize(1, 1)
  self.scroll:SetScrollChild(self.content)

  -- =========================
  -- BUTTON WIRING (IMPORTANT)
  -- =========================

  self.clearBtn:SetScript("OnClick", function()
    if not (self.clearBtn and self.clearBtn:IsEnabled()) then return end
    self:ClearSelection()
    if IC.Delete then
      IC.Delete.deleting = false
      if IC.Delete.Reset then IC.Delete:Reset() end
    end
  end)

  self.deleteBtn:SetScript("OnClick", function()
    if not (self.deleteBtn and self.deleteBtn:IsEnabled()) then return end
    if IC.Delete and IC.Delete.OnClick then
      IC.Delete:OnClick(self, IC.Popups)
    end
  end)

  local function GuardHover(btn)
    btn:SetScript("OnEnter", function(selfBtn)
      if not selfBtn:IsEnabled() then
        if selfBtn.UnlockHighlight then selfBtn:UnlockHighlight() end
        if selfBtn.SetButtonState then selfBtn:SetButtonState("NORMAL") end
      end
    end)
    btn:SetScript("OnLeave", function(selfBtn)
      if not selfBtn:IsEnabled() then
        if selfBtn.UnlockHighlight then selfBtn:UnlockHighlight() end
        if selfBtn.SetButtonState then selfBtn:SetButtonState("NORMAL") end
      end
    end)
  end
  GuardHover(self.clearBtn)
  GuardHover(self.deleteBtn)

  -- Initial state: no selection -> disabled
  self:UpdateActionButtons()
end

function IC.UI:EnableEscClose()
  if type(UISpecialFrames) == "table" then
    for _, name in ipairs(UISpecialFrames) do
      if name == "ItemCrusherFrame" then return end
    end
    table.insert(UISpecialFrames, "ItemCrusherFrame")
  end
end

function IC.UI:ApplyLocale()
  if not self.help or not self.clearBtn or not self.deleteBtn then return end
  local L = IC.L
  if not L then return end

  if self.title then
    self.title:SetText(L.TITLE or "ItemCrusher")
  end

  self.help:SetText(L.HELP or "")
  self.clearBtn:SetText(L.CLEAR or "Clear")
  self.deleteBtn:SetText(L.DELETE or "Delete")

  self:UpdateActionButtons()
end

function IC.UI:IsShown()
  return self.frame and self.frame:IsShown() or false
end

function IC.UI:Show()
  if self.frame then self.frame:Show() end
end

function IC.UI:Hide()
  if self.frame then self.frame:Hide() end
end

function IC.UI:CountSelected()
  local n = 0
  for _ in pairs(self.selected) do n = n + 1 end
  return n
end

function IC.UI:UpdateStatusReady()
  if not self.status or not IC.L then return end
  local L = IC.L
  local n = self:CountSelected()
  if n == 0 then
    self.status:SetText(L.STATUS_NONE or "")
  else
    self.status:SetText(string.format(L.STATUS_READY or "%d", n))
  end

  self:UpdateActionButtons()
end

function IC.UI:EnsureHeader(i)
  if self.headers[i] then return self.headers[i] end
  local h = self.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  self.headers[i] = h
  return h
end

function IC.UI:EnsureButton(i)
  if self.buttons[i] then return self.buttons[i] end

  local b = CreateFrame("Button", nil, self.content, "BackdropTemplate")
  b:SetSize(self.ICON_SIZE, self.ICON_SIZE)

  -- inventory-like border
  b:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8,
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
  })
  b:SetBackdropColor(0, 0, 0, 0.35)
  b:SetBackdropBorderColor(0, 0, 0, 0.85)

  -- inset icon so border is visible
  b.icon = b:CreateTexture(nil, "ARTWORK")
  b.icon:SetPoint("TOPLEFT", 3, -3)
  b.icon:SetPoint("BOTTOMRIGHT", -3, 3)
  b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

  b.count = b:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
  b.count:SetPoint("BOTTOMRIGHT", -4, 3)

  b.check = b:CreateTexture(nil, "OVERLAY")
  b.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
  b.check:SetVertexColor(0, 1, 0, 1)
  b.check:SetPoint("CENTER", 0, 0)
  b.check:SetSize(30, 30)
  b.check:Hide()

  SetQualityBorder(b, nil)

  self.buttons[i] = b
  return b
end

function IC.UI:StyleButtonSelected(b, isSelected, quality)
  b.icon:SetDesaturated(false)
  b.icon:SetVertexColor(1, 1, 1, 1)

  if isSelected then
    b.check:Show()
    b:SetBackdropBorderColor(0, 1, 0, 0.9)
  else
    b.check:Hide()
    SetQualityBorder(b, quality)
  end
end

function IC.UI:RenderCategory(titleText, list, headerIndex, buttonIndex, y, onToggle)
  if not list or #list == 0 then
    return headerIndex, buttonIndex, y
  end

  headerIndex = headerIndex + 1
  local h = self:EnsureHeader(headerIndex)
  h:Show()
  h:ClearAllPoints()
  y = y - self.HEADER_GAP_TOP
  h:SetPoint("TOPLEFT", 0, y)
  h:SetText(titleText or "")

  y = y - 24 - self.HEADER_GAP_BOTTOM

  for i = 1, #list do
    buttonIndex = buttonIndex + 1
    local b = self:EnsureButton(buttonIndex)
    b:Show()

    local it = list[i]
    self.flatIndexToItem[buttonIndex] = it

    local row = math.floor((i - 1) / self.COLS)
    local col = (i - 1) % self.COLS

    b:ClearAllPoints()
    b:SetPoint("TOPLEFT", col * (self.ICON_SIZE + self.PAD), y - (row * (self.ICON_SIZE + self.PAD)))

    b.icon:SetTexture(it.icon or 134400)
    b.count:SetText((it.count and it.count > 1) and it.count or "")

    local k = IC.Util.Key(it.bag, it.slot)
    self:StyleButtonSelected(b, self.selected[k] and true or false, it.quality)

    b:SetScript("OnClick", function()
      local newVal = not self.selected[k]
      self.selected[k] = newVal and true or nil
      self:StyleButtonSelected(b, newVal, it.quality)
      self:UpdateStatusReady()
      if onToggle then onToggle() end
    end)

    b:SetScript("OnEnter", function()
      GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
      if it.link then
        GameTooltip:SetHyperlink(it.link)
      else
        GameTooltip:SetText(it.name or "Item")
      end
      GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
  end

  local rows = math.ceil(#list / self.COLS)
  y = y - (rows * (self.ICON_SIZE + self.PAD)) - 8
  return headerIndex, buttonIndex, y
end

-- Helper: detect + cache "known/learned/collected" state per item
local function IsKnownItem(it)
  if not it or it.bag == nil or it.slot == nil then return false end
  if it.isKnown ~= nil then return it.isKnown and true or false end

  local known = false
  if IC.TooltipScan and IC.TooltipScan.IsKnown then
    known = IC.TooltipScan:IsKnown(it.bag, it.slot) and true or false
  end
  it.isKnown = known and true or false
  return known
end

function IC.UI:Refresh(model, onToggle)
  if not self.content then return end
  IC.Util.Wipe(self.flatIndexToItem)

  local headerIndex = 0
  local buttonIndex = 0
  local y = 0
  local maxWidth = self.COLS * (self.ICON_SIZE + self.PAD)

  -- ================================
  -- Build "known" list on-the-fly,
  -- and filter them out of rarities.
  -- ================================
  local knownList = {}
  local knownSet = {}

  local function AddKnown(it)
    if not it then return end
    local k = IC.Util.Key(it.bag, it.slot)
    if not knownSet[k] then
      knownSet[k] = true
      knownList[#knownList + 1] = it
    end
  end

  -- Prefer model.knownItems if provided, but also dedupe against filtered scan.
  if model and model.knownItems then
    for i = 1, #model.knownItems do
      AddKnown(model.knownItems[i])
      model.knownItems[i].isKnown = true
    end
  end

  -- Filter rarity lists: anything "known" goes to knownList
  local filteredByRarity = {}
  if model and model.rarityOrder and model.itemsByRarity then
    for _, q in ipairs(model.rarityOrder) do
      local src = model.itemsByRarity[q] or {}
      local dst = {}
      for i = 1, #src do
        local it = src[i]
        if IsKnownItem(it) then
          AddKnown(it)
        else
          dst[#dst + 1] = it
        end
      end
      filteredByRarity[q] = dst
    end
  end

  -- Render known section (always independent from rarity)
  headerIndex, buttonIndex, y = self:RenderCategory(
    (IC.L and IC.L.KNOWN_HEADER) or "Already known",
    knownList,
    headerIndex, buttonIndex, y,
    onToggle
  )

  -- Render rarities without known items
  if model and model.rarityOrder then
    for _, q in ipairs(model.rarityOrder) do
      local list = filteredByRarity[q] or {}
      local titleText =
        (IC.L and IC.L.RARITY and IC.L.RARITY[q]) or
        ((IC.L and IC.L.RARITY and IC.L.RARITY[-1]) or "Unknown")

      headerIndex, buttonIndex, y = self:RenderCategory(
        titleText, list, headerIndex, buttonIndex, y, onToggle
      )
    end
  end

  for i = headerIndex + 1, #self.headers do self.headers[i]:Hide() end
  for i = buttonIndex + 1, #self.buttons do self.buttons[i]:Hide() end

  local totalHeight = math.max(-y + 10, 1)
  self.content:SetSize(maxWidth, totalHeight)

  self:UpdateStatusReady()
end

function IC.UI:ClearSelection()
  IC.Util.Wipe(self.selected)
  self:UpdateStatusReady()

  if IC.Core and IC.Core.Refresh and self:IsShown() then
    IC.Core:Refresh()
  end
end