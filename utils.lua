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

---Get an entity by its network id
---@param serverId integer
---@return entity_t
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

return Export;
