local has_monitoring = minetest.get_modpath("monitoring")

local mapblock_count, penalized_mapblock_count

if has_monitoring then
	mapblock_count = monitoring.gauge("mesecons_debug_mapblock_count", "count of tracked mapblocks")
	penalized_mapblock_count = monitoring.gauge("mesecons_debug_penalized_mapblock_count", "count of penalized mapblocks")
end


-- blockpos-hash => context
local context_store = {}

mesecons_debug.get_context = function(pos)
	local blockpos = mesecons_debug.get_blockpos(pos)
	local hash = minetest.hash_node_position(blockpos)

	local ctx = context_store[hash]
	if not ctx then
		-- create a new context
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

	-- update context

	-- whitelist flag
	ctx.whitelisted = mesecons_debug.whitelist[hash]

	return ctx
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

	if has_monitoring then
		mapblock_count.set(mesecons_debug.context_store_size)
		penalized_mapblock_count.set(penalized_count)
	end

end)
