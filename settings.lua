mesecons_debug.settings = {
    -- in seconds
    hud_refresh_interval = tonumber(minetest.settings:get("mesecons_debug.hud_refresh_interval")) or 1,

    -- max penalty in seconds
    max_penalty = tonumber(minetest.settings:get("mesecons_debug.max_penalty")) or 120,

    -- everything above this threshold will disable the mesecons in that mapblock entirely
    penalty_mapblock_disabled = tonumber(minetest.settings:get("mesecons_debug.penalty_mapblock_disabled")) or 110,

    -- time between /mesecons_clear_penalty commands, in seconds
    penalty_clear_cooldown = tonumber(minetest.settings:get("mesecons_debug.penalty_clear_cooldown")) or 120,

    -- remove unmodified penalty data for a mapblock from memory after this many seconds
    gc_interval = tonumber(minetest.settings:get("mesecons_debug.gc_interval")) or 61,

    -- steps between updating penalties
    penalty_check_steps = tonumber(minetest.settings:get("mesecons_debug.penalty_check_steps")) or 50,

    -- ratio of actual to expected duration of server steps
    moderate_lag_ratio = tonumber(minetest.settings:get("mesecons_debug.moderate_lag_ratio")) or 3,

    -- ratio of actual to expected duration of server steps
    high_lag_ratio = tonumber(minetest.settings:get("mesecons_debug.high_lag_ratio")) or 10,

    -- percentage of total server load due to mesecons
    high_load_threshold = tonumber(minetest.settings:get("mesecons_debug.high_load_threshold")) or 0.33,

    -- scale of penalty during high load
    high_penalty_scale = tonumber(minetest.settings:get("mesecons_debug.high_penalty_scale")) or 0.5,

    -- offset of penalty during high load
    high_penalty_offset = tonumber(minetest.settings:get("mesecons_debug.high_penalty_offset")) or -0.5,

    -- scale of penalty during medium load
    medium_penalty_scale = tonumber(minetest.settings:get("mesecons_debug.medium_penalty_scale")) or 0.2,

    -- offset of penalty during medium load
    medium_penalty_offset = tonumber(minetest.settings:get("mesecons_debug.medium_penalty_offset")) or -0.67,

    -- scale of penalty during low load
    low_penalty_scale = tonumber(minetest.settings:get("mesecons_debug.low_penalty_scale")) or 0.1,

    -- offset of penalty during low load
    low_penalty_offset = tonumber(minetest.settings:get("mesecons_debug.low_penalty_offset")) or -1,

    -- forces (1 / clamp) <= relative load <= clamp
    relative_load_clamp = tonumber(minetest.settings:get("mesecons_debug.relative_load_clamp")) or 10,

    -- coefficient used in calculating an exponential moving average of values across penalty checks
    averaging_coefficient = tonumber(minetest.settings:get("mesecons_debug.averaging_coefficient")) or 0.2,

    _listeners = {},
    _subscribe_for_modification = function(name, func)
        local listeners = mesecons_debug.settings._listeners[name] or {}
        table.insert(listeners, func)
        mesecons_debug.settings._listeners[name] = listeners
    end,

    modify_setting = function(name, value)
        value = tonumber(value)
        mesecons_debug.settings[name] = value
        for _, func in ipairs(mesecons_debug.settings._listeners[name] or {}) do
            func(value)
        end
    end,
}
