local WindowerData = require('data/data');
local Constants = require('constants');

---@module 'battle_action'

local Export = T {};

local function allMemoryEntitiesIterator()
end

local function getAllMemoryEntities()
end

local function getEntityByServerId(serverId)
    for i = 0, 2048 do
        local ent = GetEntity(i);
        if ent ~= nil and ent.ServerId == serverId then
            return ent;
        end
    end
end

local function getEntityByPetIndex(ownerIndex)
    for i = 0, 2048 do
        local ent = GetEntity(i);
        if ent ~= nil and ent.PetTargetIndex == ownerIndex then
            return ent;
        end
    end
end

---@class MonsterAbility
---@field name LocalizedString Ability name
---@field id integer Game internal Ability ID
---@field resonance Skillchain[] a list of resonance properties for this ability. [0-3] entries.

-- On Horizon, SMN pets use the player's ability id, not the monster ability id.
-- But in Windower's resource files, the skillchain information is stored in the
-- player ability table, not the monster ability table.  So first we need to
-- determine if the actor is a player pet, then consult the appropriate table.

---Get a Monster's Ability being used in an packet
---@param action BattleAction
---@param target BattleActionTarget
---@param result BattleActionTargetResult
function Export.getMonsterAbility(action, target, result)
    -- Assumes action.cmd_no == 13 (monster ability finish)

    local pktSkillId = action.cmd_arg;

    -- Discern if this is a player pet and look up the skill in the player table if so.
    -- To do that, we first need to get the monster's target index.
    -- local Entity = AshitaCore:GetMemoryManager():GetEntity();
    local monster = getEntityByServerId(action.m_uID);
    if monster == nil then
        return nil; -- ?
    end
    local owner = getEntityByPetIndex(monster.Index)
    if owner == nil then
        return nil; -- TODO: return the monster skill.
    end
end
