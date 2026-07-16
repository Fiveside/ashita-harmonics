-- https://github.com/atom0s/XiPackets/tree/main/world/server/0x0028

-- Quirks of action packet processing.
-- When resolving an action id, the following math must take place
-- For weapon skills, the id is as-is
-- For player actions, add 512 to action id
-- For monster skills, subtract 256 from the action id

-- Examples:
-- Player with ifrit summons uses "Punch" pet skill.
-- - Action packet command type 6 (Player uses ability)
-- - Action arg 544
-- - Retrieve the action via AshitaCore:GetResourceManager():GetAbilityById(544+512);

-- Example:
-- Assume the above example occurred. Now Ifrit readies "Punch"
-- - Action packet command type 7 (Monster readies skill)
-- - Action arg 840
-- - Retrieve the action name via AshitaCore:GetResourceManager():GetString('monsters.abilities', 840-256);

-- PRIVATE SERVER QUIRK (HorizonXI specific)
-- In the ifrit readies "Punch" example, the action arg set is actually 544 (the player action id)
-- This is incorrect behavior, but the text log seems fine with it?
-- TODO: why does this work?

---@class BattleActionTargetResult
---@field miss integer The type of connection this attack makes (hit, miss, block, parry, etc.)
---@field kind integer cmd_no specific. Governs animations
---@field sub_kind integer cmd_no specific. Governs animations
---@field info integer miss specific. For general attacks, governs attack severity
---@field scale integer cmd_no specific. For most attacks, governs animations
---@field value integer cmd_no specific. Usually the damage or healing done
---@field message integer The format string to load and print to the chat log
---@field bit integer Extra message formatting (Crit!, Magic burst! etc.)
---@field has_proc boolean Flag declaring if proc_ fields are included. All proc_ fields are zero if this is zero.
---@field proc_kind integer cmd_no specific. Additional effects caused by the attack (enfire, distortion, etc.)
---@field proc_info integer unknown.
---@field proc_value integer cmd_no specific. Holds a parameter associated with the proc
---@field proc_message integer Format string to load and print to the chat log.
---@field has_react boolean Flag declaring if react_ fields are included. Just like has_proc
---@field react_kind integer cmd_no specific. Additional effects triggered by the defender (blaze spikes, counter, etc.)
---@field react_info integer unknown.
---@field react_value integer unknown.
---@field react_message integer Format string to load and print to the chat log.

---@class BattleActionTarget
---@field m_uID integer The defender's server id
---@field result_sum integer The number of effects this defender receives (max 8)
---@field results BattleActionTargetResult The list of effects (count lives in result_sum)

---@class BattleAction
--- A table containing information parsed from a battle packet.
---@field m_uID integer The attacker's server id
---@field trg_sum integer The number of targets affected by this attack (max 16)
---@field res_sum integer Unused. Likely always zero
---@field cmd_no integer Enum describing the type of attack made.
---@field cmd_arg integer Additional data required by indiviudal cmd_no types.
---@field info integer More data specific to individual cmd_no types.
---@field targets BattleActionTarget[] A list of targets this attack hits (count lives in trg_sum)

local Export = {};

---Creates a bit reader for reading packed bits (Big Endian).
---@param data table A list of bytes to read
---@param startingOffset integer? Optional offset to start at
---@return fun(numBits: integer): integer # pass the number of bits to read and it returns the bits read as an integer.
function NewPackedBitreader(data, startingOffset)
    local bitOffset = startingOffset or 0;
    local read = function(numBits)
        local data = ashita.bits.unpack_be(data, bitOffset, numBits);
        bitOffset = bitOffset + numBits;
        return data;
    end;
    return read;
end

---Returns true if the detected ashita packet_in event is a BattleAction
---@param e any The ashita event
---@return boolean # True if the event is a battle packet
function Export.isBattleEvent(e)
    return e.id == 0x28
end

---Short circuiting function for discarding most of the packets that do not contain skillchains
---@param e any The ashita event
---@return boolean True if this event can still contain skillchains
function Export.isPossibleSkillchainEvent(e)
    if not Export.isBattleEvent(e) then
        return false;
    end

    -- Start the reader after the first 5 bytes common to each packet.
    -- Then skip another 42 bits to get to the cmd_no.
    local readBits = NewPackedBitreader(e.data_raw, 40 + 42);

    -- targets starts at 78 bits, each target is variable size.
    -- This function's purpose is to skip extra processing.
    -- We hit diminishing returns here trying to figure out if a
    -- skillchain is present, so just check the cmd_no.
    -- This already rules out a lot of packets.

    -- skip 42 bits, read 4.
    -- skip 40, read 1 byte, mask: 0011 1100
    local cmd_no = readBits(4);

    -- 3: weaponskill finish
    -- 4: magic finish (blu shenannigans)
    -- 6: ability finish
    -- 11: monster skill finish, trust skill finish
    -- 13: pet skill finish
    -- 14: dnc ability (?)
    return T { 3, 4, 6, 11, 13, 14 }:contains(cmd_no);
end

---Parses a raw battle packet into a lua table. No additional processing.
---@param e any The Ashita packet_in event.
---@return BattleAction
function Export.parseIncomingPacketEvent(e)
    -- Start the reader after the first 5 bytes common to each packet.
    local readBits = NewPackedBitreader(e.data_raw, 40);

    local res = {};
    res.m_uID = readBits(32);
    res.trg_sum = readBits(6);
    res.res_sum = readBits(4);
    res.cmd_no = readBits(4);
    res.cmd_arg = readBits(32);
    res.info = readBits(32);
    local targets = {};
    res.targets = targets;
    ---@cast res BattleAction

    for _i = 1, res.trg_sum, 1 do
        local target = {};
        target.m_uID = readBits(32);
        target.result_sum = readBits(4);
        local results = {};
        target.results = results
        ---@cast target BattleActionTarget
        targets[#targets + 1] = target;

        for _i = 1, target.result_sum, 1 do
            -- prepopulate the proc_ and react_ stuff.
            local result = {
                proc_kind = 0,
                proc_info = 0,
                proc_value = 0,
                proc_message = 0,
                react_kind = 0,
                react_info = 0,
                react_value = 0,
                react_message = 0,
            };
            result.miss = readBits(3);
            result.kind = readBits(2);
            result.sub_kind = readBits(12);
            result.info = readBits(5);
            result.scale = readBits(5);
            result.value = readBits(17);
            result.message = readBits(10);
            result.bit = readBits(31);

            local has_proc = readBits(1);
            result.has_proc = has_proc ~= 0;
            -- result.has_proc = readBits(1);
            if result.has_proc then
                result.proc_kind = readBits(6);
                result.proc_info = readBits(4);
                result.proc_value = readBits(17);
                result.proc_message = readBits(10);
            end

            local has_react = readBits(1);
            result.has_react = has_react ~= 0;
            -- result.has_react = readBits(1);
            if result.has_react then
                result.react_kind = readBits(6);
                result.react_info = readBits(4);
                result.react_value = readBits(14);
                result.react_message = readBits(10);
            end

            ---@cast result BattleActionTargetResult
            target.results[#target.results + 1] = result;
        end
    end

    return res;
end

return Export;