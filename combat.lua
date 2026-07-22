local Events = require('events');
local BattleAction = require('battle_action');
local SMN = require('smn');
local Constants = require('constants');
local Utils = require('utils');

local Export = {};

---Get the effect of performing this action (unless it didn't connect).
---@param ba BattleAction
---@param target BattleActionTarget
---@param result BattleActionTargetResult
---@return ResonanceActionEffect?
local function getActionEffect(ba, target, result)
    -- Discard if the action missed
    if result.Miss == BattleAction.Miss.Miss or result.Miss == BattleAction.Miss.Evade then
        return;
    end

    -- TODO: That name cache thing.
    local targetEntity = Utils.getEntityByServerId(target.m_uID);
    local targetName = nil;
    if targetEntity ~= nil then
        targetName = targetEntity.Name
    end

    return {
        id = target.m_uID,

        -- TODO: the name cache...
        name = targetName,
        damage = result.value,
        kind = result.Miss,
    };
end

---Take a result from an action packet and return the skillchain inside.
---@param ba BattleAction
---@param target BattleActionTarget
---@param result BattleActionTargetResult
---@return ResonanceActionSkillchain? The skillchain data if this action caused one.
local function getSkillchain(ba, target, result)
    if not result.has_proc or result.proc_kind == 0 then
        return;
    end

    -- if result.proc_message ~= 292 then
    --     print()
    -- end

    -- TODO: Figure out what happens when the target absorbs the skillchain, healing hp.

    local chain = Constants.SKILLCHAIN_IDS[result.proc_kind]
    return {
        chain = chain,
        damage = result.proc_value,
        elements = Constants.SKILLCHAIN_ELEMENTS[chain],
    }
end


local function onPacketIn(pkt)
    if not BattleAction.isPossibleSkillchainEvent(pkt) then
        return;
    end
    local ba = BattleAction.parseIncomingPacketEvent(pkt);

    local action = nil;
    if ba.cmd_no == BattleAction.CommandKind.PetSkillFinish then
        action = SMN.getResonanceAbility(ba);
    end

    -- This action doesn't resonate.
    if action == nil then
        return;
    end

    for _, baTarget in ipairs(ba.targets) do
        for _, baResult in ipairs(baTarget.results) do
            local result = getActionEffect(ba, baTarget, baResult);
            if result ~= nil then
                -- Emit event!
                local chain = getSkillchain(ba, baTarget, baResult);
                local event = T {
                    actor = action.actor,
                    action = action.action,
                    effect = result,
                    chain = chain,
                }
                Events.trigger(Events.RESONANCE_SKILL, event);

                -- If a skillchain occurred, also broadcast that event.
                if chain ~= nil then
                    Events.trigger(Events.SKILLCHAIN, event);
                end
            end
        end
    end
end


function Export.install()
    Events.on(Events.PACKET_IN, onPacketIn)
end

return Export;
