local QBCore = exports['qb-core']:GetCoreObject()

local trapEnabled = true

local function TableHasValue(tbl, value)
    if not tbl then return false end
    for _, item in pairs(tbl) do
        if item == value then return true end
    end
    return false
end

local function IsTrapOwner(Player)
    if not Player then return false end

    local citizenid = Player.PlayerData.citizenid
    local jobName = Player.PlayerData.job and Player.PlayerData.job.name or nil
    local gangName = Player.PlayerData.gang and Player.PlayerData.gang.name or nil

    if TableHasValue(Config.Owners.citizenids, citizenid) then return true end
    if TableHasValue(Config.Owners.jobs, jobName) then return true end
    if TableHasValue(Config.Owners.gangs, gangName) then return true end
    if QBCore.Functions.HasPermission(Player.PlayerData.source, 'admin') then return true end

    return false
end

local function IsBlockedItem(itemName)
    return Config.BlockedItems[itemName] == true
end

local function GetDrugConfig(itemName)
    return Config.CustomDrugs[itemName]
end

local function GetItemLabel(itemName)
    local drugInfo = GetDrugConfig(itemName)
    if drugInfo and drugInfo.label then return drugInfo.label end
    if QBCore.Shared.Items[itemName] and QBCore.Shared.Items[itemName].label then
        return QBCore.Shared.Items[itemName].label
    end
    return itemName
end

local function GetReputation(Player)
    if not Config.Reputation.enabled then return 0 end
    return Player.PlayerData.metadata["traprep"] or 0
end

local function AddReputation(Player, amount)
    if not Config.Reputation.enabled then return end
    local rep = GetReputation(Player)
    rep = math.max(0, math.min(Config.Reputation.max, rep + amount))
    Player.Functions.SetMetaData("traprep", rep)
end

local function GetRepMultiplier(Player)
    if not Config.Reputation.enabled then return 1.0 end
    local rep = GetReputation(Player)
    local tierMultiplier = 1.0

    for _, tier in ipairs(Config.Reputation.tiers) do
        if rep >= tier.level then
            tierMultiplier = tier.multiplier
        end
    end

    return tierMultiplier
end

local function GetDrugPrice(Player, itemName, isBulk, isHVB)
    local drugInfo = GetDrugConfig(itemName)

    local min = Config.DefaultDrugPrice.min
    local max = Config.DefaultDrugPrice.max
    local itemBulkMultiplier = Config.DefaultDrugPrice.bulkMultiplier or 1.0

    if drugInfo then
        min = drugInfo.min or min
        max = drugInfo.max or max
        itemBulkMultiplier = drugInfo.bulkMultiplier or 1.0
    end

    local price = math.random(min, max)

    if isBulk then
        price = math.floor(price * (Config.BulkDelivery.payoutMultiplier or 1) * itemBulkMultiplier)
    end

    price = math.floor(price * GetRepMultiplier(Player))

    if isHVB and Config.HighValueBuyers.enabled then
        local hvbMin = Config.HighValueBuyers.payoutMultiplier.min or 2.0
        local hvbMax = Config.HighValueBuyers.payoutMultiplier.max or 4.0
        local hvbMulti = math.random(hvbMin * 100, hvbMax * 100) / 100
        price = math.floor(price * hvbMulti)
    end

    return price
end

local function IsSellableItem(item, mode)
    if not item or not item.name or not item.amount or item.amount < 1 then return false end
    if IsBlockedItem(item.name) then return false end

    local drugInfo = GetDrugConfig(item.name)

    if not Config.AllowAnyDrugItem and not drugInfo then return false end

    if drugInfo then
        if mode == 'bulk' and drugInfo.allowBulk == false then return false end
        if mode ~= 'bulk' and drugInfo.allowSingle == false then return false end
    end

    return true
end

local function GetSellableDrug(Player)
    if not Player then return false end

    for _, item in pairs(Player.PlayerData.items or {}) do
        if IsSellableItem(item, 'single') then
            return { item = item.name, label = GetItemLabel(item.name) }
        end
    end

    return false
end

local function GetBulkSellItems(Player)
    local sellItems = {}
    local totalCount = 0
    local totalPayout = 0

    for _, item in pairs(Player.PlayerData.items or {}) do
        if IsSellableItem(item, 'bulk') then
            local amountToSell = math.min(item.amount, Config.BulkDelivery.maxItems - totalCount)

            if amountToSell > 0 then
                table.insert(sellItems, { name = item.name, amount = amountToSell })

                for _ = 1, amountToSell do
                    totalPayout = totalPayout + GetDrugPrice(Player, item.name, true, false)
                end

                totalCount = totalCount + amountToSell
            end

            if totalCount >= Config.BulkDelivery.maxItems then break end
        end
    end

    if totalCount < Config.BulkDelivery.minItems then
        return false, totalCount, 0
    end

    return { items = sellItems, count = totalCount, payout = totalPayout }, totalCount, totalPayout
end

QBCore.Functions.CreateCallback('moe-drugsale:server:CanOpenPhone', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false, 'Player not found.', 'OFFLINE') return end

    local item = Player.Functions.GetItemByName(Config.RequiredItem)
    if not item then cb(false, 'You need a Trap Phone.', 'NO PHONE') return end

    cb(true, nil, trapEnabled and 'READY' or 'DISABLED')
end)

QBCore.Functions.CreateCallback('moe-drugsale:server:CanStartTrap', function(source, cb, mode)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then cb(false, 'Player not found.') return end
    if not trapEnabled then cb(false, 'Trap sales are currently turned off.') return end

    if not Player.Functions.GetItemByName(Config.RequiredItem) then
        cb(false, 'You need a Trap Phone.')
        return
    end

    if mode == 'bulk' then
        local bulkData, count = GetBulkSellItems(Player)
        if not bulkData then
            cb(false, 'You need at least ' .. Config.BulkDelivery.minItems .. ' sellable items. Current: ' .. count)
            return
        end
    else
        if not GetSellableDrug(Player) then
            cb(false, 'You do not have any sellable drug items.')
            return
        end
    end

    cb(true)
end)

QBCore.Functions.CreateCallback('moe-drugsale:server:GetTrapStatus', function(_, cb)
    cb({ enabled = trapEnabled, label = trapEnabled and 'READY' or 'DISABLED' })
end)

QBCore.Functions.CreateCallback('moe-drugsale:server:GetBuyerType', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false, nil) return end

    local rep = GetReputation(Player)
    if rep < Config.HighValueBuyers.minRep then
        cb(false, nil)
        return
    end

    if math.random(1, 100) <= Config.HighValueBuyers.chance then
        local model = Config.HighValueBuyers.pedModels[math.random(#Config.HighValueBuyers.pedModels)]
        cb(true, model)
    else
        cb(false, nil)
    end
end)

QBCore.Functions.CreateCallback('moe-drugsale:server:CheckCustomerInterest', function(source, cb, mode)
    local Player = QBCore.Functions.GetPlayer(source)
    local rep = GetReputation(Player)
    local isHVB = false

    if Config.HighValueBuyers.enabled and rep >= Config.HighValueBuyers.minRep then
        if math.random(1, 100) <= Config.HighValueBuyers.chance then
            isHVB = true
        end
    end

    if mode == 'bulk' and not Config.BulkDelivery.useInterestChance then
        cb(true, Config.CustomerInterest.interestedMessage, isHVB)
        return
    end

    if math.random(1, 100) <= Config.CustomerInterest.buyChance then
        cb(true, isHVB and 'High-value buyer is interested.' or Config.CustomerInterest.interestedMessage, isHVB)
    else
        cb(false, Config.CustomerInterest.notInterestedMessage, false)
    end
end)

QBCore.Functions.CreateCallback('moe-drugsale:server:GetSellableDrug', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    cb(GetSellableDrug(Player))
end)

QBCore.Functions.CreateCallback('moe-drugsale:server:CanBulkSell', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local bulkData, count = GetBulkSellItems(Player)
    if not bulkData then
        cb(false, 'You need at least ' .. Config.BulkDelivery.minItems .. ' sellable items. Current: ' .. count)
        return
    end
    cb(true)
end)

RegisterNetEvent('moe-drugsale:server:CompleteSale', function(itemName, isHVB)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not trapEnabled then
        TriggerClientEvent('QBCore:Notify', src, 'Trap sales are turned off.', 'error')
        return
    end

    local item = Player.Functions.GetItemByName(itemName)
    if not IsSellableItem(item, 'single') then
        TriggerClientEvent('QBCore:Notify', src, 'That item cannot be sold.', 'error')
        return
    end

    local payout = GetDrugPrice(Player, itemName, false, isHVB)

    Player.Functions.RemoveItem(itemName, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'remove')

    if Config.UseMarkedBills then
        Player.Functions.AddItem(Config.MarkedBillsItem, 1, false, { worth = payout })
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.MarkedBillsItem], 'add')
    else
        Player.Functions.AddMoney(Config.PayAccount, payout, 'trap-sale')
    end

    TriggerClientEvent('QBCore:Notify', src, 'You earned $' .. payout .. '.', 'success')
    AddReputation(Player, Config.Reputation.gainSingle)
end)

RegisterNetEvent('moe-drugsale:server:CompleteBulkSale', function(isHVB)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not trapEnabled then
        TriggerClientEvent('QBCore:Notify', src, 'Trap sales are turned off.', 'error')
        return
    end

    local bulkData, count, payout = GetBulkSellItems(Player)
    if not bulkData then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough items for bulk sale.', 'error')
        return
    end

    for _, saleItem in pairs(bulkData.items) do
        Player.Functions.RemoveItem(saleItem.name, saleItem.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[saleItem.name], 'remove')
    end

    Player.Functions.AddMoney(Config.PayAccount, payout, 'trap-bulk-sale')
    TriggerClientEvent('QBCore:Notify', src, 'Bulk sale completed for $' .. payout .. '.', 'success')
    AddReputation(Player, Config.Reputation.gainBulk)
end)

RegisterNetEvent('moe-drugsale:server:StartDelivery', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not trapEnabled then
        TriggerClientEvent('QBCore:Notify', src, 'Trap deliveries are turned off.', 'error')
        return
    end

    if not Config.Delivery.enabled then
        TriggerClientEvent('QBCore:Notify', src, 'Delivery system disabled.', 'error')
        return
    end

    local bulkData, count = GetBulkSellItems(Player)
    if not bulkData then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough items for delivery.', 'error')
        return
    end

    local loc = Config.Delivery.locations[math.random(#Config.Delivery.locations)]
    TriggerClientEvent('moe-drugsale:client:BeginDelivery', src, loc)
end)

RegisterNetEvent('moe-drugsale:server:CompleteDelivery', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local bulkData = GetBulkSellItems(Player)
    if not bulkData then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough items for delivery.', 'error')
        return
    end

    for _, saleItem in pairs(bulkData.items) do
        Player.Functions.RemoveItem(saleItem.name, saleItem.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[saleItem.name], 'remove')
    end

    local payout = bulkData.payout
    Player.Functions.AddMoney(Config.PayAccount, payout, 'trap-delivery')

    TriggerClientEvent('QBCore:Notify', src, 'Delivery completed for $' .. payout .. '.', 'success')
    AddReputation(Player, Config.Reputation.gainBulk)
end)
