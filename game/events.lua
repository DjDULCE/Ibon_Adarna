local Events = {}

local events = {}

function Events.register(obj, name)
    if not events[name] then
        events[name] = {}
    end
    table.insert(events[name], obj)
end

function Events.emit(name)
    if not events[name] then error("no event name " .. name .. " registered") end
    for _, obj in ipairs(events[name]) do
        local res = obj[name](obj)
        if res and type(res) == "boolean" and res == true then
            break
        end
    end
end

function Events.clear()
    tablex.clear(events)
end

return Events
