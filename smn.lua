-- This file adds support for summoner pets.

-- On Horizon, SMN pets use the player's ability id, not the monster ability id.
-- But in Windower's resource files, the skillchain information is stored in the
-- player ability table, not the monster ability table.  So first we need to
-- determine if the actor is a player pet, then consult the appropriate table.

local Utils = require('utils');
---@module 'battle_action'

local Export = T {};

-- a "set" of all smn pets by their english names.
local SMN_PETS = T {
    Carbuncle = true,
    Fenrir = true,
    Ramuh = true,
    Shiva = true,
    Ifrit = true,
    Garuda = true,
    Leviathan = true,
    Titan = true,

    ["Light Spirit"] = true,
    ["Dark Spirit"] = true,
    ["Thunder Spirit"] = true,
    ["Ice Spirit"] = true,
    ["Fire Spirit"] = true,
    ["Air Spirit"] = true,
    ["Water Spirit"] = true,
    ["Earth Spirit"] = true,
}

---Triggers on battle action when actor cmd_no == 13
---@param action BattleAction
function Export.onMonsterAbilityFinish(action)
    local entity = Utils.getEntityByServerId(action.m_uID);

    -- Check and make sure our actor is a player pet.
    if entity.SpawnFlags & 0x100 == 0 then
        return;
    end

    -- Check and make sure our actor is a summon.

    for _, target in ipairs(action.targets) do
        for _, result in ipairs(target.results) do
        end
    end
end
