# AGENTS.md — Contributor / Agent Guidelines

This repository contains the World of Warcraft addon **ItemCrusher**.

## Goals

- Keep the addon **lightweight**, **stable**, and **easy to maintain**
- Avoid dependencies unless they are truly needed
- Ensure features work on current WoW client versions (Retail)

## Coding Style

- Lua formatting: simple, consistent indentation (2 spaces or tabs, but consistent)
- Prefer small helper functions over large, nested logic
- Avoid global pollution: attach modules to the `ItemCrusher` table (`IC`)
- Be defensive:
  - guard optional modules/functions (`if IC.Module and IC.Module.Func then ... end`)
  - avoid nil indexing in event handlers and OnShow scripts

## SavedVariables

- All persistent settings should live under the SavedVariables table (e.g. `ItemCrusherDB`)
- Defaults must be applied safely on load (do not overwrite existing user values)
- Settings that must persist:
  - language selection
  - minimap icon position
  - minimap lock state

## UI Guidelines

- UI must not crash if opened early (before model scan finished)
- Buttons should reflect state:
  - Clear/Delete should be disabled when nothing is selected
- Use inventory-like borders for item buttons:
  - rarity color when not selected
  - green border when selected

## Deletion Workflow

- Deletion happens **one stack per click**
- If Blizzard popup confirmation appears, stop and prompt the user to confirm
- Never clear the cursor in a way that cancels a pending delete action

## Testing Checklist

Before publishing or merging changes, verify:

- `/itemcrusher` opens/closes window
- Items are listed and grouped correctly
- Selection toggles correctly
- Clear resets selection and updates button states
- Delete removes one stack per click
- Popups are handled without breaking the workflow
- Minimap icon can be moved and lock works
- SavedVariables persist after `/reload` and relog
- No Lua errors in the default UI flow

## Versioning / Releases

- Keep `## Version:` in the `.toc` updated
- Maintain a `CHANGELOG` (or release notes) per version
- Prefer tagged releases for distribution
