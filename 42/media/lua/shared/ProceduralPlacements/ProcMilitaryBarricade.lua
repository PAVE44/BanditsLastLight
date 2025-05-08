BanditProc = BanditProc or {}

function BanditProc.BarricadeNorth (x1, x2, y)
    for x=x1, x2 do
        local z = 0
        local sprite
        
        if x % 2 == 0 then
            sprite = "fencing_01_88"
        else
            sprite = "fencing_01_89"
        end
        BanditBasePlacements.IsoObject (sprite, x, y, z)

        if x % 3 == 0 then
            sprite = "fencing_01_96"
        else
            sprite = "carpentry_02_13"
        end
        BanditBasePlacements.IsoObject (sprite, x, y-1, z)
    end
end

function BanditProc.BarricadeSouth (x1, x2, y)
    for x=x1, x2 do
        local z = 0
        local sprite
    
        if x % 2 == 0 then
            sprite = "fencing_01_88"
        else
            sprite = "fencing_01_89"
        end
        BanditBasePlacements.IsoObject (sprite, x, y, z)
    
        if x % 3 == 0 then
            sprite = "fencing_01_96"
        else
            sprite = "carpentry_02_13"
        end
        BanditBasePlacements.IsoObject (sprite, x, y, z)
    end
end

function BanditProc.BarricadeWest (y1, y2, x)
    for y=y1, y2 do
        local z = 0
        local sprite
        
        if y % 2 == 0 then
            sprite = "fencing_01_90"
        else
            sprite = "fencing_01_91"
        end
        BanditBasePlacements.IsoObject (sprite, x, y, z)
    
        id = (x - 1) .. "-" .. y .. "-" .. z
        if y % 3 == 0 then
            sprite = "fencing_01_96"
        else
            sprite = "carpentry_02_12"
        end
        BanditBasePlacements.IsoObject (sprite, x-1, y, z)
    end
end

function BanditProc.BarricadeEast (y1, y2, x)
    for y=y1, y2 do
        local z = 0
        local sprite
    
        if y % 2 == 0 then
            sprite = "fencing_01_90"
        else
            sprite = "fencing_01_91"
        end
        BanditBasePlacements.IsoObject (sprite, x, y, z)

        if y % 3 == 0 then
            sprite = "fencing_01_96"
        else
            sprite = "carpentry_02_12"
        end
        BanditBasePlacements.IsoObject (sprite, x, y, z)
    end
end