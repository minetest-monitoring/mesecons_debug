local MP = minetest.get_modpath("mesecons_debug")

mesecons_debug = {}

----  dofile(MP.."/add_action.lua")
dofile(MP.."/privs.lua")
dofile(MP.."/flush.lua")
dofile(MP.."/overrides.lua")

print("[OK] mesecons_debug loaded")
