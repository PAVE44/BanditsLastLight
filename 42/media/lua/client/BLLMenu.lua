--
-- ********************************
-- *** Bandits Last Light       ***
-- ********************************
-- *** Coded by: Slayer         ***
-- ********************************
--

BLLMenu = BLLMenu or {}

function BLLMenu.SpawnObject(player, square, objectName)
    if BanditProc[objectName] then
        BanditProc[objectName](square:getX(), square:getY(), square:getZ())
    end
end

function BLLMenu.Clear(player, square)
    BanditBaseGroupPlacements.ClearSpace(square:getX(), square:getY(), 0, 100, 100)
end

function BLLMenu.Start(player)
    BLLEvents.GroupStart()
end

function BLLMenu.Bridge(player)
    BLLEvents.GroupBridge()
end

function BLLMenu.Convoy(player)
    BLLEvents.SetVar({key="convoySpeed", val=12})
end

function BLLMenu.VehicleSpawn(player, square)
    local apc = {x=square:getX(), y=square:getY(), dir=IsoDirections.S, vtype="Base.M113_APC"}
    BLLQueueManager.Add("VehicleSpawn", apc, 2200)
end

function BLLMenu.VehicleRemove(player, vehicle)
    BLLVehicles.Remove(vehicle)
end

function BLLMenu.VehicleEmbark(player, vehicle, bandit)

    local cacheLightB = BanditZombie.CacheLightB
    local cache = BanditZombie.Cache
    for _, bandit in pairs(cacheLightB) do
        if bandit.brain.cid == "9bbcac62-ac56-46db-912b-b8dc35e182d2" then
            local soldier = cache[bandit.brain.id]
            BLLVehicles.Embark(vehicle, soldier)
        end
    end
end

function BLLMenu.VehicleDisembark(player, vehicle)
    BLLVehicles.DisembarkAll(vehicle)
end

function BLLMenu.VoiceTest(player)
    BLLRadioVoice.Add("TEAM1")
    BLLRadioVoice.Add("MANDOWN")
end

-- debug end

function BLLMenu.ChangeFormation(player, teamId, formationId)
    BLLCompany.SetFormation(teamId, formationId)
    local test = BLLCompany.Get()
end

function BLLMenu.ChangeMovement(player, teamId, movementId)
    BLLCompany.SetMovement(teamId, movementId)
    local test = BLLCompany.Get()
end

function BLLMenu.ChangeWeapons(player, teamId, weaponsId)
    BLLCompany.SetWeapons(teamId, weaponsId)
    local test = BLLCompany.Get()
end


function BLLMenu.WorldContextMenuPre(playerID, context, worldobjects, test)
    local world = getWorld()
    local player = getSpecificPlayer(playerID)
    local square = BanditCompatibility.GetClickedSquare()
    local vehicle = square:getVehicleContainer()

    local teams = {
        [1] = "Viper One",
        [2] = "Raven Two",
        [3] = "Iron Three",
        [4] = "Shadow Four"
    }

    local formations = {
        ["line"] = "Line",
        ["file"] = "File",
        ["circle"] = "Circle",
    }

    local movement = {
        ["hold"] = "Hold position",
        ["advance"] = "Advance",
        ["allcosts"] = "Advance at all costs",
    }

    local weapons = {
        ["hold"] = "Hold fire",
        ["free"] = "Fire at will",
        ["surpress"] = "Surpress",
    }

    for teamId, teamLabel in pairs(teams) do
        local teamOption = context:addOption(teamLabel)
        local teamMenu = context:getNew(context)

        -- formation menu
        local formationOption = teamMenu:addOption("Formation")
        local formationMenu = teamMenu:getNew(context)

        for formationId, formationLabel in pairs(formations) do
            formationMenu:addOption(formationLabel, player, BLLMenu.ChangeFormation, teamId, formationId)
        end
        context:addSubMenu(formationOption, formationMenu)

        -- movement menu
        local movementOption = teamMenu:addOption("Movement")
        local movementMenu = teamMenu:getNew(context)

        for movementId, movementLabel in pairs(movement) do
            movementMenu:addOption(movementLabel, player, BLLMenu.ChangeMovement, teamId, movementId)
        end
        context:addSubMenu(movementOption, movementMenu)

        -- weapons menu
        local weaponsOption = teamMenu:addOption("Weapons")
        local weaponsMenu = teamMenu:getNew(context)

        for weaponsId, weaponsLabel in pairs(weapons) do
            weaponsMenu:addOption(weaponsLabel, player, BLLMenu.ChangeWeapons, teamId, weaponsId)
        end
        context:addSubMenu(weaponsOption, weaponsMenu)

        context:addSubMenu(teamOption, teamMenu)

        
    end

    -- Debug options
    if isDebugEnabled() then
        context:addOption("Vehicle Spawn", player, BLLMenu.VehicleSpawn, square)
        if vehicle then
            context:addOption("Vehicle Embark", player, BLLMenu.VehicleEmbark, vehicle)
            context:addOption("Vehicle Disembark", player, BLLMenu.VehicleDisembark, vehicle)
            context:addOption("Vehicle Remove", player, BLLMenu.VehicleRemove, vehicle)
        end

        context:addOption("Voice Test", player, BLLMenu.VoiceTest)

        local objectOption = context:addOption("Spawn Object")
        local objectMenu = context:getNew(context)
        context:addSubMenu(objectOption, objectMenu)

        local objects = {"MilitaryBase", "MedicalTent", "MilitaryField", "MilitaryShooting", 
                         "MilitaryStash", "MilitaryTent", "MilitaryTentBig", "MilitaryTentKitchen", 
                         "SatDish", "Toilet"}

        for i=1, #objects do
            local objectName = objects[i]
            objectMenu:addOption(objectName, player, BLLMenu.SpawnObject, square, objectName)
        end
    end
end

function BLLMenu.OnKeyPressed(keynum)
    if keynum == BanditCompatibility.GetGuardpostKey() then
        local playerObj = getSpecificPlayer(0)
        local cursor = BLLCursor:new("vehicle", 4)
        getCell():setDrag(cursor, playerObj:getPlayerNum())
    elseif keynum == Keyboard.KEY_T then
        if BLLMenu.Modal then
            BLLMenu.Modal:removeFromUIManager()
            BLLMenu.Modal:close()
            BLLMenu.Modal = nil
        else
            local screenWidth, screenHeight = getCore():getScreenWidth(), getCore():getScreenHeight()
            local modalWidth, modalHeight = 600, 80
            local modalX = 0
            local modalY = screenHeight - modalHeight
            BLLMenu.Modal = BLLCommandPanel:new(modalX, modalY, modalWidth, modalHeight)
            BLLMenu.Modal:initialise()
            BLLMenu.Modal:addToUIManager()
        end
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(BLLMenu.WorldContextMenuPre)
Events.OnKeyPressed.Remove(BanditMenu.OnKeyPressed)
Events.OnKeyPressed.Add(BLLMenu.OnKeyPressed)
