# MOE Drug Sale System Script

QBCore FiveM drug sale system with prepaid phone UI, customer interest, NPC passenger-seat sales, bulk delivery, and owner on/off controls.

## Features

- QBCore ready
- `/trap` command opens prepaid phone UI
- Usable `trapphone` item opens prepaid phone UI
- Single customer sale
- Bulk drug delivery sale from phone UI
- Bulk sale has double payout
- Customer interest / no-interest chance
- Any drug/item can be sold when enabled
- Blocklist for items that should never sell
- NPC walks to player's vehicle
- NPC enters passenger seat
- ox_lib progress circle animation
- Player receives cash or marked bills
- NPC exits vehicle after sale
- No NPC robbing
- Owner on/off switch

## Dependencies

- `qb-core`
- `ox_lib`

## Installation

1. Place `MOE-drug-sale-system-script` inside your resources folder.
2. Add this to `server.cfg`:

```cfg
ensure ox_lib
ensure MOE-drug-sale-system-script
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

## Commands

```txt
/trap
/trapstatus on
/trapstatus off
/trapstatus status
```

## Customer Interest

Edit in `config.lua`:

```lua
Config.CustomerInterest = {
    enabled = true,
    buyChance = 75
}
```

`buyChance = 75` means 75% interested and 25% not interested.

## Bulk Delivery

Bulk delivery is available inside the prepaid phone UI.

```lua
Config.BulkDelivery = {
    enabled = true,
    minItems = 5,
    maxItems = 20,
    payoutMultiplier = 2
}
```

This sells multiple sellable items at once and pays double.

## Sell Any Drug Item

Enabled by default:

```lua
Config.AllowAnyDrugItem = true
```

Block items that should never sell:

```lua
Config.BlockedItems = {
    ['trapphone'] = true,
    ['phone'] = true,
    ['radio'] = true
}
```

Custom prices:

```lua
Config.Drugs = {
    ['weed_bag'] = {
        label = 'Weed Bag',
        min = 150,
        max = 300
    }
}
```

Fallback price:

```lua
Config.DefaultDrugPrice = {
    min = 125,
    max = 700
}
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
