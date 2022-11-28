function Ox_target( private, entity )
    exports["ox_target"]:addLocalEntity(entity, {
        {
            icon = "fas fa-box",
            distance = 1.0,
            label = "Open Container",
            onSelect = function() OpenContainer(private, entity) end
         },
        {
            icon = "fa-solid fa-key",
            distance = 1.0,
            label = "Change Password",
            onSelect = function() ChangePassword(private, entity) end
         },
        {
            icon = "fa-solid fa-right-left",
            distance = 1.0,
            label = "Transfer Ownership",
            onSelect = function() TransferOwnership(private, entity) end
         },
        {
            icon = "fas fa-trash",
            distance = 1.0,
            label = "Delete Container",
            canInteract = function() return SuperUser() end,
            onSelect = function() DeleteContainer(private, entity) end
         },
        {
            icon = "fa-solid fa-arrows-up-down-left-right",
            distance = 1.0,
            label = "Move Container",
            canInteract = function() return SuperUser() end,
            onSelect = function() MoveContainer(private, entity) end
        },
        {
            icon = "fa-solid fa-scissors",
            distance = 1.0,
            label = "Boltcutter (Police)",
            canInteract = function() return HasAccessToBoltCutter() end,
            onSelect = function() BoltCutter(private, entity) end
        }
    })
end
