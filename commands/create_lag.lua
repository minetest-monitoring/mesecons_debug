local current_lag = 0
local lag_chance = 0

local wait = mesecons_debug.wait


minetest.register_chatcommand("create_lag", {
    description = "foce a wait of <duration> us for 1 / <chance> server steps",
    params = "<duration> <chance>",
    privs = { mesecons_debug = true },
    func = function(_name, setting)
        local lag, chance = setting:match('^(%S+)%s+(%S+)$')
        lag = tonumber(lag)
        chance = tonumber(chance)
        if not (lag and chance) then
            return false, "can't grok lag duration and chance"
        end
        current_lag = lag
        lag_chance = chance
        return true
    end,
})

minetest.register_globalstep(function(_dtime)
    if lag_chance > 0 and current_lag > 0 and math.random() < 1 / lag_chance then
        wait(current_lag)
    end
end)
