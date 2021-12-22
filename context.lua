-- returns the context data for the node-position
mesecons_debug.get_context = function(pos)
    local hash = mesecons_debug.hashpos(pos)
    local ctx = mesecons_debug.context_store[hash]

    if not ctx then
        -- create a new context
        ctx = {
            -- usage in us
            micros = 0,
            -- average micros per second
            avg_micros = 0,
            -- time penalty
            penalty = 0,
            -- modification time
            mtime = minetest.get_us_time(),
            -- whitelist status
            whitelisted = mesecons_debug.context:contains(hash)
        }
        mesecons_debug.context_store[hash] = ctx
    end

    return ctx
end
