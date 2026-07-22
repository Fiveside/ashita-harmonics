-- Tracking the state of the world around us and how it changes.

local Constants = require('constants');
local Events = require('events');
local Utils = require('utils');

---When a resonance action occurs, track it and broadcast skillchain window events.
---@param event ResonanceAction
local function onResonanceAction(event)
end

---When a skillchain occurs, track it and broadcast burst window events.
---@param event SkillchainAction
local function onSkillchainAction(event)
end

local Export = {};

function Export.install()
end


return Export;