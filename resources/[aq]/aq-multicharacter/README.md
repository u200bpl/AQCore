# aq-multicharacter
Multi Character Feature for aq-core Framework :people_holding_hands:

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
- [aq-spawn](https://github.com/AQCore-framework/aq-spawn) - Spawn selector
- [aq-apartments](https://github.com/AQCore-framework/aq-apartments) - For giving the player a apartment after creating a character.
- [aq-clothing](https://github.com/AQCore-framework/aq-clothing) - For the character creation and saving outfits.
- [aq-weathersync](https://github.com/AQCore-framework/aq-weathersync) - For adjusting the weather while player is creating a character.

## Screenshots
![Character Selection](https://i.imgur.com/EUB5X6Y.png)
![Character Registration](https://i.imgur.com/RKxiyed.png)

## Features
- Ability to create up to 5 characters and delete any character.
- Ability to see character information during selection.

## Installation
### Manual
- Download the script and put it in the `[aq]` directory.
- Add the following code to your server.cfg/resouces.cfg
```
ensure aq-core
ensure aq-multicharacter
ensure aq-spawn
ensure aq-apartments
ensure aq-clothing
ensure aq-weathersync
```
