local penalty_mapblock_disabled = mesecons_debug.settings.penalty_mapblock_disabled
mesecons_debug.settings._subscribe_for_modification("penalty_mapblock_disabled",
        function(value) penalty_mapblock_disabled = value end)

-- execute()
local old_execute = mesecon.queue.execute
mesecon.queue.execute = function(self, action)
    if not mesecons_debug.enabled then
        return old_execute(self, action)
    elseif not mesecons_debug.mesecons_enabled then
        return
    end

    local ctx = mesecons_debug.get_context(action.pos)
    if ctx.whitelisted then
        return old_execute(self, action)
    end

    local t0 = minetest.get_us_time()
    local rv = old_execute(self, action)
    local micros = minetest.get_us_time() - t0

    mesecons_debug.total_micros = mesecons_debug.total_micros + micros
    ctx.micros = ctx.micros + micros
    ctx.mtime = t0  -- modification time

    return rv
end


-- add_action()
local old_add_action = mesecon.queue.add_action
mesecon.queue.add_action = function(self, pos, func, params, time, overwritecheck, priority)
    if not mesecons_debug.enabled then
        return old_add_action(self, pos, func, params, time, overwritecheck, priority)

    elseif not mesecons_debug.mesecons_enabled then
        return
    end

    local ctx = mesecons_debug.get_context(pos)

    if not ctx.whitelisted and ctx.penalty > penalty_mapblock_disabled then
        -- penalty exceeded disable-threshold, don't even add the action
        return
    end

    return old_add_action(self, pos, func, params, (time or 0) + ctx.penalty, overwritecheck, priority)
end
