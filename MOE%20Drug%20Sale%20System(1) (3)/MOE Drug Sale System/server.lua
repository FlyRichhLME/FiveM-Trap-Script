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
    if QBCore.Shared.Items[itemName] and QBCore.Shared.Items[itemName].label then return QBCore.Shared.Items[itemName].label end
    return itemName
end

local function GetDrugPrice(itemName, isBulk)
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

    local items = Player.PlayerData.items or {}

    for _, item in pairs(items) do
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
    local items = Player.PlayerData.items or {}

    for _, item in pairs(items) do
        if IsSellableItem(item, 'bulk') then
            local amountToSell = math.min(item.amount, Config.BulkDelivery.maxItems - totalCount)

            if amountToSell > 0 then
                sellItems[#sellItems + 1] = {
                    name = item.name,
                    amount = amountToSell
                }

                for _ = 1, amountToSell do
                    totalPayout = totalPayout + GetDrugPrice(item.name, true)
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

QBCore.Functions.CreateUseableItem(Config.RequiredItem, function(source)
    TriggerClientEvent('moe-drugsale:client:UseTrapPhone', source)
end)

QBCore.Functions.CreateCallback('moe-drugsale:server:CanOpenPhone', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false, 'Player not found.', 'OFFLINE') return end

    local item = Player.Functions.GetItemByName(Config.RequiredItem)
    if not item or item.amount < 1 then cb(false, 'You need a Trap Phone.', 'NO PHONE') return end

    cb(true, nil, trapEnabled and 'READY' or 'DISABLED')
end)

QBCore.Functions.CreateCallback('moe-drugsale:server:CanStartTrap', function(source, cb, mode)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then cb(false, 'Player not found.') return end
    if not trapEnabled then cb(false, 'Trap sales are currently turned off.') return end

    local item = Player.Functions.GetItemByName(Config.RequiredItem)
    if not item or item.amount < 1 then cb(false, 'You need a Trap Phone.') return end

    if mode == 'bulk' then
        if not Config.BulkDelivery.enabled then cb(false, 'Bulk delivery is turned off.') return end
        local bulkData, count = GetBulkSellItems(Player)
        if not bulkData then
            cb(false, 'You need at least ' .. Config.BulkDelivery.minItems .. ' sellable drug items for bulk delivery. Current: ' .. count)
            return
        end
    else
        if not GetSellableDrug(Player) then cb(false, 'You do not have any sellable drug items.') return end
    end

    cb(true)
end)

QBCore.Functions.CreateCallback('moe-drugsale:server:GetTrapStatus', function(_, cb)
    cb({ enabled = trapEnabled, label = trapEnabled and 'READY' or 'DISABLED' })
end)

QBCore.Functions.CreateCallback('moe-drugsale:server:CheckCustomerInterest', function(_, cb, mode)
    if mode == 'bulk' and not Config.BulkDelivery.useInterestChance then
        cb(true, Config.CustomerInterest.interestedMessage)
        return
    end

    if not Config.CustomerInterest.enabled then
        cb(true, Config.CustomerInterest.interestedMessage)
        return
    end

    local roll = math.random(1, 100)
    if roll <= Config.CustomerInterest.buyChance then
        cb(true, Config.CustomerInterest.interestedMessage)
    else
        cb(false, Config.CustomerInterest.notInterestedMessage)
    end
end)

QBCore.Functions.CreateCallback('moe-drugsale:server:GetSellableDrug', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false) return end
    cb(GetSellableDrug(Player))
end)

QBCore.Functions.CreateCallback('moe-drugsale:server:CanBulkSell', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false, 'Player not found.') return end

    local bulkData, count = GetBulkSellItems(Player)
    if not bulkData then
        cb(false, 'You need at least ' .. Config.BulkDelivery.minItems .. ' sellable drug items. Current: ' .. count)
        return
    end

    cb(true)
end)

RegisterNetEvent('moe-drugsale:server:CompleteSale', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not trapEnabled then
        TriggerClientEvent('QBCore:Notify', src, 'Trap sales are currently turned off.', 'error')
        return
    end

    local item = Player.Functions.GetItemByName(itemName)
    if not IsSellableItem(item, 'single') then
        TriggerClientEvent('QBCore:Notify', src, 'That item cannot be sold.', 'error')
        return
    end

    local payout = GetDrugPrice(itemName, false)

    Player.Functions.RemoveItem(itemName, 1)

    if QBCore.Shared.Items[itemName] then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'remove')
    end

    if Config.UseMarkedBills then
        Player.Functions.AddItem(Config.MarkedBillsItem, 1, false, { worth = payout })
        if QBCore.Shared.Items[Config.MarkedBillsItem] then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.MarkedBillsItem], 'add')
        end
        TriggerClientEvent('QBCore:Notify', src, 'You received marked bills worth $' .. payout, 'success')
    else
        Player.Functions.AddMoney(Config.PayAccount, payout, 'drug-sale')
        TriggerClientEvent('QBCore:Notify', src, 'You received $' .. payout .. '.', 'success')
    end
end)

RegisterNetEvent('moe-drugsale:server:CompleteBulkSale', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not trapEnabled then
        TriggerClientEvent('QBCore:Notify', src, 'Trap sales are currently turned off.', 'error')
        return
    end

    local bulkData = GetBulkSellItems(Player)
    if not bulkData then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have enough sellable drug items for bulk delivery.', 'error')
        return
    end

    for _, saleItem in pairs(bulkData.items) do
        Player.Functions.RemoveItem(saleItem.name, saleItem.amount)

        if QBCore.Shared.Items[saleItem.name] then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[saleItem.name], 'remove')
        end
    end

    if Config.UseMarkedBills then
        Player.Functions.AddItem(Config.MarkedBillsItem, 1, false, { worth = bulkData.payout })
        if QBCore.Shared.Items[Config.MarkedBillsItem] then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.MarkedBillsItem], 'add')
        end
        TriggerClientEvent('QBCore:Notify', src, 'Bulk delivery sold ' .. bulkData.count .. ' items for marked bills worth $' .. bulkData.payout, 'success')
    else
        Player.Functions.AddMoney(Config.PayAccount, bulkData.payout, 'bulk-drug-sale')
        TriggerClientEvent('QBCore:Notify', src, 'Bulk delivery sold ' .. bulkData.count .. ' items for $' .. bulkData.payout .. '.', 'success')
    end
end)

QBCore.Commands.Add(Config.OwnerToggleCommand, 'Owner: turn trap sales on or off', {
    { name = 'state', help = 'on/off/status' }
}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)

    if not IsTrapOwner(Player) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not allowed to control trap sales.', 'error')
        return
    end

    local state = args[1] and string.lower(args[1]) or 'status'

    if state == 'on' then
        trapEnabled = true
        TriggerClientEvent('QBCore:Notify', source, 'Trap sales turned ON.', 'success')
    elseif state == 'off' then
        trapEnabled = false
        TriggerClientEvent('QBCore:Notify', source, 'Trap sales turned OFF.', 'error')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Trap sales are currently ' .. (trapEnabled and 'ON' or 'OFF') .. '.', 'primary')
    end
end, 'user')
