local function DebugPrint(msg)
  if Config.Debug then print("^3[Trucker-Logictics-Client]^7 " .. tostring(msg)) end
end


local curretMission = {}

function startMission(route)
  if not route then
    DebugPrint("function:startMission error occured")
    return
  end

    currentMission = route
  -- ✅ REGISTER MISSION ON SERVER
  TriggerServerEvent('trucker:server:startMission', route.id)
  DebugPrint("Mission started (sent to server): " .. route.id)
  exports.qbx_core:Notify("Contract Accepted: Drive to the pickup point.", "success")

  local pickupBlip = AddBlipForCoord(route.pickup.x, route.pickup.y, route.pickup.z)
  SetBlipSprite(pickupBlip, 479)   -- Trailer icon
  SetBlipColour(pickupBlip, 5)     -- Yellow
  SetBlipRoute(pickupBlip, true)   -- Draw line on GPS

  CreateThread(function()
    local trailerSpawned = false
    local trailerEntity = nil

    while currentMission do
      local sleep = 1000
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local dist = #(pos - vec3(route.pickup.x, route.pickup.y, route.pickup.z))

      if dist > 50.0 and not trailerSpawned then
        TriggerServerEvent('trucker:server:spawnTrailer', route.id)
        trailerSpawned = true
        sleep = 2000
      end

      local veh = GetVehiclePedIsIn(ped, false)
      if veh ~= 0 then
        local attached, trailer = GetVehicleTrailerVehicle(veh)
        if attached then
          RemoveBlip(pickupBlip)
          createDropOffStage(route)
          break
        end
      end
      Wait(sleep)
    end
  end)
end

CreateThread(function()
    local model = Config.Peds.Logistics.model

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

  local ped = CreatePed(4, model, Config.Peds.Logistics.coords.x, Config.Peds.Logistics.coords.y,
        Config.Peds.Logistics.coords.z, Config.Peds.Logistics.coords.w, false, false)
    
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
  SetEntityInvincible(ped , true)

  exports.ox_target:addLocalEntity(ped, {
    {
      name = 'trucker_logistics',
      label = 'Talk to Logistics Manager',
      icon = 'fas fa-clipboard-list',
      onSelect = function()
        OpenMissionMenu()
      end
    }
    })
  
  end)


function OpenMissionMenu()

    if not curretMission then
        exports.qbx_core:Notify("you already have an active contract", "error")
        return
    end
      
  local playerVeh = GetVehiclePedIsIn(PlayerPedId(), false)
  if playerVeh == 0 then
    exports.qbx_core:Notify("Bring your truck here to receive a contract.", "error")
    return
  end

    local options = {}
    for _, route in ipairs(Config.Routes) do
        table.insert(options, {
            title = route.label,
            description = "Cargo: " .. route.cargo .. " | Pay: $" .. route.payout,
            icon = 'truck',
            onSelect = function()
        startMission(route)
            end
        })
    end

    lib.registerContext({
        id = 'trucker_mission_menu',
        title = 'Available Logistics Contracts',
        options = options
    })
    lib.showContext('trucker_mission_menu')
    
end 

function createDropOffStage(route)
  DebugPrint("createDropOffStage function running")
  if not route then 
    DebugPrint("function:createDropOffStage error occured") 
    return  
  end
  
  local deliveryBlip = AddBlipForCoord(route.dropoff.x, route.dropoff.y, route.dropoff.z)
    SetBlipSprite(deliveryBlip, 615) -- Delivery icon
    SetBlipColour(deliveryBlip, 2)   -- Green
    SetBlipRoute(deliveryBlip, true) -- GPS path to destination

  CreateThread(function ()
    while currentMission do 
      local sleep = 1000
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)

      local destPos = vec3(route.dropoff.x , route.dropoff.y , route.dropoff.z)
      local dist = #(pos - destPos)
 
      if dist < 20.0 then
        sleep = 0
        DebugPrint("Inside 20 range")

        DrawMarker(1, destPos.x, destPos.y, destPos.z + 1.0,
          0, 0, 0, 0, 0, 0,
          3.5, 3.5, 1.0,
          50, 200, 50, 100,
          false, false, 2, false, nil, nil, false)

        if dist < 5.0 then
          DebugPrint("Inside 5 range")

          local veh = GetVehiclePedIsIn(ped, false)
          local attached, trailer = GetVehicleTrailerVehicle(veh)
                    DebugPrint(veh)
              DebugPrint(attached)
          if attached then
            local trailerPos = GetEntityCoords(trailer)
            local trailerDist = #(trailerPos - destPos)

            if trailerDist < 10.0 then
              DebugPrint("Trailer in zone")
              RemoveBlip(deliveryBlip)
              FinishMission(route)
              break
            end
          else
            BeginTextCommandDisplayHelp("STRING")
            AddTextComponentSubstringPlayerName("Park here and ~INPUT_VEH_DETACH_TRAILER~ to complete.")
            EndTextCommandDisplayHelp(0, 0, 1, -1)
          end
        end
      end
      Wait(sleep)
    end
  end)
end

function FinishMission(route)
  DebugPrint("FinishMission function running")

  if not route then
    DebugPrint("function:FinishMission error occured")
    return
  end

  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  if veh == 0 then
    DebugPrint("Player not in vehicle")
    return
  end

  -- ✅ GET ATTACHED TRAILER DIRECTLY
  local attached, trailer = GetVehicleTrailerVehicle(veh)

  if attached and DoesEntityExist(trailer) then
    local networkId = NetworkGetNetworkIdFromEntity(trailer)

    DebugPrint("Trailer found & attached")
    DebugPrint("Trailer NetID: " .. tostring(networkId))

    TriggerServerEvent('trucker:server:completeContract', route.id, networkId)

    currentMission = nil
    exports.qbx_core:Notify("Delivery successful! Processing payment...", "success")
  else
    DebugPrint("❌ No trailer attached at finish")

    exports.qbx_core:Notify("No trailer attached to truck!", "error")
  end
end



RegisterCommand('canceljob', function()
  if currentMission then
    currentMission = nil
    -- Clean up any leftover blips if they exist
    if pickupBlip then RemoveBlip(pickupBlip) end
    if deliveryBlip then RemoveBlip(deliveryBlip) end

    exports.qbx_core:Notify("Active contract has been force-cancelled.", "warning")
  else
    exports.qbx_core:Notify("You don't have an active contract to cancel.", "error")
  end
end, false)
