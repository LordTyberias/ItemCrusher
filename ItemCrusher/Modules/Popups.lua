-- Popups.lua
local IC = ItemCrusher

IC.Popups = {}

function IC.Popups:IsDeletePopupShown()
  local shown = false
  local function scan(d)
    if d.which == "DELETE_ITEM" or d.which == "DELETE_GOOD_ITEM" then
      shown = true
    end
  end

  if StaticPopup_ForEachShownDialog then
    StaticPopup_ForEachShownDialog(scan)
  else
    for i = 1, STATICPOPUP_NUMDIALOGS do
      local d = _G["StaticPopup"..i]
      if d and d:IsShown() then scan(d) end
    end
  end

  return shown
end

function IC.Popups:SetupDeletePopups()
  if not StaticPopupDialogs then return end
  if StaticPopupDialogs["DELETE_ITEM"] then
    StaticPopupDialogs["DELETE_ITEM"].enterClicksFirstButton = 1
  end
  if StaticPopupDialogs["DELETE_GOOD_ITEM"] then
    StaticPopupDialogs["DELETE_GOOD_ITEM"].enterClicksFirstButton = 1
  end
end