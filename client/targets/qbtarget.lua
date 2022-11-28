function Qb_target( private, entity )
    exports["qb-target"]:AddTargetEntity(entity, {
        options = {
            {
                icon = "fas fa-box",
                label = "Open Container",
                action = function() OpenContainer(private, entity) end
             },
            {
                icon = "fas fa-box",
                label = "Change Password",
                action = function() ChangePassword(private, entity) end
             },
            {
                icon = "fas fa-box",
                label = "Transfer Ownership",
                action = function() TransferOwnership(private, entity) end
             },
            {
                icon = "fas fa-box",
                label = "Delete Container",
                canInteract = function() return SuperUser() end,
                action = function() DeleteContainer(private, entity) end
             },
            {
                icon = "fa-solid fa-arrows-up-down-left-right",
                label = "Move Container",
                canInteract = function() return SuperUser() end,
                action = function() MoveContainer(private, entity) end
             },
             {
                icon = "fa-solid fa-scissors",
                label = "Boltcutter (Police)",
                canInteract = function() return HasAccessToBoltCutter() end,
                action = function() BoltCutter(private, entity) end
             }
        },
        distance = 1.0
    })
end
