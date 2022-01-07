local function override_node_timer(node_name)
    local def = minetest.registered_nodes[node_name]
    local old_node_timer = def.on_timer
    def.on_timer = function(pos)
        local ctx = mesecons_debug.get_context(pos)
        if ctx.whitelisted then return old_node_timer(pos) end

        if ctx.penalty > 0 then
            -- defer
            local timer = minetest.get_node_timer(pos)
            local meta = minetest.get_meta(pos)
            local is_defered = meta:get_int("_defered") == 1

            if is_defered then
                -- already delayed
                meta:set_int("_defered", 0)
                return old_node_timer(pos)
            else
                -- start timer
                meta:set_int("_defered", 1)
                timer:start(ctx.penalty)
            end
        else
            -- immediate
            return old_node_timer(pos)
        end
    end
end

-- luaC
for a = 0, 1 do
    for b = 0, 1 do
        for c = 0, 1 do
            for d = 0, 1 do
                override_node_timer(("mesecons_luacontroller:luacontroller%i%i%i%i"):format(a, b, c, d))
            end
        end
    end
end

-- blinky
override_node_timer("mesecons_blinkyplant:blinky_plant_off")
override_node_timer("mesecons_blinkyplant:blinky_plant_on")
