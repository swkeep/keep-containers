--                _
--               | |
--   _____      _| | _____  ___ _ __
--  / __\ \ /\ / / |/ / _ \/ _ \ '_ \
--  \__ \\ V  V /|   <  __/  __/ |_) |
--  |___/ \_/\_/ |_|\_\___|\___| .__/
--                             | |
--                             |_|
-- https://github.com/swkeep
-- container's types
local types = {
    ["SMALL"] = {
        size = 75000,
        slots = 25
    },
    ["MID"] = {
        size = 100000,
        slots = 50
    },
    ["BIG"] = {
        size = 500000,
        slots = 75
    }
}

-- container's objects
local Object = {
    ["SMALL"] = {
        ["green"] = {
            -- no logo
            name = "prop_container_05mb", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["red"] = {
            -- no logo
            name = "prop_container_05a", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["redred"] = {
            -- no logo
            name = "prop_container_ld_pu", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        }
    },
    ["MID"] = {
        ["red"] = {
            -- no logo
            name = "prop_container_03a", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["blue"] = {
            -- no logo
            name = "prop_container_03b", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["green"] = {
            -- no logo
            name = "prop_container_01mb", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["old"] = {
            -- no logo
            name = "prop_container_old1", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        }
    },
    ["BIG"] = {
        ["red"] = {
            -- no logo
            name = "prop_container_01a", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["green"] = {
            -- no logo
            name = "prop_container_01mb", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["krapea_green"] = {
            -- logo krapea
            name = "prop_container_01b", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["bilgeco_blue"] = {
            -- logo bilgeco
            name = "prop_container_01c", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["bilgeco_green"] = {
            -- logo bilgeco
            name = "prop_container_01e", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["teal"] = {
            -- logo jetsam
            name = "prop_container_01d", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["white"] = {
            -- logo lando-crop
            name = "prop_container_01f", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["postal_white"] = {
            -- logo lando-crop
            name = "prop_container_01g", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        },
        ["brown"] = {
            -- logo lando-crop
            name = "prop_container_01h", -- Embedded Collision, basegame
            offset = vector3(0, 0, 0)
        }
    }
}

-- ESX
local containers = {
    ["container_green_small"] = {
        type = types.SMALL,
        object = Object.SMALL.green
    },

    ["container_blue_mid"] = {
        type = types.BIG,
        object = Object.BIG.teal
    },

    ["container_old_mid"] = {
        type = types.BIG,
        object = Object.MID.old
    },

    ["container_white_mid"] = {
        type = types.BIG,
        object = Object.BIG.white
    }
}

-- QBCORE
local qbcore_containers = {
    ["containergreensmall"] = {
        type = types.SMALL,
        object = Object.SMALL.green
    },

    ["containerbluemid"] = {
        type = types.BIG,
        object = Object.BIG.teal
    },

    ["containeroldmid"] = {
        type = types.BIG,
        object = Object.MID.old
    },

    ["containerwhitemid"] = {
        type = types.BIG,
        object = Object.BIG.white
    }
}

function GetContainerInfromation(container_name)
    if Framework() == 1 then
        if qbcore_containers[container_name] then return qbcore_containers[container_name] end
    elseif Framework() == 2 or Framework() == 3 then
        if containers[container_name] then return containers[container_name] end
    end
    return false
end

function GetContainerItems()
    if Framework() == 1 then
        return qbcore_containers
    elseif Framework() == 2 or Framework() == 3 then
        return containers
    end
end
