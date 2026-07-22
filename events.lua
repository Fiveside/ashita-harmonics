-- Allows users to register callbacks to some formalized events
-- local ffi = require('ffi');

-- -- https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps
-- ffi.cdef [[
--     typedef long long LONGLONG;
--     typedef struct _LARGE_INTEGER {
--         LONGLONG QuadPart;
--     } LARGE_INTEGER;

--     int QueryPerformanceCounter(LARGE_INTEGER *lpPerformanceCounter);
--     int QueryPerformanceFrequency(LARGE_INTEGER *lpFrequency);
-- ]];

-- local PERFORMANCE_COUNTER = ffi.new("LARGE_INTEGER");

-- -- Frequency is set once at system boot and stays constant after.
-- local PERFORMANCE_FREQUENCY = ffi.new("LARGE_INTEGER");
-- ffi.C.QueryPerformanceFrequency(PERFORMANCE_FREQUENCY);

-- local function getPerformanceStampMilliseconds()
--     ffi.C.QueryPerformanceCounter(PERFORMANCE_COUNTER);

--     -- Performance counter is in second resolution, and frequency is in the range of
--     -- some hundred thousand or million.  This means we still have high resolution if
--     -- we multiply here to obtain milliseconds or even microseconds.
--     --
--     -- Luajit extends the syntax to include LL and ULL suffixes for int64 and uint64
--     -- Simple math operations on 64 bit integers don't cast down to float64.
--     local stamp = PERFORMANCE_COUNTER.QuadPart;
--     stamp = stamp * 1000LL;
--     stamp = stamp / PERFORMANCE_FREQUENCY.QuadPart;
--     return stamp;
-- end

local Utils = require('utils');

local Events = {};
Events.__index = Events;

local ASHITA_PACKET_IN_NAME = "event_emitter_packet_handler"

---@class TimeEvent
---@field after integer
---@field callback fun(...)

---@alias EventName string

-- Get notified when a new packet comes in
Events.PACKET_IN = "packetIn"

-- Get notified when a nearby skill causes a target to resonate
Events.RESONANCE_ACTION = "resonanceAction"

-- Get notified when the window to complete a skillchain opens and closes.
Events.SKILLCHAIN_WINDOW_OPEN = "skillchainWindowOpen"
Events.SKILLCHAIN_WINDOW_CLOSE = "skillchainWindowClose"


-- Get notified when a nearby target eats a skillchain.
Events.SKILLCHAIN = "skillchain"

-- Get notified when a nearby target eats a magic burst.
Events.MAGIC_BURST = "magicBurst"

-- Get notified when the window to perform a magic burst on a nearby target opens and closes.
Events.MAGIC_BURST_WINDOW_OPEN = "magicBurstWindowOpen"
Events.MAGIC_BURST_WINDOW_CLOSE = "magicBurstWindowClose"

-- Force an internal state reset.  If we do our job right, this shouldn't be neccesary.
Events.RESET = "reset"

---@type table<integer, fun(...)[]>
local namedEvents = T {
    [Events.PACKET_IN] = T {},
    [Events.RESONANCE_ACTION] = T {},
    [Events.SKILLCHAIN] = T {},
    [Events.SKILLCHAIN_WINDOW_OPEN] = T {},
    [Events.SKILLCHAIN_WINDOW_CLOSE] = T {},
    [Events.MAGIC_BURST] = T {},
    [Events.MAGIC_BURST_WINDOW_OPEN] = T {},
    [Events.MAGIC_BURST_WINDOW_CLOSE] = T {},
    [Events.RESET] = T {},
};

---@type TimeEvent[]
local timeEvents = T {};

function Events.install()
    -- Make sure we reset and wipe state as well
    for k, handlers in pairs(namedEvents) do
        namedEvents[k] = T {};
    end
    timeEvents = T {};

    ashita.events.register("packet_in", ASHITA_PACKET_IN_NAME, function(pkt)
        Events.trigger(Events.PACKET_IN, pkt);
    end);
end

function Events.uninstall()
    ashita.events.unregister("packet_in", ASHITA_PACKET_IN_NAME);
end

function Events.tick()
    -- do shit.  Call this each frame.
    local stamp = Utils.getPerformanceStampMilliseconds();

    -- Backwards iteration because we're modifying the table
    -- in the middle of the loop.
    for i = #timeEvents, 1, -1 do
        local event = timeEvents[i];
        if stamp > event.after then
            event.callback()
            table.remove(timeEvents, i);
        end
    end
end

---Set a function to run after a duration
---@param after integer The amount of time to delay execution by (milliseconds).
---@param fn fun() The callback to run
function Events.after(after, fn)
    table.insert(timeEvents, {
        callback = fn,
        after = Utils.getPerformanceStampMilliseconds() + after,
    });
end

---Register an event handler
---@param event integer
---@param callback fun(...)
function Events.on(event, callback)
    table.insert(namedEvents[event], callback)
end

---Trigger all event handlers for an event
---@param event EventName
---@param ... unknown Arguments to pass to the event handler.
function Events.trigger(event, ...)
    -- Could probably use pcall, but this is all my code.
    -- so don't write shitty event handlers.
    for _, cb in ipairs(namedEvents[event]) do
        cb(...);
    end
end

return Events;
