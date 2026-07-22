require 'common'

local Events = require("events");
local Combat = require('combat');
local State = require('state');
local Chat = require('chat');
local Gui = require('gui');

addon.name       = 'Oracle'
addon.author     = 'Fiveside'
addon.version    = '0.1'
addon.desc       = 'An addon that displays active skillchains and shows which weapon skills will create skillchains.  Similar to chains.'


ashita.events.register("load", "load_cb", function()
    Events.install();
    Combat.install();
    State.install();

    Gui.resetData();
    
    -- ---asdf
    -- ---@param event SkillchainAction
    -- Events.on(Events.SKILLCHAIN, function(event)
    --     local actor = string.format("[%s]%s", event.actor.owner, event.actor.name)
    --     local action = string.format("%s (%d)", event.action.name, event.effect.damage);
    --     local defender = string.format("%s [%s!]", event.effect.name, event.chain.chain);
    --     local logline = string.format("%s %s -> %s", actor, action, defender);
    
    --     print(Chat.header(addon.name) .. "SKILLCHAIN " .. Chat.message(logline));
    -- end);
    
    ---adfasfsfasf
    ---@param event ResonanceAction
    Events.on(Events.RESONANCE_ACTION, function(event)
        local actor = string.format("[%s]%s", event.actor.owner, event.actor.name)
        local action = string.format("%s (%d)", event.action.name, event.effect.damage);
        local defender;
        if event.chain ~= nil then
            defender = string.format("%s [%s!]", event.effect.name, event.chain.chain);
        else
            defender = string.format("%s", event.effect.name);
        end
        local logline = string.format("%s %s -> %s", actor, action, defender);

        print(Chat.header(addon.name) .. "RESONANCE_ACTION " .. Chat.message(logline));
    end);
end);

ashita.events.register("unload", "unload_cb", function()
    Events.uninstall();
end);

ashita.events.register("d3d_present", "each_frame_cb", function()
    Events.tick();
    Gui.drawGui();
end);

