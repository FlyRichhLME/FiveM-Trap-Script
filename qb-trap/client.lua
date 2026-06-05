local QBCore = exports['qb-core']:GetCoreObject()

local trapPed = nil
local activeDeal = false

CreateThread(function()

    RequestModel(Config.TrapPed.model)

    while not HasModelLoaded(Config.TrapPed.model) do
        Wait(0)
    end

    trapPed = CreatePed(
        0,
        Config.TrapPed.model,
        Config.TrapPed.coords.x,
        Config.TrapPed.coords.y,
        Config.TrapPed.coords.z - 1.0,
        Config.TrapPed.coords.w,
        false,
        false
    )

    FreezeEntityPosition(trapPed, true)
    SetEntityInvincible(trapPed, true)
    SetBlockingOfNonTemporaryEvents(trapPed, true)

    exports['qb-target']:AddTargetEntity(trapPed, {
        options = {
            {
                icon = "fas fa-mobile",
                label = "Start Trap Sales",
                action = function()
                    StartTrapRun()
                end
            }
        },
        distance = 2.0
    })

end)

function StartTrapRun()

    if activeDeal then
        QBCore.Functions.Notify("A trap run is already active", "error")
        return
    end

    QBCore.Functions.TriggerCallback('trap:server:HasTrapPhone', function(hasItem)

        if not hasItem then
            QBCore.Functions.Notify("You need a Trap Phone", "error")
            return
        end

        activeDeal = true

        QBCore.Functions.Notify("Customer incoming...", "primary")

        Wait(math.random(6000, 12000))

        SpawnBuyerVehicle()

    end)

end

function SpawnBuyerVehicle()

    local playerCoords = GetEntityCoords(PlayerPedId())

    local spawnCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 40.0, 40.0, 0.0)

    local vehicleModel = Config.VehicleModels[math.random(#Config.VehicleModels)]

    local model = joaat(vehicleModel)

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(0)
    end

    local vehicle = CreateVehicle(model,
        spawnCoords.x,
        spawnCoords.y,
        spawnCoords.z,
        0.0,
        true,
        false
    )

    local pedModel = joaat("g_m_y_mexgoon_02")

    RequestModel(pedModel)

    while not HasModelLoaded(pedModel) do
        Wait(0)
    end

    local buyerPed = CreatePed(0, pedModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false)

    TaskWarpPedIntoVehicle(buyerPed, vehicle, -1)

    TaskVehicleDriveToCoord(
        buyerPed,
        vehicle,
        playerCoords.x,
        playerCoords.y,
        playerCoords.z,
        20.0,
        0,
        model,
        786603,
        5.0
    )

    QBCore.Functions.Notify("Buyer is pulling up...", "success")

    CreateThread(function()

        local completed = false

        while not completed do

            Wait(1000)

            local vehCoords = GetEntityCoords(vehicle)
            local dist = #(playerCoords - vehCoords)

            if dist < 10.0 then

                TaskLeaveVehicle(buyerPed, vehicle, 0)

                Wait(2500)

                TaskGoToCoordAnyMeans(
                    buyerPed,
                    playerCoords.x,
                    playerCoords.y,
                    playerCoords.z,
                    1.0,
                    0,
                    0,
                    786603,
                    0xbf800000
                )

                Wait(3500)

                lib.progressCircle({
                    duration = Config.ProgressTime,
                    label = 'Making Exchange...',
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        move = true,
                        combat = true,
                        car = true
                    },
                    anim = {
                        dict = 'mp_common',
                        clip = 'givetake1_a'
                    }
                })

                TriggerServerEvent('trap:server:CompleteSale')

                TaskEnterVehicle(
                    buyerPed,
                    vehicle,
                    -1,
                    -1,
                    1.0,
                    1,
                    0
                )

                Wait(3000)

                TaskVehicleDriveWander(buyerPed, vehicle, 30.0, 786603)

                completed = true

                activeDeal = false

                SetTimeout(15000, function()
                    DeleteEntity(buyerPed)
                    DeleteEntity(vehicle)
                end)

            end

        end

    end)

end
