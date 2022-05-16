local expected_dtime = tonumber(minetest.settings:get("dedicated_server_step")) or 0.09

local subscribe_for_modification = mesecons_debug.settings._subscribe_for_modification
local max_penalty = mesecons_debug.settings.max_penalty
subscribe_for_modification("max_penalty", function(value) max_penalty = value end)
local moderate_lag_ratio = mesecons_debug.settings.moderate_lag_ratio
subscribe_for_modification("moderate_lag_ratio", function(value) moderate_lag_ratio = value end)
local high_lag_ratio = mesecons_debug.settings.high_lag_ratio
local high_lag_dtime = expected_dtime * high_lag_ratio
subscribe_for_modification("high_lag_ratio", function(value)
    high_lag_ratio = value
    high_lag_dtime = expected_dtime * value
end)
local high_load_threshold = mesecons_debug.settings.high_load_threshold
subscribe_for_modification("high_load_threshold", function(value) high_load_threshold = value end)
local penalty_check_steps = mesecons_debug.settings.penalty_check_steps
subscribe_for_modification("penalty_check_steps", function(value) penalty_check_steps = value end)
local high_penalty_scale = mesecons_debug.settings.high_penalty_scale
subscribe_for_modification("high_penalty_scale", function(value) high_penalty_scale = value end)
local high_penalty_offset = mesecons_debug.settings.high_penalty_offset
subscribe_for_modification("high_penalty_offset", function(value) high_penalty_offset = value end)
local medium_penalty_scale = mesecons_debug.settings.medium_penalty_scale
subscribe_for_modification("medium_penalty_scale", function(value) medium_penalty_scale = value end)
local medium_penalty_offset = mesecons_debug.settings.medium_penalty_offset
subscribe_for_modification("medium_penalty_offset", function(value) medium_penalty_offset = value end)
local low_penalty_scale = mesecons_debug.settings.low_penalty_scale
subscribe_for_modification("low_penalty_scale", function(value) low_penalty_scale = value end)
local low_penalty_offset = mesecons_debug.settings.low_penalty_offset
subscribe_for_modification("low_penalty_offset", function(value) low_penalty_offset = value end)
local relative_load_max = mesecons_debug.settings.relative_load_clamp
local relative_load_min = 1 / mesecons_debug.settings.relative_load_clamp
subscribe_for_modification("relative_load_clamp", function(value)
    relative_load_max = value
    relative_load_min = 1 / value
end)
-- see https://en.wikipedia.org/w/index.php?title=Moving_average&oldid=1069105690#Exponential_moving_average
local averaging_coefficient = mesecons_debug.settings.averaging_coefficient
subscribe_for_modification("averaging_coefficient", function(value) averaging_coefficient = value end)

local max = math.max
local min = math.min

local function clamp(low, value, high)
    return max(low, min(value, high))
end

local function clamp_load(load)
    return max(relative_load_min, min(load, relative_load_max))
end

local function update_average(current, history)
    return (current * averaging_coefficient) + (history * (1 - averaging_coefficient))
end

local has_monitoring = mesecons_debug.has.monitoring
local mapblock_count, penalized_mapblock_count
if has_monitoring then
    mapblock_count = monitoring.gauge("mesecons_debug_mapblock_count", "count of tracked mapblocks")
    penalized_mapblock_count = monitoring.gauge("mesecons_debug_penalized_mapblock_count",
        "count of penalized mapblocks")
end

local elapsed_steps = 0
local elapsed = 0

minetest.register_globalstep(function(dtime)
    elapsed = elapsed + dtime
    elapsed_steps = elapsed_steps + 1

    --[[
        we check every N steps instead of every T seconds because we are more interested in the length of the steps
        than in the number of them.
        we also force a check if a particular step takes quite a long time, to keep things responsive.
    ]]
    if dtime < high_lag_dtime and elapsed_steps < penalty_check_steps then
        return
    end

    local context_store_size = mesecons_debug.context_store_size  -- # of blocks w/ active mesecons
    local total_micros = mesecons_debug.total_micros
    local total_micros_per_second = total_micros / elapsed
    local avg_total_micros_per_second = update_average(total_micros_per_second,
        mesecons_debug.avg_total_micros_per_second)
    mesecons_debug.avg_total_micros_per_second = avg_total_micros_per_second

    -- how much lag is there?
    local lag = elapsed / (elapsed_steps * expected_dtime)
    local avg_lag = update_average(lag, mesecons_debug.avg_lag)
    mesecons_debug.avg_lag = avg_lag

    local is_high_lag = avg_lag > high_lag_ratio
    local is_moderate_lag = avg_lag > moderate_lag_ratio
    -- for use by HUD
    if is_high_lag then
        mesecons_debug.lag_level = "high"
    elseif is_moderate_lag then
        mesecons_debug.lag_level = "moderate"
    else
        mesecons_debug.lag_level = "low"
    end

    if context_store_size == 0 or avg_total_micros_per_second == 0 then
        -- nothing to do, but reset counters
        elapsed = 0
        elapsed_steps = 0
        mesecons_debug.total_micros = 0
        mesecons_debug.load_level = "none"
        return
    end

    -- how much of the lag was mesecons?
    local mesecons_load = avg_total_micros_per_second / 1000000
    local is_high_load = mesecons_load > high_load_threshold

    -- for use by HUD
    if is_high_load then
        mesecons_debug.load_level = "high"
    else
        mesecons_debug.load_level = "low"
    end

    local penalty_scale, penalty_offset
    if is_high_lag or (is_moderate_lag and is_high_load) then
        penalty_scale = high_penalty_scale
        penalty_offset = high_penalty_offset
    elseif is_moderate_lag then
        penalty_scale = medium_penalty_scale
        penalty_offset = medium_penalty_offset
    else
        penalty_scale = low_penalty_scale
        penalty_offset = low_penalty_offset
    end

    -- avg load per active context
    local avg_avg_micros_per_second = avg_total_micros_per_second / context_store_size

    local penalized_count = 0  -- for monitoring
    for _, ctx in pairs(mesecons_debug.context_store) do
        if not ctx.whitelisted then
            -- moving avg
            local micros_per_second = ctx.micros / elapsed
            local avg_micros_per_second = update_average(micros_per_second, ctx.avg_micros_per_second)
            ctx.avg_micros_per_second = avg_micros_per_second

            local relative_load = clamp_load(avg_micros_per_second / avg_avg_micros_per_second)

            local new_penalty = ctx.penalty + (relative_load * penalty_scale) + penalty_offset
            ctx.penalty = clamp(0, new_penalty, max_penalty)

            if has_monitoring and new_penalty > 0 then
                penalized_count = penalized_count + 1
            end

            -- reset cpu usage counter
            ctx.micros = 0
        end
    end

    if has_monitoring then
        mapblock_count.set(mesecons_debug.context_store_size)
        penalized_mapblock_count.set(penalized_count)
    end

    -- reset counters
    elapsed = 0
    elapsed_steps = 0
    mesecons_debug.total_micros = 0
end)
