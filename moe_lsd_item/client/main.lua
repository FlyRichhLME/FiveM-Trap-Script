local QBCore = exports[Config.CoreName]:GetCoreObject()
local staminaActive = false
local lastSellAttempt = 0

local function notify(msg, msgType)
    QBCore.Functions.Notify(msg, msgType or 'primary')
end

local function requestClipset(clipset)
    RequestAnimSet(clipset)
    local timeout = GetGameTimer() + 3000
    while not HasAnimSetLoaded(clipset) and GetGameTimer() < timeout do
        Wait(10)
    end
    return HasAnimSetLoaded(clipset)
end

RegisterNetEvent('moe_lsd_item:client:useLsd', function()
    local ped = PlayerPedId()

    QBCore.Functions.Progressbar('moe_use_lsd', Config.ProgressLabel, Config.ProgressTime, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'mp_suicide',
        anim = 'pill',
        flags = 49,
    }, {}, {}, function()
        ClearPedTasks(ped)

        if Config.SetHealthMax then
            SetEntityMaxHealth(ped, Config.MaxHealth)
        end

        if Config.SetHealth then
            SetEntityHealth(ped, Config.HealthAmount)
        end

        if Config.SetArmor then
            SetPedArmour(ped, Config.ArmorAmount)
        end

        if Config.EnableVisualEffect then
            StartScreenEffect(Config.VisualEffectName, Config.VisualEffectDurationSeconds * 1000, false)
        end

        if Config.EnableMovementClipset and requestClipset(Config.MovementClipset) then
            SetPedMovementClipset(ped, Config.MovementClipset, 0.25)
            SetTimeout(Config.VisualEffectDurationSeconds * 1000, function()
                ResetPedMovementClipset(PlayerPedId(), 0.25)
            end)
        end

        if Config.StaminaBoost and not staminaActive then
            staminaActive = true
            local endTime = GetGameTimer() + (Config.StaminaDurationSeconds * 1000)
            CreateThread(function()
                notify(('Stamina boosted for %s seconds.'):format(Config.StaminaDurationSeconds), 'success')
                while GetGameTimer() < endTime do
                    if Config.RestoreSprintStaminaEachTick then
                        RestorePlayerStamina(PlayerId(), 1.0)
                    end
                    Wait(Config.StaminaTickMs)
                end
                staminaActive = false
                notify('Stamina boost ended.', 'primary')
            end)
        end

        notify(('Used %s.'):format(Config.ItemLabel), 'success')
    end, function()
        ClearPedTasks(ped)
        notify('Cancelled.', 'error')
    end)
end)

local function hasNearbyBuyer()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closestPed = nil
    local closestDist = 3.0

    local handle, foundPed = FindFirstPed()
    local success = true
    repeat
        if foundPed ~= ped and not IsPedAPlayer(foundPed) and not IsPedDeadOrDying(foundPed, true) then
            local dist = #(coords - GetEntityCoords(foundPed))
            if dist < closestDist then
                closestDist = dist
                closestPed = foundPed
            end
        end
        success, foundPed = FindNextPed(handle)
    until not success
    EndFindPed(handle)

    return closestPed ~= nil, closestPed
end

if Config.AllowSellCommand then
    RegisterCommand(Config.SellCommand, function()
        local now = GetGameTimer()
        if now - lastSellAttempt < Config.SellCooldownSeconds * 1000 then
            notify('Slow down before selling again.', 'error')
            return
        end
        lastSellAttempt = now

        local foundBuyer, buyerPed = hasNearbyBuyer()
        if not foundBuyer then
            notify('No buyer nearby. Stand close to an NPC and try again.', 'error')
            return
        end

        TaskTurnPedToFaceEntity(buyerPed, PlayerPedId(), 1000)
        Wait(700)
        TriggerServerEvent('moe_lsd_item:server:sellLsd')
    end, false)
end
