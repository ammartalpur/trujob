-- client/garage.lua
local Bridge = exports['community_bridge']:Bridge()
local function DebugPrint(msg)
  if Config.Debug then print("^3[Garage-Client]^7 " .. tostring(msg)) end
end

local function DrawText3D(x, y, z, text)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)

  if onScreen then
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextCentre(true)

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(_x, _y)

    -- Background box
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 120)
  end
end

CreateThread(function()
  while true do
    local sleep = 1000
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local dist = #(pos - vec3(Config.Garage.coords.x, Config.Garage.coords.y, Config.Garage.coords.z))

    if dist < 10.0 then
      sleep = 0
      -- Draw a marker so players know where to park
      local x = Config.Garage.coords.x
      local y = Config.Garage.coords.y
      local z = Config.Garage.coords.z + 0.5 -- lifted

      -- ✨ GLOWING MARKER
      DrawMarker(2, x, y, z,
        0.0, 0.0, 0.0,
        0.0, 180.0, 0.0, -- rotation for style
        0.4, 0.4, 0.4, -- bigger size
        0, 150, 255, 180, -- 🔵 blue glow color
        true,         -- bob up & down (glow feel)
        true,         -- face camera
        false, true, false, false, false
      )

      -- 🧾 3D TEXT
      DrawText3D(x, y, z + 0.3, "~g~[E]~w~ Store Truck")

      if dist < 2.0 then
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
          -- Display help text (Native GTA style)
          BeginTextCommandDisplayHelp("STRING")
          AddTextComponentScaleform("Press ~INPUT_CONTEXT~ to Store Truck")
          EndTextCommandDisplayHelp(0, 0, 1, -1)



                    if IsControlJustReleased(0, 38) then
            DebugPrint(" E key pressed")
            local plate = GetVehicleNumberPlateText(veh)

            -- Use a local variable to check the state
            local vehicleState = Entity(veh).state
            local ownerId = vehicleState.owner -- This is what was returning null

            -- DEBUG: Run this once to see what's happening in your console
            print("DEBUG: Checking Plate: " ..
            plate .. " | Owner ID in State: " .. tostring(ownerId) .. " | My ID: " .. GetPlayerServerId(PlayerId()))

            if ownerId and ownerId == GetPlayerServerId(PlayerId()) then
              -- Proceed to store...
              local vitals = {
                fuel = GetVehicleFuelLevel(veh),
                engine = GetVehicleEngineHealth(veh),
                body = GetVehicleBodyHealth(veh)
              }
              TriggerServerEvent('trucker:server:storeVehicle', plate, vitals)
            else
              -- If it's null, we give a specific error
              if not ownerId then
                Bridge.Notify.SendNotification("Truck Job", "This vehicle has no registered owner state!", "error")
              else
                Bridge.Notify.SendNotification("Truck Job", "You don't own this vehicle!", "error")
              end
            end
          end
        end
      end
    end
    Wait(sleep)
  end
end)
