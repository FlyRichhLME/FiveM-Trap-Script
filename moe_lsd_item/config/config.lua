Config = {}

-- Core settings
Config.CoreName = 'qb-core'
Config.ItemName = 'lsd'
Config.ItemLabel = 'LSD Tab'
Config.Debug = false

-- Use behavior
Config.RemoveOnUse = true
Config.UseCooldownSeconds = 10
Config.ProgressTime = 3500
Config.ProgressLabel = 'Taking LSD...'

-- Health / armor behavior
-- GTA/FiveM player armor is normally 0-100.
-- SetHealthMax applies max health first, then fills health to HealthAmount.
Config.SetArmor = true
Config.ArmorAmount = 100
Config.SetHealthMax = true
Config.MaxHealth = 200
Config.SetHealth = true
Config.HealthAmount = 200

-- Stamina effect: 300 seconds by default.
Config.StaminaBoost = true
Config.StaminaDurationSeconds = 300
Config.RestoreSprintStaminaEachTick = true

-- Optional screen/gameplay effects
Config.EnableVisualEffect = true
Config.VisualEffectName = 'DrugsMichaelAliensFightIn'
Config.VisualEffectDurationSeconds = 15
Config.EnableMovementClipset = false
Config.MovementClipset = 'MOVE_M@DRUNK@SLIGHTLYDRUNK'

-- Selling behavior
Config.AllowSellCommand = true
Config.SellCommand = 'selllsd'
Config.SellRequiresItem = true
Config.SellRemoveAmount = 1
Config.SellMoneyType = 'cash' -- cash, bank, crypto if your server supports it
Config.SellPriceMin = 350
Config.SellPriceMax = 650
Config.SellNotifyPolice = false
Config.PoliceJobNames = { 'police', 'sheriff' }

-- Anti-spam / optimization
Config.SellCooldownSeconds = 8
Config.StaminaTickMs = 1000
