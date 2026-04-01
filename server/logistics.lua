local function DebugPrint(msg)
  if Config.Debug then print("^3[Trucker-Logictics-Server]^7 " .. tostring(msg)) end
end


local ActiveTrailers = {}
local ActiveMissions = {}


RegisterNetEvent("trucker:server:spawnTrailer", function(routeId)
  local src = source

  if ActiveTrailers[src] then
    DebugPrint("Spawn blocked (already has trailer)")
    return
  end

  local route
  for _, r in ipairs(Config.Routes) do
    if r.id == routeId then
      route = r
      break
    end
  end

  if not route then return end

  local trailer = CreateVehicleServerSetter(
    route.trailerModel,
    "trailer",
    route.pickup.x,
    route.pickup.y,
    route.pickup.z,
    route.pickup.w
  )

  local timeout = 0
  while not DoesEntityExist(trailer) and timeout < 50 do
    Wait(50)
    timeout += 1
  end

  if DoesEntityExist(trailer) then
    Entity(trailer).state:set('associated_player', src, true)
    Entity(trailer).state:set('cargo_integrity', 100, true)

    ActiveTrailers[src] = trailer

    local netId = NetworkGetNetworkIdFromEntity(trailer)
    TriggerClientEvent('trucker:client:setTrailer', src, netId)

    DebugPrint("Trailer spawned for player " .. src)
  end
end)


RegisterNetEvent('trucker:server:startMission', function(routeId)
  local src = source

  if ActiveMissions[src] then
    DebugPrint("Mission blocked (already active)")
    return
  end

  ActiveMissions[src] = {
    routeId = routeId,
    startTime = os.time()
  }
end)


RegisterNetEvent('trucker:server:completeContract', function(routeId, trailerNetId)
  local src = source
  local player = exports.qbx_core:GetPlayer(src)


  DebugPrint("Player: " .. src)
  DebugPrint("RouteId: " .. tostring(routeId))
  DebugPrint("TrailerNetId: " .. tostring(trailerNetId))

  if not player then
    DebugPrint("Player not found")
    return
  end

  local mission = ActiveMissions[src]

  -- ❗ MAIN ERROR SOURCE
  if not mission then
    DebugPrint(" No active mission found for player")
    print("^1[Security]^7 Invalid mission completion attempt by " .. src)
    return
  end

  if mission.routeId ~= routeId then
 
    DebugPrint("Expected: " .. tostring(mission.routeId))
    DebugPrint("Got: " .. tostring(routeId))
    return
  end

  DebugPrint(" Mission validated")

  local route
  for _, r in ipairs(Config.Routes) do
    if r.id == routeId then
      route = r
      break
    end
  end

  if not route then
    DebugPrint(" Route not found in config")
    return
  end


  local duration = os.time() - mission.startTime
  DebugPrint("Mission duration: " .. duration)

  if duration < 10 then
    print("^1[AntiCheat]^7 Player " .. src .. " finished too fast!")
    return
  end


  local ped = GetPlayerPed(src)
  local pos = GetEntityCoords(ped)
  local dist = #(pos - vec3(route.dropoff.x, route.dropoff.y, route.dropoff.z))

  DebugPrint("Distance from dropoff: " .. dist)

  if dist > 25.0 then
    print("^1[Security]^7 Player " .. src .. " too far from dropoff!")
    return
  end


  if trailerNetId then
    local trailer = NetworkGetEntityFromNetworkId(trailerNetId)

    if DoesEntityExist(trailer) then
      local owner = Entity(trailer).state.associated_player

      DebugPrint("Trailer owner: " .. tostring(owner))

      if owner ~= src then
        print("^1[Security]^7 Trailer ownership mismatch!")
        return
      end

      DeleteEntity(trailer)
      DebugPrint("Trailer deleted")
    else
      DebugPrint("Trailer entity does not exist")
    end
  else
    DebugPrint("No trailerNetId received")
  end

 
  local payout = route.payout
  player.Functions.AddMoney('bank', payout, "trucker-job")

  Bridge.Notify.SendNotification(src, "Truck Job", "Received $" .. payout .. " for delivery.", "success")


  ActiveMissions[src] = nil
  ActiveTrailers[src] = nil

  DebugPrint("✅ Mission completed successfully")
  DebugPrint("-----------------------------------")
end)


AddEventHandler('playerDropped', function()
  local src = source

  if ActiveTrailers[src] then
    local trailer = ActiveTrailers[src]
    if DoesEntityExist(trailer) then
      DeleteEntity(trailer)
    end
  end

  ActiveTrailers[src] = nil
  ActiveMissions[src] = nil
end)
