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

minetest.register_chatcommand("mesecons_debug_set", {
    description = "modify mesecons_debug settings",
    params = "<setting> <value>",
    privs = { mesecons_debug = true },
    func = function(name, params)
        local player = minetest.get_player_by_name(name)
        if not player or not params then
            return false
        end

        local setting, value = params:match('^([a-zA-Z0-9_-]+)%s+(.*)$')
        value = tonumber(value)
        if not setting or not value then
            return false
        end

        if not mesecons_debug.settings[setting] then
            return false, "unknown setting"
        end

        mesecons_debug.settings.modify_setting(setting, value)

        return true, "setting updated"
    end
})

minetest.register_chatcommand("mesecons_debug_get", {
    description = "get mesecons_debug settings",
    params = "<setting>",
    privs = { mesecons_debug = true },
    func = function(name, setting)
        local player = minetest.get_player_by_name(name)
        if not player or not setting then
            return false
        end

        local value = mesecons_debug.settings[setting]
        if value then
            return true, tostring(value)
        else
            return false, "unknown setting"
        end
    end
})
