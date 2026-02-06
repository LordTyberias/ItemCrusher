-- Modules/Minimap.lua
local IC = ItemCrusher
IC.Minimap = {}

local minimapShapes = {
  ["ROUND"] = {true, true, true, true},
  ["SQUARE"] = {false, false, false, false},
  ["CORNER-TOPLEFT"] = {false, false, false, true},
  ["CORNER-TOPRIGHT"] = {false, false, true, false},
  ["CORNER-BOTTOMLEFT"] = {false, true, false, false},
  ["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
  ["SIDE-LEFT"] = {false, true, false, true},
  ["SIDE-RIGHT"] = {true, false, true, false},
  ["SIDE-TOP"] = {false, false, true, true},
  ["SIDE-BOTTOM"] = {true, true, false, false},
  ["TRICORNER-TOPLEFT"] = {false, true, true, true},
  ["TRICORNER-TOPRIGHT"] = {true, false, true, true},
  ["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
  ["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local function PlaceButton(self)
  local db = IC.db.minimap
  local angle = math.rad(db.position or 200)
  local x, y, q = math.cos(angle), math.sin(angle), 1
  if x < 0 then q = q + 1 end
  if y > 0 then q = q + 2 end

  local shape = (GetMinimapShape and GetMinimapShape()) or "ROUND"
  local quadTable = minimapShapes[shape] or minimapShapes["ROUND"]

  local w = (Minimap:GetWidth() / 2) + 5
  local h = (Minimap:GetHeight() / 2) + 5

  if quadTable[q] then
    x, y = x * w, y * h
  else
    local diagRadiusW = math.sqrt(2 * (w)^2) - 10
    local diagRadiusH = math.sqrt(2 * (h)^2) - 10
    x = math.max(-w, math.min(x * diagRadiusW, w))
    y = math.max(-h, math.min(y * diagRadiusH, h))
  end

  self:ClearAllPoints()
  self:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function IC.Minimap:Create()
  if self.btn then return self.btn end
  local btn = CreateFrame("Button", "ItemCrusherMinimapButton", Minimap)
  self.btn = btn

  btn:SetFrameStrata(Minimap:GetFrameStrata())
  btn:SetFrameLevel(8)
  btn:SetSize(31, 31)
  btn:SetMovable(true)
  btn:EnableMouse(true)
  btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  local overlay = btn:CreateTexture(nil, "OVERLAY")
  overlay:SetSize(53, 53)
  overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  overlay:SetPoint("TOPLEFT")

  local bg = btn:CreateTexture(nil, "BACKGROUND")
  bg:SetSize(20, 20)
  bg:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
  bg:SetPoint("TOPLEFT", 6, -6)

  local icon = btn:CreateTexture(nil, "BORDER")
  icon:SetSize(20, 20)
  icon:SetTexture("Interface\\Icons\\Ships_ability_depthcharges")
  icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
  icon:SetPoint("TOPLEFT", 6, -5)
  btn.icon = icon

  btn:SetScript("OnEnter", function(self)
    local L = IC.L
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine(L.MM_TIP_TITLE, 1, 1, 1)
    GameTooltip:AddLine(L.MM_TIP_LEFT, 0.8, 0.8, 0.8)
    GameTooltip:AddLine(L.MM_TIP_RIGHT, 0.8, 0.8, 0.8)
    if IC.db.minimap.locked then
      GameTooltip:AddLine(L.MM_TIP_LOCKED, 0.2, 1.0, 0.2)
    else
      GameTooltip:AddLine(L.MM_TIP_DRAG, 0.8, 0.8, 0.8)
    end
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

  btn:SetScript("OnClick", function(_, button)
    if button == "RightButton" then
      IC.Settings:Open()
      return
    end
    if IC.UI:IsShown() then
      IC.UI:Hide()
    else
      IC.UI:Show()
      IC.Core:Refresh()
    end
  end)

  btn:SetScript("OnMouseDown", function(self) self.icon:SetTexCoord(0, 1, 0, 1) end)
  btn:SetScript("OnMouseUp", function(self) self.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95) end)

  btn.UpdatePosition = function(self)
    self:SetFrameStrata(Minimap:GetFrameStrata())
    self:SetParent(Minimap)
    self:SetFrameLevel(8)
    PlaceButton(self)
  end

  btn.OnUpdate = function(self)
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    px, py = px / scale, py / scale

    IC.db.minimap.position = math.deg(math.atan2(py - my, px - mx)) % 360
    self:UpdatePosition()
  end

  btn:SetScript("OnDragStart", function(self)
    if IC.db.minimap.locked then return end
    self.dragging = true
    self:LockHighlight()
    self.icon:SetTexCoord(0, 1, 0, 1)
    self:SetScript("OnUpdate", self.OnUpdate)
    GameTooltip:Hide()
  end)

  btn:SetScript("OnDragStop", function(self)
    self.dragging = nil
    self:SetScript("OnUpdate", nil)
    self.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    self:UnlockHighlight()
  end)

  function btn:UpdateLockState()
    if IC.db.minimap.locked then
      self:RegisterForDrag() -- none
    else
      self:RegisterForDrag("LeftButton")
    end
    self:UpdatePosition()
  end

  -- initial state from DB
  btn:UpdateLockState()
  btn:UpdatePosition()

  -- optional hide flag support
  if IC.db.minimap.hide then
    btn:Hide()
  end

  return btn
end