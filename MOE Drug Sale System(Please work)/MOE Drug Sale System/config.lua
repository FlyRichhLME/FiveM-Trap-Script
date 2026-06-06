Config = {}

Config.Command = 'trap'
Config.OwnerToggleCommand = 'trapstatus'
Config.RequiredItem = 'trapphone'

Config.UsePhoneUI = true
Config.DriverOnly = true
Config.RequirePassengerSeatOpen = true

Config.CustomerDelay = {
    min = 6000,
    max = 12000
}

Config.EnterDistance = 8.0
Config.SpawnDistance = 35.0
Config.CustomerTimeout = 45000

Config.ProgressTime = 6500
Config.ProgressLabel = 'Making trap sale...'
Config.SaleCooldown = 15000

Config.PayAccount = 'cash'
Config.UseMarkedBills = false
Config.MarkedBillsItem = 'markedbills'

-- No NPC robbing.
Config.AllowNpcRobbing = false

-- Customer interest system.
Config.CustomerInterest = {
    enabled = true,
    buyChance = 75,
    interestedMessage = 'Customer is interested.',
    notInterestedMessage = 'Customer is not interested in what you have.'
}

-- ===== BULK DELIVERY SYSTEM =====
Config.BulkDelivery = {
    enabled = true,
    minItems = 5,
    maxItems = 20,
    payoutMultiplier = 2,
    progressTime = 10000,
    progressLabel = 'Completing bulk drug delivery...',
    cooldown = 30000,
    useInterestChance = true,
    
    -- Ping timeout in seconds (how long customer will wait)
    pingTimeout = 30,
    
    -- Distance player must be within to spawn NPC at delivery location
    deliveryDistance = 50.0,
    
    -- Distance NPC must reach before entering vehicle
    npcApproachDistance = 8.0
}

-- ===== DELIVERY LOCATIONS =====
-- Add custom delivery locations here
-- Server owner can customize these coordinates and names
Config.DeliveryLocations = {
    {
        name = 'Pillbox Medical Center',
        coords = vector3(326.4, -585.5, 44.1),
        heading = 161.5
    },
    {
        name = 'Legion Square',
        coords = vector3(200.5, -934.2, 24.1),
        heading = 0.0
    },
    {
        name = 'Del Perro Pier',
        coords = vector3(-1553.5, -1042.3, 13.0),
        heading = 180.0
    },
    {
        name = 'Maze Bank Arena',
        coords = vector3(-254.9, -2011.8, 30.5),
        heading = 45.0
    },
    {
        name = 'Mirror Park',
        coords = vector3(1127.5, -795.2, 57.6),
        heading = 270.0
    },
    {
        name = 'Rockford Hills',
        coords = vector3(-610.5, -925.2, 21.5),
        heading = 90.0
    },
    {
        name = 'Vinewood Bowl',
        coords = vector3(662.5, 522.3, 130.4),
        heading = 225.0
    },
    {
        name = 'Desert Airfield',
        coords = vector3(2141.5, 4783.2, 41.1),
        heading = 315.0
    },
}

-- CUSTOM DRUG SYSTEM
-- Add any drug item from your qb-core/shared/items.lua here.
-- item = inventory item name
-- label = display name
-- min/max = single sale payout range
-- bulkMultiplier = extra multiplier for this specific item during bulk sales
-- allowSingle = can sell with CALL CUSTOMER
-- allowBulk = can sell with BULK DELIVERY
Config.CustomDrugs = {
    ['weed_bag'] = {
        label = 'Weed Bag',
        min = 150,
        max = 300,
        bulkMultiplier = 1.0,
        allowSingle = true,
        allowBulk = true
    },

    ['cokebaggy'] = {
        label = 'Coke Baggy',
        min = 350,
        max = 650,
        bulkMultiplier = 1.0,
        allowSingle = true,
        allowBulk = true
    },

    ['meth'] = {
        label = 'Meth',
        min = 450,
        max = 800,
        bulkMultiplier = 1.0,
        allowSingle = true,
        allowBulk = true
    },

    -- Example custom drug:
    -- ['lean_bottle'] = {
    --     label = 'Lean Bottle',
    --     min = 500,
    --     max = 950,
    --     bulkMultiplier = 1.25,
    --     allowSingle = true,
    --     allowBulk = true
    -- },
}

-- If true, the system can sell any inventory item that is not blocked.
-- Recommended: false for serious RP economy control.
-- If false, only Config.CustomDrugs can be sold.
Config.AllowAnyDrugItem = false

-- Used only when Config.AllowAnyDrugItem = true.
Config.DefaultDrugPrice = {
    min = 125,
    max = 700,
    bulkMultiplier = 1.0
}

-- Items that should never be sold when AllowAnyDrugItem is true.
Config.BlockedItems = {
    ['trapphone'] = true,
    ['phone'] = true,
    ['radio'] = true,
    ['cash'] = true,
    ['money'] = true,
    ['weapon_pistol'] = true,
    ['weapon_combatpistol'] = true,
    ['weapon_smg'] = true
}

Config.Owners = {
    citizenids = {
        -- 'YOUR_CITIZEN_ID'
    },

    jobs = {
        -- 'boss'
    },

    gangs = {
        -- 'ballas'
    }
}

Config.CustomerPeds = {
    'a_m_y_stwhi_02',
    'a_m_y_hipster_01',
    'a_m_m_soucent_02',
    'g_m_y_ballasout_01',
    'g_m_y_famca_01'
}
