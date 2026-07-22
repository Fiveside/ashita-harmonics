-- This file adds support for summoner pets.

-- On Horizon, SMN pets use the player's ability id, not the monster ability id.
-- But in Windower's resource files, the skillchain information is stored in the
-- player ability table, not the monster ability table.  So first we need to
-- determine if the actor is a player pet, then consult the appropriate table.

local Data = require('data/data');
local Utils = require('utils');

---@module 'battle_action'
---@module 'constants'

local Export = T {};

---Take a packet and return its actor names and optional owner.
---@param action BattleAction
---@return ResonanceActionActor
local function getActor(action)
    -- We can assume the actor is an avatar because spirits have no skills with resonance data.
    local petName = nil;
    local ownerName = nil;

    -- TODO: Create a name cache for a zone and use that instead of these.
    -- as these may or may not be populated at lookup time.
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
        defaultName = "{Unknown Avatar}",
        owner = ownerName,
        defaultOwner = "{Unknown SMN}",
    }
end

---Get the actor information for a resonating summoner action. Triggers on battle action when cmd_no == 13
---@param action BattleAction
---@return {actor: ResonanceActionActor, action: ResonanceActionAction}
function Export.getResonanceAbility(action)
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
        return;
    end

    if jobAbility.type ~= "BloodPactRage" and jobAbility.type ~= "BloodPactWard" then
        return;
    end

    -- discard if this ability doesn't resonate.
    local resonance = Data.getResonanceProperties(jobAbility);
    if #resonance == 0 then
        return;
    end

    -- TODO: This is a Horizon specific lookup, see the top of battle_action for more info.
    local monsterActionId = Data.PlayerPetMonsterMapping[actionId];
    local attackName = AshitaCore:GetResourceManager():GetString('monsters.abilities', monsterActionId-256);

    return T{
        actor = getActor(action),
        action = {
            recordName = Data.getLocalizedString(jobAbility),
            name = attackName,
            resonance = resonance,
        },
    };
end
