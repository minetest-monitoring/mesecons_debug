local MP = minetest.get_modpath("mesecons_debug")

mesecons_debug = {
	enabled = true
}

dofile(MP.."/privs.lua")
dofile(MP.."/chatcommands.lua")
dofile(MP.."/api_action_on.lua")
dofile(MP.."/api_nodetimer.lua")
dofile(MP.."/register.lua")
dofile(MP.."/flush.lua")
dofile(MP.."/globalstep.lua")
dofile(MP.."/actionqueue.lua")

print("[OK] mesecons_debug loaded")
