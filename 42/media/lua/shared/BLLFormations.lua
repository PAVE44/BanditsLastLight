local function rotateFormation(formation, angleDegrees)
    local angle = math.rad(angleDegrees)
    local rotated = {}
    local cosA = math.cos(angle)
    local sinA = math.sin(angle)

    for i, point in ipairs(formation) do
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
    local m = math.floor(n/2) + 1
    for i=1, m do
        table.insert(formation, {x=3, y=-i})
        table.insert(formation, {x=3, y=i})
    end
    return formation
end

BLLFormations.columns = {
    {x=-2, y=-3},
    {x=-2, y=-1.5},
    {x=-2, y=1.5},
    {x=-2, y=3},

    {x=-4, y=-3},
    {x=-4, y=-1.5},
    {x=-4, y=1.5},
    {x=-4, y=3},

    {x=-6, y=-3},
    {x=-6, y=-1.5},
    {x=-6, y=1.5},
    {x=-6, y=3},

    {x=-8, y=-3},
    {x=-8, y=-1.5},
    {x=-8, y=1.5},
    {x=-8, y=3},

    {x=-10, y=-3},
    {x=-10, y=-1.5},
    {x=-10, y=1.5},
    {x=-10, y=3},
}

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



BLLFormations.Get = function (name, angleDegrees)
    
    if not BLLFormations[name] then return end

    local formation = BLLFormations[name](21)

    if angleDegrees then
        formation = rotateFormation(formation, angleDegrees)
    end

    return formation
end
