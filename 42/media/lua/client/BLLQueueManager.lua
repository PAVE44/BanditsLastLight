BLLQueueManager = BLLQueueManager or {}

-- table for enqueued events
BLLQueueManager.Events = {}

-- queue adder
function BLLQueueManager.Add(name, params, delay)
    event = {}
    event.start = BanditUtils.GetTime() + delay
    event.name = name
    event.params = params
    table.insert(BLLQueueManager.Events, event)
end

-- queue processor
function BLLQueueManager.Check()
    local player = getSpecificPlayer(0)
    if not player then return end

    local ct = BanditUtils.GetTime()
    for i, event in pairs(BLLQueueManager.Events) do
        if event.start < ct then
            if BLLEvents[event.name] then
                BLLEvents[event.name](event.params)
            end
            table.remove(BLLQueueManager.Events, i)
            break
        end
    end
end

Events.OnTick.Add(BLLQueueManager.Check)