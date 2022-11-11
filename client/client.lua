--                _
--               | |
--   _____      _| | _____  ___ _ __
--  / __\ \ /\ / / |/ / _ \/ _ \ '_ \
--  \__ \\ V  V /|   <  __/  __/ |_) |
--  |___/ \_/\_/ |_|\_\___|\___| .__/
--                             | |
--                             |_|
-- https://github.com/swkeep
-- TODO
-- [idea] smart load? load all container models when eveything is spawned remove their models from memnory
-- [-] police can access via lockpick!?
-- [-] logging access to containers
local ZONE = {}
local current_zone
local loaded = false

Core = GetCoreObject() -- framwork

local SpawnObject = function( model, coord, rotation, offset )
    local modelHash = GetHashKey(model)
    LoadModel(modelHash)
    local entity = CreateObject(modelHash, coord.x + offset.x, coord.y + offset.y, coord.z + offset.z, false)
    WaitForEntity(entity)

    SetEntityAsMissionEntity(entity, true, true)
    SetEntityRotation(entity, rotation, 0.0, true)
    FreezeEntityPosition(entity, true)
    SetEntityProofs(entity, 1, 1, 1, 1, 1, 1, 1, 1)
    SetModelAsNoLongerNeeded(modelHash)
    return entity
end

local function PlayerData()
    local Framework = Framework()
    if Framework == 1 then
        return Core.Functions.GetPlayerData()
    elseif Framework == 2 then
        return Core.PlayerData
    end
end

function GetCitizenId( PlayerData )
    local Framework = Framework()
    if Framework == 1 then
        if not PlayerData then return -1 end
        return PlayerData.citizenid
    elseif Framework == 2 then
        return PlayerData.identifier
    end
end

local function ShowDrawText( text )
    if Framework() == 1 then
        exports["qb-core"]:DrawText(text or "Container Depot")
    elseif Config.input == "ox_lib" then
        lib.showTextUI(text or "Container Depot", {
            icon = "warehouse",
            style = {
                borderRadius = 0,
                backgroundColor = "#48BB78",
                color = "white"
             }
        })
    end
end

local function HideDrawText()
    if Framework() == 1 then
        exports["qb-core"]:HideText()
    elseif Config.input == "ox_lib" then
        lib.hideTextUI()
    end
end

local CreateBlip = function( options )
    local blip = AddBlipForCoord(options.coords)
    SetBlipSprite(blip, options.sprite)
    SetBlipScale(blip, options.scale or 1.0)
    SetBlipColour(blip, options.color or 49)
    SetBlipDisplay(blip, 4)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(options.name or "no-name")
    EndTextCommandSetBlipName(blip)
    return blip
end

local function Init()
    if loaded then return end
    loaded = true
    for k, v in pairs(Config.container_depots) do
        ZONE[k] = PolyZone:Create(v.positions, {
            name = "c_depot " .. k,
            minZ = v.minz,
            maxZ = v.maxz,
            debugPoly = Config.MagicTouch
         })
        CreateBlip(v.blip)
        ZONE[k]:onPlayerInOut(function( isPointInside )
            if isPointInside then
                current_zone = k
                Wait(50)
                ShowDrawText(v.name)
                TriggerCallback("keep-containers:server:GET:ZONE:containers", function( containers ) for k, container in pairs(containers) do Containers:new(container) end end, current_zone)
            else
                current_zone = nil
                Containers:clean_up()
                HideDrawText()
            end
        end)
    end
end

Containers = {
    data = {}
 }

local function is_super_user( citizenid )
    if Config.super_users[citizenid] and Config.super_users[citizenid] == true then return true end
    return false
end

function Containers:new( options )
    local _self = {}
    local private = {
        random_id = options.random_id,
        position = json.decode(options.position),
        container_type = options.container_type,
        objects = {}
     }

    local function add_target( entity )
        local Framework = Framework()
        if Framework == 1 then
            exports["qb-target"]:AddTargetEntity(entity, {
                options = {
                    {
                        icon = "fas fa-box",
                        label = "Open Container",
                        action = function( entity )
                            local Input = {
                                header = "Container Password", -- qb-input
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
                            local zone_name, zone = GetCurrentZone()
                            if inputData and inputData.password then
                                TriggerServerEvent("keep-containers:server:container:check_password", private.random_id, inputData.password, zone_name)
                            end
                        end
                    },
                    {
                        icon = "fas fa-box",
                        label = "Change Password",
                        action = function( entity )
                            local Input = {
                                header = "Change Password", -- qb-input
                                inputs = {
                                    {
                                        type = "password",
                                        name = "current_password",
                                        icon = "fa-solid fa-money-bill-trend-up",
                                        title = "Current Password",
                                        text = "Current Password", -- qb-input
                                        isRequired = true
                                    },
                                    {
                                        type = "password",
                                        name = "new_password",
                                        icon = "fa-solid fa-money-bill-trend-up",
                                        title = "New Password",
                                        text = "New Password", -- qb-input
                                        isRequired = true
                                    }
                                }
                            }

                            local inputData = exports[Config.input]:ShowInput(Input)
                            local zone_name, zone = GetCurrentZone()
                            if inputData and inputData.current_password and inputData.new_password and (zone_name ~= -1) then
                                TriggerServerEvent("keep-containers:server:container:change_password", private.random_id, inputData.current_password, inputData.new_password, zone_name)
                            end
                        end
                    },
                    {
                        icon = "fas fa-box",
                        label = "Transfer Ownership",
                        action = function( entity )
                            local inputData = exports[Config.input]:ShowInput({
                                header = "Transfer Ownership", -- qb-input
                                inputs = {
                                    {
                                        type = "number",
                                        name = "new_owner",
                                        icon = "fa-solid fa-money-bill-trend-up",
                                        title = "New Owner's State Id",
                                        text = "New Owner's State Id", -- qb-input
                                        isRequired = true
                                    }
                                }
                            })
                            local zone_name, zone = GetCurrentZone()
                            if inputData and inputData.new_owner then
                                local confData = exports[Config.input]:ShowInput({
                                    inputs = {
                                        {
                                            type = "text",
                                            isRequired = true,
                                            name = "conf",
                                            text = "Type Confirm (^.^)",
                                            icon = "fa-solid fa-money-bill-trend-up",
                                            title = ("Confirm (transfer ownership to stateId (%s))"):format(inputData.new_owner)
                                        }
                                    }
                                })
                                if confData and confData.conf == "Confirm" then
                                    TriggerServerEvent("keep-containers:server:container:transfer_ownership", private.random_id, zone_name, inputData.new_owner)
                                end
                            end
                        end
                    },
                    {
                        icon = "fas fa-box",
                        label = "Delete Container",
                        canInteract = function()
                            local PlayerData = PlayerData()
                            local citizenid = GetCitizenId(PlayerData)
                            return is_super_user(citizenid)
                        end,
                        action = function( entity )
                            local confData = exports[Config.input]:ShowInput({
                                inputs = {
                                    {
                                        type = "text",
                                        isRequired = true,
                                        name = "conf",
                                        text = "Type Confirm (^.^)",
                                        icon = "fa-solid fa-money-bill-trend-up",
                                        title = "Confirm"
                                     }
                                }
                            })
                            if confData and confData.conf == "Confirm" then
                                local zone_name, zone = GetCurrentZone()
                                TriggerServerEvent("keep-containers:server:container:delete", private.random_id, zone_name)
                            end
                        end
                    }
                },
                distance = 1.0
            })
        elseif Framework == 2 then
            exports["ox_target"]:addLocalEntity(entity, {
                {
                    icon = "fas fa-box",
                    distance = 1.0,
                    label = "Open Container",
                    onSelect = function( entity )
                        if Config.input ~= "ox_lib" then
                            local Input = {
                                header = "Container", -- qb-input
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
                            if inputData and inputData.password then
                                local zone_name, zone = GetCurrentZone()
                                TriggerServerEvent("keep-containers:server:container:check_password", private.random_id, inputData.password, zone_name)
                            end
                        else
                            local inputData = lib.inputDialog("Container", {
                                {
                                    type = "input",
                                    label = "Password",
                                    password = true,
                                    icon = "lock"
                                 }
                            })
                            if inputData and inputData[1] then
                                local zone_name, zone = GetCurrentZone()
                                TriggerServerEvent("keep-containers:server:container:check_password", private.random_id, inputData[1], zone_name)
                            end
                        end
                    end
                },
                {
                    icon = "fa-solid fa-key",
                    distance = 1.0,
                    label = "Change Password",
                    onSelect = function( entity )
                        if Config.input ~= "ox_lib" then
                            local Input = {
                                header = "Change Password", -- qb-input
                                inputs = {
                                    {
                                        type = "password",
                                        name = "current_password",
                                        icon = "fa-solid fa-money-bill-trend-up",
                                        title = "Current Password",
                                        text = "Current Password", -- qb-input
                                        isRequired = true
                                    },
                                    {
                                        type = "password",
                                        name = "new_password",
                                        icon = "fa-solid fa-money-bill-trend-up",
                                        title = "New Password",
                                        text = "New Password", -- qb-input
                                        isRequired = true
                                    }
                                }
                            }

                            local inputData = exports[Config.input]:ShowInput(Input)
                            local zone_name, zone = GetCurrentZone()
                            if inputData and inputData.current_password and inputData.new_password and (zone_name ~= -1) then
                                TriggerServerEvent("keep-containers:server:container:change_password", private.random_id, inputData.current_password, inputData.new_password, zone_name)
                            end
                        else
                            local inputData = lib.inputDialog("Change Passowrd", {
                                {
                                    type = "input",
                                    label = "Current Password",
                                    password = true,
                                    icon = "lock"
                                 },
                                {
                                    type = "input",
                                    label = "New Password",
                                    password = true,
                                    icon = "lock"
                                 }
                            })
                            if inputData and inputData[1] and inputData[2] then
                                local zone_name, zone = GetCurrentZone()
                                TriggerServerEvent("keep-containers:server:container:change_password", private.random_id, inputData[1], inputData[2], zone_name)
                            end
                        end
                    end
                },
                {
                    icon = "fa-solid fa-right-left",
                    distance = 1.0,
                    label = "Transfer Ownership",
                    onSelect = function( entity )
                        if Config.input ~= "ox_lib" then
                            local inputData = exports[Config.input]:ShowInput({
                                header = "Transfer Ownership", -- qb-input
                                inputs = {
                                    {
                                        type = "number",
                                        name = "new_owner",
                                        icon = "fa-solid fa-money-bill-trend-up",
                                        title = "New Owner's State Id",
                                        text = "New Owner's State Id", -- qb-input
                                        isRequired = true
                                    }
                                }
                            })
                            local zone_name, zone = GetCurrentZone()
                            if inputData and inputData.new_owner then

                                local confData = exports[Config.input]:ShowInput({
                                    inputs = {
                                        {
                                            type = "text",
                                            isRequired = true,
                                            name = "conf",
                                            text = "Type Confirm (^.^)",
                                            icon = "fa-solid fa-money-bill-trend-up",
                                            title = ("Confirm (transfer ownership to stateId (%s))"):format(inputData.new_owner)
                                        }
                                    }
                                })
                                if confData and confData.conf == "Confirm" then
                                    TriggerServerEvent("keep-containers:server:container:transfer_ownership", private.random_id, zone_name, inputData.new_owner)
                                end
                            end
                        else
                            local inputData = lib.inputDialog("Transfer Ownership", {
                                "New Owner's State Id"
                             })
                            if inputData and inputData[1] then
                                local alert = lib.alertDialog({
                                    header = "Transfer Ownership",
                                    content = "Confirm the transfer to the new owner. \n You be able to reverse the operation when it starts. ",
                                    centered = true,
                                    cancel = true
                                })
                                if alert == "confirm" then
                                    local zone_name, zone = GetCurrentZone()
                                    TriggerServerEvent("keep-containers:server:container:transfer_ownership", private.random_id, zone_name, inputData[1])
                                else
                                    lib.notify({
                                        title = "Container Depot",
                                        description = "Operation has been canceled.",
                                        style = {
                                            backgroundColor = "#141517",
                                            color = "#909296"
                                         },
                                        icon = "ban",
                                        iconColor = "#C53030"
                                    })
                                end
                            end
                        end
                    end
                },
                {
                    icon = "fas fa-trash",
                    distance = 1.0,
                    label = "Delete Container",
                    canInteract = function()
                        local PlayerData = PlayerData()
                        local citizenid = GetCitizenId(PlayerData)
                        return is_super_user(citizenid)
                    end,
                    onSelect = function( entity )
                        if Config.input ~= "ox_lib" then
                            local confData = exports[Config.input]:ShowInput({
                                inputs = {
                                    {
                                        type = "text",
                                        isRequired = true,
                                        name = "conf",
                                        text = "Type Confirm (^.^)",
                                        icon = "fa-solid fa-money-bill-trend-up",
                                        title = "Confirm"
                                     }
                                }
                            })
                            if confData and confData.conf == "Confirm" then
                                local zone_name, zone = GetCurrentZone()
                                TriggerServerEvent("keep-containers:server:container:delete", private.random_id, zone_name)
                            end
                        else
                            local inputData = lib.inputDialog("Confirm", {
                                "Type Confirm (^.^)"
                             })
                            if inputData and inputData[1] == "Confirm" then
                                local zone_name, zone = GetCurrentZone()
                                TriggerServerEvent("keep-containers:server:container:delete", private.random_id, zone_name)
                            end
                        end
                    end
                }
            })
        end
    end

    local function spawn()
        local container = GetContainerInfromation(private.container_type)
        local coords = TableToVector3(private.position)
        local heading = private.position.w
        local index = #private.objects + 1
        private.objects[index] = SpawnObject(container.object.name, coords, vector3(0, 0, heading), container.object.offset)
        add_target(private.objects[index])
    end

    function _self.remove_object() for _, object in pairs(private.objects) do DeleteEntity(object) end end

    local function constructor() spawn() end

    constructor()

    Containers.data[options.random_id] = _self
    return _self
end

RegisterNetEvent("keep-containers:client:update_zone", function( zone_name )
    local current_zone, zone = GetCurrentZone()
    if zone_name == current_zone then
        Containers:clean_up()
        TriggerCallback("keep-containers:server:GET:ZONE:containers", function( containers ) for k, container in pairs(containers) do Containers:new(container) end end, zone_name)
    end
end)

function Containers:clean_up() for _, Container in pairs(self.data) do Container.remove_object() end end
function GetCurrentZone() return current_zone, ZONE[current_zone] end

AddEventHandler("onResourceStop", function( resource )
    if resource ~= GetCurrentResourceName() then return end
    Containers:clean_up()
end)

AddEventHandler("onResourceStart", function( resourceName )
    if (GetCurrentResourceName() ~= resourceName) then return end
    Init()
end)

if Framework() == 1 then
    RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function() Init() end)
elseif Framework() == 2 then
    RegisterNetEvent("esx:playerLoaded")
    AddEventHandler("esx:playerLoaded", function() Init() end)
end
