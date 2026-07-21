-- This file adds support for summoner pets.

-- On Horizon, SMN pets use the player's ability id, not the monster ability id.
-- But in Windower's resource files, the skillchain information is stored in the
-- player ability table, not the monster ability table.  So first we need to
-- determine if the actor is a player pet, then consult the appropriate table.

local Data = require('data/data');
local Constants = require('constants');
local Utils = require('utils');
local BattleAction = require('battle_action');
local Skillchains = require('skillchains');

local Export = T {};

---Take a packet and return its actor names and optional owner.
---@param action BattleAction
---@return table TODO - Flesh this out
local function getActor(action)
    -- We can assume the actor is an avatar because spirits have no skills with resonance data.
    local petName = "{Unknown Avatar}";
    local ownerName = "{Unknown SMN}";

    local pet = Utils.getEntityByServerId(action.m_uID);
    if pet ~= nil then
        petName = pet.Name;
        local owner = Utils.getPetOwnerByEntity(pet);
        if owner ~= nil then
            ownerName = owner.Name;
        end
    end
    return {
        id = action.m_uID,
        name = petName,
        owner = ownerName,
    }
end

---Triggers on battle action when cmd_no == 13
---@param action BattleAction
function Export.onMonsterAbilityFinish(action)
    -- We can assert whether our actor was a player smn's pet by looking up the skill used.
    -- Skillchain data for smn pets is stored on the job ability
    -- table in the auxiliary resource files.  We can be sure
    -- that a pet is a smn pet by checking the ability and checking
    -- that it is a blood pact.
    local actionId = action.cmd_arg;
    
    -- On horizon, the packet's ability id is the same number as the ability id
    -- on the job abilities resource table.  On retail, this needs to be
    -- dereferenced through the data pet mapping.
    -- TODO: Verify the dereference is required and implement the dereference.
    local jobAbility = Data.JobAbilities[actionId];
    if jobAbility == nil then
        print(string.format("Error: tried to look up SMN job ability %d, but it doesn't exist", actionId));
        return {};
    end
    if jobAbility.type ~= "BloodPactRage" and jobAbility.type ~= "BloodPactWard" then
        return {};
    end

    -- discard if this ability doesn't resonate.
    local resonance = Data.getResonanceProperties(jobAbility);
    if #resonance == 0 then
        return {};
    end

    -- TODO: This is a Horizon specific lookup, see the top of battle_action for more info.
    local monsterActionId = Data.PlayerPetMonsterMapping[actionId];
    local attackName = AshitaCore:GetResourceManager():GetString('monsters.abilities', monsterActionId-256);

    local actor = getActor(action);

    local attack = T{
        recordName = Data.getLocalizedString(jobAbility),
        name = attackName,
        resonance = resonance,
    }

    local results = T{};
    for _, target in ipairs(action.targets) do
        local targetEntity = Utils.getEntityByServerId(target.m_uID);
        for _, result in ipairs(target.results) do
            -- Discard if the attack missed.
            if result.miss ~= BattleAction.Miss.Miss and result.miss ~= BattleAction.Miss.Evade then
                -- TODO: negative numbers on damage absorb?
                local defender = {
                    id = target.m_uID,
                    name = targetEntity.Name,
                    damage = result.value,
                    disposition = result.Miss,
                }

                table.insert(results, T{
                    actor = actor,
                    attack = attack,
                    defender = defender,
                    chain = Skillchains.parseSkillchain(action, target, result),
                });
            end
        end
    end

    return results;
end
