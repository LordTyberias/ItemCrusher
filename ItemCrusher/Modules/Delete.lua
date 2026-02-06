-- Delete.lua
local IC = ItemCrusher

IC.Delete = IC.Delete or {
  deleting = false,
  queue = {},
  index = 1,
}

function IC.Delete:Reset()
  self.deleting = false
  IC.Util.Wipe(self.queue)
  self.index = 1
end

local function BuildQueueFromSelected(ui)
  IC.Util.Wipe(IC.Delete.queue)
  IC.Delete.index = 1

  for key in pairs(ui.selected) do
    local bag, slot = key:match("^(%d+):(%d+)$")
    if bag and slot then
      IC.Delete.queue[#IC.Delete.queue + 1] = {
        bag = tonumber(bag),
        slot = tonumber(slot),
        key = key,
      }
    end
  end

  table.sort(IC.Delete.queue, function(a, b)
    if a.bag == b.bag then return a.slot < b.slot end
    return a.bag < b.bag
  end)
end

local function GetNextValidEntry(ui)
  while IC.Delete.index <= #IC.Delete.queue do
    local e = IC.Delete.queue[IC.Delete.index]
    local info = C_Container.GetContainerItemInfo(e.bag, e.slot)

    if info and info.hyperlink then
      if info.isLocked then
        return e, "LOCKED"
      end
      return e, "OK"
    else
      -- slot is empty now -> drop selection and continue
      ui.selected[e.key] = nil
      IC.Delete.index = IC.Delete.index + 1
    end
  end
  return nil, "DONE"
end

function IC.Delete:OnClick(ui, popups)
  local L = IC.L

  -- If a delete popup is currently visible: user must confirm first.
  if popups and popups.IsDeletePopupShown and popups:IsDeletePopupShown() then
    ui.status:SetText(L.STATUS_POPUP)
    return
  end

  -- If cursor has something (maybe from a previous attempt), do NOT clear it blindly.
  -- Clearing can cancel a pending delete. Tell user to finish/confirm first.
  if CursorHasItem() then
    ui.status:SetText(L.STATUS_POPUP)
    return
  end

  -- Build queue on first delete click
  if not self.deleting then
    BuildQueueFromSelected(ui)
    if #self.queue == 0 then
      ui.status:SetText(L.STATUS_NONE)
      return
    end
    self.deleting = true
  end

  local entry, state = GetNextValidEntry(ui)
  if state == "DONE" or not entry then
    self:Reset()
    ui.status:SetText(L.STATUS_DONE)
    IC.Core:Refresh()
    return
  end
  if state == "LOCKED" then
    ui.status:SetText(L.STATUS_LOCKED)
    return
  end

  -- Pick up + delete (one stack per hardware click)
  C_Container.PickupContainerItem(entry.bag, entry.slot)

  if not CursorHasItem() then
    ui.status:SetText(L.STATUS_CURSOR)
    return
  end

  DeleteCursorItem()

  -- IMPORTANT:
  -- If a popup appears (DELETE_ITEM / DELETE_GOOD_ITEM), we must NOT ClearCursor(),
  -- otherwise the deletion gets canceled by putting the item back.
  if popups and popups.IsDeletePopupShown and popups:IsDeletePopupShown() then
    ui.status:SetText(L.STATUS_POPUP)
    return
  end

  -- No popup => safe to clear cursor and continue.
  ClearCursor()

  -- Remove selection entry and advance queue
  ui.selected[entry.key] = nil
  self.index = self.index + 1

  ui:UpdateStatusReady()
  IC.Core:Refresh()
end