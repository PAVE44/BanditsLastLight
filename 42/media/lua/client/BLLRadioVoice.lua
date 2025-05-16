BLLRadioVoice = BLLRadioVoice or {}

-- table for enqueued events
BLLRadioVoice.Events = {}

BLLRadioVoice.Sounds = {
    ["SPOTTED"]         = {base = "BLL_Voice_Radio_1_Spotted", vcnt = 6},
    ["SOUTH"]           = {base = "BLL_Voice_Radio_1_South", vcnt = 1},
    ["SOUTHEAST"]       = {base = "BLL_Voice_Radio_1_SouthEast", vcnt = 1},
    ["SOUTHWEST"]       = {base = "BLL_Voice_Radio_1_SouthWest", vcnt = 1},
    ["EAST"]            = {base = "BLL_Voice_Radio_1_East", vcnt = 1},
    ["WEST"]            = {base = "BLL_Voice_Radio_1_West", vcnt = 1},
    ["NORTH"]           = {base = "BLL_Voice_Radio_1_North", vcnt = 1},
    ["NORTHEAST"]       = {base = "BLL_Voice_Radio_1_NorthEast", vcnt = 1},
    ["NORTHWEST"]       = {base = "BLL_Voice_Radio_1_NorthWest", vcnt = 1},
    ["REGROUP"]         = {base = "BLL_Voice_Radio_1_Regroup", vcnt = 8},
    ["MOVE"]            = {base = "BLL_Voice_Radio_1_Move", vcnt = 6},
    ["MANDOWN"]         = {base = "BLL_Voice_Radio_1_Mandown", vcnt = 6},
    ["KILL"]            = {base = "BLL_Voice_Radio_1_Kill", vcnt = 12},
    ["INPOSITION"]      = {base = "BLL_Voice_Radio_1_Inposition", vcnt = 6},
    ["FORMATIONLINE"]   = {base = "BLL_Voice_Radio_1_FormationLine", vcnt = 2},
    ["FORMATIONFILE"]   = {base = "BLL_Voice_Radio_1_FormationFile", vcnt = 2},
    ["FORMATIONCIRCLE"] = {base = "BLL_Voice_Radio_1_FormationCircle", vcnt = 2},
    ["EMBARK"]          = {base = "BLL_Voice_Radio_1_Embark", vcnt = 6},
    ["DISEMBARK"]       = {base = "BLL_Voice_Radio_1_Disembark", vcnt = 6},

}

local function getVariant(name)
    local sounds = BLLRadioVoice.Sounds
    local sound = sounds[name]
    local base = sound.base
    local rnd = 1 + ZombRand(sound.vcnt)
    return base .. "_" .. rnd
end

-- queue adder
function BLLRadioVoice.Add(name)
    local variant = getVariant(name)
    if not variant then return end

    local event = {}
    event.variant = variant
    event.started = false
    table.insert(BLLRadioVoice.Events, event)
end

-- queue processor
function BLLRadioVoice.Check()
    local player = getSpecificPlayer(0)
    local emitter = player:getPlayer()
    for i, event in pairs(BLLRadioVoice.Events) do
        
        if not event.started then
            event.started = true
            emitter:playSound(event.variant)
        else
            if not emitter:isPlaying(event.variant) then
                table.remove(BLLQueueManager.Events, i)
            end
        end
        break
    end 
end

Events.OnTick.Add(BLLRadioVoice.Check)