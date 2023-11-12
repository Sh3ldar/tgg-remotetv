[Join our Discord](https://discord.gg/yflip)  
[Showcase video](https://youtu.be/nxs7fEmt8g4)

## Installation

### Config

A framework is required when you want to use the remote control as a usable item in your inventory.
Otherwise, you can use the resource as a standalone.

```lua
Config.Framework = 'QB'
Config.Framework = 'ESX'
```

If you want to use the resource as standalone you must keep `Config.UsableItem` to _false_ and follow the instructions below.

```lua
Config.Framework = 'Standalone'
```

**IMPORTANT** - If you want to use the item as usable you need to provide:

```lua
Config.Framework = 'ESX' or 'QB'
```

If the usable item is `false` you need to provide the (`Config.CommandDescription`, `Config.Keybind`) to open the TV menu.

If the usable item is true the `Keybind` won't work and you must have an item in your inventory with the name 'remotecontrol' to open the TV menu.

And the `Config.Framework` should be 'ESX' or 'QB'.

```lua
Config.UsableItem = false
```

```lua
Config.CommandDescription = 'Open the remote control menu.' -- The command description.
Config.Keybind = 'F2' -- The keybind to open the TV menu.
```

```
Config.DistanceToTv = 10.0 -- How far you can be from the TV to interact with it(suggested default is - 10.0).
```

If you want to use the remote control prop animation in hand - Make sure that you have started the resource with the remote control prop(`tgg-remotecontrol-prop`) otherwise, it will not work. 
*Locate it in the `[assets]` folder.*

```lua
Config.RemoteControlInHand = true
```

1. Dependency
   Download this resource - https://forum.cfx.re/t/release-generic-dui-2d-3d-renderer/131208
2. Configuration
   `ensure generic_texture_renderer_gfx` - This is a dependency and **MUST** be started before the script.

   ```
   ensure generic_texture_renderer_gfx

   ensure tgg-remotecontrol-prop - This is a dependency if the `Config.RemoteControlInHand` is set to true.
   ensure tgg-remotetv
   ```
***
## Item setup

### QB Core

- Add the item below in `shared.lua`
  ```lua
  ["remotecontrol"] = {
  ["name"] = "remotecontrol",
  ["label"] = "Remote control",
  ["weight"] = 10,
  ["type"] = "item",
  ["image"] = "remotecontrol.png", -- Use the image included in the script.
  ["unique"] = false,
  ["useable"] = true,
  ["shouldClose"] = true,
  ["combinable"] = nil,
  ["description"] = "Oh, will you watch tv?"
  },
  ```

---

### ESX

- Insert the item in the database
  ```sql
  INSERT INTO `items`(`name`, `label`, `weight`, `limit`, `rare`, `can_remove`) VALUES ('remotecontrol','remotecontrol', 1, 1, 0, 1)
  ```

### ox_inventory

- Add the item below in `data/items.lua`

  ```lua
  ['remotecontrol'] = {
  label = "Remote control",
  weight = 10,
  stack = false,
  consume = 0,
  description = "Oh, will you watch tv?",
  client = {
    event = "tgg-remotetv:use",
    },
  }
  ```

```

3. Ensure that the resource name is `tgg-remotetv`.
```
