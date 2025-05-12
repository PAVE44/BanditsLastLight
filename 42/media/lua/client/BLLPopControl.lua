BLLPopControl = BLLPopControl or {}

-- zombie despawner
BLLPopControl.Zombie = function()

    local HQSafe = BLLVars.Get("HQSafe")
    if not HQSafe then return end

    local zombieList = BanditZombie.CacheLightZ

    for id, z in pairs(zombieList) do
        if false and z.y <= 960 then
            local zombie = BanditZombie.GetInstanceById(z.id)
            if zombie:isAlive()  then
                zombie:removeFromSquare()
                zombie:removeFromWorld()
            end
        end
    end
end


local onTick = function(numTicks)
    if numTicks % 2 == 0 then
        BLLPopControl.Zombie()
    end
end

Events.OnTick.Add(onTick)
