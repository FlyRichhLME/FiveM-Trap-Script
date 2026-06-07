Config = {}

Config.Command = 'trap'
Config.OwnerToggleCommand = 'trapstatus'
Config.RequiredItem = 'trapphone'

Config.UsePhoneUI = true
Config.DriverOnly = true
Config.RequirePassengerSeatOpen = true

Config.CustomerDelay = { min = 6000, max = 12000 }
Config.EnterDistance = 8.0
Config.SpawnDistance = 35.0
Config.CustomerTimeout = 45000

Config.ProgressTime = 6500
Config.ProgressLabel = 'Making trap sale...'
Config.SaleCooldown = 15000

Config.PayAccount = 'cash'
Config.UseMarkedBills = false
Config.MarkedBillsItem = 'markedbills'

Config.AllowNpcRobbing = true

Config.CustomerInterest = {
    enabled = true,
    buyChance = 75,
    interestedMessage = 'Customer is interested.',
    notInterestedMessage = 'Customer is not interested in what you have.'
}

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

Config.Reputation = {
    enabled = true,
    max = 1000,
    gainSingle = 5,
    gainBulk = 20,
    lossRobbery = 25,
    tiers = {
        { level = 0,   label = "Rookie",             multiplier = 1.0 },
        { level = 200, label = "Local Plug",         multiplier = 1.1 },
        { level = 500, label = "Trusted Supplier",   multiplier = 1.25 },
        { level = 800, label = "Neighborhood Boss",  multiplier = 1.4 },
        { level = 1000,label = "Trap King",          multiplier = 1.6 }
    }
}

Config.HighValueBuyers = {
    enabled = true,
    chance = 5,
    minRep = 300,
    payoutMultiplier = { min = 2.0, max = 4.0 },
    pedModels = {
        "g_m_m_chicold_01",
        "g_m_m_armboss_01",
        "g_m_m_mexboss_02"
    }
}

Config.Robbery = {
    enabled = true,
    chance = 10,
    minRepToAvoid = 400
}

Config.Delivery = {
    enabled = true,
    locations = {
        vector3(123.4, -321.5, 43.2),
        vector3(-456.2, 234.1, 35.1),
        vector3(812.3, -1124.5, 28.1)
    },
    blip = {
        sprite = 514,
        color = 2,
        scale = 0.9,
        label = "Trap Delivery"
    }
}

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
}

Config.AllowAnyDrugItem = false

Config.DefaultDrugPrice = {
    min = 125,
    max = 700,
    bulkMultiplier = 1.0
}

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
    citizenids = {},
    jobs = {},
    gangs = {}
}

Config.CustomerPeds = {
    'a_m_y_stwhi_02',
    'a_m_y_hipster_01',
    'a_m_m_soucent_02',
    'g_m_y_ballasout_01',
    'g_m_y_famca_01'
}
