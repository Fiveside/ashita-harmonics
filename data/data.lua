local Constants = require('constants');

---@class WindowerData
---@field id integer The game id
---@field en string The english name
---@field ja string The japanese name
---@field skillchain_a (Skillchain | "")? First resonance property. Nil if this doesn't resonate
---@field skillchain_b (Skillchain | "")? Second resonance property. Empty string if this only has one resonance proprety. Nil if this doesn't resonate.
---@field skillchain_c (Skillchain | "")? Third resonance property. Empty string if this has less than 3 resonance properties. Nil if this doesn't resonate.


---@class MonsterAbilityData : WindowerData

---@alias JobAbilityDataType
---| '"JobAbility"'
---| '"BloodPactWard"'
---| '"BloodPactRage"'
---| '"PetCommand"'
---| '"CorsairRoll"'
---| '"CorsairShot"'
---| '"Ward"'
---| '"Effusion"'
---| '"Scholar"'
---| '"Waltz"'
---| '"Samba"'
---| '"Jig"'
---| '"Step"'
---| '"Flourish1"'
---| '"Flourish2"'
---| '"Flourish3"'
---| '"Monster"'
---| '"Rune"'

---@class JobAbilityData : WindowerData
---@field type JobAbilityDataType
---@field element integer XI Element ID

---@class WeaponSkillData : WindowerData
---@field element integer XI Element ID
---@field skill integer XI Combat skill ID

local Export = T {};

---@type WeaponSkillData[]
Export.WeaponSkills = require('data/resources/resources_data/weapon_skills')

---@type WindowerData[]
Export.MonsterAbilities = require('data/resources/resources_data/weapon_skills')

---@type JobAbilityData[]
Export.JobAbilities = require('data/resources/resources_data/job_abilities')

-- Some types that we use representing the above
---@class BaseDataAbility
---@field name LocalizedString Ability name
---@field id integer Game internal Ability ID
---@field resonance Skillchain[] a list of resonance properties for this ability. [0-3] entries.

---@class MonsterAbility : BaseDataAbility

---@class JobAbility : BaseDataAbility
---@field type JobAbilityDataType

-- Windower stores resonance data for player pets on the job abilites table instead
-- of the monster abilities table.  This is a mapping of monster abilities that resonate
-- to player skills that contain resonance data.
-- Mapping is monster skill id -> player skill id
--
-- smn pets are the only ones that seem to have resonance data in the job abilities table?
--
-- TODO: This mapping is currently incomplete and only contains data for jobs and skills
-- on horizon atm.  Need to add the rest of the mappings
Export.MonsterPlayerPetMapping = T {
    -- SMN pet skills.
    [907] = 513, -- Poison Nails
    [831] = 528, -- Moonlit Charge
    [832] = 529, -- Crescent Fang
    [840] = 544, -- Punch
    [842] = 546, -- Burning Strike
    [843] = 547, -- Double Punch
    [849] = 560, -- Rock Throw
    [851] = 562, -- Rock Buster
    [852] = 563, -- Megalith Throw
    [858] = 576, -- Barracuda Dive
    [860] = 578, -- Tail Whip
    [867] = 592, -- Claw
    [876] = 608, -- Axe Kick
    [880] = 612, -- Double Slap
    [885] = 624, -- Shock Strike
};

-- and the reverse
Export.PlayerPetMonsterMapping = T{};
do
    for monsterSkill, playerSkill in pairs(Export.MonsterPlayerPetMapping) do
        Export.PlayerPetMonsterMapping[playerSkill] = monsterSkill;
    end
end

---Takes a data record and returns the resonance properties in a more easily digestable format
---@param record WindowerData
---@return Skillchain[]
function Export.getResonanceProperties(record)
    ---@type Skillchain[]
    local resonance = T{};

    if record.skillchain_a ~= nil then
        table.insert(resonance, record.skillchain_a);
        if record.skillchain_b ~= "" then
            table.insert(resonance, record.skillchain_b);
        end
        if record.skillchain_c ~= "" then
            table.insert(resonance, record.skillchain_c)
        end
    end

    return resonance;
end

---Takes a data record and returns a localized string for the record name
---@param record WindowerData
---@return LocalizedString
function Export.getLocalizedString(record)
    return {
        en = record.en,
        ja = record.ja,
    };
end

return Export;
