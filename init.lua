local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

mesecons_debug = {
    -- is mesecons_debug enabled?
    enabled = true,

    -- is mescons enabled?
    mesecons_enabled = true,

    -- blockpos-hash => context
    context_store = {},
    context_store_size = 0,

    -- persistent storage for whitelist
    storage = minetest.get_mod_storage(),

    -- total amount of time used by mesecons in the last period
    total_micros = 0,

    -- running average of how much mesecons is doing
    avg_total_micros_per_second = 0,

    -- average lag
    avg_lag = 1,
    lag_level = 'none',
    load_level = 'none',

    -- playername => true
    hud_enabled_by_playername = {},

    -- which optional dependencies are installed?
    has = {
        monitoring = minetest.get_modpath("monitoring"),
        digilines = minetest.get_modpath("digilines"),
    },

    log = function(level, message_fmt, ...)
        minetest.log(level, ("[%s] "):format(modname) .. message_fmt:format(...))
    end
}

dofile(modpath .. "/settings.lua")
dofile(modpath .. "/util.lua")
dofile(modpath .. "/privs.lua")
dofile(modpath .. "/context.lua")
dofile(modpath .. "/penalty.lua")
dofile(modpath .. "/cleanup.lua")
dofile(modpath .. "/hud.lua")
dofile(modpath .. "/overrides/mesecons_queue.lua")
dofile(modpath .. "/overrides/node_timers.lua")
dofile(modpath .. "/commands/user_commands.lua")
dofile(modpath .. "/commands/admin_commands.lua")
dofile(modpath .. "/commands/create_lag.lua")
dofile(modpath .. "/commands/clear_penalty.lua")
dofile(modpath .. "/commands/flush.lua")

dofile(modpath .. "/nodes/mesecons_lagger.lua")
if mesecons_debug.has.digilines then
    dofile(modpath .. "/nodes/penalty_controller.lua")
end

dofile(modpath .. "/compat/convert_old_whitelist.lua")
