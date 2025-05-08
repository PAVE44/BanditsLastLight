BanditUtils = BanditUtils or {}

BanditUtils.GetTime = function()
    -- the unit is arbitrary but it gives good resolution
    return getGameTime():getWorldAgeHours() * 2500000 / 24
end