--                _
--               | |
--   _____      _| | _____  ___ _ __
--  / __\ \ /\ / / |/ / _ \/ _ \ '_ \
--  \__ \\ V  V /|   <  __/  __/ |_) |
--  |___/ \_/\_/ |_|\_\___|\___| .__/
--                             | |
--                             |_|
-- https://github.com/swkeep
Core = GetCoreObject() -- framwork
local Framework = Framework()
local creation_list = {}

local function init_database()
    local array = {
        [[
            CREATE TABLE IF NOT EXISTS `keep_containers` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `random_id` varchar(50) NOT NULL,
                `container_type` varchar(50) NOT NULL,
                `owner_citizenid` varchar(50) DEFAULT NULL,
                `password` CHAR(60) DEFAULT NULL,
                `position` TEXT DEFAULT NULL,
                `zone` varchar(50) DEFAULT NULL,
                `deleted` BOOLEAN NOT NULL DEFAULT TRUE,
                `deleted_by` varchar(50) DEFAULT NULL,
                PRIMARY KEY (`id`),
                KEY `random_id` (`random_id`)
              ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
    ]],
        [[
            CREATE TABLE IF NOT EXISTS `keep_containers_access_log` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `random_id` varchar(50) NOT NULL,
                `citizenid` varchar(50) DEFAULT NULL,
                `action` varchar(50) DEFAULT NULL,
                `metadata` TEXT DEFAULT NULL,
                PRIMARY KEY (`id`),
                KEY `random_id` (`random_id`)
              ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
    ]]
    }

    local function trim1(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

    for key, query in pairs(array) do MySQL.Sync.fetchScalar(trim1(query), {}) end
end

CreateThread(function() init_database() end)

local function Player(source)
    if Framework == 1 or Framework == 3 then
        return Core.Functions.GetPlayer(source)
    elseif Framework == 2 then
        return Core.GetPlayerFromId(source)
    end
end

local function GetCitizenId(Player)
    if Framework == 1 or Framework == 3 then
        if not Player then return -1 end
        return Player.PlayerData.citizenid
    elseif Framework == 2 then
        return Player.getIdentifier()
    end
end

local function GetJob(source)
    local player = Player(source)
    if Framework == 1 or Framework == 3 then
        return player.PlayerData.job.name, player.PlayerData.job.grade.level
    elseif Framework == 2 then
        local job = player.getJob()
        return job.name, job.grade
    end
end

local function HasAccessToBoltCutter(source)
    local job_name, job_grade = GetJob(source)

    if Config.bolt_cutter[tostring(job_name)] then
        if Config.bolt_cutter[tostring(job_name)][tonumber(job_grade)] and Config.bolt_cutter[tostring(job_name)][tonumber(job_grade)] == true then return true end
        return false
    end
    return false
end

local function HasBoltCutter(source, player)
    if Framework == 1 then
        local item = player.Functions.GetItemByName(Config.bolt_cutter_item_name)
        if item then
            return true
        end
        return false
    elseif Framework == 2 then
        if not player.hasItem(Config.bolt_cutter_item_name) then return false end
        local count = player.hasItem(Config.bolt_cutter_item_name).count
        if count > 0 then
            return true
        else
            return false
        end
    end
end

local function remove_item(source, Player, item_name, amount, slot)
    local res = Player.Functions.RemoveItem(item_name, amount, slot)
    TriggerClientEvent("qb-inventory:client:ItemBox", source, Core.Shared.Items[item_name], "remove")
    return res
end

local function RemoveItem(source, Player, item_name, amount, slot)
    if Framework == 1 or Framework == 3 then
        return remove_item(source, Player, item_name, amount, slot)
    elseif Framework == 2 then
        return Player.removeInventoryItem(item_name, amount)
    end
end

RegisterNetEvent("keep-containers:server:create_container", function(password, position, zone_name)
    local function is_a_valid_zone()
        if Config.container_depots[zone_name] then return true end
        return false
    end

    local src = source
    local Player = Player(src)
    local citizenid = GetCitizenId(Player)
    local container_type = creation_list[src]

    -- validate zone_name
    if not is_a_valid_zone() then
        Notification_S(src, "Depot is not valid", "error")
        return
    end

    if not password or password == "" then
        Notification_S(src, "Enter a better password", "primary")
        return
    end

    if not container_type then
        Notification_S(src, "Wrong container type", "error")
        return
    end

    if not RemoveItem(src, Player, container_type, 1) then
        Notification_S(src, "The requested container was not found in your inventory!", "error")
        return
    end

    local sqlQuery = "INSERT INTO keep_containers (random_id,container_type,owner_citizenid,password,position,zone,deleted,deleted_by) VALUES (?,?,?,?,?,?,?,?)"
    local QueryData = {
        RandomID(9),
        container_type,
        citizenid,
        GetPasswordHash(password),
        json.encode(position),
        zone_name,
        false,
        ""
    }
    MySQL.Async.insert(sqlQuery, QueryData, function()
        creation_list[src] = nil
        TriggerClientEvent("keep-containers:client:update_zone", -1, zone_name)
        Notification_S(src, "Success", "success")
    end)
end)

CreateCallback("keep-containers:server:GET:ZONE:containers", function(source, cb, zone_name)
    MySQL.Async.fetchAll("SELECT random_id,position,container_type FROM keep_containers WHERE zone = ? and deleted = false", {
        zone_name
    }, function(res) cb(res) end)
end)

function VerifyPassword(src, password, passwordHash, notification)
    if not password or password == "" or not passwordHash then
        if notification then Notification_S(src, "Bad password input!", "error") end
        return false
    end
    if VerifyPasswordHash(password, passwordHash) == 1 then
        if notification then Notification_S(src, "Success", "success") end
        return true
    else
        if notification then Notification_S(src, "Password is wrong", "error") end
        return false
    end
end

local query = "SELECT container_type, password FROM keep_containers WHERE random_id = ?"

RegisterNetEvent("keep-containers:server:container:check_password", function(random_id, password, zone_name)
    local src = source
    MySQL.Async.fetchAll(query, { random_id }, function(results)
        local result = results[1]
        local container_info = GetContainerInfromation(result.container_type)
        if not container_info then return end

        if VerifyPassword(src, password, result.password, true) then
            local container_id = "container-" .. random_id
            if Framework == 1 then
                exports['qb-inventory']:OpenInventory(src, container_id, {
                    slots = container_info.slots or 10,
                    maxweight = container_info.size or 10000
                })
                -- TriggerClientEvent("keep-containers:client:open", src, container_type.type) -- old qb-inventory
            elseif Framework == 2 or Framework == 3 then
                local stash_id = "Container_" .. random_id
                exports["ox_inventory"]:RegisterStash(stash_id, "Container", container_info.slots, container_info.size)
                TriggerClientEvent("keep_containers:client:open", src, container_info.type)
            end
        end
    end)
end)

RegisterNetEvent("keep-containers:server:use_bolt_cutter", function(entity, random_id, zone_name)
    local src = source
    local player = Player(src)
    if not HasBoltCutter(src, player) then
        Notification_S(src, "You don't have on a single boltcutter on you", "error")
        return
    end
    if not HasAccessToBoltCutter(src) then
        Notification_S(src, "You can't use boltcutter", "error")
        return
    end
    TriggerClientEvent("keep-containers:targets:use_bolt_cutter", src, entity, random_id, zone_name)
end)

RegisterNetEvent("keep-containers:server:open_with_bolt_cutter", function(random_id, zone_name)
    local src = source
    local player = Player(src)
    if not HasAccessToBoltCutter(src) then
        Notification_S(src, "You can't use boltcutter", "error")
        return
    end
    if not HasBoltCutter(src, player) then
        Notification_S(src, "You don't have on a single boltcutter on you", "error")
        return
    end

    if Config.remove_bolt_cutter_on_use then
        if not RemoveItem(src, player, Config.bolt_cutter_item_name, 1) then
            Notification_S(src, "Can't remove boltcutter from you!", "error")
            return
        end
    end

    MySQL.Async.fetchAll("SELECT container_type FROM keep_containers WHERE random_id = ?", {
        random_id
    }, function(res)
        res = res[1]
        local container_type = GetContainerInfromation(res.container_type)
        local type = container_type.type
        type.random_id = random_id

        if Framework == 1 then
            TriggerClientEvent("keep-containers:client:open", src, container_type.type)
        elseif Framework == 2 or Framework == 3 then
            local id = "Container_" .. random_id
            exports["ox_inventory"]:RegisterStash(id, "Container", type.slots, type.size)
            TriggerClientEvent("keep-containers:client:open", src, container_type.type)
        end
    end)
end)

function is_owner(owner_citizenid, current_citizenid)
    if owner_citizenid == current_citizenid then return true end
    return false
end

RegisterNetEvent("keep-containers:server:container:change_password", function(random_id, current_password, new_password, zone_name)
    local src = source
    local Player = Player(src)
    local citizenid = GetCitizenId(Player)

    -- Verify new password
    if not new_password or new_password == "" then
        Notification_S(src, "Bad password input.", "error")
        return
    end

    MySQL.Async.fetchAll("SELECT id,owner_citizenid, password FROM keep_containers WHERE random_id = ?", {
        random_id
    }, function(res)
        res = res[1]
        if not is_owner(res.owner_citizenid, citizenid) then
            Notification_S(src, "Only the owner of this container can change the password!", "error")
            return
        end

        if VerifyPassword(src, current_password, res.password, notification) == true then
            MySQL.Async.execute("UPDATE keep_containers SET password = ? WHERE id = ?", {
                GetPasswordHash(new_password),
                res.id
            }, function() Notification_S(src, "Password Updated.", "primary") end)
        else
            Notification_S(src, "Current password is wrong.", "error")
        end
    end)
end)

RegisterNetEvent("keep-containers:server:container:transfer_ownership", function(random_id, zone_name, new_owner)
    local src = source
    new_owner = tonumber(new_owner)
    if src == new_owner then
        Notification_S(src, "You can't transfer it to yourself.", "primary")
        return
    end

    local player = Player(src)
    local o_citizenid = GetCitizenId(player)

    player = Player(new_owner)
    local citizenid = GetCitizenId(player)
    if not player or not citizenid == -1 then
        Notification_S(src, "Hmm, is new owner in the city? we can't find him/her!", "primary")
        return
    end

    MySQL.Async.fetchAll("SELECT id,owner_citizenid FROM keep_containers WHERE random_id = ?", {
        random_id
    }, function(res)
        res = res[1]
        if not is_owner(res.owner_citizenid, o_citizenid) then
            Notification_S(src, "Only owner of this container can change transfer ownership!", "primary")
            return
        end

        MySQL.Async.execute("UPDATE keep_containers SET owner_citizenid = ?, password = ? WHERE id = ?", {
            citizenid,
            GetPasswordHash("0000"),
            res.id
        }, function()
            Notification_S(src, "Transfer completed.", "primary")
            Notification_S(new_owner, "Transfer completed.", "primary")
            Notification_S(new_owner, "Password is set to '0000'", "success")
        end)
    end)
end)

local function is_super_user(citizenid)
    if Config.super_users[citizenid] and Config.super_users[citizenid] == true then return true end
    return false
end

RegisterNetEvent("keep-containers:server:container:delete", function(random_id, zone_name)
    local src = source
    local player = Player(src)
    local citizenid = GetCitizenId(player)

    if not is_super_user(citizenid) then
        Notification_S(src, "Hmm, you can't do that!", "primary")
        return
    end

    MySQL.Async.execute("UPDATE keep_containers SET deleted = ?, deleted_by = ? WHERE random_id = ? AND zone = ?", {
        true,
        citizenid,
        random_id,
        zone_name
    }, function()
        Notification_S(src, "Container has been removed!", "primary")
        TriggerClientEvent("keep-containers:client:update_zone", -1, zone_name)
    end)
end)

RegisterNetEvent("keep-containers:server:container:update_position", function(random_id, zone_name, new_position)
    local src = source
    local player = Player(src)
    local citizenid = GetCitizenId(player)

    if type(new_position) ~= "vector4" then
        Notification_S(src, "Wrong position type!", "primary")
        return
    end

    if not is_super_user(citizenid) then
        Notification_S(src, "Hmm, you can't do that!", "primary")
        TriggerClientEvent("keep-containers:client:update_zone", src, zone_name)
        return
    end

    MySQL.Async.fetchAll("SELECT id,owner_citizenid,container_type FROM keep_containers WHERE random_id = ?", {
        random_id
    }, function(res)
        res = res[1]
        MySQL.Async.execute("UPDATE keep_containers SET position = ? WHERE id = ?", {
            json.encode(new_position),
            res.id
        }, function(res)
            if res then
                Notification_S(src, "Completed.", "primary")
                TriggerClientEvent("keep-containers:client:update_zone", -1, zone_name)
            end
        end)
    end)
end)

------------------------------
--          ITEMS
------------------------------

if Framework == 1 or Framework == 3 then
    for k, v in pairs(GetContainerItems()) do
        Core.Functions.CreateUseableItem(k, function(source, item)
            local player = Player(source)
            if not player then return end
            creation_list[source] = k
            TriggerClientEvent("keep-containers:client:container:place", source, k)
        end)
    end
elseif Framework == 2 then
    for k, v in pairs(GetContainerItems()) do
        Core.RegisterUsableItem(k, function(playerId)
            local player = Player(playerId)
            if not player then return end
            creation_list[playerId] = k
            TriggerClientEvent("keep-containers:client:container:place", playerId, k)
        end)
    end
end
