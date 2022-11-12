function Qb_target(private,entity)
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
end