local MP = minetest.get_modpath("mesecons_debug")

mesecons_debug = {}

dofile(MP.."/api.lua")
dofile(MP.."/register.lua")
dofile(MP.."/flush.lua")
dofile(MP.."/globalstep.lua")

print("[OK] mesecons_debug loaded")
