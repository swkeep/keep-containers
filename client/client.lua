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
local Framework = Framework()
Containers = {
    data = {}
 }

function is_super_user( citizenid )
    if Config.super_users[citizenid] and Config.super_users[citizenid] == true then return true end
    return false
end

function PlayerData()
    if Framework == 1 then
        return Core.Functions.GetPlayerData()
    elseif Framework == 2 then
        return Core.PlayerData
    end
end

function GetCitizenId( PlayerData )
    if Framework == 1 then
        if not PlayerData then return -1 end
        return PlayerData.citizenid
    elseif Framework == 2 then
        return PlayerData.identifier
    end
end

function GetJob()
    local PlayerData = PlayerData()
    if Framework == 1 then
        return PlayerData.job.name ,PlayerData.job.grade.level
    elseif Framework == 2 then
        return PlayerData.job.name, PlayerData.job.grade
    end
end

function Notification_c( msg, type )
    if Config.input == "ox_lib" then if type == "primary" then type = "inform" end end

    if Config.input ~= "ox_lib" then
        if Framework == 1 then
            Core.Functions.Notify(msg, type)
        elseif Framework == 2 then
            if type == "primary" then type = "info" end
            TriggerEvent("esx:showNotification", msg, type)
        end
    else
        if type == "error" then
            lib.notify({
                title = "Container Depot",
                description = msg,
                style = {
                    backgroundColor = "#141517",
                    color = "#909296"
                 },
                icon = "ban",
                iconColor = "#C53030"
            })
        else
            lib.notify({
                title = "Container Depot",
                description = msg,
                type = type
             })
        end
    end
end

RegisterNetEvent("keep-containers:client:notification", function( msg, type ) Notification_c(msg, type) end)

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

local function ShowDrawText( text )
    if Framework == 1 then
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
    if Framework == 1 then
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
        if Config.EnableBlips then CreateBlip(v.blip) end --create blip if enabled
        ZONE[k] = PolyZone:Create(v.positions, {
            name = "c_depot " .. k,
            minZ = v.minz,
            maxZ = v.maxz,
            debugPoly = Config.MagicTouch
         })
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
        end, 500)
    end
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
        if Framework == 1 then
            Qb_target(private, entity)
        elseif Framework == 2 then
            if (Config.esx_target):lower() == "ox_target" then
                Ox_target(private, entity)
            elseif (Config.esx_target):lower() == "qtarget" then
                Qtarget(private, entity)
            end
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
    setmetatable(Containers, _self)
    return _self
end

function Containers:clean_up() for _, Container in pairs(self.data) do Container.remove_object() end end
function GetCurrentZone() return current_zone, ZONE[current_zone] end

RegisterNetEvent("keep-containers:client:update_zone", function( zone_name )
    local current_zone, zone = GetCurrentZone()
    if zone_name == current_zone then
        Containers:clean_up()
        TriggerCallback("keep-containers:server:GET:ZONE:containers", function( containers ) for k, container in pairs(containers) do Containers:new(container) end end, zone_name)
    end
end)

AddEventHandler("onResourceStop", function( resource )
    if resource ~= GetCurrentResourceName() then return end
    Containers:clean_up()
end)

AddEventHandler("onResourceStart", function( resourceName )
    if (GetCurrentResourceName() ~= resourceName) then return end
    Init()
end)

if Framework == 1 then
    RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function() Init() end)
elseif Framework == 2 then
    RegisterNetEvent("esx:playerLoaded")
    AddEventHandler("esx:playerLoaded", function() Init() end)
end
