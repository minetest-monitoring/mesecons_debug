minetest.register_chatcommand("mesecons_hud", {
    description = "mesecons_hud toggle",
    func = function(name)
        mesecons_debug.hud[name] = not mesecons_debug.hud[name] or nil
        if mesecons_debug.hud[name] then
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
            if not top_ctx or top_ctx.avg_micros < ctx.avg_micros then
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
                top_ctx.avg_micros
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
            ctx.avg_micros,
            mesecons_debug.context_store_size
        )
    end
})

minetest.register_chatcommand("mesecons_enable", {
    description = "enables the mesecons globlastep",
    privs = { mesecons_debug = true },
    func = function()
        -- flush actions, while we are on it
        mesecon.queue.actions = {}
        mesecons_debug.mesecons_enabled = true
        return true, "mesecons enabled"
    end
})

minetest.register_chatcommand("mesecons_disable", {
    description = "disables the mesecons globlastep",
    privs = { mesecons_debug = true },
    func = function()
        mesecons_debug.mesecons_enabled = false
        return true, "mesecons disabled"
    end
})

minetest.register_chatcommand("mesecons_whitelist_get", {
    description = "shows the current mapblock whitelist",
    privs = { mesecons_debug = true },
    func = function()
        local count = 0
        local list = {}
        for hash, _ in pairs(mesecons_debug.storage:to_table().fields) do
            table.insert(list, minetest.pos_to_string(minetest.get_position_from_hash(hash)))
            count = count + 1
        end

        return true, (
            "mesecons whitelist:\n" ..
            "%s\n" ..
            "%i mapblocks whitelisted"
        ):format(
            table.concat(list, "\n"),
            count
        )
    end
})

minetest.register_chatcommand("mesecons_whitelist_add", {
    description = "adds the current mapblock to the whitelist",
    privs = { mesecons_debug = true },
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return
        end

        local hash = mesecons_debug.hashpos(player:get_pos())
        local ctx = mesecons_debug.get_context(hash)
        ctx.whitelisted = true
        mesecons_debug.storage:set_string(hash, "1")

        return true, "mapblock whitlisted"
    end
})

minetest.register_chatcommand("mesecons_whitelist_remove", {
    description = "removes the current mapblock from the whitelist",
    privs = { mesecons_debug = true },
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return
        end

        local hash = mesecons_debug.hashpos(player:get_pos())
        local ctx = mesecons_debug.get_context(hash)
        ctx.whitelisted = false
        mesecons_debug.storage:set_string(hash, "")

        return true, "mapblock removed from whitelist"
    end
})
