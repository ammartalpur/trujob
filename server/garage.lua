

local function DebugPrint(msg)
  if Config.Debug then print("^3[Garage-Server]^7 " .. tostring(msg)) end
end

RegisterNetEvent('trucker:server:storeVehicle', function(plate, vitals)
  local src = source
  local player = exports.qbx_core:GetPlayer(src)
  if not player then return end

  local citizenid = player.PlayerData.citizenid

 
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
        exports.qbx_core:Notify(src, "Truck safely stored in garage.", "success")

        TriggerEvent('trucker:server:getMyTrucks', src)
      else
        exports.qbx_core:Notify(src, "Truck stored in DB, but entity was not found.", "warning")
      end
    else
      exports.qbx_core:Notify(src, "Failed to store: Vehicle not found in your records.", "error")
    end
  end)
end)
