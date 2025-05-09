BLLCompany = BLLCompany or {}

-- table storing company status
BLLCompany.tab = {}

-- table listing cids for squads the will be under player command
BLLCompany.underCommand = {
    "", "", "", "" --cids
}

-- gets the status of the company
BLLCompany.Get = function()
    return BLLCompany.tab
end

-- updates the status of the company
BLLCompany.Update = function()
    local tab = {}
    local clans = BanditCustom.clanData
    local cache = BanditZombie.CacheLightB
    local underCommand = BLLCompany.underCommand
    for _, bandit in pairs(cache) do
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
                break
            end
        end
    end
    BLLCompany.tab = tab
end

Events.EveryOneMinute.Add(BLLCompany.Update)
