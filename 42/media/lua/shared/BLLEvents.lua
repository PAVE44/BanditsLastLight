BLLEvents = BLLEvents or {}

BLLEvents.VehicleSpawn = function(params)
    BLLVehicles.Spawn(params.x, params.y, params.dir, params.vtype)
end

BLLEvents.SetVar = function(params)
    BLLVars.Set(params.key, params.val)
end

BLLEvents.FadeOut = function(params)
    local playerList = BanditPlayer.GetPlayers()
    for i=0, playerList:size()-1 do
        local player = playerList:get(i)
        if player then
            local playerNum = player:getPlayerNum()
            player:setBlockMovement(true)
            player:setBannedAttacking(true)
            UIManager.setFadeBeforeUI(playerNum, false)
            UIManager.FadeOut(playerNum, params.time)
        end
    end
end

BLLEvents.FadeIn = function(params)
    local playerList = BanditPlayer.GetPlayers()
    for i=0, playerList:size()-1 do
        local player = playerList:get(i)
        if player then
            local playerNum = player:getPlayerNum()
            player:setBlockMovement(false)
            player:setBannedAttacking(false)
            UIManager.FadeIn(playerNum, params.time)
            UIManager.setFadeBeforeUI(playerNum, false)
        end
    end
end

BLLEvents.Teleport = function(params)
    local playerList = BanditPlayer.GetPlayers()
    for i=0, playerList:size()-1 do
        local player = playerList:get(i)
        if player then
            player:setX(params.x + i)
            player:setY(params.y + i)
            player:setZ(params.z)
            player:setLastX(params.x + i)
            player:setLastY(params.y + i)
            player:setLastZ(params.z)
        end
    end
    getWorld():update()
end

BLLEvents.ProceduralPlacement = function(params)
    if BanditProc[params.proc] then
        BanditProc[params.proc](params.x, params.y, params.z)
    end
end

BLLEvents.Explosion = function(params)
    local sounds = {"BurnedObjectExploded", "FlameTrapExplode", "SmokeBombExplode", "PipeBombExplode", 
                    "BLL_ExploClose1", "BLL_ExploClose2", "BLL_ExploClose3", "BLL_ExploClose4", "BLL_ExploClose5", 
                    "BLL_ExploClose6", "BLL_ExploClose7", "DOExploClose8"}

    local function getSound()
        return sounds[1 + ZombRand(#sounds)]
    end

    local player = getSpecificPlayer(0)
    if not player then return end

    local cell = getCell()
    local x = params.x
    local y = params.y

    local square = cell:getGridSquare(x, y, 0)
    if not square then return end

    -- bomb sound
    local sound = getSound()
    local emitter = getWorld():getFreeEmitter(x, y, 0)
    emitter:playSound(sound)
    emitter:setVolumeAll(0.9)
    addSound(player, x, y, 0, 120, 100)

    -- wake up players
    BanditPlayer.WakeEveryone()
    
    -- explosion and fire

    IsoFireManager.explode(cell, square, 100)
    
    local effect = {}
    effect.x = square:getX()
    effect.y = square:getY()
    effect.z = square:getZ()
    effect.size = 640
    effect.colors = {r=0.1, g=0.7, b=0.2, a=0.2}
    effect.name = "explobig"
    effect.frameCnt = 17
    table.insert(BLLEffects.tab, effect)
    
    -- light blast
    local colors = {r=1.0, g=0.5, b=0.5}
    local lightSource = IsoLightSource.new(x, y, 0, colors.r, colors.g, colors.b, 60, 10)
    getCell():addLamppost(lightSource)
                
    local lightLevel = square:getLightLevel(0)
    if lightLevel < 0.95 and player:isOutside() then
        local px = player:getX()
        local py = player:getY()
        local sx = square:getX()
        local sy = square:getY()

        local dx = math.abs(px - sx)
        local dy = math.abs(py - sy)

        local tex
        local dist = math.sqrt(math.pow(sx - px, 2) + math.pow(sy - py, 2))
        if dist > 40 then dist = 40 end

        if dx > dy then
            if sx > px then
                tex = "e"
            else
                tex = "w"
            end
        else
            if sy > py then
                tex = "s"
            else
                tex = "n"
            end
        end

        BLLTex.tex = getTexture("media/textures/blast_" .. tex .. ".png")
        BLLTex.speed = 0.05
        BLLTex.mode = "full"
        local alpha = 1.2 - (dist / 40)
        if alpha > 1 then alpha = 1 end
        BLLTex.alpha = alpha
    end
    
    -- junk placement
    BanditBaseGroupPlacements.Junk (x-4, y-4, 0, 6, 8, 13)

    -- damage to zombies, players are safe
    local fakeItem = BanditCompatibility.InstanceItem("Base.RollingPin")
    local cell = getCell()
    for dx=x-3, x+5 do
        for dy=y-3, y+4 do
            local square = cell:getGridSquare(dx, dy, 0)
            if square then
                square:BurnWalls(false)
                if ZombRand(4) == 1 then
                    BanditBasePlacements.IsoObject("floors_burnt_01_1", dx, dy, 0)
                end
                local zombie = square:getZombie()
                if zombie then
                    zombie:Hit(fakeItem, cell:getFakeZombieForHit(), 50, false, 1, false)
                end
            end
        end
    end

    if params.clear then
        BanditBaseGroupPlacements.ClearSpace(x-2, y-2, 0, 5, 5)
    end
end