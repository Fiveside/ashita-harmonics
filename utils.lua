local Export = T {};

-- The game tracks 2319 entities total
-- Generally, 0 through 2047 are your environment (objects, npcs, players, enemies)
-- and 2048 through 2318 are your alliance and alliance pets.
-- This might change if XI ever does some under the hood code cleanup.

local function entityIterator(_invariant, index)
    while index < 2319 do
        local ent = GetEntity(index);
        index = index + 1
        if ent ~= nil then
            return index, ent
        end
    end
end

function Export.getAllEntities()
    return entityIterator, nil, 0;
end

---Get an entity by its network id
---@param serverId integer
---@return entity_t?
function Export.getEntityByServerId(serverId)
    for _entityId, entity in Export.getAllEntities() do
        if entity.ServerId == serverId then
            return entity;
        end
    end
end

---Get an entity's owner by the entity itself.
---@param entity entity_t
---@return entity_t?
function Export.getPetOwnerByEntity(entity)
    for _, maybeOwner in Export.getAllEntities() do
        if maybeOwner.PetTargetIndex == entity.TargetIndex then
            return maybeOwner
        end
    end
end

local lastNonce = 0;

---Create a unique integer.
function Export.newNonce()
    lastNonce = lastNonce + 1;
    return lastNonce;
end

-- Allows users to register callbacks to some formalized events
local ffi = require('ffi');

-- https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps
ffi.cdef [[
    typedef long long LONGLONG;
    typedef struct _LARGE_INTEGER {
        LONGLONG QuadPart;
    } LARGE_INTEGER;

    int QueryPerformanceCounter(LARGE_INTEGER *lpPerformanceCounter);
    int QueryPerformanceFrequency(LARGE_INTEGER *lpFrequency);
]];

local PERFORMANCE_COUNTER = ffi.new("LARGE_INTEGER");

-- Frequency is set once at system boot and stays constant after.
local PERFORMANCE_FREQUENCY = ffi.new("LARGE_INTEGER");
ffi.C.QueryPerformanceFrequency(PERFORMANCE_FREQUENCY);

function Export.getPerformanceStampMilliseconds()
    ffi.C.QueryPerformanceCounter(PERFORMANCE_COUNTER);

    -- Performance counter is in second resolution, and frequency is in the range of
    -- some hundred thousand or million.  This means we still have high resolution if
    -- we multiply here to obtain milliseconds or even microseconds.
    --
    -- Luajit extends the syntax to include LL and ULL suffixes for int64 and uint64
    -- Simple math operations on 64 bit integers don't cast down to float64.
    local stamp = PERFORMANCE_COUNTER.QuadPart;
    stamp = stamp * 1000LL;
    stamp = stamp / PERFORMANCE_FREQUENCY.QuadPart;
    return stamp;
end

return Export;
