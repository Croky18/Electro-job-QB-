local QBCore = exports['qb-core']:GetCoreObject()
local isWorking = false
local currentStep = 0
local spawnedVehicle = nil
local currentBlip = nil
local hasNotified = false

CreateThread(function()
    local model = GetHashKey(Config.NPC.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(0, model, Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z - 1, Config.NPC.heading, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    local blip = AddBlipForCoord(Config.NPC.coords)
    SetBlipSprite(blip, 761)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Electro Job")
    EndTextCommandSetBlipName(blip)

    local npcCoords = vector3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)

    CreateThread(function()
        while true do
            Wait(0)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - npcCoords)

            if distance < 2.0 then
                DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, "[E] Open Menu")
                if IsControlJustReleased(0, 38) then
                    lib.registerContext({
                        id = 'electro_job_menu',
                        title = 'Electro Job',
                        options = {
                            {
                                title = 'Start Elektriciteitsklus',
                                description = 'Start Electro job',
                                icon = 'truck',
                                onSelect = function()
                                    TriggerEvent('electrojob:start')
                                end
                            },
                            {
                                title = 'Stop Elektriciteitsklus',
                                description = 'Stop Electro job',
                                icon = 'xmark',
                                disabled = not isWorking,
                                onSelect = function()
                                    TriggerEvent('electrojob:stop')
                                end
                            }
                        }
                    })
                    lib.showContext('electro_job_menu')
                end
            end
        end
    end)
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

RegisterNetEvent("electrojob:start", function()
    if isWorking then 
        return QBCore.Functions.Notify("You're already working!", "error") 
    end

    local player = QBCore.Functions.GetPlayerData()
    if player.job.name ~= Config.RequiredJob then
        return QBCore.Functions.Notify("No access to this job.", "error")
    end

    QBCore.Functions.Notify("Vehicle is spawning...", "success")

    local vehicleModel = GetHashKey(Config.Vehicle.model)
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Wait(500)
    end

    spawnedVehicle = CreateVehicle(vehicleModel, Config.Vehicle.spawnPoint.x, Config.Vehicle.spawnPoint.y, Config.Vehicle.spawnPoint.z, Config.Vehicle.spawnPoint.w, true, false)
    SetVehicleOnGroundProperly(spawnedVehicle)
    SetEntityAsMissionEntity(spawnedVehicle, true, true)

    if not DoesEntityExist(spawnedVehicle) then
        QBCore.Functions.Notify("There is a problem with the vehicle.", "error")
        return
    end

    isWorking = true
    currentStep = 1
    GoToNextLocation()
end)

function GoToNextLocation()
    if currentBlip then RemoveBlip(currentBlip) end
    if currentStep > #Config.Locations then
        QBCore.Functions.Notify("Bring the vehicle back", "primary")
        SetGpsBlipForReturn()
        return
    end

    local coords = Config.Locations[currentStep]
    currentBlip = AddBlipForCoord(coords)
    SetBlipRoute(currentBlip, true)

    CreateThread(function()
        while isWorking do
            Wait(0)
            local playerCoords = GetEntityCoords(PlayerPedId())
            if #(playerCoords - coords) < 2.0 then
                if not hasNotified then
                    QBCore.Functions.Notify("Press E to start washing zekerings!", "success")
                    hasNotified = true 
                end

                if IsControlJustPressed(0, 38) then
                    TaskStartScenarioInPlace(PlayerPedId(), "world_human_welding", 0, true)
                    local success = StartProgress(9000, "Busy with electrical restoration......")

                    ClearPedTasks(PlayerPedId())
                    if success then
                        local randomReward = math.random(Config.RewardPerWindow.min, Config.RewardPerWindow.max)  -- Willekeurig bedrag tussen min en max
                        TriggerServerEvent("electrojob:addMoney", randomReward)
                        QBCore.Functions.Notify("You have $" .. randomReward .. " earned for repair performed.", "success")
                    
                        currentStep = currentStep + 1
                    
                        GoToNextLocation()
                    end
                    break
                end
            else
                if hasNotified then
                    hasNotified = false
                end
            end
        end
    end)
end

function SetGpsBlipForReturn()
    if not Config.VehicleReturn or not Config.VehicleReturn.x or not Config.VehicleReturn.y or not Config.VehicleReturn.z then
        print("Error: VehicleReturn coordinates are not set in the Config.")
        return
    end

    currentBlip = AddBlipForCoord(Config.VehicleReturn.x, Config.VehicleReturn.y, Config.VehicleReturn.z)
    SetBlipRoute(currentBlip, true)

    CreateThread(function()
        while true do
            Wait(500)

            local playerCoords = GetEntityCoords(PlayerPedId())
            local distanceToReturn = #(playerCoords - vector3(Config.VehicleReturn.x, Config.VehicleReturn.y, Config.VehicleReturn.z))

            -- If the player reaches the return location
            if distanceToReturn < 2.0 then
                QBCore.Functions.Notify("Return to the NPC to stop the job.", "success")
                RemoveBlip(currentBlip)
                break
            end
        end
    end)
end

function StartProgress(duration, label)
    if Config.Progressbar == 'qs' then
        local result = exports['qs-interface']:ProgressBar({
            duration = duration,
            label = label,
            position = 'bottom',
            canCancel = false
        })
        return result
    else
        local finished = exports['qb-progressbar']:Progress({
            name = "electro_job",
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }
        })
        return finished
    end
end

RegisterNetEvent("electrojob:stop", function()
    if not isWorking then return QBCore.Functions.Notify("You are not working.", "error") end

    if DoesEntityExist(spawnedVehicle) then
        DeleteVehicle(spawnedVehicle)
    end

    isWorking = false
    currentStep = 0
    if currentBlip then RemoveBlip(currentBlip) end
    QBCore.Functions.Notify("End of job.", "primary")
end)