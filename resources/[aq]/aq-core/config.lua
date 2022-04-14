AQConfig = {}

AQConfig.MaxPlayers = GetConvarInt('sv_maxclients', 64) -- Gets max players from config file, default 32
AQConfig.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)
AQConfig.UpdateInterval = 5 -- how often to update player data in minutes
AQConfig.StatusInterval = 5000 -- how often to check hunger/thirst status in ms

AQConfig.Money = {}
AQConfig.Money.MoneyTypes = {['cash'] = 500, ['bank'] = 5000, ['crypto'] = 0 } -- ['type']=startamount - Add or remove money types for your server (for ex. ['blackmoney']=0), remember once added it will not be removed from the database!
AQConfig.Money.DontAllowMinus = {'cash', 'crypto'} -- Money that is not allowed going in minus
AQConfig.Money.PayCheckTimeOut = 10 -- The time in minutes that it will give the paycheck

AQConfig.Player = {}
AQConfig.Player.MaxWeight = 120000 -- Max weight a player can carry (currently 120kg, written in grams)
AQConfig.Player.MaxInvSlots = 41 -- Max inventory slots for a player
AQConfig.Player.HungerRate = 4.2 -- Rate at which hunger goes down.
AQConfig.Player.ThirstRate = 3.8 -- Rate at which thirst goes down.
AQConfig.Player.Bloodtypes = {
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
}

AQConfig.Server = {} -- General server config
AQConfig.Server.closed = false -- Set server closed (no one can join except people with ace permission 'aqadmin.join')
AQConfig.Server.closedReason = "Server Closed" -- Reason message to display when people can't join the server
AQConfig.Server.uptime = 0 -- Time the server has been up.
AQConfig.Server.whitelist = false -- Enable or disable whitelist on the server
AQConfig.Server.discord = "https://discord.gg/PjHzw8tNmC" -- Discord invite link
AQConfig.Server.PermissionList = {} -- permission list
