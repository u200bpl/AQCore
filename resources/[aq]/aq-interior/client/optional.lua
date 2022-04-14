local function CreateK4Lester(spawn)
	local objects = {}
    local POIOffsets = {}
    POIOffsets.exit = json.decode('{\
    "x": -1.780,\
    "y": -0.795,\
    "z": 1.1,\
    "h": 270.30,\
    }')
	DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
	RequestModel(`shell_lester`)
	while not HasModelLoaded(`shell_lester`) do
	    Citizen.Wait(1000)
	end
	local house = CreateObject(`shell_lester`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(house, true)
	objects[#objects+1] = house
	TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z, POIOffsets.exit.h)
    return { objects, POIOffsets }
end

local function CreateK4Ranch(spawn)
	local objects = {}
    local POIOffsets = {}
    POIOffsets.exit = json.decode('{\
    "x": -1.257,\
    "y": -5.469,\
    "z": 2.5,\
    "h": 270.57,\
    }')
	DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
	RequestModel(`shell_ranch`)
	while not HasModelLoaded(`shell_ranch`) do
	    Citizen.Wait(1000)
	end
	local house = CreateObject(`shell_ranch`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(house, true)
	objects[#objects+1] = house
	TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 2.0, POIOffsets.exit.h)
    return { objects, POIOffsets }
end

local function CreateK4Trailer(spawn)
	local objects = {}
    local POIOffsets = {}
    POIOffsets.exit = json.decode('{\
    "x": -1.235,\
    "y": -2.027,\
    "z": 2.5,\
    "h": 349.74,\
    }')
	DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
	RequestModel(`shell_trailer`)
	while not HasModelLoaded(`shell_trailer`) do
	    Citizen.Wait(1000)
	end
	local house = CreateObject(`shell_trailer`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(house, true)
	objects[#objects+1] = house
	TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 2.0, POIOffsets.exit.h)
    return { objects, POIOffsets }
end

local function CreateK4Trevor(spawn)
	local objects = {}
    local POIOffsets = {}
    POIOffsets.exit = json.decode('{\
    "x": 0.104,\
    "y": -3.794,\
    "z": 2.5,\
    "h": 359.01,\
    }')
	DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
	RequestModel(`shell_trevor`)
	while not HasModelLoaded(`shell_trevor`) do
	    Citizen.Wait(1000)
	end
	local house = CreateObject(`shell_trevor`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(house, true)
	objects[#objects+1] = house
	TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 2.0, POIOffsets.exit.h)
    return { objects, POIOffsets }
end

local function CreateK4Michael(spawn)
	local objects = {}
    local POIOffsets = {}
    POIOffsets.exit = json.decode('{\
    "x": -9.417,\
    "y": 5.656,\
    "z": 8.1,\
    "h": 268.17,\
    }')
	DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
	RequestModel(`shell_michael`)
	while not HasModelLoaded(`shell_michael`) do
	    Citizen.Wait(1000)
	end
	local house = CreateObject(`shell_michael`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(house, true)
	objects[#objects+1] = house
	TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 2.0, POIOffsets.exit.h)
    return { objects, POIOffsets }
end

local function CreateK4Low(spawn)
	local objects = {}
    local POIOffsets = {}
    POIOffsets.exit = json.decode('{\
    "x": 4.728,\
    "y": -6.432,\
    "z": 1.1,\
    "h": 356.89,\
    }')
	DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
	RequestModel(`shell_v16low`)
	while not HasModelLoaded(`shell_v16low`) do
	    Citizen.Wait(1000)
	end
	local house = CreateObject(`shell_v16low`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(house, true)
	objects[#objects+1] = house
	TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + 2.0, POIOffsets.exit.h)
    return { objects, POIOffsets }
end

local function CreateK4Mid(spawn)
	local objects = {}
    local POIOffsets = {}
    POIOffsets.exit = json.decode('{\
    "x": 1.468,\
    "y": -14.286,\
    "z": 1.1,\
    "h": 359.82,\
    }')
	DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
	RequestModel(`shell_v16mid`)
	while not HasModelLoaded(`shell_v16mid`) do
	    Citizen.Wait(1000)
	end
	local house = CreateObject(`shell_v16mid`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(house, true)
	objects[#objects+1] = house
	TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z, POIOffsets.exit.h)
    return { objects, POIOffsets }
end

local function CreateK4High(spawn)
	local objects = {}
    local POIOffsets = {}
    POIOffsets.exit = json.decode('{\
    "x": -22.170,\
    "y": -0.464,\
    "z": 7.5,\
    "h": 268.09,\
    }')
	DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
	RequestModel(`shell_highend`)
	while not HasModelLoaded(`shell_highend`) do
	    Citizen.Wait(1000)
	end
	local house = CreateObject(`shell_highend`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(house, true)
	objects[#objects+1] = house
	TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + POIOffsets.exit.z, POIOffsets.exit.h)
    return { objects, POIOffsets }
end

local function CreateK4High2(spawn)
	local objects = {}
    local POIOffsets = {}
    POIOffsets.exit = json.decode('{\
    "x": -10.326,\
    "y": 0.803,\
    "z": 6.55,\
    "h": 268.45,\
    }')
	DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
	RequestModel(`shell_highendv2`)
	while not HasModelLoaded(`shell_highendv2`) do
	    Citizen.Wait(1000)
	end
	local house = CreateObject(`shell_highendv2`, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(house, true)
	objects[#objects+1] = house
	TeleportToInterior(spawn.x + POIOffsets.exit.x, spawn.y + POIOffsets.exit.y, spawn.z + POIOffsets.exit.z, POIOffsets.exit.h)
    return { objects, POIOffsets }
end

-- Exports

exports('CreateK4Lester', CreateK4Lester)
exports('CreateK4Ranch', CreateK4Ranch)
exports('CreateK4Trailer', CreateK4Trailer)
exports('CreateK4Trevor', CreateK4Trevor)
exports('CreateK4Michael', CreateK4Michael)
exports('CreateK4Low', CreateK4Low)
exports('CreateK4Mid', CreateK4Mid)
exports('CreateK4High', CreateK4High)
exports('CreateK4High2', CreateK4High2)