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

function BLLMenu.CommandPanel(player)
    local screenWidth, screenHeight = getCore():getScreenWidth(), getCore():getScreenHeight()
    local modalWidth, modalHeight = 600, 80
    local modalX = 0
    local modalY = screenHeight - modalHeight
    local modal = BLLCommandPanel:new(modalX, modalY, modalWidth, modalHeight)
    modal:initialise()
    modal:addToUIManager()
end

function BLLMenu.WorldContextMenuPre(playerID, context, worldobjects, test)
    local world = getWorld()
    local player = getSpecificPlayer(playerID)
    local square = BanditCompatibility.GetClickedSquare()

    -- Debug options
    if isDebugEnabled() then
        context:addOption("Vehicle Spawn", player, BLLMenu.VehicleSpawn, square)
        context:addOption("Command Panel", player, BLLMenu.CommandPanel)
        context:addOption("Clear", player, BLLMenu.Clear, square)
        context:addOption("Start", player, BLLMenu.Start)
        context:addOption("Convoy", player, BLLMenu.Convoy)
        context:addOption("Bridge", player, BLLMenu.Bridge)

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
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(BLLMenu.WorldContextMenuPre)
Events.OnKeyPressed.Remove(BanditMenu.OnKeyPressed)
Events.OnKeyPressed.Add(BLLMenu.OnKeyPressed)
