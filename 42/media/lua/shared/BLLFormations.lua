local function rotateFormation(formation, angleDegrees)
    local angle = math.rad(angleDegrees)
    local rotated = {}
    local cosA = math.cos(angle)
    local sinA = math.sin(angle)

    for _, point in ipairs(formation) do
        local x = point.x
        local y = point.y

        local newX = x * cosA - y * sinA
        local newY = x * sinA + y * cosA

        table.insert(rotated, {x = newX, y = newY})
    end
    return rotated
end

BLLFormations = BLLFormations or {}

BLLFormations.line = function(n)
    local formation = {}
    local m = math.floor(n / 2) + 1
    for i=1, m do
        table.insert(formation, {x=3, y=-i})
        table.insert(formation, {x=3, y=i})
    end
    return formation
end

BLLFormations.file = function(n)
    local formation = {}
    for i=1, n do
        table.insert(formation, {x=-i, y=0})
    end
    return formation
end

BLLFormations.doublefile = function(n)
    local formation = {}
    local m = math.floor(n / 2) + 1
    for i=1, m do
        table.insert(formation, {x=-i, y=-1})
        table.insert(formation, {x=-i, y=1})
    end
end

BLLFormations.circle = function(n)
    local formation = {}
    local minRadius = 2
    local maxRadius = 8
    local maxPoints = 28

    local t = math.min(n, maxPoints) / maxPoints
    local radius = minRadius + (maxRadius - minRadius) * t

    for i = 0, n - 1 do
        local angle = (2 * math.pi * i) / n
        local x = radius * math.cos(angle)
        local y = radius * math.sin(angle)
        table.insert(formation, {x = x, y = y})
    end

    return formation
end

BLLFormations.Get = function (cid, angleDegrees)

    local company = BLLCompany.Get()
    local formationId = company[cid].formation

    if not formationId or not BLLFormations[formationId] then return end

    -- formation depends on the number of soldiers so we need to 
    -- calculate the number of soldiers with the same formation and the same guardpost
    local members = BLLCompany.GetMembersFormation(cid, formationId)

    local formation = BLLFormations[formationId](members)

    if angleDegrees then
        formation = rotateFormation(formation, angleDegrees)
    end

    return formation
end
