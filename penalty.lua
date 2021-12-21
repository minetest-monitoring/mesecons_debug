local max_penalty = mesecons_debug.settings.max_penalty
local max_usage_micros = mesecons_debug.settings.max_usage_micros
local cleanup_time_micros = mesecons_debug.settings.cleanup_time_micros
local penalty_check_interval = mesecons_debug.settings.penalty_check_interval

local has_monitoring = minetest.get_modpath("monitoring")
local mapblock_count, penalized_mapblock_count

if has_monitoring then
    mapblock_count = monitoring.gauge("mesecons_debug_mapblock_count", "count of tracked mapblocks")
    penalized_mapblock_count = monitoring.gauge("mesecons_debug_penalized_mapblock_count", "count of penalized mapblocks")
end

local timer = 0
minetest.register_globalstep(function(dtime)
    -- TODO: there should be 2 versions of this function; one for has_monitoring, one for not
    -- TODO: but functional fixes need done first
    timer = timer + dtime
    if timer < penalty_check_interval then
        return
    end
    timer = 0

    if has_monitoring then
        mesecons_debug.context_store_size = 0
    end

    local penalized_count = 0

    for _, ctx in pairs(mesecons_debug.context_store) do
        -- calculate moving average
        ctx.avg_micros = math.floor((ctx.avg_micros * 0.8) + (ctx.micros * 0.2))
        -- reset cpu usage counter
        ctx.micros = 0

        -- apply penalty values
        if ctx.avg_micros > (max_usage_micros * 10) then
            -- 10 times the limit used, potential abuse, add a greater penalty value
            ctx.penalty = math.min(ctx.penalty + 5, max_penalty)

        elseif ctx.avg_micros > max_usage_micros then
            -- add penalty value
            ctx.penalty = math.min(ctx.penalty + 0.2, max_penalty)

        else
            -- remove penalty (very slowly)
            ctx.penalty = math.max(ctx.penalty - 0.001, 0)
        end

        if has_monitoring then
            mesecons_debug.context_store_size = mesecons_debug.context_store_size + 1
            if ctx.penalty > 0 then
                penalized_count = penalized_count + 1
            end
        end
    end

    if has_monitoring then
        mapblock_count.set(mesecons_debug.context_store_size)
        penalized_mapblock_count.set(penalized_count)
    end
end)


local cleanup_timer = 0
minetest.register_globalstep(function(dtime)
    cleanup_timer = cleanup_timer + dtime
    if cleanup_timer < penalty_check_interval then
        return
    end
    cleanup_timer = 0

    local now = minetest.get_us_time()
    for hash, ctx in pairs(mesecons_debug.context_store) do
        local time_diff = now - ctx.mtime
        if time_diff > cleanup_time_micros then
            -- remove item
            mesecons_debug.context_store[hash] = nil
        end
    end
end)
