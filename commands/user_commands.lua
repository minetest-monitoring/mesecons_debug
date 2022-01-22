minetest.register_chatcommand("mesecons_hud", {
    description = "mesecons_hud toggle",
    func = function(name)
        local enabled = (not mesecons_debug.hud_enabled_by_playername[name]) or nil
        mesecons_debug.hud_enabled_by_playername[name] = enabled
        if enabled then
            return true, "mesecons hud enabled"
        else
            return true, "mesecons hud disabled"
        end
    end
})

minetest.register_chatcommand("mesecons_global_stats", {
    description = "shows the global mesecons stats",
    func = function()
        local top_ctx, top_hash

        for hash, ctx in pairs(mesecons_debug.context_store) do
            if not top_ctx or top_ctx.avg_micros_per_second < ctx.avg_micros_per_second then
                -- store context with the most average time
                top_ctx = ctx
                top_hash = hash
            end
        end

        local txt
        if top_ctx then
            txt = (
                "Most prominent mesecons usage at mapblock %s" ..
                " with %f seconds penalty and %i us average use"
            ):format(
                minetest.pos_to_string(minetest.get_position_from_hash(top_hash)),
                top_ctx.penalty,
                top_ctx.avg_micros_per_second
            )
        else
            txt = "no context available"
        end

        return true, txt
    end
})

minetest.register_chatcommand("mesecons_stats", {
    description = "shows some mesecons stats for the current position",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return
        end

        local ctx = mesecons_debug.get_context(player:get_pos())
        return true, ("Mapblock usage: %i us/s (across %i mapblocks)"):format(
            ctx.avg_micros_per_second,
            mesecons_debug.context_store_size
        )
    end
})

