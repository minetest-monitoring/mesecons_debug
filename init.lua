local MP = minetest.get_modpath("mesecons_debug")

mesecons_debug = {}

dofile(MP.."/privs.lua")
dofile(MP.."/api_action_on.lua")
dofile(MP.."/api_nodetimer.lua")
dofile(MP.."/register.lua")
dofile(MP.."/flush.lua")
dofile(MP.."/globalstep.lua")
dofile(MP.."/dump_queue.lua")

print("[OK] mesecons_debug loaded")
