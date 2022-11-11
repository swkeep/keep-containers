--                _
--               | |
--   _____      _| | _____  ___ _ __
--  / __\ \ /\ / / |/ / _ \/ _ \ '_ \
--  \__ \\ V  V /|   <  __/  __/ |_) |
--  |___/ \_/\_/ |_|\_\___|\___| .__/
--                             | |
--                             |_|
-- https://github.com/swkeep
---print tables : debug
---@param node table
function print_table( node )
    local cache, stack, output = {}, {}, {}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k, v in pairs(node) do size = size + 1 end

        local cur_index = 1
        for k, v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str, "}", output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str, "\n", output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output, output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "[" .. tostring(k) .. "]"
                else
                    key = "['" .. tostring(k) .. "']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep("\t", depth) .. key .. " = " .. tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep("\t", depth) .. key .. " = {\n"
                    table.insert(stack, node)
                    table.insert(stack, v)
                    cache[node] = cur_index + 1
                    break
                else
                    output_str = output_str .. string.rep("\t", depth) .. key .. " = '" .. tostring(v) .. "'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep("\t", depth - 1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then output_str = output_str .. "\n" .. string.rep("\t", depth - 1) .. "}" end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then output_str = output_str .. "\n" .. string.rep("\t", depth - 1) .. "}" end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output, output_str)
    output_str = table.concat(output)

    print(output_str)
end

-- Return the first index with the given value (or nil if not found).
function IndexOf( array, value )
    for i, v in ipairs(array) do if v == value then return i end end
    return nil
end

-- Return a key with the given value (or nil if not found).  If there are
-- multiple keys with that value, the particular key returned is arbitrary.
function KeyOf( tbl, value )
    for k, v in pairs(tbl) do if v == value then return k end end
    return nil
end

function RoundNum( n ) return math.floor(n + 0.5) end

function Round( num, dp )
    local mult = 10 ^ (dp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function RandomID( length )
    local string = ""
    for i = 1, length do
        local str = string.char(math.random(97, 122))
        if math.random(1, 2) == 1 then
            if math.random(1, 2) == 1 then
                str = str:upper()
            else
                str = str:lower()
            end
        else
            str = tostring(math.random(0, 9))
        end
        string = string .. str
    end
    return string
end

function Framework()
    if Config.FrameWork:lower() == "qb" then
        return 1
    elseif Config.FrameWork:lower() == "esx" then
        return 2
    end
end

function GetCoreObject()
    if Framework() == 1 then
        -- QBCore 
        return exports["qb-core"]:GetCoreObject()
    elseif Framework() == 2 then
        return exports["es_extended"]:getSharedObject()
    end
end

function TableToVector3( t ) return vector3(t.x, t.y, t.z) end

function LoadModel( hash )
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do Wait(10) end
    end
end

function WaitForEntity( entity ) while not DoesEntityExist(entity) do Wait(10) end end
