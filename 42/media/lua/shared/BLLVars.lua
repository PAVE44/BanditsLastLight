BLLVars = BLLVars or {}

BLLVars.vars = {}

BLLVars.defaultVars = {
    HQSafe = true, -- removes zombies near HQ to make it safe in the initial part of the game
    HQTools = false, -- controls access to hq tools like bombing runs
    companyCommand = false, -- enables control over the squads for the player
    convoySpeed = 0, -- establishes current convoy speed
}

BLLVars.Set = function(key, val)
    if BLLVars.vars[key] then
        BLLVars.vars[key] = val
    end
end

BLLVars.Get = function(key)
    local test = BLLVars
    return BLLVars.vars[key]
end

BLLVars.Init = function()
    local globalData = ModData.getOrCreate("BanditLastLight")

    for k, v in pairs(BLLVars.defaultVars) do
        if not globalData[k] then 
            globalData[k] = v
        end
    end

    BLLVars.vars = globalData
end

Events.OnInitGlobalModData.Add(BLLVars.Init)

