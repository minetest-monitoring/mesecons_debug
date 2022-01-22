local subscribe_for_modification = mesecons_debug.settings._subscribe_for_modification
local gc_interval = mesecons_debug.settings.gc_interval
local cleanup_time_micros = gc_interval * 1000000

subscribe_for_modification("gc_interval", function(value)
    gc_interval = value
    cleanup_time_micros = value * 1000000
end)

local context_store = mesecons_debug.context_store

local cleanup_timer = 0
minetest.register_globalstep(function(dtime)
    cleanup_timer = cleanup_timer + dtime
    if cleanup_timer < gc_interval then
        return
    end
    cleanup_timer = 0

    local now = minetest.get_us_time()
    for hash, ctx in pairs(context_store) do
        local time_diff = now - ctx.mtime
        if time_diff > cleanup_time_micros then
            -- remove item
            context_store[hash] = nil
            mesecons_debug.context_store_size = mesecons_debug.context_store_size - 1
        end
    end
end)
