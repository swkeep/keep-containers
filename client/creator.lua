--                _
--               | |
--   _____      _| | _____  ___ _ __
--  / __\ \ /\ / / |/ / _ \/ _ \ '_ \
--  \__ \\ V  V /|   <  __/  __/ |_) |
--  |___/ \_/\_/ |_|\_\___|\___| .__/
--                             | |
--                             |_|
-- https://github.com/swkeep
local function Draw2DText( content, font, colour, scale, x, y )
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1], colour[2], colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

local function RotationToDirection( rotation )
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
     }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

local function RayCastGamePlayCamera( distance )
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
     }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return c, e
end

local function up( object, offset )
    DisableControlAction(0, 27, true)
    if IsDisabledControlPressed(0, 27) then -- arrow up
        local delta = 0.05
        DisableControlAction(0, 36, true)
        if IsDisabledControlPressed(0, 36) then -- ctrl held down
            delta = 0.10
        end
        local object_coords = GetEntityCoords(object)
        SetEntityCoords(object, object_coords.x + offset.x, object_coords.y + offset.y, object_coords.z + offset.z + delta)
    end
end

local function down( object, offset )
    DisableControlAction(0, 173, true)
    if IsDisabledControlPressed(0, 173) then -- arrow up
        local delta = 0.05
        DisableControlAction(0, 36, true)
        if IsDisabledControlPressed(0, 36) then -- ctrl held down
            delta = 0.10
        end
        local object_coords = GetEntityCoords(object)
        SetEntityCoords(object, object_coords.x + offset.x, object_coords.y + offset.y, object_coords.z + offset.z - delta)
    end
end

local function left( object, offset, xy )
    DisableControlAction(0, 174, true)
    if IsDisabledControlPressed(0, 174) then -- arrow up
        local delta = 0.05
        DisableControlAction(0, 36, true)
        if IsDisabledControlPressed(0, 36) then -- ctrl held down
            delta = 0.10
        end
        local object_coords = GetEntityCoords(object)
        if xy == "x" then
            SetEntityCoords(object, object_coords.x + offset.x + delta, object_coords.y + offset.y, object_coords.z + offset.z)
        else
            SetEntityCoords(object, object_coords.x + offset.x, object_coords.y + offset.y + delta, object_coords.z + offset.z)
        end
    end
end

local function right( object, offset, xy )
    DisableControlAction(0, 175, true)
    if IsDisabledControlPressed(0, 175) then -- arrow up
        local delta = 0.05
        DisableControlAction(0, 36, true)
        if IsDisabledControlPressed(0, 36) then -- ctrl held down
            delta = 0.10
        end
        local object_coords = GetEntityCoords(object)
        if xy == "x" then
            SetEntityCoords(object, object_coords.x + offset.x - delta, object_coords.y + offset.y, object_coords.z + offset.z)
        else
            SetEntityCoords(object, object_coords.x + offset.x, object_coords.y + offset.y - delta, object_coords.z + offset.z)
        end
    end
end

local object
local function ChooseSpawnLocation( model, offset )
    local plyped = PlayerPedId()
    local pedCoord = GetEntityCoords(plyped)
    local object_placed = false
    local xy = "x"
    object = CreateObject(GetHashKey(model), pedCoord.x + offset.x, pedCoord.y + offset.y, pedCoord.z + offset.z, 1, 0, 0)
    SetEntityAlpha(object, 150, true)
    SetEntityCollision(object, false, false)
    while true do
        BlockWeaponWheelThisFrame()
        local coords, entity = RayCastGamePlayCamera(50.0)
        Draw2DText("Press ~g~E~w~ To Lock Position | ~g~Mouse Wheel~w~ To Rotate | Press ~g~ESC~w~ To Exit", 4, {
            255,
            255,
            255
         }, 0.4, 0.43, 0.888)
        Draw2DText("Press ~g~Up~w~/~g~Down~w~/~g~Left~w~/~g~Right~w~ After Position Is Locked", 4, {
            255,
            255,
            255
         }, 0.4, 0.43, 0.888 + 0.025)
        Draw2DText("Press ~g~Page Up~w~ to change X Axis | Press ~g~Page Down~w~ to Y Axis | Current Axis: " .. xy, 4, {
            255,
            255,
            255
         }, 0.4, 0.43, 0.888 + 0.05)
        Draw2DText("Press ~g~ENTER~w~ To Confirm", 4, {
            255,
            255,
            255
         }, 0.4, 0.5, 0.86)
        if IsControlJustReleased(0, 38) then object_placed = true end

        if IsControlJustReleased(0, 191) then
            local ec = GetEntityCoords(object)
            local w = GetEntityHeading(object)
            DeleteEntity(object)
            return vector4(ec.x - offset.x, ec.y - offset.y, ec.z - offset.z, w)
        end

        up(object, offset)
        down(object, offset)
        right(object, offset, xy)
        left(object, offset, xy)

        DisableControlAction(0, 81, true)
        if IsDisabledControlJustPressed(0, 81) then
            local head = GetEntityHeading(object)
            local delta = 7.5
            DisableControlAction(0, 36, true)
            if IsDisabledControlPressed(0, 36) then -- ctrl held down
                delta = 1.0
            end
            head = head + delta
            SetEntityHeading(object, head)
        end

        DisableControlAction(0, 99, true)
        if IsDisabledControlJustPressed(0, 99) then
            local head = GetEntityHeading(object)
            local delta = 7.5
            DisableControlAction(0, 36, true)
            if IsDisabledControlPressed(0, 36) then -- ctrl held down
                delta = 1.0
            end
            head = head - delta
            SetEntityHeading(object, head)
        end

        DisableControlAction(0, 200, true)
        if IsDisabledControlJustPressed(0, 200) then
            DeleteEntity(object)
            return "exit"
        end

        if IsControlPressed(0, 10) then xy = "x" end

        if IsControlPressed(0, 11) then xy = "y" end

        DisableControlAction(0, 36, true)

        if not object_placed then SetEntityCoords(object, coords.x + offset.x, coords.y + offset.y, coords.z + offset.z) end
        Wait(10)
    end
end

RegisterNetEvent("keep-containers:client:container:place", function( container_type )
    local zone_name, Zone = GetCurrentZone()
    if not zone_name or not Zone then
        Notification_c("The container cannot be placed outside the depot!", "error")
        return
    end
    if Config.input ~= "ox_lib" then
        local Input = {
            header = "Set Password", -- qb-input
            inputs = {
                {
                    type = "password",
                    name = "password",
                    icon = "fa-solid fa-money-bill-trend-up",
                    title = "Password",
                    text = "Enter Password", -- qb-input
                    isRequired = true
                }
            }
        }

        local inputData = exports[Config.input]:ShowInput(Input)

        if inputData and inputData.password and inputData.password ~= "" then
            local container = GetContainerInfromation(container_type)
            if not container then
                print("contaienr type is wrong!")
                return
            end
            local position = ChooseSpawnLocation(container.object.name, container.object.offset)

            if position == "exit" then return end
            local is_in_zone = Zone:isPointInside(position) -- this should be somehow server-side
            if is_in_zone then
                TriggerServerEvent("keep-containers:server:create_container", inputData.password, position, zone_name)
            else
                Notification_c("The container is outside of depot!", "error")
            end
        else
            Notification_c("Use a better password!", "error")
        end
    else
        local inputData = lib.inputDialog("Enter Password", {
            {
                type = "input",
                label = "Password",
                password = true,
                icon = "lock"
             }
        })
        if inputData and inputData[1] then
            local container = GetContainerInfromation(container_type)
            local position = ChooseSpawnLocation(container.object.name, container.object.offset)

            if position == "exit" then
                Notification_c("The container placement has been cancelled!", "error")
                return
            end

            local is_in_zone = Zone:isPointInside(position) -- this should be somehow server-side
            if is_in_zone then
                TriggerServerEvent("keep-containers:server:create_container", inputData[1], position, zone_name)
            else
                Notification_c("The container is outside of depot!", "error")
            end
        end
    end
end)

AddEventHandler("keep-containers:client:container:update_location", function( random_id, zone_name, container_type )
    local _, Zone = GetCurrentZone()
    if not zone_name or not Zone then
        Notification_c("The container cannot be placed outside the depot!", "error")
        return
    end
    local container = GetContainerInfromation(container_type)
    local position = ChooseSpawnLocation(container.object.name, container.object.offset)
    if position == "exit" then
        TriggerEvent("keep-containers:client:update_zone", zone_name)
        return
    end
    local is_in_zone = Zone:isPointInside(position) -- this should be somehow server-side
    if is_in_zone then
        TriggerServerEvent("keep-containers:server:container:update_position", random_id, zone_name, position)
    else
        TriggerEvent("keep-containers:client:update_zone", zone_name)
        Notification_c("The container is outside of depot!", "error")
    end
end)

AddEventHandler("onResourceStop", function( resource )
    if resource ~= GetCurrentResourceName() then return end
    DeleteEntity(object)
end)
