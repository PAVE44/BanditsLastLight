BLLEvents = BLLEvents or {}

-- when player starts the game
BLLEvents.GroupStart = function(params)
    -- fade out
    BLLQueueManager.Add("FadeOut", {time=0}, 0)

    -- player start coords
    local px = 12615
    local py = 618
    local pz = 0
    BLLQueueManager.Add("Teleport", {x = px, y = py, z = pz}, 100)

    -- base coord
    local bx = 12570
    local by = 600
    local bz = 0
    BLLQueueManager.Add("ProceduralPlacement", {proc = "MilitaryBase", x = bx, y = by, z = bz}, 2000)

    -- apc coords
    local apc = {}
    table.insert(apc, {x=12596, y=610, dir=IsoDirections.S, vtype="Base.M113_APC"})
    table.insert(apc, {x=12604, y=612, dir=IsoDirections.S, vtype="Base.M113_APC"})
    -- table.insert(apc, {x=12596, y=325, dir=IsoDirections.S, vtype="Base.M113_APC"})
    -- table.insert(apc, {x=12604, y=327, dir=IsoDirections.S, vtype="Base.M113_APC"})
    -- table.insert(apc, {x=12596, y=340, dir=IsoDirections.S, vtype="Base.M113_APC"})
    -- table.insert(apc, {x=12604, y=342, dir=IsoDirections.S, vtype="Base.M113_APC"})

    for i=1, #apc do
        BLLQueueManager.Add("VehicleSpawn", apc[i], 2200)
    end

    -- fade in
    BLLQueueManager.Add("FadeIn", {time=4}, 3000)
end

-- when player orders bridge barricade detonation
BLLEvents.GroupBridge = function(params)
    BLLQueueManager.Add("Explosion", {x = 12593, y = 963, z = pz, clear=true}, 100 + ZombRand(600))
    BLLQueueManager.Add("Explosion", {x = 12596, y = 963, z = pz, clear=true}, 100 + ZombRand(600))
    BLLQueueManager.Add("Explosion", {x = 12600, y = 963, z = pz, clear=true}, 100 + ZombRand(600))
    BLLQueueManager.Add("Explosion", {x = 12603, y = 963, z = pz, clear=true}, 100 + ZombRand(600))
end

