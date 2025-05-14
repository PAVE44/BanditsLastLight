BLLCursor = ISBuildingObject:derive("BLLCursor")

BLLCursor.points = {}

BLLCursor.sprites = {}
for i = 1, 30 do
    sprite = IsoSprite.new()
    sprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
    table.insert(BLLCursor.sprites, sprite)
end

function BLLCursor:getPoints(sx, sy)
    local points = {}
    local sep = 4
    local isRoad = BLLRoads.IsRoad
    local road = isRoad(sx, sy)
    local contE = isRoad(sx + 10, sy) and isRoad(sx + 20, sy)
    local contW = isRoad(sx - 10, sy) and isRoad(sx - 20, sy)
    local contS = isRoad(sx, sy + 10) and isRoad(sx, sy + 20)
    local contN = isRoad(sx, sy - 10) and isRoad(sx, sy - 20)

    if contE or contW then
        local w = 0
        local miny = sy
        local maxy = sy
        for dy = sy - 15, sy + 15 do
            if isRoad(sx, dy) then
                w = w + 1
                if dy < miny then miny = dy end
                if dy > maxy then maxy = dy end
            end
        end
        if w > 0 then
            if w >= 11 then
                points = {
                    {y = miny + 3, x = sx - sep},
                    {y = maxy - 3, x = sx - sep},
                    {y = miny + 3, x = sx + sep},
                    {y = maxy - 3, x = sx + sep}
                }
            else
                points = {
                    {y = miny + (w / 2), x = sx - 9},
                    {y = miny + (w / 2), x = sx - 3},
                    {y = miny + (w / 2), x = sx + 3},
                    {y = miny + (w / 2), x = sx + 9},
                }
            end
        end

    elseif contS or contN then
        local w = 0
        local minx = sx
        local maxx = sx
        
        for dx = sx - 15, sx + 15 do
            if isRoad(dx, sy) then
                w = w + 1
                if dx < minx then minx = dx end
                if dx > maxx then maxx = dx end
            end
        end
        if w > 0 then
            if w >= 11 then
                points = {
                    {x = minx + 3, y = sy - sep},
                    {x = maxx - 3, y = sy - sep},
                    {x = minx + 3, y = sy + sep},
                    {x = maxx - 3, y = sy + sep}
                }
            else
                points = {
                    {x = minx + (w / 2), y = sy - 9},
                    {x = minx + (w / 2), y = sy - 3},
                    {x = minx + (w / 2), y = sy + 3},
                    {x = minx + (w / 2), y = sy + 9},
                }
            end
        end
    end

    return points

end

function BLLCursor:create(x, y, z, north, sprite)
    -- BanditPost.GuardToggle(getPlayer(), x, y, z)
    local points = BLLCursor:getPoints(x, y)
    BLLCursor.points = {}
    for i = 1, #points do
        BLLCursor.points[i] = points[i]
        BLLCursor.points[i].id = i
    end
end

function BLLCursor:walkTo(x, y, z)
    return true
end

function BLLCursor:isValid(square)
    return true
end

function BLLCursor:render(x, y, z, square)

    local sx, sy, sz = square:getX(), square:getY(), square:getZ()

    local currentPoints = BLLCursor.points
    for i = 1, #currentPoints do
        local point = currentPoints[i]
        BLLCursor.sprites[i]:RenderGhostTileColor(point.x, point.y, 0, 1, 1, 0, 0.8)
    end

    local points = BLLCursor:getPoints(sx, sy)

    if #points == 0 then
        BLLCursor.sprites[1]:RenderGhostTileColor(sx, sy, sz, 1, 0, 0, 0.8)
        return
    end

    for i = 1, #points do
        local point = points[i]
        BLLCursor.sprites[i]:RenderGhostTileColor(point.x, point.y, 0, 0, 1, 0, 0.8)
    end


end

function BLLCursor:new(mode, cnt)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o:init()
    o.mode = mode
    o.cnt = cnt
    o.noNeedHammer = true
    o.skipBuildAction = true
    return o
end

