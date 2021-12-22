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
dofile(MP .. "/functions.lua")
dofile(MP .. "/mesecons_queue_overrides.lua")
dofile(MP .. "/privs.lua")
dofile(MP .. "/flush.lua")
dofile(MP .. "/context.lua")
dofile(MP .. "/penalty.lua")
dofile(MP .. "/clear_penalty.lua")
dofile(MP .. "/overrides.lua")
dofile(MP .. "/luacontroller.lua")
dofile(MP .. "/chatcommands.lua")
dofile(MP .. "/hud.lua")

if minetest.get_modpath("digilines") then
    dofile(MP .. "/penalty_controller.lua")
end

mesecons_debug.load_legacy_whitelist()

print("[OK] mesecons_debug loaded")
