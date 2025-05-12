ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Military = {}

ZombiePrograms.Military.Prepare = function(bandit)
    local tasks = {}

    Bandit.ForceStationary(bandit, false)
  
    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Military.Main = function(bandit)
    local tasks = {}

    Bandit.ForceStationary(bandit, false)
 
    -- Companion logic depends on one of the players who is the master od the companion
    -- if there is no master, there is nothing to do.
    local master = BanditPlayer.GetMasterPlayer(bandit)
    if not master then
        local task = {action="Time", anim="Shrug", time=200}
        table.insert(tasks, task)
        return {status=true, next="Main", tasks=tasks}
    end

    local bx, by, bz = bandit:getX(), bandit:getY(), bandit:getZ()
    local mx, my, mz = master:getX(), master:getY(), master:getZ()
    
    -- update walktype
    local walkType = "Walk"
    local endurance = 0.00
    local vehicle = master:getVehicle()
    local dist = BanditUtils.DistTo(bx, by, mx, my)

  

    local id = BanditUtils.GetCharacterID(bandit)

    local mangle = master:getDirectionAngle()

    local dangle = BanditUtils.DominantAngle(mx, my, 15)

    if dangle then
        walkType = "WalkAim"
    end

    local formation = BLLFormations.Get("line", dangle)
    local brain = BanditBrain.Get(bandit)
    local idx = brain.idx

    local dx = mx + formation[idx].x
    local dy = my + formation[idx].y
    local dz = mz

    -- print (brain.id .. " " .. idx .. " DX: " .. dx .. " DY: " .. dy)

    if master:isRunning() or master:isSprinting() or dist > 10 then
        walkType = "Run"
        endurance = -0.07
    end

    local health = bandit:getHealth()
    if health < 0.4 then
        walkType = "Limp"
        endurance = 0
    end 

    local distTarget = BanditUtils.DistTo(bandit:getX(), bandit:getY(), dx, dy)

    if distTarget > 0.7 then
        table.insert(tasks, BanditUtils.GetMoveTask(endurance, dx, dy, dz, walkType, distTarget, false))
        return {status=true, next="Main", tasks=tasks}
    else

        local subTasks = BanditPrograms.Idle(bandit)
        if #subTasks > 0 then
            for _, subTask in pairs(subTasks) do
                table.insert(tasks, subTask)
            end
            return {status=true, next="Main", tasks=tasks}
        end
    end
    
    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Military.Guard = function(bandit)
    local tasks = {}

    Bandit.ForceStationary(bandit, true)
    
    -- If at guardpost, switch to the CompanionGuard program.
    local atGuardpost = BanditPost.At(bandit, "guard")
    if not atGuardpost then
        return {status=true, next="Main", tasks=tasks}
    end

    local closestZombie = BanditUtils.GetClosestZombieLocation(bandit)
    local closestBandit = BanditUtils.GetClosestEnemyBanditLocation(bandit)
    local closestEnemy = closestZombie

    if closestBandit.dist < closestZombie.dist then 
        closestEnemy = closestBandit
    end

    if closestEnemy.dist < 24 then
        local task = {action="FaceLocation", anim=anim, x=closestEnemy.x, y=closestEnemy.y, time=100}
        table.insert(tasks, task)
    else
        local subTasks = BanditPrograms.Idle(bandit)
        if #subTasks > 0 then
            for _, subTask in pairs(subTasks) do
                table.insert(tasks, subTask)
            end
        end
    end
    return {status=true, next="Guard", tasks=tasks}
end