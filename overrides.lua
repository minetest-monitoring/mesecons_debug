
local function get_blockpos(pos)
	return {x = math.floor(pos.x / 16),
	        y = math.floor(pos.y / 16),
	        z = math.floor(pos.z / 16)}
end

-- blockpos-hash => context
local context_store = {}

mesecons_debug.get_context = function(pos)
  local blockpos = get_blockpos(pos)
  local hash = minetest.hash_node_position(blockpos)

  local ctx = context_store[hash]
  if not ctx then
    ctx = {
      -- usage in us
      micros = 0,
      -- average micros per second
      avg_micros = 0,
      -- time penalty
      penalty = 0
    }
    context_store[hash] = ctx
  end

  return ctx
end

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

    --print("execute() func=" .. action.func .. " pos=" .. minetest.pos_to_string(action.pos) .. " micros=" .. micros)
  end
end


local timer = 0
minetest.register_globalstep(function(dtime)
  timer = timer + dtime
  if timer < 1 then return end
  timer=0
  mesecons_debug.context_store_size = 0
  for _, ctx in pairs(context_store) do
    ctx.avg_micros = math.floor((ctx.avg_micros * 0.9) + (ctx.micros * 0.1))
    ctx.micros = 0
    if ctx.avg_micros > mesecons_debug.max_usage_micros then
      ctx.penalty = math.min(ctx.penalty + 0.1, 20)
    elseif ctx.penalty > 0 then
      ctx.penalty = math.max(ctx.penalty - 0.01, 0)
    end
    mesecons_debug.context_store_size = mesecons_debug.context_store_size + 1
  end

end)

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
