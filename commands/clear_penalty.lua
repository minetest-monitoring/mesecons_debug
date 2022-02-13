local penalty_clear_cooldown = mesecons_debug.settings.penalty_clear_cooldown

-- playername => time-of-last-cooldown
local cooldown_expiry_by_name = {}


minetest.register_chatcommand("mesecons_clear_penalty", {
    description = "clears the penalty in the current mapblock " ..
            "(cooldown: " .. penalty_clear_cooldown .. ")",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return
        end

        local is_admin = minetest.check_player_privs(player, "mesecons_debug")
        if not is_admin then
            local now = os.time()
            local expires = cooldown_expiry_by_name[name] or 0
            local remaining_time = math.floor(expires - now)
            if remaining_time > 0 then
                -- cooldown still in progress
                return true, "cooldown still in progress, remaining time: " .. remaining_time .. " seconds"
            end
            cooldown_expiry_by_name[name] = now + penalty_clear_cooldown
        end

        local ctx = mesecons_debug.get_context(player:get_pos())
        ctx.penalty = 0

        return true, "penalty reset"
    end
})
