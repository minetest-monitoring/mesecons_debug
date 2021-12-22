local cleanup_time_micros = mesecons_debug.settings.cleanup_time_micros
local context_store = mesecons_debug.context_store

local cleanup_timer = 0
minetest.register_globalstep(function(dtime)
    cleanup_timer = cleanup_timer + dtime
    if cleanup_timer < cleanup_time_micros then
        return
    end
    cleanup_timer = 0

    local now = minetest.get_us_time()
    for hash, ctx in pairs(context_store) do
        local time_diff = now - ctx.mtime
        if time_diff > cleanup_time_micros then
            -- remove item
            context_store[hash] = nil
        end
    end
end)
