local Events = require('events');
local Constants = require('constants');
local Chat = require('chat');
-- local Parser = require('parser');
-- local BitReader = require("bitreader");
local BattleAction = require('battle_action')

local function parseSkillchain(ba, target, result)
    if not result.has_proc or result.proc_kind == 0 then
        return
    end

    -- if result.proc_message ~= 292 then
    --     print()
    -- end

    local chain = Constants.SKILLCHAIN_IDS[result.proc_kind]
    return {
        chain = chain,
        damage = result.proc_value,
        elements = Constants.SKILLCHAIN_ELEMENTS[chain],
    }
end

-- called when cmd_no = 13
local function onPetSkill(ba, target, result)

end

---Gets resonance values for a monster's skill id
---@param skillId integer The network skill id
local function getMonsterResonance(skillId)

end

local function emitSkillchain(action, target, result, skillchain)
    -- TODO: this is currently hardcoded for player pets.
    if action.cmd_no ~= 13 then
        return
    end

    -- Get the target's current resonance properties
end

local function onPacketIn(pkt)
    -- Short circuit to omit any packets that cannot possibly contain a skillchain
    -- the cmd_no is 82 bits into the packet.
    -- 5 bytes + 32 bits (4 bytes) + 6 bits + 4 bits
    -- 40 bits + 42 bits
    -- if pkt.id ~= 0x028 then
    --     return
    -- end
    if not BattleAction.isPossibleSkillchainEvent(pkt) then
        return
    end

    -- interesting cmd_no events:
    -- cmd_no == 13 -- Monster completes skill.  Can occur with player pets.
    -- - cmd_arg == un-corrected monster skill id.
    -- cmd_no == 6 -- Player completes ability.
    -- - cmd_arg == uncorrected player ability id.
    -- cmd_no == 3 -- Player completes weapon skill.  Some JAs (like mug) also use this.
    -- - cmd_arg == corrected player ability id.
    -- cmd_no == 4 -- Player completes magic spell cast.
    -- - Check miss, as cmd_no==4 is also used for weapon skills that do not complete due to out of range.
    -- - bit contains a flag indicating magic burst.  However documentation notes this is inconsistent.
    -- -   More reliable MB detection may come from checking the message id.
 
    local res = AshitaCore:GetResourceManager();
    local mem = AshitaCore:GetMemoryManager();

    local action = BattleAction.parseIncomingPacketEvent(pkt);
    for _, target in ipairs(action.targets) do
        local actorId = action.m_uID;
        local receiverId = target.m_uID;
        local actorEntity = {Name = "unknown"};
        local receiverEntity = {Name = "unknown"};
        for i = 0, 2300 do
            local entity = GetEntity(i);
            if entity ~= nil then
                if entity.ServerId == actorId then
                    actorEntity = entity;
                elseif entity.ServerId == receiverId then
                    receiverEntity = entity;
                end
            end
        end
        local skillName = res:GetString("monsters.abilities", action.cmd_arg);
        local actionId = ashita.bits.unpack_be(pkt.data_raw, 0, 213, 17);
        print(string.format("[%s][%d] %s -> %s", actorEntity.Name, actionId, skillName:clean(), receiverEntity.Name))
        for _, result in ipairs(target.results) do
            local sc = parseSkillchain(action, target, result);
            if sc ~= nil then
                emitSkillchain(action, target, result, sc);
            end
        end
    end
end


local Export = {};

function Export.install()
    Events.on(Events.PACKET_IN, onPacketIn)
end

return Export;