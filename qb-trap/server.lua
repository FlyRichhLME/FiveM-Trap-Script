local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('trap:server:HasTrapPhone', function(source, cb)

    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        cb(false)
        return
    end

    local item = Player.Functions.GetItemByName(Config.RequireItem)

    if item then
        cb(true)
    else
        cb(false)
    end

end)

RegisterNetEvent('trap:server:CompleteSale', function()

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local foundDrug = nil

    for _, drug in pairs(Config.Drugs) do

        local item = Player.Functions.GetItemByName(drug)

        if item and item.amount > 0 then
            foundDrug = drug
            break
        end

    end

    if not foundDrug then

        TriggerClientEvent('QBCore:Notify',
            src,
            'You have no drugs to sell',
            'error'
        )

        return
    end

    local payout = math.random(
        Config.Payment.min,
        Config.Payment.max
    )

    Player.Functions.RemoveItem(foundDrug, 1)

    Player.Functions.AddMoney('cash', payout)

    TriggerClientEvent('inventory:client:ItemBox',
        src,
        QBCore.Shared.Items[foundDrug],
        "remove"
    )

    TriggerClientEvent('QBCore:Notify',
        src,
        'Sale completed for $' .. payout,
        'success'
    )

end)
