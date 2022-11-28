function Qtarget( private, entity )
    exports["qtarget"]:AddTargetEntity(entity, {
        options = {
            {
                icon = "fas fa-box",
                label = "Open Container",
                action = function() OpenContainer(private, entity) end
             },
            {
                icon = "fa-solid fa-key",
                label = "Change Password",
                action = function() ChangePassword(private, entity) end
             },
            {
                icon = "fa-solid fa-right-left",
                label = "Transfer Ownership",
                action = function() TransferOwnership(private, entity) end
             },
            {
                icon = "fas fa-trash",
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
