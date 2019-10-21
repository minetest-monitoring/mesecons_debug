local has_monitoring = minetest.get_modpath("monitoring")

local mapblock_count, penalized_mapblock_count

if has_monitoring then
	mapblock_count = monitoring.gauge("mesecons_debug_mapblock_count", "count of tracked mapblocks")
	penalized_mapblock_count = monitoring.gauge("mesecons_debug_penalized_mapblock_count", "count of penalized mapblocks")
end


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
      penalty = 0,

			-- mtime
			mtime = minetest.get_us_time(),
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
		ctx.mtime = t0

    --print("execute() func=" .. action.func .. " pos=" .. minetest.pos_to_string(action.pos) .. " micros=" .. micros)
  end
end


local timer = 0
minetest.register_globalstep(function(dtime)
  timer = timer + dtime
  if timer < 1 then return end
  timer=0

	local penalized_count = 0
	local now = minetest.get_us_time()
	local cleanup_time_micros = 300 * 1000 * 1000

  mesecons_debug.context_store_size = 0
  for hash, ctx in pairs(context_store) do
		local time_diff = now - ctx.mtime
		if time_diff > cleanup_time_micros then
			-- remove item
			context_store[hash] = nil

		else
			-- calculate stuff
			ctx.avg_micros = math.floor((ctx.avg_micros * 0.9) + (ctx.micros * 0.1))
	    ctx.micros = 0
	    if ctx.avg_micros > mesecons_debug.max_usage_micros then
				-- add penalty
	      ctx.penalty = math.min(ctx.penalty + 0.1, 20)
	    elseif ctx.penalty > 0 then
				-- remove penalty (slowly)
	      ctx.penalty = math.max(ctx.penalty - 0.01, 0)
	    end

	    mesecons_debug.context_store_size = mesecons_debug.context_store_size + 1
			if ctx.penalty > 0 then
				penalized_count = penalized_count + 1
			end

		end
  end

	mapblock_count.set(mesecons_debug.context_store_size)
	penalized_mapblock_count.set(penalized_count)

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
