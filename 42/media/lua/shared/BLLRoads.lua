BLLRoads = BLLRoads or {}

local function isRoad(x, y)
    return BanditUtils.HasZoneType(x, y, 0, "Nav")
end

BLLRoads.GetPoints = function(sx, sy)
    local points = {}
    local sep = 4

    local contE = isRoad(sx + 10, y)
    local contW = isRoad(sx - 10, y)
    local contS = isRoad(sx, sy + 10)
    local contN = isRoad(sx, sy - 10)

    if contE or contW then
        local w = 0
        local miny = sy
        local maxy = sy
        for dy = sy - 8, sy + 8 do
            if isRoad(sx, dy) then
                w = w + 1
                if dy < miny then miny = dy end
                if dy > maxy then maxy = dy end
            end
        end
        if w > 0 then
            if w >= 11 then
                points = {
                    {y = miny + 3, x = x - sep},
                    {y = maxy - 3, x = x - sep},
                    {y = miny + 3, x = x + sep},
                    {y = maxy - 3, x = x + sep}
                }
            else
                points = {
                    {y = miny + 3, x = x - (2 * sep)},
                    {y = miny + 3, x = x - sep},
                    {y = miny + 3, x = x + sep},
                    {y = miny + 3, x = x + (2 * sep)},
                }
            end
        end

    elseif contS or contN then
        local w = 0
        local minx = sx
        local maxx = sx
        for dx = sx - 8, sx + 8 do
            if isRoad(dx, sy) then
                w = w + 1
                if dx < minx then minx = dx end
                if dx > maxx then maxx = dx end
            end
        end
        if w > 0 then
            if w >= 11 then
                points = {
                    {x = minx + 3, y = y - sep},
                    {x = maxx - 3, y = y - sep},
                    {x = minx + 3, y = y + sep},
                    {x = maxx - 3, y = y + sep}
                }
            else
                points = {
                    {x = minx + 3, y = y - (2 * sep)},
                    {x = minx + 3, y = y - sep},
                    {x = minx + 3, y = y + sep},
                    {x = minx + 3, y = y + (2 * sep)},
                }
            end
        end
    end

    return points

end
