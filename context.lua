local storage = mesecons_debug.storage

-- returns the context data for the node-position
mesecons_debug.get_context = function(pos)
    local hash = mesecons_debug.hashpos(pos)
    local ctx = mesecons_debug.context_store[hash]

    if not ctx then
        -- create a new context
        ctx = {
            -- usage in us
            micros = 0,
            -- "running average" micros per second
            avg_micros_per_second = 0,
            -- time penalty
            penalty = 0,
            -- modification time
            mtime = minetest.get_us_time(),
            -- whitelist status
            whitelisted = storage:contains(hash)
        }
        mesecons_debug.context_store[hash] = ctx
        mesecons_debug.context_store_size = mesecons_debug.context_store_size + 1
    end

    return ctx
end
