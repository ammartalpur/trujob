local function DebugPrint(msg)
  if Config.Debug then print("^3[Trucker-Client]^7 " .. tostring(msg)) end
end

-- =========================
-- DEALER PED + UI OPEN
-- =========================
CreateThread(function()
  local pedConfig = Config.Peds.Dealer
  RequestModel(pedConfig.model)
  while not HasModelLoaded(pedConfig.model) do Wait(10) end

  local dealerPed = CreatePed(4, pedConfig.model,
    pedConfig.coords.x,
    pedConfig.coords.y,
    pedConfig.coords.z - 1.0,
    pedConfig.coords.w,
    false,
    false
  )

  SetEntityAsMissionEntity(dealerPed, true, true)
  SetBlockingOfNonTemporaryEvents(dealerPed, true)
  FreezeEntityPosition(dealerPed, true)
  SetEntityInvincible(dealerPed, true)

  exports.ox_target:addLocalEntity(dealerPed, {
    {
      name = 'truck_dealer_menu',
      label = 'Talk to Dealer',
      icon = 'fas fa-truck-moving',
      onSelect = function()
        -- Get owned trucks
        TriggerServerEvent('trucker:server:getMyTrucks')

        -- Open UI
        SendNUIMessage({ action = 'setVisible', data = true })
        SendNUIMessage({ action = 'OPEN_DEALER', data = Config.Trucks })

        SetNuiFocus(true, true)
      end
    }
  })
end)

-- =========================
-- RECEIVE OWNED TRUCKS (UI)
-- =========================
RegisterNetEvent("trucker:client:receiveMyTrucks", function(trucklist)
  SendNUIMessage({
    action = 'UPDATE_OWNED',
    data = trucklist
  })
end)

-- =========================
-- BUY TRUCK (UI → SERVER)
-- =========================
RegisterNUICallback("buyTruck", function(data, cb)
  TriggerServerEvent("trucker:server:purchaseTruck", data)
  cb("ok")
end)

-- =========================
-- SPAWN OWNED TRUCK (UI)
-- =========================
RegisterNUICallback('spawnOwnedTruck', function(data, cb)
  TriggerServerEvent('trucker:server:spawnFromGarage', data.plate)
  cb('ok')
end)

-- =========================
-- ENTER TRUCK AFTER SPAWN
-- =========================
RegisterNetEvent('trucker:client:enterTruck', function(netId, plate)
  local tries = 0

  -- Wait until vehicle exists properly
  while not NetworkDoesNetworkIdExist(netId) do
    Wait(50)
    tries += 1
    if tries > 100 then return end
  end

  local vehicle = NetToVeh(netId)

  while not DoesEntityExist(vehicle) do
    Wait(50)
  end

  local ped = PlayerPedId()

  -- Warp player
  TaskWarpPedIntoVehicle(ped, vehicle, -1)

  -- Ensure control
  NetworkRequestControlOfEntity(vehicle)

  -- Start engine
  SetVehicleEngineOn(vehicle, true, true, false)

  -- Unlock vehicle
  SetVehicleDoorsLocked(vehicle, 1)

  -- Optional: smooth entry feeling
  SetPedIntoVehicle(ped, vehicle, -1)

  -- Notify
  exports.qbx_core:Notify("Truck ready & keys received!", "success")
end)

RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
  local ped = PlayerPedId()
  local vehicle = GetVehiclePedIsIn(ped, false)

  if vehicle ~= 0 then
    SetVehicleDoorsLocked(vehicle, 1)
    SetVehicleEngineOn(vehicle, true, true, false)

    -- Optional: mark as owned locally
    LocalPlayer.state:set('ownedVehicle', plate, true)
  end
end)

-- =========================
-- CLOSE UI
-- =========================
RegisterNUICallback("hideFrame", function(data, cb)
  SetNuiFocus(false, false)
  cb("ok")
end)

-- =========================
-- DELETE VEHICLE COMMAND
-- =========================
RegisterCommand('dvi', function()
  local ped = PlayerPedId()
  local vehicle

  if IsPedInAnyVehicle(ped, false) then
    vehicle = GetVehiclePedIsIn(ped, false)
  else
    local coords = GetEntityCoords(ped)
    vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
  end

  if DoesEntityExist(vehicle) then
    NetworkRequestControlOfEntity(vehicle)

    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)

    if DoesEntityExist(vehicle) then
      DeleteEntity(vehicle)
    end

    exports.qbx_core:Notify("Vehicle deleted", "success")
  else
    exports.qbx_core:Notify("No vehicle nearby", "error")
  end
end, false)
