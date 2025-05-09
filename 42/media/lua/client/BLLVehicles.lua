BLLVehicles = BLLVehicles or {}

BLLVehicles.tab = {}

BLLVehicles.tick = 0

local function sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

local dirMap = {}
dirMap.N = {}
for y=-8, -4 do
    for x=-1, 1 do
        table.insert(dirMap.N, {x=x, y=y})
    end
end

dirMap.S = {}
for y=4, 8 do
    for x=-1, 1 do
        table.insert(dirMap.S, {x=x, y=y})
    end
end

dirMap.W = {}
for x=-8, -4 do
    for y=-1, -1 do
        table.insert(dirMap.W, {x=x, y=y})
    end
end

dirMap.E = {}
for x=4, 8 do
    for y=-1, 1 do
        table.insert(dirMap.E, {x=x, y=y})
    end
end

BLLVehicles.dirMap = dirMap

local function manageDriver(square, vehicle)
    local md = vehicle:getModData()

    local cell = square:getCell()
    local vx = vehicle:getX()
    local vy = vehicle:getY()
    local dirMap = BLLVehicles.dirMap

    local dir = md.BLL.dir
    if dir then
        local vecs = dirMap[dir]

        -- stop if needed
        for _, vec in pairs(vecs) do
            local asquare = cell:getGridSquare(vx + vec.x, vy + vec.y, 0)
            if asquare then
                local shouldStop = false

                if not asquare:isFree(false) or asquare:isVehicleIntersecting() then
                    shouldStop = true
                elseif (asquare:getPlayer() and not asquare:getPlayer():isNPC()) then
                    local emitter = vehicle:getEmitter()
                    if not emitter:isPlaying("VehicleHornStandard") then
                        emitter:playSound("VehicleHornStandard")
                    end
                    shouldStop = true
                end

                if shouldStop then
                    vehicle:setRegulatorSpeed(0)
                    vehicle:setRegulator(false)
                    return
                end
            end
        end

        -- drive forward
        local emitter = vehicle:getEmitter()
        if emitter:isPlaying("VehicleHornStandard") then
            emitter:stopSoundByName("VehicleHornStandard")
        end
        if vehicle:isStopped() then
            vehicle:setRegulator(true)
            vehicle:setRegulatorSpeed(BLLVars.Get("convoySpeed"))
        end
    end

    -- engine smoke
    if BLLVehicles.tick % 48 == 0 and vehicle:isEngineRunning() then
        local angleX = vehicle:getAngleX()
        local angleY = vehicle:getAngleY()
        local angleZ = vehicle:getAngleZ()
        local vehicleRotation = calculateVehicleRotation(angleX, angleY, angleZ)
        local rad = math.rad(vehicleRotation)
        local l = 2.5
        local sx = vx - (l * math.cos(rad)) + ZombRandFloat(-0.5, 0.5)
        local sy = vy - (l * math.sin(rad)) + ZombRandFloat(-0.5, 0.5)

        local effect = {}
        effect.x = sx
        effect.y = sy
        effect.z = 0
        effect.size = 600
        effect.name = "smoke"
        effect.frameCnt = 60
        effect.repCnt = 5
        table.insert(BLLEffects.tab, effect)
    end
end

local function setDriver(square, vehicle)
    
    local npcAesthetics = SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, false)
    npcAesthetics:setForename("Driver")
    npcAesthetics:setSurname("Driver")
    npcAesthetics:dressInNamedOutfit("Police")

    local driver = IsoPlayer.new(cell, npcAesthetics, square:getX(), square:getY(), square:getZ())

    driver:setSceneCulled(false)
    driver:setNPC(true)
    driver:setGodMod(true)
    driver:setInvisible(true)
    driver:setGhostMode(true)

    local vx = driver:getForwardDirection():getX()
    local vy = driver:getForwardDirection():getY()
    local forwardVector = Vector3f.new(vx, vy, 0)
    
    if vehicle:getChunk() then
        vehicle:setPassenger(0, driver, forwardVector)
        driver:setVehicle(vehicle)
        driver:setCollidable(false)
    end

    vehicle:tryStartEngine(true)
    vehicle:engineDoStartingSuccess()
    vehicle:engineDoRunning()
    vehicle:setHeadlightsOn(true)
    vehicle:setPhysicsActive(true)
    return driver
end

local function setGunner(square, vehicle)
    
    local npcAesthetics = SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, false)
    npcAesthetics:setForename("Gunner")
    npcAesthetics:setSurname("Gunner")
    npcAesthetics:dressInNamedOutfit("Police")

    local gunner = IsoPlayer.new(cell, npcAesthetics, square:getX(), square:getY(), square:getZ())

    gunner:setSceneCulled(false)
    gunner:setNPC(true)
    gunner:setGodMod(true)
    gunner:setInvisible(true)
    gunner:setGhostMode(true)

    local vx = gunner:getForwardDirection():getX()
    local vy = gunner:getForwardDirection():getY()
    local forwardVector = Vector3f.new(vx, vy, 0)
    
    if vehicle:getChunk() then
        vehicle:setPassenger(1, gunner, forwardVector)
        gunner:setVehicle(vehicle)
        gunner:setCollidable(false)
    end

    return gunner
end

BLLVehicles.Repair = function(vehicle)
    -- we cant use vehicle:replair() because it will add armor to ki5 vehicles

    for i = 0, vehicle:getPartCount() - 1 do
        local part = vehicle:getPartByIndex(i)
        local area = part:getArea()

        if area and not area:embodies("Armor") then
            local cond = 70 + ZombRand(40)
            if cond > 100 then cond = 100 end
            part:setCondition(cond)
        end
    end

    local gasTank = vehicle:getPartById("GasTank")
    if gasTank then
        local max = gasTank:getContainerCapacity() * 0.7
        gasTank:setContainerContentAmount(ZombRandFloat(0, max))
    end
end


BLLVehicles.Spawn = function(x, y, dir, btype)
    local square = getCell():getGridSquare(x, y, 0)
    if square then

        if not square:isFree(false) then return end

        if square:isVehicleIntersecting() then return end

        local vehicle = addVehicle(btype, square:getX(), square:getY(), square:getZ())
        if vehicle then
            for i = 0, vehicle:getPartCount() - 1 do
                local container = vehicle:getPartByIndex(i):getItemContainer()
                if container then
                    container:removeAllItems()
                end
            end
            vehicle:getModData().BLL = {}
            BLLVehicles.Repair(vehicle)
            vehicle:setAlarmed(false)
            vehicle:setGeneralPartCondition(100, 80)
            vehicle:setPhysicsActive(true)

            local md = vehicle:getModData()
            if not md.BLL then md.BLL = {} end

            if dir == IsoDirections.N then
                vehicle:setAngles(0, 180, 0)
                md.BLL.dir = "N"
            elseif dir == IsoDirections.S then
                vehicle:setAngles(0, 0, 0)
                md.BLL.dir = "S"
            elseif dir == IsoDirections.E then
                vehicle:setAngles(0, 90, 0)
                md.BLL.dir = "E"
            elseif dir == IsoDirections.W then
                vehicle:setAngles(0, -90, 0)
                md.BLL.dir = "W"
            end

            md.BLL.turretDir = 0

            local id = vehicle:getId()
            BLLVehicles.tab[id] = vehicle

            --[[
            if args.lightbar or args.siren or args.alarm then
                local newargs = {id=vehicle:getId(), lightbar=args.lightbar, siren=args.siren, alarm=args.alarm}
                sendServerCommand('Commands', 'UpdateVehicle', newargs)
            end
            ]]
        end
    end
end

local Manage = function(ticks)
    -- if true then return end
    BLLVehicles.tick = ticks

    if ticks % 6 > 0 then return end

    local player = getSpecificPlayer(0)
    if not player then return end

    local vehicleList = BLLVehicles.tab
    for id, vehicle in pairs(vehicleList) do
        local controller = vehicle:getController()
        if not controller then
            BLLVehicles.tab[id] = nil
            break
        end

        if not vehicle:isSeatInstalled(0) then
            BLLVehicles.tab[id] = nil
            break
        end

        local square = vehicle:getSquare()
        if square then
            local driver = vehicle:getDriver()
            if driver and driver:isNPC() then

                local dist = BanditUtils.DistToManhattan(player:getX(), player:getY(), vehicle:getX(), vehicle:getY())
                if dist > 51 then
                    local seat = vehicle:getSeat(driver)
                    vehicle:clearPassenger(seat)
                    driver:setVehicle(nil)
                    driver:setCollidable(true)
                    --driver:setHealth(0)
                    driver:Kill(nil)
                    driver:removeSaveFile()
                    driver:removeFromSquare()
                    driver:removeFromWorld()
                    vehicle:permanentlyRemove()
                    BLLVehicles.tab[id] = nil
                    
                    break
                end

                manageDriver(square, vehicle)
            else
                setDriver(square, vehicle)
            end

            local gunner = vehicle:getCharacter(1)

            if gunner and gunner:isNPC() then

                local bestDist = 40
                local enemyCharacter
                local vx = vehicle:getX()
                local vy = vehicle:getY()
                local vz = vehicle:getZ()
                local vid = vehicle:getId()
                local cell = square:getCell()

                local cache, potentialEnemyList = BanditZombie.Cache, BanditZombie.CacheLight
                for id, potentialEnemy in pairs(potentialEnemyList) do
                    if math.abs(potentialEnemy.x - vx) + math.abs(potentialEnemy.y - vy) < 57 then
                        if not potentialEnemy.brain or potentialEnemy.brain.hostile then
                            local potentialEnemy = cache[id]
                            local px, py, pz = potentialEnemy:getX(), potentialEnemy:getY(), potentialEnemy:getZ()
                            local dist = math.sqrt(((vx - px) * (vx - px)) + ((vy - py) * (vy - py)))
                            if dist < bestDist then
                                bestDist, enemyCharacter = dist, potentialEnemy
                            end
                        end
                    end
                end

                if enemyCharacter then

                    local dx = enemyCharacter:getX() - vx
                    local dy = enemyCharacter:getY() - vy
                    local aimAngle = math.deg(math.atan2(dy, dx))

                    -- local aimAngle = player:getDirectionAngle()
                    -- aimAngle = (aimAngle + 720) % 360

                    local md = vehicle:getModData()
                    local currentRotation = md.BLL.turretDir

                    local angleX = vehicle:getAngleX()
                    local angleY = vehicle:getAngleY()
                    local angleZ = vehicle:getAngleZ()
                    local vehicleRotation = calculateVehicleRotation(angleX, angleY, angleZ)

                    local targetRotation = (vehicleRotation - aimAngle + 720) % 360

                    local deltaTime = 1
                    local rotationSpeed = 6
                    local rotationStep = rotationSpeed * deltaTime
                    local angleDifference = ((targetRotation - currentRotation + 540) % 360) - 180
                
                    local newRotation
                    local firing = false
                    if math.abs(angleDifference) <= rotationStep then
                        newRotation = targetRotation
                        firing = true
                    else
                        newRotation = (currentRotation + sign(angleDifference) * rotationStep + 360) % 360
                    end
                    md.BLL.turretDir = newRotation

                    local turretWorldAngle = newRotation
                    local currentAnimID = math.floor(turretWorldAngle / 2) * 2 + 2
                    if currentAnimID > 360 then
                        currentAnimID = 2
                    elseif currentAnimID < 2 then
                        currentAnimID = 360
                    end

                    if currentAnimID ~= md.BLL.lastAnimID then
                        local animIDFormatted = string.format("%03d", currentAnimID)			
                        vehicle:playPartAnim(vehicle:getPartById("Turrent"), animIDFormatted)

                        md.BLL.lastAnimID = currentAnimID
                    end

                    if firing and BLLVehicles.tick % 12 > 0 then
                        BanditProjectile.Add(vid, vx, vy, vz, aimAngle, 1)
                        local emitter = getWorld():getFreeEmitter(vx, vy, vz)
                        emitter:playSound("BLL_M2_Fire")

                        local lightSource = IsoLightSource.new(vx, vy, vz, 1.0, 0.9, 0.8, 18, 2)
                        cell:addLamppost(lightSource)
                        
                        local item = BanditCompatibility.InstanceItem("Base.RollingPin")
                        enemyCharacter:setBumpDone(true)
                        enemyCharacter:setHitFromBehind(gunner:isBehind(enemyCharacter))
                        enemyCharacter:setHitAngle(gunner:getForwardDirection())
                        enemyCharacter:setPlayerAttackPosition(enemyCharacter:testDotSide(gunner))
                        enemyCharacter:setHitReaction("ShotBelly")
                        enemyCharacter:Hit(item, gunner, 3, false, 1, false)
                        enemyCharacter:setAttackedBy(shooter)
                        enemyCharacter:setHealth(0)
                        BanditCompatibility.Splash(enemyCharacter, item, gunner)
                    end
                end

            else
                setGunner(square, vehicle)
            end
        end
    end
end

Events.OnTick.Add(Manage)
