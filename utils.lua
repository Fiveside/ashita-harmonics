local Export = T {};

local function entityIterator(_invariant, index)
    while index < 2034 do
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

function Export.getEntityByServerId(serverId)
    for _entityId, entity in Export.getAllEntities() do
        if entity.ServerId == serverId then
            return entity;
        end
    end
end

return Export;
