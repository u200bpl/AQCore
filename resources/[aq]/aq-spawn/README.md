# aq-spawn
Spawn Selector for aq-core Framework :eagle:

# License

    AQCore Framework
    Copyright (C) 2021 Joshua Eger

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>


## Dependencies
- [aq-core](https://github.com/AQCore-framework/aq-core)
- [aq-houses](https://github.com/AQCore-framework/aq-houses) - Lets player select the house
- [aq-apartment](https://github.com/AQCore-framework/aq-apartment) - Lets player select the apartment
- [aq-garages](https://github.com/AQCore-framework/aq-houses) - For house garages

## Screenshots
![Spawn selector](https://i.imgur.com/nz0mPGe.png)

## Features
- Ability to select spawn after selecting the character

## Installation
### Manual
- Download the script and put it in the `[aq]` directory.
- Import `aq-spawn.sql` in your database
- Add the following code to your server.cfg/resouces.cfg
```
ensure aq-core
ensure aq-spawn
ensure aq-apartmen
ensure aq-garages
```

## Configuration
An example to add spawn option
```
AQ.Spawns = {
    ["spawn1"] = { -- Needs to be unique
        coords = {
            x = 0.0, -- Coords player will be spawned
            y = 0.0, 
            z = 0.0, 
            h = 180.0
        },
        location = "spawn1", -- Needs to be unique
        label = "Spawn 1 Name", -- This is the label which will show up in selection menu.
    },
    ["spawn2"] = { -- Needs to be unique
        coords = {
            x = 1.1, -- Coords player will be spawned
            y = -1.1, 
            z = 1.1, 
            h = 180.0 
        }, 
        location = "spawn2", -- Needs to be unique
        label = "Spawn 2 Name", -- This is the label which will show up in selection menu.
    },
}
```
