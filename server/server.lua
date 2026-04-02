local Bridge = exports['community_bridge']:Bridge()

local function DebugPrint(msg)
  if Config.Debug then print("^3[Trucker-Server]^7 " .. tostring(msg)) end
end


local function GeneratePlate()
  return "TRK" .. math.random(100, 999) .. string.upper(string.char(math.random(65, 90)))
end

local SpawnLocks = {}


RegisterNetEvent('trucker:server:getMyTrucks', function()
  local src = source
  local player = Bridge.Framework.GetPlayer(src)

  if not player then return end

  exports.oxmysql:query('SELECT * FROM player_trucks WHERE citizenid = ?', {
    player.PlayerData.citizenid
  }, function(result)
    TriggerClientEvent('trucker:client:receiveMyTrucks', src, result or {})
  end)
end)


RegisterNetEvent("trucker:server:purchaseTruck", function(truckData)
  local src = source
  local player = Bridge.Framework.GetPlayer(src)

  if not player then return end

  local price = truckData.price
  local model = truckData.model
    local label = truckData.label
  
  local balance = Bridge.Framework.GetAccountBalance(src, 'bank')
  if balance < price then
    Bridge.Notify.SendNotification(src, "Truck Job", "You cannot afford this truck.", "error")
    return
  end

  local plate = GeneratePlate()

  local success = Bridge.Framework.RemoveAccountBalance(src, 'cash', price)
  if not success then return end


  exports.oxmysql:insert([[
        INSERT INTO player_trucks (citizenid, model, plate, label)
        VALUES (?, ?, ?, ?)
    ]], {
    player.PlayerData.citizenid,
    model,
    plate,
    label
  }, function(id)
    if id then
      DebugPrint("Truck saved with ID: " .. id)


      TriggerClientEvent('trucker:client:receiveMyTrucks', src, {})

    
      TriggerEvent('trucker:server:spawnOwnedTruck', src, model, plate)
    end
  end)
end)


local ActiveSpawns = {}

RegisterNetEvent('trucker:server:spawnOwnedTruck', function(src, model, plate)

  if ActiveSpawns[src] then
    print("^1[Trucker]^7 Duplicate spawn blocked (player): " .. src)
    return
  end


  if ActiveSpawns[plate] then
    print("^1[Trucker]^7 Duplicate spawn blocked (plate): " .. plate)
    return
  end

  ActiveSpawns[src] = true
  ActiveSpawns[plate] = true

  local coords = Config.TruckSpawn
  local modelHash = tonumber(model) or GetHashKey(model)

  local vehicle = CreateVehicleServerSetter(
    modelHash,
    "automobile",
    coords.x,
    coords.y,
    coords.z,
    coords.w
  )

  Wait(200)

  if DoesEntityExist(vehicle) then
    SetVehicleNumberPlateText(vehicle, plate)

        local netId = NetworkGetNetworkIdFromEntity(vehicle)
    
    local serverId = src
    Entity(vehicle).state:set('owner', serverId, true)
    Entity(vehicle).state:set('is_truck', true, true)

  
    TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)


        TriggerClientEvent('trucker:client:enterTruck', src, netId)
    
    DebugPrint("State Bag 'owner' set to " .. serverId .. " for vehicle " .. plate)
  end


  SetTimeout(1500, function()
    ActiveSpawns[src] = nil
    ActiveSpawns[plate] = nil
  end)
end)


RegisterNetEvent('trucker:server:spawnFromGarage', function(plate)
  local src = source

  exports.oxmysql:single('SELECT model FROM player_trucks WHERE plate = ?', { plate }, function(result)
    if not result then return end

    TriggerEvent('trucker:server:spawnOwnedTruck', src, result.model, plate)
  end)
end)
