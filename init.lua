local MP = minetest.get_modpath("mesecons_debug")

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
    average_total_micros = 0,

    -- playername => true
    hud = {},

    -- which optional dependencies are installed?
    has = {
        monitoring = minetest.get_modpath("monitoring"),
        digilines = minetest.get_modpath("digilines"),
    }
}

dofile(MP .. "/settings.lua")
dofile(MP .. "/util.lua")
dofile(MP .. "/privs.lua")
dofile(MP .. "/context.lua")
dofile(MP .. "/penalty.lua")
dofile(MP .. "/cleanup.lua")
dofile(MP .. "/hud.lua")
dofile(MP .. "/overrides/mesecons_queue.lua")
dofile(MP .. "/overrides/node_timers.lua")
dofile(MP .. "/commands/user_commands.lua")
dofile(MP .. "/commands/admin_commands.lua")
dofile(MP .. "/commands/clear_penalty.lua")
dofile(MP .. "/commands/flush.lua")

if mesecons_debug.has.digilines then
    dofile(MP .. "/penalty_controller.lua")
end

dofile(MP .. "/compat/convert_old_whitelist.lua")
