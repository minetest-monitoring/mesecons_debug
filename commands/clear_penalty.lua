local penalty_clear_cooldown = mesecons_debug.settings.penalty_clear_cooldown

-- playername => time-of-last-cooldown
local cooldown = {}

minetest.register_chatcommand("mesecons_clear_penalty", {
    description = "clears the penalty in the current mapblock " ..
            "(cooldown: " .. penalty_clear_cooldown .. ")",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return
        end

        local last_cooldown_time = cooldown[name] or 0
        local remaining_time = penalty_clear_cooldown - (os.time() - last_cooldown_time)
        if remaining_time > 0 then
            -- cooldown still in progress
            return true, "cooldown still in progress, remaining time: " .. remaining_time .. " seconds"
        end

        -- set timer
        cooldown[name] = os.time()

        local ctx = mesecons_debug.get_context(player:get_pos())
        ctx.penalty = 0

        return true, "penalty reset"
    end
})
