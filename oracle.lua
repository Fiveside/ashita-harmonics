require 'common'

local events = require("events");
local constants = require("constants");
local Skillchains = require('skillchains');

addon.name       = 'Oracle'
addon.author     = 'Fiveside'
addon.version    = '0.1'
addon.desc       = 'An addon that displays active skillchains and shows which weapon skills will create skillchains.  Similar to chains.'


ashita.events.register("load", "load_cb", function()
    events.install();
    Skillchains.install();
end);

ashita.events.register("unload", "unload_cb", function()
    events.uninstall();
end);

ashita.events.register("d3d_present", "each_frame_cb", function()
    events.tick();
end);