BanditProc = BanditProc or {}

function BanditProc.MilitaryBase (sx, sy, sz)

    local w = 100
    local h = 50
    BanditBaseGroupPlacements.ClearSpace(sx-2, sy-2, 0, w+4, h+4)
    BanditProc.BarricadeNorth(sx-4, sx+19, sy-4)
    BanditProc.BarricadeNorth(sx+39, sx+w+4, sy-4)
    
    BanditProc.BarricadeSouth(sx-4, sx+19, sy+h+4)
    BanditProc.BarricadeSouth(sx+39, sx+w+4, sy+h+4)

    BanditProc.BarricadeWest(sy-4, sy+h+4, sx-4)
    BanditProc.BarricadeEast(sy-4, sy+h+4, sx+w+4)

    BanditBasePlacements.IsoGenerator (nil, sx + 7, sy + 12, sz)
    BanditProc.MedicalTent (sx + 0, sy + 0, sz)
    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_48", sx + 7, sy + 13, sz)
    BanditProc.MilitaryTent (sx + 3, sy + 14, sz)
    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_48", sx + 7, sy + 22, sz)
    BanditProc.MilitaryTent (sx + 3, sy + 23, sz)
    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_48", sx + 7, sy + 31, sz)
    BanditProc.MilitaryTent (sx + 3, sy + 32, sz)
    BanditBasePlacements.IsoGenerator (nil, sx + 7, sy + 41, sz)
    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_48", sx + 7, sy + 40, sz)
    BanditProc.SatDish (sx + 4, sy + 41, sz)

    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_48", sx + 17, sy + 13, sz)
    BanditProc.MilitaryStash (sx + 11, sy + 15, sz)
    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_48", sx + 17, sy + 22, sz)
    BanditProc.MilitaryStash (sx + 11, sy + 24, sz)
    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_48", sx + 17, sy + 31, sz)

    BanditProc.MilitaryTentBig (sx + 40, sy, sz)
    BanditBasePlacements.IsoGenerator (nil, sx + 50, sy + 12, sz)
    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_49", sx + 49, sy + 12, sz)
    BanditProc.MilitaryTentBig (sx + 50, sy, sz)
    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_49", sx + 59, sy + 12, sz)
    BanditProc.MilitaryTentBig (sx + 60, sy, sz)
    BanditBasePlacements.IsoGenerator (nil, sx + 70, sy + 12, sz)
    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_49", sx + 69, sy + 12, sz)
    BanditProc.MilitaryTentBig (sx + 70, sy, sz)
    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_49", sx + 79, sy + 12, sz)

    BanditProc.MilitaryField (sx + 40, sy + 20, sz)
    BanditProc.MilitaryField (sx + 40, sy + 26, sz)

    BanditProc.MilitaryTentKitchen (sx + 56, sy + 22, sz)
    BanditBasePlacements.IsoLightSwitch ("lighting_outdoor_01_50", sx + 46, sy + 27, sz)
    BanditBaseGroupPlacements.Junk (sx + 76, sy + 45, 0, 7, 7, 88)

    BanditProc.MilitaryShooting (sx + 49, sy + 43, sz)
end