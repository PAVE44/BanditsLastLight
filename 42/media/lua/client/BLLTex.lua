BLLTex = BLLTex or {}

BLLTex.tex = getTexture("media/textures/blast_n.png")
BLLTex.alpha = 0.4
BLLTex.speed = 0.05
BLLTex.mode = "full"
BLLTex.screenWidth = getCore():getScreenWidth()
BLLTex.screenHeight = getCore():getScreenHeight()

BLLTex.Blast = function()
    if not isIngameState() then return end
    if BLLTex.alpha == 0 then return end

    local player = getSpecificPlayer(0)
    if not player then return end

    -- if not player:isOutside() then return end

    local speed = BLLTex.speed * getGameSpeed()
    -- local zoom = getCore():getZoom(player:getPlayerNum())
    -- zoom = PZMath.clampFloat(zoom, 0.0, 1.0)

    local alpha = BLLTex.alpha
    if alpha > 1 then alpha = 1 end

    if BLLTex.mode == "full" then
        UIManager.DrawTexture(BLLTex.tex, 0, 0, BLLTex.screenWidth, BLLTex.screenHeight, alpha)
    elseif BLLTex.mode == "center" then
        local xc = BLLTex.screenWidth / 2
        local x1 = xc - BLLTex.tex:getWidth()
        -- local x2 = xc + (BLLTex.tex:getWidth() / 2)

        local yc = BLLTex.screenHeight / 2
        local y1 = yc - BLLTex.tex:getHeight()
        -- local y2 = yc + (BLLTex.tex:getHeight() / 2)
        UIManager.DrawTexture(BLLTex.tex, x1, y1, BLLTex.tex:getWidth() * 2, BLLTex.tex:getHeight() * 2, alpha)
    end

    BLLTex.alpha = BLLTex.alpha - speed
    if BLLTex.alpha < 0 then BLLTex.alpha = 0 end
end

BLLTex.SizeChange = function (n, n2, x, y)
    BLLTex.screenWidth = x
    BLLTex.screenHeight = y
end

Events.OnPreUIDraw.Add(BLLTex.Blast)
Events.OnResolutionChange.Add(BLLTex.SizeChange)
