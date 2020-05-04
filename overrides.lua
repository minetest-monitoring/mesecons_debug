
-- execute()
local old_execute = mesecon.queue.execute
mesecon.queue.execute = function(self, action)
  if mesecons_debug.enabled then
    local t0 = minetest.get_us_time()
    old_execute(self, action)
    local t1 = minetest.get_us_time()
    local micros = t1 - t0

    local ctx = mesecons_debug.get_context(action.pos)
    ctx.micros = ctx.micros + micros
		ctx.mtime = t0

    --print("execute() func=" .. action.func .. " pos=" .. minetest.pos_to_string(action.pos) .. " micros=" .. micros)
  end
end


-- add_action()
local old_add_action = mesecon.queue.add_action
mesecon.queue.add_action = function(self, pos, func, params, time, overwritecheck, priority)
  if mesecons_debug.enabled then
    local ctx = mesecons_debug.get_context(pos)

    time = time or 0
    time = time + ctx.penalty

    old_add_action(self, pos, func, params, time, overwritecheck, priority)
    --print("add_action() pos=" .. minetest.pos_to_string(pos))
  end
end
