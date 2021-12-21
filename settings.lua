mesecons_debug.settings = {
	-- max penalty in seconds
	max_penalty = tonumber(minetest.settings:get("mesecons_debug.max_penalty")) or 300,

	-- everything above this threshold will disable the mesecons in that mapblock
	penalty_mapblock_disabled = tonumber(minetest.settings:get("mesecons_debug.penalty_mapblock_disabled")) or 60,

	-- time between /mesecons_clear_penalty commands, in seconds
	penalty_clear_cooldown = tonumber(minetest.settings:get("mesecons_debug.penalty_clear_cooldown")) or 120,

	-- cpu usage in microseconds that triggers the penalty mechanism
	max_usage_micros = tonumber(minetest.settings:get("mesecons_debug.max_usage_micros")) or 15000,

	-- remove unmodified penalty data for a mapblock from memory after this many microseconds
	cleanup_time_micros = tonumber(minetest.settings:get("mesecons_debug.cleanup_time_micros")) or 300 * 1000 * 1000,

	-- interval between running penalty checks
	penalty_check_interval = tonumber(minetest.settings:get("mesecons_debug.penalty_check_interval")) or 1,
}
