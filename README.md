![Keep-containers](https://raw.githubusercontent.com/swkeep/keep-containers/master/.github/images/keep-containers.jpg)

# keep-containers
By using this script you're going to have access to custom container depot zones.
In Container Depot you can place containers and have access to them with a password.

# Dependencies

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [keep-input](https://github.com/swkeep/keep-input) or [qb-input](https://github.com/qbcore-framework/qb-input)
- [PolyZone](https://github.com/mkafrin/PolyZone)
- [qb-target]()

OR

- [esx-legacy](https://github.com/esx-framework/esx-legacy)
- [keep-input](https://github.com/swkeep/keep-input) or [ox_lib](https://github.com/overextended/ox_lib)
- [PolyZone](https://github.com/mkafrin/PolyZone)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_target](https://github.com/overextended/ox_target)

## Features

- Custom container size and weight
- Ability to transfer ownership of containers
- Locking containers with password (encrypted by bcrypt)
- Container variant
- Dynamic object loading
- Little bit of admin control (WIP)
- Container placer! (i don't know what to call it!)

## Preview

- [Version 1.0.0](https://youtu.be/dTQa6EVSSVc)

## Screenshots
![Keep-containers](https://raw.githubusercontent.com/swkeep/keep-containers/master/.github/images/ox_target.jpg)
![Keep-containers](https://raw.githubusercontent.com/swkeep/keep-containers/master/.github/images/qbtarget.jpg)

## Installation

- Step 1: Drag and drop resources onto your server!
- Step 1-2: You don't need to import sql in your database script is doing it itself.
- Step 2: Configure the script in the framework of your choice.
- Step 3: Add items to the list

- QBCore (shared/items.lua)
```lua
    ["containergreensmall"] = {
        ["name"] = "containergreensmall",
        ["label"] = "Small Green Container",
        ["weight"] = 5000,
        ["type"] = "item",
        ["image"] = "container_green_small.png",
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = "Small Green Container"
    },

    ["containerbluemid"] = {
        ["name"] = "containerbluemid",
        ["label"] = "Mid Blue Container",
        ["weight"] = 5000,
        ["type"] = "item",
        ["image"] = "container_blue_mid.png",
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = "Small Green Container"
    },

    ["containeroldmid"] = {
        ["name"] = "containeroldmid",
        ["label"] = "Mid Old Container",
        ["weight"] = 5000,
        ["type"] = "item",
        ["image"] = "container_old_mid.png",
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = "Small Green Container"
    },

    ["containerwhitemid"] = {
        ["name"] = "containerwhitemid",
        ["label"] = "Mid White Container",
        ["weight"] = 5000,
        ["type"] = "item",
        ["image"] = "container_white_mid.png",
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = "Small Green Container"
    },

    ["containerboltcutter"] = {
        ["name"] = "containerboltcutter",
        ["label"] = "Boltcutter",
        ["weight"] = 1000,
        ["type"] = "item",
        ["image"] = "boltcutter.png",
        ["unique"] = true,
        ["useable"] = false,
        ["shouldClose"] = false,
        ["combinable"] = nil,
        ["description"] = "a boltcutter to open containers by police"
    }
```

- ESX (ox_inventory/data/items.lua)
```lua
    ["container_green_small"] = {
        label = "Small Green Container",
        weight = 5,
        stack = false,
        close = true,
        description = nil
     },

    ["container_blue_mid"] = {
        label = "Mid Blue Container",
        weight = 15,
        stack = false,
        close = true,
        description = nil
     },

    ["container_old_mid"] = {
        label = "Mid Old Container",
        weight = 15,
        stack = false,
        close = true,
        description = nil
     },

    ["container_white_mid"] = {
        label = "Mid White Container",
        weight = 15,
        stack = false,
        close = true,
        description = nil
     },

    ["containerboltcutter"] = {
        label = "Boltcutter",
        weight = 1,
        stack = false,
        close = false,
        description = 'a boltcutter to open containers by police'
     }
```

- Step 4: If you want to use ox_lib, make sure this line "@ox_lib/init.lua" in fxmanifest.lua is uncommented.
