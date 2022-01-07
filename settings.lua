mesecons_debug.settings = {
    -- max penalty in seconds
    max_penalty = tonumber(minetest.settings:get("mesecons_debug.max_penalty")) or 120,

    -- everything above this threshold will disable the mesecons in that mapblock
    penalty_mapblock_disabled = tonumber(minetest.settings:get("mesecons_debug.penalty_mapblock_disabled")) or 60,

    -- time between /mesecons_clear_penalty commands, in seconds
    penalty_clear_cooldown = tonumber(minetest.settings:get("mesecons_debug.penalty_clear_cooldown")) or 120,

    -- remove unmodified penalty data for a mapblock from memory after this many seconds
    gc_interval = tonumber(minetest.settings:get("mesecons_debug.gc_interval")) or 61,

    low_lag_ratio = tonumber(minetest.settings:get("mesecons_debug.low_lag_ratio")) or 3,
    high_lag_ratio = tonumber(minetest.settings:get("mesecons_debug.high_lag_ratio")) or 10,
    high_load_ratio = tonumber(minetest.settings:get("mesecons_debug.high_load_ratio")) or 0.3,
    penalty_check_steps = tonumber(minetest.settings:get("mesecons_debug.penalty_check_steps")) or 100,
}
