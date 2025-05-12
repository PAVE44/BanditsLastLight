BLLCompany = BLLCompany or {}

-- table storing company status
BLLCompany.tab = {}

-- table listing cids for squads the will be under player command
BLLCompany.underCommand = {
    "9bbcac62-ac56-46db-912b-b8dc35e182d2", -- viper one
    "c9c8780f-1d32-43f5-a51f-5210db5890ad", -- raven two
    "938d9643-935e-4a9c-b963-ff174c2124d8", -- iron three
    "a6718ac2-2a78-40c1-a61f-04cde31145c6", -- shadow four
}

-- gets the status of the company
BLLCompany.Get = function()
    return BLLCompany.tab
end

-- updates the status of the company
BLLCompany.Update = function()
    local tab = {}
    local clans = BanditCustom.clanData
    local cacheLightB = BanditZombie.CacheLightB
    local cache = BanditZombie.Cache
    local underCommand = BLLCompany.underCommand
    local idx = 1
    for _, bandit in pairs(cacheLightB) do
        for i=1, #underCommand do
            if bandit.brain.cid == underCommand[i] then
                local cid = bandit.brain.cid
                if not tab[cid] then 
                    tab[cid] = {}
                    tab[cid].name = clans[cid].general.name
                    tab[cid].formation = "LINE"
                    tab[cid].weapons = "FREE"
                    tab[cid].program = "GUARD"
                    tab[cid].members = 0
                end
                tab[cid].members = tab[cid].members + 1
                
                local bandit = cache[bandit.brain.id]
                if bandit then
                    local brain = BanditBrain.Get(bandit)
                    brain.idx = idx
                    idx = idx + 1
                end
            end
        end
    end
    BLLCompany.tab = tab
end

Events.EveryOneMinute.Add(BLLCompany.Update)
