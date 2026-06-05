# MOE LSD Item for QBCore

A configurable QBCore-compatible FiveM item resource for an `lsd` inventory item. Players can use it for armor/health and a timed stamina boost, or sell it to nearby NPCs using a command.

## Features

- QBCore usable item: `lsd`
- Optional remove-on-use
- Armor fill, max health, and health fill settings
- Stamina boost for 300 seconds by default
- Optional screen effect and movement clipset
- NPC sale command with configurable payout
- Owner-friendly settings in `config/config.lua`
- Optimized cooldowns and adjustable stamina tick rate

## Installation

1. Put the folder `moe_lsd_item` in your server `resources` folder.
2. Add this to `server.cfg`:

```cfg
ensure moe_lsd_item
```

3. Add the item image:

Copy `images/lsd.png` into your inventory image folder, usually:

```text
qb-inventory/html/images/lsd.png
```

4. Add this item to `qb-core/shared/items.lua`:

```lua
['lsd'] = {
    ['name'] = 'lsd',
    ['label'] = 'LSD Tab',
    ['weight'] = 10,
    ['type'] = 'item',
    ['image'] = 'lsd.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'A small colorful tab.'
},
```

5. Restart your server.

## Usage

- Use the item from inventory to apply effects.
- Stand near an NPC and run:

```text
/selllsd
```

## Customization

Edit `config/config.lua`:

- `Config.ArmorAmount = 100`
- `Config.MaxHealth = 200`
- `Config.HealthAmount = 200`
- `Config.StaminaDurationSeconds = 300`
- `Config.SellPriceMin = 350`
- `Config.SellPriceMax = 650`
- `Config.RemoveOnUse = true`

## Notes

- Armor and health remain until normal gameplay damage changes them.
- Stamina boost lasts only for `Config.StaminaDurationSeconds`.
- For custom inventories, keep the item name as `lsd` unless you also update `Config.ItemName`.
