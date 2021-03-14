
-- returns the context data for the node-position
mesecons_debug.get_context = function(pos)
	local blockpos = mesecons_debug.get_blockpos(pos)
	local hash = minetest.hash_node_position(blockpos)

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

			-- mtime
			mtime = minetest.get_us_time(),
		}
		mesecons_debug.context_store[hash] = ctx
	end

	-- update context

	-- whitelist flag
	ctx.whitelisted = mesecons_debug.whitelist[hash]

	return ctx
end
