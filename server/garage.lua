
local Bridge = exports['community_bridge']:Bridge()
local function DebugPrint(msg)
  if Config.Debug then print("^3[Garage-Server]^7 " .. tostring(msg)) end
end

local function getCitizenId(src)
    local cid = Bridge.Framework.GetPlayerIdentifier(src)
    return cid
end

RegisterNetEvent('trucker:server:storeVehicle', function(plate, vitals)
  DebugPrint(" trucker:server:storeVehicle running")
  local src = source
  local player = Bridge.Framework.GetPlayer(src)
  if not player then return end

  local citizenid = getCitizenId(src)


 
  exports.oxmysql:update([[
        UPDATE player_trucks
        SET in_garage = 1, fuel = ?, engine_health = ?, body_health = ?
        WHERE plate = ? AND citizenid = ?
    ]], {
    vitals.fuel, vitals.engine, vitals.body, plate, citizenid
  }, function(affectedRows)
    if affectedRows > 0 then
     
      local allVehs = GetAllVehicles()
      local deleted = false

      for _, veh in ipairs(allVehs) do
        if GetVehicleNumberPlateText(veh) == plate then
          DeleteEntity(veh)
          deleted = true
          break
        end
      end

   
      if deleted then
        Bridge.Notify.SendNotification(src, "Truck Job" , "Truck safely stored in garage.", "success")

        TriggerEvent('trucker:server:getMyTrucks', src)
      else
        Bridge.Notify.SendNotification(src, "Truck Job", "Truck stored in DB, but entity was not found.", "warning")
      end
    else
      Bridge.Notify.SendNotification(src, "Truck Job", "Failed to store: Vehicle not found in your records.", "error")
    end
  end)
end)
