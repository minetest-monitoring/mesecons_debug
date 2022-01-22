local function override_node_timer(node_name)
    local old_node_timer = minetest.registered_nodes[node_name].on_timer
    minetest.override_item(node_name, {
        on_timer = function(pos, elapsed)
            if not mesecons_debug.enabled then
                return old_node_timer(pos, elapsed)

            elseif not mesecons_debug.mesecons_enabled then
                return true
            end

            local ctx = mesecons_debug.get_context(pos)

            if ctx.whitelisted or elapsed > ctx.penalty then
                return old_node_timer(pos, elapsed)
            else
                -- defer
                return true
            end
        end,
    })
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
