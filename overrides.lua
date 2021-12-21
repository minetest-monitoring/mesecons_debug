local penalty_mapblock_disabled = mesecons_debug.settings.penalty_mapblock_disabled

-- execute()
local old_execute = mesecon.queue.execute
mesecon.queue.execute = function(self, action)
    if not mesecons_debug.enabled then
        return
    end

    local t0 = minetest.get_us_time()
    old_execute(self, action)
    local micros = minetest.get_us_time() - t0

    local ctx = mesecons_debug.get_context(action.pos)
    ctx.micros = ctx.micros + micros
    ctx.mtime = t0
end


-- add_action()
local old_add_action = mesecon.queue.add_action
mesecon.queue.add_action = function(self, pos, func, params, time, overwritecheck, priority)
    if not mesecons_debug.enabled then
        return
    end

    local ctx = mesecons_debug.get_context(pos)

    time = time or 0
    time = time + ctx.penalty
    if time > penalty_mapblock_disabled then
        -- penalty exceeded disable-threshold, don't even add the action
        return
    end

    return old_add_action(self, pos, func, params, time, overwritecheck, priority)
end
