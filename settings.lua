mesecons_debug.settings = {
	-- max penalty in seconds
	max_penalty = tonumber(minetest.settings:get("mesecons_debug.max_penalty")) or 300,

	-- everything above this threshold will disable the mesecons in that mapblock
	penalty_mapblock_disabled = tonumber(minetest.settings:get("mesecons_debug.penalty_mapblock_disabled")) or 60,

	-- time between /mesecons_clear_penalty commands, in seconds
	penalty_clear_cooldown = tonumber(minetest.settings:get("mesecons_debug.penalty_clear_cooldown")) or 120,

	-- cpu usage in microseconds that triggers the penalty mechanism
	max_usage_micros = tonumber(minetest.settings:get("mesecons_debug.max_usage_micros")) or 15000
}
