function MoveContainer( private, entity )
    local Framework = Framework()
    local zone_name, zone = GetCurrentZone()
    if Framework == 1 then
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

            TriggerEvent("keep-containers:client:container:update_location", private.random_id, zone_name, private.container_type)
            DeleteEntity(entity)
        end
    elseif Framework == 2 then
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
                TriggerEvent("keep-containers:client:container:update_location", private.random_id, zone_name, private.container_type)
                DeleteEntity(entity)
            end
        else
            local inputData = lib.inputDialog("Confirm", {
                "Type Confirm (^.^)"
             })
            if inputData and inputData[1] == "Confirm" then
                TriggerEvent("keep-containers:client:container:update_location", private.random_id, zone_name, private.container_type)
                DeleteEntity(entity)
            end
        end
    end
end

function DeleteContainer( private, entity )
    local Framework = Framework()
    local zone_name, zone = GetCurrentZone()
    if Framework == 1 then
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
        if confData and confData.conf == "Confirm" then TriggerServerEvent("keep-containers:server:container:delete", private.random_id, zone_name) end
    elseif Framework == 2 then
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
            if confData and confData.conf == "Confirm" then TriggerServerEvent("keep-containers:server:container:delete", private.random_id, zone_name) end
        else
            local inputData = lib.inputDialog("Confirm", {
                "Type Confirm (^.^)"
             })
            if inputData and inputData[1] == "Confirm" then TriggerServerEvent("keep-containers:server:container:delete", private.random_id, zone_name) end
        end
    end
end

function TransferOwnership( private, entity )
    local Framework = Framework()
    local zone_name, zone = GetCurrentZone()

    if Framework == 1 then
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
            if confData and confData.conf == "Confirm" then TriggerServerEvent("keep-containers:server:container:transfer_ownership", private.random_id, zone_name, inputData.new_owner) end
        end
    elseif Framework == 2 then
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
                    TriggerServerEvent("keep-containers:server:container:transfer_ownership", private.random_id, zone_name, inputData[1])
                else
                    Notification_c("Transfer of ownership has been canceled.", "error")
                end
            end
        end
    end
end

function ChangePassword( private, entity )
    local Framework = Framework()
    local zone_name, zone = GetCurrentZone()

    if Framework == 1 then
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
        if inputData and inputData.current_password and inputData.new_password and (zone_name ~= -1) then
            TriggerServerEvent("keep-containers:server:container:change_password", private.random_id, inputData.current_password, inputData.new_password, zone_name)
        end
    elseif Framework == 2 then
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
                TriggerServerEvent("keep-containers:server:container:change_password", private.random_id, inputData[1], inputData[2], zone_name)
            end
        end
    end

end

function OpenContainer( private, entity )
    local Framework = Framework()
    local zone_name, zone = GetCurrentZone()

    if Framework == 1 then
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
        if inputData and inputData.password then TriggerServerEvent("keep-containers:server:container:check_password", private.random_id, inputData.password, zone_name) end
    elseif Framework == 2 then
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
            if inputData and inputData.password then TriggerServerEvent("keep-containers:server:container:check_password", private.random_id, inputData.password, zone_name) end
        else
            local inputData = lib.inputDialog("Container", {
                {
                    type = "input",
                    label = "Password",
                    password = true,
                    icon = "lock"
                 }
            })
            if inputData and inputData[1] then TriggerServerEvent("keep-containers:server:container:check_password", private.random_id, inputData[1], zone_name) end
        end
    end
end

local function LoadAnimationDict( animation )
    RequestAnimDict(animation)
    while not HasAnimDictLoaded(animation) do Wait(25) end
    return true
end

local function bolt_cutter( entity, random_id, zone_name )
    local scene
    local playerped = PlayerPedId()
    local playercoords, pedRotation = GetEntityCoords(playerped), GetEntityRotation(playerped)
    local animDict = "anim@scripted@heist@ig4_bolt_cutters@male@"
    local scenePos = vector3(playercoords.x, playercoords.y, playercoords.z + 0.2)
    local sceneRot = pedRotation
    LoadAnimationDict(animDict)

    local cutter = GetHashKey("h4_prop_h4_bolt_cutter_01a")
    local bag = GetHashKey("ch_p_m_bag_var02_arm_s")
    LoadModel(cutter)
    LoadModel(bag)
    -- spawn cutter
    cutter = CreateObject(cutter, playercoords, 1, 1, 0)
    -- spawn bag
    bag = CreateObject(bag, playercoords, 1, 1, 0)

    Wait(50)
    scene = NetworkCreateSynchronisedScene(scenePos, sceneRot, 2, true, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(playerped, scene, animDict, "action_male", 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(cutter, scene, animDict, "action_cutter", 1.0, -1.0, 1148846080)
    NetworkAddEntityToSynchronisedScene(bag, scene, animDict, "action_bag", 1.0, -1.0, 1148846080)
    NetworkStartSynchronisedScene(scene)
    Wait(5750)
    NetworkStopSynchronisedScene(scene)
    DeleteEntity(bag)
    DeleteEntity(cutter)

    TriggerServerEvent("keep-containers:server:open_with_bolt_cutter", random_id, zone_name)
end

RegisterNetEvent("keep-containers:targets:use_bolt_cutter", function( entity, random_id, zone_name ) bolt_cutter(entity, random_id, zone_name) end)

function BoltCutter( private, entity )
    local zone_name, Zone = GetCurrentZone()
    if not zone_name or not Zone then
        Notification_c("The container cannot be outside the depot!", "error")
        return
    end
    TriggerServerEvent("keep-containers:server:use_bolt_cutter", entity, private.random_id, zone_name)
end

function SuperUser()
    local PlayerData = PlayerData()
    local citizenid = GetCitizenId(PlayerData)
    return is_super_user(citizenid)
end

function HasAccessToBoltCutter()
    local job_name, job_grade = GetJob()
    if Config.bolt_cutter[tostring(job_name)] then
        if Config.bolt_cutter[tostring(job_name)][tonumber(job_grade)] and Config.bolt_cutter[tostring(job_name)][tonumber(job_grade)] == true then return true end
        return false
    end
    return false
end
