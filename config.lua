--                _
--               | |
--   _____      _| | _____  ___ _ __
--  / __\ \ /\ / / |/ / _ \/ _ \ '_ \
--  \__ \\ V  V /|   <  __/  __/ |_) |
--  |___/ \_/\_/ |_|\_\___|\___| .__/
--                             | |
--                             |_|
-- https://github.com/swkeep
Config = Config or {}

-- to add more items/containers check shared/containers.lua

Config.MagicTouch = false
Config.FrameWork = "qb" -- qb/esx
Config.input = "qb-input" -- keep-input / qb-input / ox_lib (ESX)
Config.esx_target = "ox_target" -- ox_target / qtarget (ONLY ESX won't effect qbcore)

Config.container_depots = {
    -- when adding new zone make sure it has enough minZ and maxZ or might get into issue with placing system
    ["LT_WELD_SUPPLY"] = {
        name = "LT Weld Ssupply",
        positions = {
            vector2(1219.7977294922, -1369.8439941406),
            vector2(1177.3232421875, -1366.3834228516),
            vector2(1183.0499267578, -1292.2061767578),
            vector2(1226.3927001953, -1296.7211914062)
         },
        minz = 33.00,
        maxz = 40.00,
        blip = {
            name = "Containers Depot",
            coords = vector3(1199.14, -1364.4923, 35.21),
            scale = 1.5,
            color = 43,
            sprite = 677
         }
    },
    ["POSTAL"] = {
        name = "Postal Depot",
        positions = {
            vector2(1178.2783203125, -1287.4509277344),
            vector2(1175.4, -1232),
            vector2(1203.64, -1222.33),
            vector2(1229.0767822266, -1221.9503173828),
            vector2(1227.5753173828, -1289.41796875)
        },
        minz = 33.00,
        maxz = 45.00,
        blip = {
            name = "Postal Containers Depot",
            coords = vector3(1199.14, -1364.4923, 35.21),
            scale = 1.5,
            color = 43,
            sprite = 677
         }
    }
}

-- just give it to admins they can access containers and remove them!
Config.super_users = {
    ["Gxxxxxxx2"] = true, -- < in qb use character citizen id
    ["char1:8xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx5"] = true --- < in esx use users's identifier 
}

-- Who can use BoltCutter (Police by defualt)

Config.bolt_cutter = {
    -- ['jobname'] = {grades}
    ["police"] = {
        -- [grade(number)] = true/false
        [0] = true,
        [1] = true
    }
}

Config.remove_bolt_cutter_on_use = true
-- Do not change this value (if you already have a bolt cutter item, you can change it to what you have)
Config.bolt_cutter_item_name = "containerboltcutter"
