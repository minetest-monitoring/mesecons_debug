local MP = minetest.get_modpath("mesecons_debug")

mesecons_debug = {
    enabled = true,

    -- blockpos-hash => context
    context_store = {},
    context_store_size = 0,

    -- persistent storage for whitelist
    storage = minetest.get_mod_storage(),

    -- playername => true
    hud = {},
}

dofile(MP .. "/settings.lua")
dofile(MP .. "/util.lua")
dofile(MP .. "/privs.lua")
dofile(MP .. "/context.lua")
dofile(MP .. "/penalty.lua")
dofile(MP .. "/hud.lua")
dofile(MP .. "/overrides/mesecons_queue.lua")
dofile(MP .. "/overrides/node_timers.lua")
dofile(MP .. "/commands/flush.lua")
dofile(MP .. "/commands/clear_penalty.lua")
dofile(MP .. "/commands/basic_commands.lua")

if minetest.get_modpath("digilines") then
    dofile(MP .. "/penalty_controller.lua")
end

dofile(MP .. "/compat/convert_old_whitelist.lua")
