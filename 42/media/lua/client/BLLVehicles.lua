BLLVehicles = BLLVehicles or {}

-- const
BLLVehicles.speedMin = 2
BLLVehicles.speedMax = 10
BLLVehicles.reloadTime = 100
BLLVehicles.ammoContainerPartName = "" -- fixme
BLLVehicles.ammoItemTypeName = "" -- fixme
BLLVehicles.ammoBoxItemTypeName = "" -- fixme
BLLVehicles.ammoBoxSize = 100 -- fixme

BLLVehicles.tab = {}
BLLVehicles.tick = 0
BLLVehicles.reloadTick = 0

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

            local slot = 1
            for _, _ in pairs(BLLVehicles.tab) do
                slot = slot + 1
            end
            md.BLL.turretDir = 0
            md.BLL.slot = slot

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

BLLVehicles.Embark = function(vehicle, bandit)
end

BLLVehicles.Disembark = function(vehicle)
end

local function sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

local function normalize(angle)
    angle = (angle + 180) % 360 - 180
    return angle
end

local function predicateAmmo(item)
    if item:getType() == BLLVehicles.ammoItemTypeName then return true end
    return true
end

local function predicateAmmoBox(item)
    if item:getType() == BLLVehicles.ammoBoxItemTypeName then return true end -- fixme
    return true
end

local function manageEngineSmoke(vehicle)
    if BLLVehicles.tick % 66 == 0 and vehicle:isEngineRunning() then
        local vx = vehicle:getX()
        local vy = vehicle:getY()
        local vax = vehicle:getAngleX()
        local vay = vehicle:getAngleY()
        local vaz = vehicle:getAngleZ()
        local vr = calculateVehicleRotation(vax, vay, vaz)
        local rad = math.rad(vr)
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

local function manageDriver(square, vehicle, driver)

    local vehicleList = BLLVehicles.tab
    local vid = vehicle:getId()
    local vx = vehicle:getX()
    local vy = vehicle:getY()

    local slot = 1
    for id, _ in pairs(vehicleList) do
        if id ~= vid and vehicle:getX() < vx then
            slot = slot + 1
        end
    end

    local target = BLLCursor.points[slot]
    if not target then return end

    local vax = vehicle:getAngleX()
    local vay = vehicle:getAngleY()
    local vaz = vehicle:getAngleZ()
    local vr = calculateVehicleRotation(vax, vay, vaz)

    local dist = BanditUtils.DistTo(vx, vy, target.x, target.y)
    local tvr = BanditUtils.CalcAngle (vx, vy, target.x, target.y)
    local delta = normalize(normalize(tvr) - normalize(vr))

    if dist < 2 then
        vehicle:setRegulator(false)
        vehicle:setRegulatorSpeed(0)
    elseif math.abs(delta) < 2 then
        local speed = dist / 10
        if speed < BLLVehicles.speedMin then speed = BLLVehicles.speedMin end
        if speed > BLLVehicles.speedMax then speed = BLLVehicles.speedMax end

        vehicle:setRegulator(true)
        vehicle:setRegulatorSpeed(speed)
        -- print ("vid: " .. vid .. "slot: " .. slot)
    else
        vehicle:setRegulator(false)
        vehicle:setRegulatorSpeed(0)
        if vehicle:isStopped() then
            local step = (delta > 0) and 1 or -1
            local nva = (90 - normalize(vr + step)) % 360
            vehicle:setAngles(0, nva, 0)
        end
    end

end

local function setDriver(square, vehicle)

    local survDesc = SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, false)
    survDesc:setForename("Driver")
    survDesc:setSurname("Driver")
    survDesc:dressInNamedOutfit("Police")

    local driver = IsoPlayer.new(square:getCell(), survDesc, square:getX(), square:getY(), square:getZ())

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

local function manageGunner(square, vehicle, gunner)
    local vx = vehicle:getX()
    local vy = vehicle:getY()
    local vz = vehicle:getZ()
    local vid = vehicle:getId()
    local cell = square:getCell()

    -- manage reload if necessary
    local ammoItems = ArrayList.new()
    local ammoContainer = vehicle:getPartById(BLLVehicles.ammoContainerPartName):getItemContainer()
    ammoContainer:getAllEvalRecurse(predicateAmmo, ammoItems)
    local ammoLeft = ammoItems:size()
    if ammoLeft == 0 then
        local ammoBoxItems = ArrayList.new()
        ammoContainer:getAllEvalRecurse(predicateAmmoBox, ammoBoxItems)
        local ammoBoxLeft = ammoBoxItems:size()
        if ammoBoxLeft > 0 then
            BLLVehicles.reloadTick = BLLVehicles.reloadTick + 1
            if BLLVehicles.reloadTick == BLLVehicles.reloadTime then
                ammoContainer:RemoveOneOf(BLLVehicles.ammoBoxItemTypeName, true)
                local cnt = BLLVehicles.ammoBoxSize
                for i=1, cnt do
                    local item = BanditCompatibility.InstanceItem(BLLVehicles.ammoItemTypeName)
                    ammoContainer:AddItem(item)
                end
                BLLVehicles.reloadTick = 0
            end
        end
    end

    if ammoLeft == 0 then return end

    -- detect enemies
    local bestDist = 40
    local enemyCharacter
    local cache, potentialEnemyList = BanditZombie.Cache, BanditZombie.CacheLight
    for id, potentialEnemy in pairs(potentialEnemyList) do
        if math.abs(potentialEnemy.x - vx) + math.abs(potentialEnemy.y - vy) < 57 then
            if not potentialEnemy.brain or potentialEnemy.brain.hostile then
                local zombie = cache[id]
                if gunner:CanSee(zombie) then
                    local px, py, pz = zombie:getX(), zombie:getY(), zombie:getZ()
                    local dist = math.sqrt(((vx - px) * (vx - px)) + ((vy - py) * (vy - py)))
                    if dist < bestDist then
                        bestDist, enemyCharacter = dist, zombie
                    end
                end
            end
        end
    end

    if not enemyCharacter then return end

    -- manage turret rotation and firing
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

        addSound(getSpecificPlayer(0), vx, vy, vz, 40, 100)

        weaponItem = BanditCompatibility.InstanceItem("Base.HuntingRifle")
        BanditUtils.ManageLineOfFire(gunner, enemyCharacter, weaponItem)
        gunner:playSound(weaponItem:getShellFallSound())
    end
end

local function setGunner(square, vehicle)
    local survDesc = SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, false)
    survDesc:setForename("Gunner")
    survDesc:setSurname("Gunner")
    survDesc:dressInNamedOutfit("Police")

    local gunner = IsoPlayer.new(square:getCell(), survDesc, square:getX(), square:getY(), square:getZ())

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

local Manage = function(ticks)

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
        if not square then return end

        -- engine smoke
        manageEngineSmoke(vehicle)

        local driver = vehicle:getDriver()
        if driver and driver:isNPC() then
            manageDriver(square, vehicle, driver)
        else
            setDriver(square, vehicle)
        end

        local gunner = vehicle:getCharacter(1)
        if gunner and gunner:isNPC() then
            manageGunner(square, vehicle, gunner)
        else
            setGunner(square, vehicle)
        end
    end
end

Events.OnTick.Add(Manage)
