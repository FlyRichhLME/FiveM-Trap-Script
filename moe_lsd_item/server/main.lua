local QBCore = exports[Config.CoreName]:GetCoreObject()
local useCooldowns = {}
local sellCooldowns = {}

local function debugPrint(msg)
    if Config.Debug then
        print(('[moe_lsd_item] %s'):format(msg))
    end
end

local function notify(src, msg, msgType)
    TriggerClientEvent('QBCore:Notify', src, msg, msgType or 'primary')
end

local function onCooldown(tbl, src, seconds)
    local now = os.time()
    local last = tbl[src] or 0
    if now - last < seconds then
        return true, seconds - (now - last)
    end
    tbl[src] = now
    return false, 0
end

QBCore.Functions.CreateUseableItem(Config.ItemName, function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coolingDown, remaining = onCooldown(useCooldowns, src, Config.UseCooldownSeconds)
    if coolingDown then
        notify(src, ('Wait %s seconds before using another.'):format(remaining), 'error')
        return
    end

    local itemData = Player.Functions.GetItemByName(Config.ItemName)
    if not itemData or itemData.amount < 1 then
        notify(src, ('You do not have %s.'):format(Config.ItemLabel), 'error')
        return
    end

    if Config.RemoveOnUse then
        local removed = Player.Functions.RemoveItem(Config.ItemName, 1)
        if not removed then
            notify(src, ('Could not use %s.'):format(Config.ItemLabel), 'error')
            return
        end
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ItemName], 'remove', 1)
    end

    TriggerClientEvent('moe_lsd_item:client:useLsd', src)
    debugPrint(('Player %s used %s'):format(src, Config.ItemName))
end)

RegisterNetEvent('moe_lsd_item:server:sellLsd', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coolingDown, remaining = onCooldown(sellCooldowns, src, Config.SellCooldownSeconds)
    if coolingDown then
        notify(src, ('Wait %s seconds before selling again.'):format(remaining), 'error')
        return
    end

    if Config.SellRequiresItem then
        local itemData = Player.Functions.GetItemByName(Config.ItemName)
        if not itemData or itemData.amount < Config.SellRemoveAmount then
            notify(src, ('You need %sx %s to sell.'):format(Config.SellRemoveAmount, Config.ItemLabel), 'error')
            return
        end
        local removed = Player.Functions.RemoveItem(Config.ItemName, Config.SellRemoveAmount)
        if not removed then
            notify(src, 'Sale failed.', 'error')
            return
        end
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ItemName], 'remove', Config.SellRemoveAmount)
    end

    local payout = math.random(Config.SellPriceMin, Config.SellPriceMax)
    Player.Functions.AddMoney(Config.SellMoneyType, payout, 'sold-lsd')
    notify(src, ('Sold %sx %s for $%s.'):format(Config.SellRemoveAmount, Config.ItemLabel, payout), 'success')

    if Config.SellNotifyPolice then
        for _, id in pairs(QBCore.Functions.GetPlayers()) do
            local Officer = QBCore.Functions.GetPlayer(id)
            if Officer and Officer.PlayerData.job and Officer.PlayerData.job.onduty then
                for _, jobName in ipairs(Config.PoliceJobNames) do
                    if Officer.PlayerData.job.name == jobName then
                        TriggerClientEvent('QBCore:Notify', id, 'Suspicious drug activity reported nearby.', 'error')
                    end
                end
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    useCooldowns[src] = nil
    sellCooldowns[src] = nil
end)
