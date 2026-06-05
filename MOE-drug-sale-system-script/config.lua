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

-- Bulk delivery through prepaid phone NUI.
Config.BulkDelivery = {
    enabled = true,
    minItems = 5,
    maxItems = 20,
    payoutMultiplier = 2,
    progressTime = 10000,
    progressLabel = 'Completing bulk drug delivery...',
    cooldown = 30000,
    useInterestChance = true
}

-- true = any inventory item not blocked can be sold.
-- false = only Config.Drugs can be sold.
Config.AllowAnyDrugItem = true

-- Items that should never be sold when AllowAnyDrugItem is true.
Config.BlockedItems = {
    ['trapphone'] = true,
    ['phone'] = true,
    ['radio'] = true,
    ['cash'] = true,
    ['money'] = true,
    ['weapon_pistol'] = true
}

-- Fallback pricing for items not listed in Config.Drugs.
Config.DefaultDrugPrice = {
    min = 125,
    max = 700
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

-- Add any specific drug here for custom labels/prices.
Config.Drugs = {
    ['weed_bag'] = {
        label = 'Weed Bag',
        min = 150,
        max = 300
    },

    ['cokebaggy'] = {
        label = 'Coke Baggy',
        min = 350,
        max = 650
    },

    ['meth'] = {
        label = 'Meth',
        min = 450,
        max = 800
    }
}

Config.CustomerPeds = {
    'a_m_y_stwhi_02',
    'a_m_y_hipster_01',
    'a_m_m_soucent_02',
    'g_m_y_ballasout_01',
    'g_m_y_famca_01'
}
