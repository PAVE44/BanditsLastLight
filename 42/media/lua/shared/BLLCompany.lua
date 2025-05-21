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

for i=1, #BLLCompany.underCommand do
    local cid = BLLCompany.underCommand[i]
    local tab = {}
    tab.formation = "line"
    tab.weapons = "hold"
    tab.movement = "advance"
    tab.guardpost = {}
    tab.members = 0 
    BLLCompany.tab[cid] = tab

end

-- gets the status of the company
BLLCompany.Get = function()
    return BLLCompany.tab
end

BLLCompany.SetFormation = function(teamId, formationId)
    local cid = BLLCompany.underCommand[teamId]

    if BLLCompany.tab[cid] then
        
        local smap1 = {
            [1] = "TEAM1",
            [2] = "TEAM2",
            [3] = "TEAM3",
            [4] = "TEAM4",
        }

        local smap2 = {
            ["line"] = "FORMATIONLINE",
            ["file"] = "FORMATIONFILE",
            ["circle"] = "FORMATIONCIRCLE",
        }

        BLLRadioVoice.Add(smap1[teamId])
        BLLRadioVoice.Add(smap2[formationId])

        BLLCompany.tab[cid].formation = formationId
    end
end

BLLCompany.GetMembersFormation = function(cid, formationId)
    local cnt = 0
    local underCommand = BLLCompany.underCommand
    for i=1, #underCommand do
        local cid2 = underCommand[i]
        if BLLCompany.tab[cid2].formation == formationId then
            cnt = cnt + BLLCompany.tab[cid2].members
        end
    end

    return cnt
end


BLLCompany.SetWeapons = function(teamId, weaponsId)
    local cid = BLLCompany.underCommand[teamId]

    if BLLCompany.tab[cid] then
        
        local smap1 = {
            [1] = "TEAM1",
            [2] = "TEAM2",
            [3] = "TEAM3",
            [4] = "TEAM4",
        }

        local smap2 = {
            ["hold"] = "WEAPONSHOLD",
            ["free"] = "WEAPONSFREE",
            ["surpress"] = "WEAPONSSURPRESS",
        }

        BLLRadioVoice.Add(smap1[teamId])
        BLLRadioVoice.Add(smap2[weaponsId])

        BLLCompany.tab[cid].weapons = weaponsId
    end
end

BLLCompany.SetGuardpost = function(teamId, x, y, z)
    local cid = BLLCompany.underCommand[teamId]

    if BLLCompany.tab[cid] then
        
        local smap1 = {
            [1] = "TEAM1",
            [2] = "TEAM2",
            [3] = "TEAM3",
            [4] = "TEAM4",
        }

        BLLRadioVoice.Add(smap1[teamId])
        BLLRadioVoice.Add("MOVE")

        BLLCompany.tab[cid].guardpost = {x=x, y=y, z=z}
    end
end

BLLCompany.SetMovement = function(teamId, movementId)
    local cid = BLLCompany.underCommand[teamId]

    if BLLCompany.tab[cid] then
        
        local smap1 = {
            [1] = "TEAM1",
            [2] = "TEAM2",
            [3] = "TEAM3",
            [4] = "TEAM4",
        }

        local smap2 = {
            ["hold"] = "MOVEHOLD",
            ["advance"] = "MOVEADVANCE",
            ["allcosts"] = "MOVEALLCOSTS",
        }

        BLLRadioVoice.Add(smap1[teamId])
        BLLRadioVoice.Add(smap2[movementId])

        BLLCompany.tab[cid].movement = movementId
    end
end

-- soldier indexer
BLLCompany.Update = function()
    local tab = BLLCompany.tab
    local clans = BanditCustom.clanData
    local cacheLightB = BanditZombie.CacheLightB
    local cache = BanditZombie.Cache
    local underCommand = BLLCompany.underCommand
    local idx = {}


    local members = {}
    for i=1, #underCommand do
        local cid = underCommand[i]
        members[cid] = 0
    end

    for _, bandit in pairs(cacheLightB) do
        for i=1, #underCommand do
            local cid = underCommand[i]
            if bandit.brain.cid == cid then
                local formationId = BLLCompany.tab[cid].formation
                local bandit = cache[bandit.brain.id]
                if bandit then
                    local brain = BanditBrain.Get(bandit)
                    if brain then
                        if not idx[formationId] then
                            idx[formationId] = 0
                        end
                        idx[formationId] = idx[formationId] + 1
                        brain.idx = idx[formationId]
                        members[cid] = members[cid] + 1
                    end
                end
            end
        end
    end

    for i=1, #underCommand do
        local cid = underCommand[i]
        BLLCompany.tab[cid].members = members[cid]
    end
end

Events.EveryOneMinute.Add(BLLCompany.Update)
