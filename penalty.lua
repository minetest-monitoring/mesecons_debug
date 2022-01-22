local expected_dtime = tonumber(minetest.settings:get("dedicated_server_step")) or 0.09

local subscribe_for_modification = mesecons_debug.settings._subscribe_for_modification
local max_penalty = mesecons_debug.settings.max_penalty
subscribe_for_modification("max_penalty", function(value) max_penalty = value end)
local low_lag_ratio = mesecons_debug.settings.low_lag_ratio
subscribe_for_modification("low_lag_ratio", function(value) low_lag_ratio = value end)
local high_lag_ratio = mesecons_debug.settings.high_lag_ratio
local high_lag_dtime = expected_dtime * high_lag_ratio
subscribe_for_modification("high_lag_ratio", function(value)
    high_lag_ratio = value
    high_lag_dtime = expected_dtime * value
end)
local high_load_ratio = mesecons_debug.settings.high_load_ratio
subscribe_for_modification("high_load_ratio", function(value) high_load_ratio = value end)
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

local max = math.max
local min = math.min

local elapsed_steps = 0
local elapsed = 0

local has_monitoring = mesecons_debug.has.monitoring
local mapblock_count, penalized_mapblock_count
if has_monitoring then
    mapblock_count = monitoring.gauge("mesecons_debug_mapblock_count", "count of tracked mapblocks")
    penalized_mapblock_count = monitoring.gauge("mesecons_debug_penalized_mapblock_count",
            "count of penalized mapblocks")
end

minetest.register_globalstep(function(dtime)
    elapsed = elapsed + dtime
    elapsed_steps = elapsed_steps + 1
    if dtime < high_lag_dtime and elapsed_steps < penalty_check_steps then
        return
    end

    local context_store_size = mesecons_debug.context_store_size
    local total_micros = mesecons_debug.total_micros
    local total_micros_per_second = total_micros / elapsed
    local avg_total_micros_per_second = (total_micros_per_second * 0.2) +
            (mesecons_debug.avg_total_micros_per_second * 0.8)
    mesecons_debug.avg_total_micros_per_second = avg_total_micros_per_second

    if context_store_size == 0 or avg_total_micros_per_second == 0 then
        -- nothing to do, but reset counters
        elapsed = 0
        elapsed_steps = 0
        mesecons_debug.total_micros = 0
        return
    end


    -- how much lag is there?
    local lag = elapsed / (elapsed_steps * expected_dtime)
    local avg_lag = (lag * 0.2) + (mesecons_debug.avg_lag * 0.8)
    mesecons_debug.avg_lag = avg_lag
    local is_high_lag = avg_lag > high_lag_ratio
    local is_moderate_lag = avg_lag > low_lag_ratio

    if is_high_lag then
        mesecons_debug.lag_level = 'high'
    elseif is_moderate_lag then
        mesecons_debug.lag_level = 'moderate'
    else
        mesecons_debug.lag_level = 'low'
    end

    -- how much of the lag was mesecons?
    local mesecons_load = avg_total_micros_per_second / 1000000
    local is_high_load = mesecons_load > high_load_ratio

    if is_high_load then
        mesecons_debug.load_level = 'high'
    else
        mesecons_debug.load_level = 'low'
    end

    -- avg load per active context
    local avg_avg_micros_per_second = avg_total_micros_per_second / context_store_size

    local penalized_count = 0  -- for monitoring
    --[[
    in high lag, penalize mesecons unless it's very low usage
    in moderate lag, penalize mesecons that's being excessive, lighten penalties for the rest
    if low lag, lighten penalties (mostly)
    ]]
    for _, ctx in pairs(mesecons_debug.context_store) do
        if not ctx.whitelisted then
            -- moving avg
            local micros_per_second = ctx.micros / elapsed
            local avg_micros_per_second = (micros_per_second * 0.2) + (ctx.avg_micros_per_second * 0.8)
            ctx.avg_micros_per_second = avg_micros_per_second
            -- reset cpu usage counter
            ctx.micros = 0

            local relative_load = max(0.1, min(avg_micros_per_second / avg_avg_micros_per_second, 10))

            local new_penalty
            if is_high_lag or (is_moderate_lag and is_high_load) then
                new_penalty = ctx.penalty + (relative_load * high_penalty_scale) + high_penalty_offset

            elseif is_moderate_lag then
                new_penalty = ctx.penalty + (relative_load * medium_penalty_scale) + medium_penalty_offset

            else
                new_penalty = ctx.penalty + (relative_load * low_penalty_scale) + low_penalty_offset
            end

            ctx.penalty = max(0, min(new_penalty, max_penalty))
            if has_monitoring and new_penalty > 0 then
                penalized_count = penalized_count + 1
            end
        end
    end

    if has_monitoring then
        mapblock_count.set(mesecons_debug.context_store_size)
        penalized_mapblock_count.set(penalized_count)
    end

    -- cleanup
    elapsed = 0
    elapsed_steps = 0
    mesecons_debug.total_micros = 0
end)
