local QBCore = exports['qb-core']:GetCoreObject()

local trapActive = false
local saleBusy = false
local currentCustomer = nil
local phoneOpen = false
local currentMode = 'single'

local function Notify(msg, msgType)
    QBCore.Functions.Notify(msg, msgType or 'primary')
end

local function LoadModel(model)
    local hash = joaat(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    return hash
end

local function CleanupCustomer(ped)
    if DoesEntityExist(ped) then
        ClearPedTasks(ped)
        SetPedAsNoLongerNeeded(ped)
        DeleteEntity(ped)
    end
end

local function ResetTrapState()
    currentCustomer = nil
    saleBusy = false
    trapActive = false
    currentMode = 'single'
end

local function CloseTrapPhone()
    phoneOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function OpenTrapPhone()
    if phoneOpen then return end

    QBCore.Functions.TriggerCallback('moe-drugsale:server:CanOpenPhone', function(canOpen, reason, status)
        if not canOpen then
            Notify(reason or 'You cannot use the trap phone.', 'error')
            return
        end

        phoneOpen = true
        SetNuiFocus(true, true)

        SendNUIMessage({
            action = 'open',
            status = status or 'READY',
            command = '/' .. Config.Command,
            bulkEnabled = Config.BulkDelivery.enabled
        })
    end)
end

local function CustomerLeave(customerPed, playerVeh)
    TaskLeaveVehicle(customerPed, playerVeh, 0)
    Wait(3500)
    TaskWanderStandard(customerPed, 10.0, 10)
    SetPedAsNoLongerNeeded(customerPed)
end

local function StartDeal(customerPed, playerVeh)
    if saleBusy then return end
    saleBusy = true

    TaskEnterVehicle(customerPed, playerVeh, 10000, 0, 1.0, 1, 0)

    local timeout = GetGameTimer() + 12000
    while GetGameTimer() < timeout do
        Wait(500)
        if IsPedInVehicle(customerPed, playerVeh, false) then break end
    end

    if not IsPedInVehicle(customerPed, playerVeh, false) then
        Notify('Customer could not get in the passenger seat.', 'error')
        CleanupCustomer(customerPed)
        ResetTrapState()
        return
    end

    QBCore.Functions.TriggerCallback('moe-drugsale:server:CheckCustomerInterest', function(isInterested, message)
        if not isInterested then
            Notify(message or Config.CustomerInterest.notInterestedMessage, 'error')
            CustomerLeave(customerPed, playerVeh)
            currentCustomer = nil
            saleBusy = false
            Wait(Config.SaleCooldown)
            trapActive = false
            currentMode = 'single'
            Notify('Trap phone is ready again.', 'primary')
            return
        end

        Notify(message or Config.CustomerInterest.interestedMessage, 'success')

        if currentMode == 'bulk' then
            QBCore.Functions.TriggerCallback('moe-drugsale:server:CanBulkSell', function(canBulk, reason)
                if not canBulk then
                    Notify(reason or 'You do not have enough product for bulk delivery.', 'error')
                    CustomerLeave(customerPed, playerVeh)
                    ResetTrapState()
                    return
                end

                local success = lib.progressCircle({
                    duration = Config.BulkDelivery.progressTime,
                    label = Config.BulkDelivery.progressLabel,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = false, car = true, combat = true },
                    anim = { dict = 'mp_common', clip = 'givetake1_a' }
                })

                if success then
                    TriggerServerEvent('moe-drugsale:server:CompleteBulkSale')
                    Notify('Bulk delivery completed. Double payout received.', 'success')
                else
                    Notify('Bulk delivery cancelled.', 'error')
                end

                CustomerLeave(customerPed, playerVeh)
                currentCustomer = nil
                saleBusy = false
                Wait(Config.BulkDelivery.cooldown)
                trapActive = false
                currentMode = 'single'
                Notify('Trap phone is ready again.', 'primary')
            end)
            return
        end

        QBCore.Functions.TriggerCallback('moe-drugsale:server:GetSellableDrug', function(drugData)
            if not drugData then
                Notify('You do not have any sellable drug items.', 'error')
                CustomerLeave(customerPed, playerVeh)
                ResetTrapState()
                return
            end

            local success = lib.progressCircle({
                duration = Config.ProgressTime,
                label = Config.ProgressLabel .. ' ' .. drugData.label,
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disable = { move = false, car = true, combat = true },
                anim = { dict = 'mp_common', clip = 'givetake1_a' }
            })

            if success then
                TriggerServerEvent('moe-drugsale:server:CompleteSale', drugData.item)
                Notify('Customer paid and is getting out.', 'success')
            else
                Notify('Trap sale cancelled.', 'error')
            end

            CustomerLeave(customerPed, playerVeh)
            currentCustomer = nil
            saleBusy = false
            Wait(Config.SaleCooldown)
            trapActive = false
            currentMode = 'single'
            Notify('Trap phone is ready again.', 'primary')
        end)
    end, currentMode)
end

local function SpawnCustomer()
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed, false)

    if playerVeh == 0 then Notify('You need to be inside your vehicle.', 'error') ResetTrapState() return end
    if Config.DriverOnly and GetPedInVehicleSeat(playerVeh, -1) ~= playerPed then Notify('You must be the driver.', 'error') ResetTrapState() return end
    if Config.RequirePassengerSeatOpen and GetPedInVehicleSeat(playerVeh, 0) ~= 0 then Notify('Passenger seat must be empty.', 'error') ResetTrapState() return end

    local coords = GetEntityCoords(playerPed)
    local angle = math.random() * math.pi * 2
    local spawn = vector3(coords.x + math.cos(angle) * Config.SpawnDistance, coords.y + math.sin(angle) * Config.SpawnDistance, coords.z)

    local foundGround, groundZ = GetGroundZFor_3dCoord(spawn.x, spawn.y, spawn.z + 50.0, false)
    if foundGround then spawn = vector3(spawn.x, spawn.y, groundZ) end

    local model = Config.CustomerPeds[math.random(#Config.CustomerPeds)]
    local hash = LoadModel(model)
    local customerPed = CreatePed(4, hash, spawn.x, spawn.y, spawn.z, 0.0, true, true)
    currentCustomer = customerPed

    SetEntityAsMissionEntity(customerPed, true, true)
    SetBlockingOfNonTemporaryEvents(customerPed, true)
    SetPedCanRagdoll(customerPed, false)
    SetPedFleeAttributes(customerPed, 0, false)
    SetPedCombatAttributes(customerPed, 17, true)

    Notify(currentMode == 'bulk' and 'Bulk buyer is walking to your passenger door.' or 'Customer is walking to your passenger door.', 'success')
    TaskGoToEntity(customerPed, playerVeh, -1, Config.EnterDistance, 2.0, 1073741824, 0)

    CreateThread(function()
        local timeout = GetGameTimer() + Config.CustomerTimeout
        while trapActive and currentCustomer == customerPed and DoesEntityExist(customerPed) do
            Wait(750)
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)

            if veh == 0 then Notify('Trap sale cancelled because you left the vehicle.', 'error') CleanupCustomer(customerPed) ResetTrapState() return end
            if Config.RequirePassengerSeatOpen and GetPedInVehicleSeat(veh, 0) ~= 0 then Notify('Trap sale cancelled because passenger seat is occupied.', 'error') CleanupCustomer(customerPed) ResetTrapState() return end

            local dist = #(GetEntityCoords(customerPed) - GetEntityCoords(veh))
            if dist <= Config.EnterDistance then StartDeal(customerPed, veh) return end

            if GetGameTimer() > timeout then
                Notify('Customer could not find you.', 'error')
                CleanupCustomer(customerPed)
                ResetTrapState()
                return
            end
        end
    end)
end

local function StartTrap(mode)
    if phoneOpen then CloseTrapPhone() end
    if trapActive or saleBusy then Notify('Trap sale already active.', 'error') return end

    currentMode = mode or 'single'

    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed, false)

    if playerVeh == 0 then Notify('Get in a vehicle first.', 'error') ResetTrapState() return end
    if Config.DriverOnly and GetPedInVehicleSeat(playerVeh, -1) ~= playerPed then Notify('You must be the driver.', 'error') ResetTrapState() return end
    if Config.RequirePassengerSeatOpen and GetPedInVehicleSeat(playerVeh, 0) ~= 0 then Notify('Passenger seat must be empty.', 'error') ResetTrapState() return end

    QBCore.Functions.TriggerCallback('moe-drugsale:server:CanStartTrap', function(canStart, reason)
        if not canStart then
            Notify(reason or 'You cannot start trap sales.', 'error')
            ResetTrapState()
            return
        end

        trapActive = true
        Notify(currentMode == 'bulk' and 'Bulk delivery request sent. Buyer incoming...' or 'Trap phone active. Customer incoming...', 'primary')

        Wait(math.random(Config.CustomerDelay.min, Config.CustomerDelay.max))
        SpawnCustomer()
    end, currentMode)
end

RegisterCommand(Config.Command, function()
    if Config.UsePhoneUI then OpenTrapPhone() else StartTrap('single') end
end, false)

RegisterNetEvent('moe-drugsale:client:UseTrapPhone', function()
    OpenTrapPhone()
end)

RegisterNUICallback('closePhone', function(_, cb)
    CloseTrapPhone()
    cb('ok')
end)

RegisterNUICallback('callCustomer', function(_, cb)
    StartTrap('single')
    cb('ok')
end)

RegisterNUICallback('bulkDelivery', function(_, cb)
    StartTrap('bulk')
    cb('ok')
end)

RegisterNUICallback('checkStatus', function(_, cb)
    QBCore.Functions.TriggerCallback('moe-drugsale:server:GetTrapStatus', function(status)
        cb(status)
    end)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    if currentCustomer and DoesEntityExist(currentCustomer) then DeleteEntity(currentCustomer) end
end)
