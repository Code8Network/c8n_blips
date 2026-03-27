# c8n_blips
Just a simple way to place &amp; make blips
# c8n_blips – Standalone FiveM Blip System

c8n_blips is a lightweight, fully standalone blip management system designed for simplicity, performance, and flexibility. Built without any framework dependencies, this script allows server owners to easily create, manage, and customize map blips across their server with minimal setup.

## Features

- **Fully standalone**: no framework dependency required.
- **Static blips** for permanent locations like stations, businesses, and landmarks.
- **Dynamic blips** for temporary events and real-time map updates.
- **Config-driven setup** for sprite IDs, colors, scale, names, visibility, and short-range behavior.
- **Performance-focused** design with minimal resource usage.
- **Framework compatible** with vMenu, QBCore, ESX, and custom server stacks.

## Use Cases

- Marking police, EMS, mechanic, or other department locations.
- Highlighting event zones and temporary activities.
- Revealing hidden or unlockable spots.
- Defining interactive map areas for gameplay systems.

## Why c8n_blips?

Whether you need a few map markers or a large, categorized blip setup, c8n_blips provides a reliable and developer-friendly foundation for server-wide mapping.

## Installation

1. Place the `c8n_blips` folder in your server's `resources` directory.
2. Add `ensure c8n_blips` to your `server.cfg`.
3. Edit `config.lua` to customize static blips and defaults.

## Server Exports

Use these exports from any other resource:

- `exports.c8n_blips:AddGlobalBlip(id, data[, target])`
- `exports.c8n_blips:RemoveGlobalBlip(id[, target])`
- `exports.c8n_blips:ClearGlobalBlips([target])`
- `exports.c8n_blips:GetGlobalBlips()`

### Example

<!-- ```lua
exports.c8n_blips:AddGlobalBlip('event_zone', {
    coords = vector3(-259.18, -973.81, 31.22),
    name = 'Live Event',
    sprite = 161,
    color = 1,
    scale = 0.9,
    shortRange = false
}) -->
```