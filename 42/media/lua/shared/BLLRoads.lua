BLLRoads = BLLRoads or {}

BLLRoads.IsRoad = function (x, y)
    local zones = getZones(x, y, 0)
    if zones then
        for i=0, zones:size()-1 do
            local zone = zones:get(i)
            if zone:getType() == "Nav" then
                local square = getCell():getGridSquare(x, y, 0)
                if square then
                    local objects = square:getObjects()
                    for i=0, objects:size()-1 do
                        local object = objects:get(i)
                        if object then
                            local sprite = object:getSprite()
                            if sprite then
                                local spriteName = sprite:getName()
                                if spriteName then
                                    if spriteName:embodies("street") then
                                        local spriteProps = sprite:getProperties()
                                        if spriteProps:Is(IsoFlagType.attachedFloor) then
                                            local material = spriteProps:Val("FootstepMaterial")
                                            if material ~= "Gravel" then
                                                return true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

BLLRoads.IsFree = function(x, y)
    local cell = getCell()
    for dx = x - 1, x + 1 do
        for dy = y - 1, y + 1 do
            --if not isRoad(dx, dy) then return false end
            
            local square = cell:getGridSquare(dx, dy, 0)
            if not square or not square:isFree(false) then
                return false
            end
        end
    end
end