# ItemCrusher

ItemCrusher is a lightweight World of Warcraft addon that helps you **select items from your bags and delete them quickly** — **one item stack per click** — with minimal friction.

It provides a simple UI to browse your bag items, grouped by rarity, lets you mark items with a single click, and then delete them step-by-step (including handling Blizzard confirmation popups).

## Features

- **Fast deletion workflow:** deletes **one item stack per click**
- **Selection UI:** click item icons to mark/unmark (big green checkmark)
- **Smart grouping:**
  - “Already known” section (for learned/known items where applicable)
  - Everything else grouped by **rarity (ascending)**
- **Rarity-colored borders** around item icons (inventory-style)
- **Hearthstones are hidden** by default
- **Minimap button**
  - draggable position
  - optional lock (prevents moving)
- **Settings panel**
  - language dropdown
  - minimap lock toggle
- **Saved settings**
  - selected language
  - minimap icon position
  - minimap lock state

## Commands

- `/itemcrusher` — Toggle the ItemCrusher window  
- `/itemcrusher options` — Open settings

## How to use

1. Open the window with `/itemcrusher` (or via the minimap icon).
2. Click item icons to mark items you want to delete.
3. Click **Delete**:
   - ItemCrusher deletes **one stack per click**
   - If Blizzard shows a confirmation popup, confirm it and click Delete again
4. Use **Clear** to unselect everything.

## Supported Languages

The UI language can be changed in settings:

- English
- German
- Portuguese
- French
- Spanish
- Italian
- Russian
- Ukrainian
- Korean
- Simplified Chinese

## Installation

### CurseForge / Addons Manager
- Install via CurseForge (recommended).

### Manual
1. Download the release ZIP.
2. Extract to your WoW AddOns folder:
   - `_retail_/Interface/AddOns/ItemCrusher/`
3. Restart WoW or run `/reload`.

## Notes

- Deleting items is permanent. Use carefully.
- Some items may trigger Blizzard confirmation popups; ItemCrusher will pause and guide you to confirm.

## License

Choose a license that matches your preference (see `LICENSE` file in the repository).

## Credits

Created by **LordTyberias / Tyberîas**.
