--                _
--               | |
--   _____      _| | _____  ___ _ __
--  / __\ \ /\ / / |/ / _ \/ _ \ '_ \
--  \__ \\ V  V /|   <  __/  __/ |_) |
--  |___/ \_/\_/ |_|\_\___|\___| .__/
--                             | |
--                             |_|
-- https://github.com/swkeep
local function LoadAnimationDict(animation)
    RequestAnimDict(animation)
    while not HasAnimDictLoaded(animation) do Wait(25) end
end

local function makeEntityFaceCoord(entity, coord)
    local p1 = GetEntityCoords(entity, true)

    SetEntityHeading(entity, GetHeadingFromVector_2d((coord.x - p1.x), (coord.y - p1.y)))
end

local function open_animation()
    if Framework() == 2 then Wait(1000) end
    LoadAnimationDict("amb@prop_human_bum_bin@idle_b")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 1, false, false, false)
end

local function close_aimation()
    LoadAnimationDict("amb@prop_human_bum_bin@idle_b")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
    Wait(1500)
    ClearPedTasks(PlayerPedId())
end

local function Close()
    local duration = 1
    if Framework() == 1 then
        Core.Functions.Progressbar("keep_container_close", "Close", duration * 1000, false, false, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true
        }, {}, {}, {}, function() close_aimation() end)
    elseif Framework() == 2 or Framework() == 3 then
        close_aimation()
    end
end

local function open_stash(metadata)
    local id = "Container_" .. metadata.random_id
    local framework = Framework()

    if framework == 1 then
        open_animation()
        TriggerServerEvent("inventory:server:OpenInventory", "stash", id, {
            maxweight = metadata.size,
            slots = metadata.slots
        })
        TriggerEvent("inventory:client:SetCurrentStash", id)
    elseif framework == 2 or framework == 3 then
        exports["ox_inventory"]:openInventory("stash", {
            id = id
        })
        open_animation()
    end

    Wait(1000)
    repeat Wait(100) until IsNuiFocused() == false
    Close()
end

RegisterNetEvent("keep-containers:client:open", function(metadata)
    if not metadata then return end
    local duration = 1

    if Config.input == "ox_lib" then
        if lib.progressCircle({
                duration = 2000,
                position = "bottom",
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true

                }
            }) then
            open_stash(metadata)
        else
            print("Do stuff when cancelled")
        end
    else
        Core.Functions.Progressbar("keep_container_opening", "Open", duration * 1000, false, false, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true
        }, {}, {}, {}, function() open_stash(metadata) end)
    end
end)
