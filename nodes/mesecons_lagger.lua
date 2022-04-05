
local wait = mesecons_debug.wait

mesecon.queue:add_function("create_lag", function(_pos, duration)
    wait(duration)
end)


minetest.register_node("mesecons_debug:mesecons_lagger", {
    description = "machine for adding artificial mesecons lag",
    group = {
        not_in_creative_inventory = 1,
        unbreakable = 1,
    },
    tiles = {"default_mese_block.png^[colorize:#F00:128"},
    on_blast = function() end,
    drop = "",

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_float("lag", 0.0)
        meta:set_float("chance", 0.0)
        meta:set_string("formspec",
                ("field[lag;Lag (in us);%s]field[chance;Chance;%s]"):format(0.0, 0.0))

        local timer = minetest.get_node_timer(pos)
        timer:start(0)
    end,

    on_receive_fields = function(pos, _formname, fields, sender)
        if not minetest.check_player_privs(sender, "mesecons_debug") then
            return
        end
        local meta = minetest.get_meta(pos)
        if fields.lag then
            meta:set_float("lag", fields.lag)
        end
        if fields.chance then
            meta:set_float("chance", fields.chance)
        end
        meta:set_string("formspec",
                ("field[lag;Lag (in us);%s]field[chance;Chance;%s]"):format(
                        meta:get_float("lag"), meta:get_float("chance")))

    end,

    on_timer = function(pos, _elapsed)
        local meta = minetest.get_meta(pos)
        local lag = meta:get_float("lag")
        local chance = meta:get_float("chance")
        if lag > 0 and chance > 0 then
            if math.random() < 1 / chance then
                mesecon.queue:add_action(pos, "create_lag", { lag })
            end
        end

        return true
    end,
})
