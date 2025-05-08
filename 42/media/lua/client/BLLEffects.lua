BLLEffects = BLLEffects or {}

BLLEffects.tab = {}
BLLEffects.tick = 0

BLLEffects.Add = function(effect)
    table.insert(BLLEffects.tab, effect)
end

BLLEffects.Process = function()
    if not isIngameState() then return end
    if isServer() then return end

    local player = getSpecificPlayer(0)
    if player == nil then return end
    local playerNum = player:getPlayerNum()
    local zoom = getCore():getZoom(playerNum)

    local cell = getCell()
    for i, effect in pairs(BLLEffects.tab) do

        local square = cell:getGridSquare(effect.x, effect.y, effect.z)
        if square then

            if not effect.repCnt then effect.repCnt = 1 end
            if not effect.rep then effect.rep = 1 end

            local size = effect.size / zoom
            local offset = size / 2
            local tx = isoToScreenX(playerNum, effect.x, effect.y, effect.z) - offset
            local ty = isoToScreenY(playerNum, effect.x, effect.y, effect.z) - offset

            if not effect.frame then 
                if effect.frameRnd then
                    effect.frame = 1 + ZombRand(effect.frameCnt)
                else
                    effect.frame = 1
                end
            end

            if effect.frame > effect.frameCnt and effect.rep >= effect.repCnt then
                BLLEffects.tab[i] = nil
            else
                if effect.frame > effect.frameCnt then
                    effect.rep = effect.rep + 1
                    effect.frame = 1
                end

                local frameStr = string.format("%03d", effect.frame)
                local tex = getTexture("media/textures/FX/" .. effect.name .. "/" .. frameStr .. ".png")
                local alfa = (effect.repCnt - effect.rep + 1) / effect.repCnt
                UIManager.DrawTexture(tex, tx, ty, size, size, alfa)

                if effect.colors then
                    -- .object:setCustomColor(effect.colors.r, effect.colors.g, effect.colors.b, effect.colors.a)
                end
                effect.frame = effect.frame + 1

            end
        else
            BLLEffects.tab[i] = nil
        end
    end
end

Events.OnPreUIDraw.Add(BLLEffects.Process)