BLLHQ = BLLHQ or {}

BLLHQ.tools = {}

BLLHQ.tools.strafingRun = {
    name = "Strafing run",
    available = false,
    icon = "", 
    cooldownMax = 30,
    uses = 8,
    cooldown = 0
}

BLLHQ.tools.gasRun = {
    name = "Gas run",
    available = false,
    icon = "", 
    cooldownMax = 120,
    uses = 4,
    cooldown = 0
}

BLLHQ.tools.bombRun = {
    name = "Bombing run",
    available = false,
    icon = "", 
    cooldownMax = 120,
    uses = 4,
    cooldown = 0
}

BLLHQ.tools.supplyDrop = {
    name = "Supply drop",
    available = false,
    icon = "", 
    cooldownMax = 30,
    uses = 1,
    cooldown = 0
}

BLLHQ.Use = function(toolName)
    if BLLHQ.tools[toolName] then
        local tool = BLLHQ.tools[toolName]
        if tool.available and tool.uses > 0 and tool.cooldown == 0 then
            tool.cooldown = tool.cooldownMax
            tool.uses = tool.uses - 1
        end
    end
end

BLLHQ.Update = function()
    local tools = BLLHQ.tools
    for _, tool in pairs(tools) do
        if tool.cooldown > 0 then
            tool.cooldown = tool.cooldown - 1
        end
    end
end

Events.EveryOneMinute.Add(BLLHQ.Update)
