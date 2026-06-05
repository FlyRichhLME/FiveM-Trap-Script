# MOE Drug Sale System

QBCore FiveM drug sale system with prepaid phone UI, custom drugs, customer interest, NPC passenger-seat sales, bulk delivery, and owner on/off controls.

## Features

- QBCore ready
- `/trap` opens prepaid phone UI
- Usable `trapphone` item opens prepaid phone UI
- Custom drug list in `config.lua`
- Single customer sale
- Bulk drug delivery sale
- Bulk delivery double payout
- Per-drug bulk multiplier support
- Customer interest / no-interest chance
- Optional sell-any-item mode
- NPC enters and exits passenger seat
- ox_lib progress circle animation
- Player receives cash or marked bills
- No NPC robbing
- Owner on/off switch

## Installation

1. Place `MOE Drug Sale System` inside your resources folder.
2. Add this to `server.cfg`:

```cfg
ensure ox_lib
ensure "MOE Drug Sale System"
```

3. Add this item to `qb-core/shared/items.lua`:

```lua
['trapphone'] = {
    ['name'] = 'trapphone',
    ['label'] = 'Trap Phone',
    ['weight'] = 100,
    ['type'] = 'item',
    ['image'] = 'phone.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'Used to contact trap customers'
},
```

## Add Custom Drugs

Add custom drugs in `config.lua` under `Config.CustomDrugs`.

Example:

```lua
['lean_bottle'] = {
    label = 'Lean Bottle',
    min = 500,
    max = 950,
    bulkMultiplier = 1.25,
    allowSingle = true,
    allowBulk = true
},
```

The item name must match the item in `qb-core/shared/items.lua`.

## Sell Any Drug Item

By default, only drugs listed in `Config.CustomDrugs` can sell:

```lua
Config.AllowAnyDrugItem = false
```

Set it to true to allow any inventory item except blocked items:

```lua
Config.AllowAnyDrugItem = true
```

Block items here:

```lua
Config.BlockedItems = {
    ['trapphone'] = true,
    ['phone'] = true,
    ['radio'] = true
}
```

## Commands

```txt
/trap
/trapstatus on
/trapstatus off
/trapstatus status
```

## Owner Setup

Edit `config.lua`:

```lua
Config.Owners = {
    citizenids = {
        'YOUR_CITIZEN_ID'
    },

    jobs = {
        'boss'
    },

    gangs = {
        'ballas'
    }
}
```

QBCore admins can also use `/trapstatus`.
