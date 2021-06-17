local MP = minetest.get_modpath("mesecons_debug")

mesecons_debug = {
	enabled = true,
	-- blockpos-hash => context
	context_store = {},
	context_store_size = 0,

	-- max penalty in seconds
	max_penalty = 300,

	-- everything above this threshold will disable the mesecons in that mapblock
	penalty_mapblock_disabled = 60,

	-- time between /mesecons_clear_penalty commands, in seconds
	penalty_clear_cooldown = 120,

	-- mapblock-hash -> true
	whitelist = {},

	-- playername => true
	hud = {},

	-- cpu usage in microseconds that triggers the penalty mechanism
	max_usage_micros = tonumber(minetest.settings:get("mesecons_debug.max_usage_micros")) or 15000
}

dofile(MP.."/functions.lua")
dofile(MP.."/whitelist.lua")
dofile(MP.."/privs.lua")
dofile(MP.."/flush.lua")
dofile(MP.."/context.lua")
dofile(MP.."/penalty.lua")
dofile(MP.."/clear_penalty.lua")
dofile(MP.."/overrides.lua")
dofile(MP.."/luacontroller.lua")
dofile(MP.."/chatcommands.lua")
dofile(MP.."/hud.lua")

if minetest.get_modpath("digilines") then
	dofile(MP.."/penalty_controller.lua")
end

mesecons_debug.load_whitelist()

print("[OK] mesecons_debug loaded")
