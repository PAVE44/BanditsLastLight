BLLVehicles = BLLVehicles or {}

-- const
BLLVehicles.speedMin = 2
BLLVehicles.speedMax = 10
BLLVehicles.reloadTime = 100
BLLVehicles.ammoContainerPartName = "Browning_M2"
BLLVehicles.ammoBoxItemTypeName = "Base.127x99mmClip"
BLLVehicles.seatOptions = {0, 1, 3}

-- temp data
BLLVehicles.tick = 0
BLLVehicles.reloadTick = 0

local function getVehicleBack(vehicle, l)
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
    return sx, sy
end

local function createPassenger(vehicle, seat)

    if not vehicle:getChunk() then return end

    local survDesc = SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, false)
    survDesc:setForename("Passenger")
    survDesc:setSurname("Passenger")
    survDesc:dressInNamedOutfit("Police")

    local square = vehicle:getSquare()
    local passenger = IsoPlayer.new(square:getCell(), survDesc, square:getX(), square:getY(), square:getZ())

    passenger:setSceneCulled(false)
    passenger:setNPC(true)
    passenger:setGodMod(true)
    passenger:setInvisible(true)
    passenger:setGhostMode(true)

    local vx = passenger:getForwardDirection():getX()
    local vy = passenger:getForwardDirection():getY()
    local forwardVector = Vector3f.new(vx, vy, 0)

    vehicle:setPassenger(seat, passenger, forwardVector)
    passenger:setVehicle(vehicle)
    passenger:setCollidable(false)

    if not passenger:getVehicle() then return end

    return passenger
end

BLLVehicles.Repair = function(vehicle)
    vehicle:repair()

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
            for _, _ in pairs(BLLVehicles.vehicles) do
                slot = slot + 1
            end
            md.BLL.turretDir = 0
            md.BLL.slot = slot

            local id = vehicle:getId()
            BLLVehicles.vehicles[id] = {
                x = vehicle:getX(), 
                y = vehicle:getY()
            }

            --[[
            if args.lightbar or args.siren or args.alarm then
                local newargs = {id=vehicle:getId(), lightbar=args.lightbar, siren=args.siren, alarm=args.alarm}
                sendServerCommand('Commands', 'UpdateVehicle', newargs)
            end
            ]]
        end
    end
end

BLLVehicles.Remove = function(vehicle)
    local vid = vehicle:getId()
    BLLVehicles.DisembarkAll(vehicle)
    vehicle:permanentlyRemove()
    BLLVehicles.vehicles[vid] = nil
    BLLVehicles.passengers[vid] = nil
end

BLLVehicles.Embark = function(vehicle, bandit)
    local gmd = GetBanditModData()

    -- find first free sit
    local vid = vehicle:getId()
    local passengers = BLLVehicles.passengers[vid] or {}
    local seatOptions = BLLVehicles.seatOptions
    local seat
    for _, i in pairs(seatOptions) do
        if vehicle:isSeatInstalled(i) and not vehicle:isSeatOccupied(i) then
            local occupied = false
            for _, seatTaken in pairs(passengers) do
                if i == seatTaken then
                    occupied = true
                end
            end
            if not occupied then
                seat = i
                break
            end
        end
    end

    if not seat then return end

    -- add passenger
    createPassenger(vehicle, seat)

    -- mark bandit as in vehicle and remove from world
    local brain = BanditBrain.Get(bandit)
    gmd.Queue[brain.id].inVehicle = true
    bandit:playSound("VehicleDoorOpen")
    bandit:removeFromSquare()
    bandit:removeFromWorld()

    -- update passenger list
    if not BLLVehicles.passengers[vid] then
        BLLVehicles.passengers[vid] = {}
    end
    BLLVehicles.passengers[vid][brain.id] = seat

end

BLLVehicles.DisembarkAll = function(vehicle)
    local vid = vehicle:getId()
    local passengers = BLLVehicles.passengers[vid]

    local gmd = GetBanditModData()
    if passengers then
        for bid, seat in pairs(passengers) do
            if gmd.Queue[bid] then
                local brain = gmd.Queue[bid]
                if brain and brain.inVehicle then
                    -- remove passenger
                    local character = vehicle:getCharacter(seat)
                    vehicle:clearPassenger(seat)
                    if character then
                        character:setVehicle(nil)
                        character:setCollidable(true)
                        character:Kill(nil)
                        character:removeSaveFile()
                        character:removeFromSquare()
                        character:removeFromWorld()
                    end

                    -- restore bandit
                    local ex, ey = getVehicleBack(vehicle, 3)
                    brain.bornCoords.x = ex
                    brain.bornCoords.y = ey
                    brain.bornCoords.z = 0
                    brain.inVehicle = false
                    sendClientCommand(getSpecificPlayer(0), 'Commands', 'SpawnRestore', brain)

                    -- update passenger list
                    passengers[bid] = nil
                end
            end
        end
    end    
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

local function predicateAmmoBox(item)
    if item:getFullType() == BLLVehicles.ammoBoxItemTypeName then 
        if item:getCurrentAmmoCount() > 0 then
            return true
        end
    end
    return false
end

local function initGlobalModData()
    local globalData = ModData.getOrCreate("BanditLastLight")

    if not globalData.vehicles then globalData.vehicles = {} end
    if not globalData.passengers then globalData.passengers = {} end

    BLLVehicles.vehicles = globalData.vehicles
    BLLVehicles.passengers = globalData.passengers
end

local function findVehicle(vdata)
    local cell = getCell()

    local search = {
        {x = 0, y = 0},
        {x = 1, y = 0},
        {x = 1, y = 1},
        {x = 0, y = 1},
        {x = -1, y = 1},
        {x = -1, y = 0},
        {x = -1, y = -1},
        {x = 0, y = -1},
        {x = 1, y = -1},
    }

    for _, s in pairs(search) do
        local sx = vdata.x + s.x
        local sy = vdata.y + s.y
        local square = cell:getGridSquare(sx, sy, 0)
        if square then
            local vehicle = square:getVehicleContainer()
            if vehicle then
                return vehicle
            end
        end
    end
end

local function manageEngineSmoke(vehicle)
    if BLLVehicles.tick % 66 == 0 and vehicle:isEngineRunning() then

        local sx, sy = getVehicleBack(vehicle, 3)
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

local function manageMovement(square, vehicle, driver)

    local vdataList = BLLVehicles.vehicles
    local vid = vehicle:getId()
    local vx = vehicle:getX()
    local vy = vehicle:getY()

    local slot = 1
    for id, vdata in pairs(vdataList) do
        if id ~= vid and vdata.x < vx then
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

    if not vehicle:isEngineRunning() then
        vehicle:tryStartEngine(true)
        vehicle:engineDoStartingSuccess()
        vehicle:engineDoRunning()
    elseif dist < 2 then
        vehicle:setRegulator(false)
        vehicle:setRegulatorSpeed(0)
    elseif math.abs(delta) < 2 then
        local speed = dist / 2
        if speed < BLLVehicles.speedMin then speed = BLLVehicles.speedMin end
        if speed > BLLVehicles.speedMax then speed = BLLVehicles.speedMax end

        vehicle:setRegulator(true)
        vehicle:setRegulatorSpeed(speed)
        -- print ("vid: " .. vid .. "slot: " .. slot)
    else
        vehicle:setRegulator(true)
        vehicle:setRegulatorSpeed(1)
            local step = (delta > 0) and 1 or -1
            local nva = (90 - normalize(vr + step)) % 360
            vehicle:setAngles(0, nva, 0)
    end

end

local function manageTurret(square, vehicle, gunner)
    local vx = vehicle:getX()
    local vy = vehicle:getY()
    local vz = vehicle:getZ()
    local vid = vehicle:getId()
    local cell = square:getCell()

    -- manage reload if necessary
    local firing = false
    local ammoBox
    local ammoMax
    local ammoLeft
    local ammoBoxItems = ArrayList.new()
    local ammoPart = vehicle:getPartById(BLLVehicles.ammoContainerPartName)
    local ammoContainer = ammoPart:getItemContainer()
    ammoContainer:getAllEvalRecurse(predicateAmmoBox, ammoBoxItems)
    if ammoBoxItems:size() > 0 then
        firing = true
        ammoBox = ammoBoxItems:get(0)
        ammoMax = ammoBox:getMaxAmmo()
        ammoLeft = ammoBox:getCurrentAmmoCount()
        
        if ammoLeft == ammoMax then -- new clip, needs to load it
            firing = false
            BLLVehicles.reloadTick = BLLVehicles.reloadTick + 1
            if BLLVehicles.reloadTick == BLLVehicles.reloadTime then
                BLLVehicles.reloadTick = 0
                firing = true
            end
        end
    end

    if not firing then return end -- out of ammo or reloading

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
        ammoBox:setCurrentAmmoCount(ammoLeft - 1)

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

local function manage(ticks)

    BLLVehicles.tick = ticks
    local test = BLLVehicles
    initGlobalModData()

    if ticks % 6 > 0 then return end

    local player = getSpecificPlayer(0)
    if not player then return end

    local vdataList = BLLVehicles.vehicles
    for vid, vdata in pairs(vdataList) do

        local vehicle = findVehicle(vdata)
        if not vehicle then 
            -- BLLVehicles.vehicles[vid] = nil
            break
        end

        local controller = vehicle:getController()
        if not controller then
            -- BLLVehicles.vehicles[vid] = nil
            break
        end

        -- update passanger after game reload
        local passengers = BLLVehicles.passengers[vid] or {}
        for bid, seat in pairs(passengers) do
            if not vehicle:getCharacter(seat) then
                if vehicle:isSeatInstalled(seat) and not vehicle:isSeatOccupied(seat) then
                    createPassenger(vehicle, seat)
                end
            end
        end

        -- engine smoke
        manageEngineSmoke(vehicle)

        local square = vehicle:getSquare()

        local driver = vehicle:getDriver()
        if driver and driver:isNPC() then
            manageMovement(square, vehicle, driver)
        end

        local gunner = vehicle:getCharacter(1)
        if gunner and gunner:isNPC() then
            manageTurret(square, vehicle, gunner)
        end

        -- update gmd
        vdataList[vid] = {
            x = vehicle:getX(), 
            y = vehicle:getY()
        }
    end
end

Events.OnInitGlobalModData.Add(initGlobalModData)
Events.OnTick.Add(manage)
