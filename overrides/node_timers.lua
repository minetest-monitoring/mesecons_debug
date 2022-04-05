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

if minetest.get_modpath("digistuff") then
    override_node_timer("digistuff:timer")
end

if minetest.get_modpath("mesecons_luacontroller") then
    for a = 0, 1 do
        for b = 0, 1 do
            for c = 0, 1 do
                for d = 0, 1 do
                    override_node_timer(("mesecons_luacontroller:luacontroller%i%i%i%i"):format(a, b, c, d))
                end
            end
        end
    end
end

if minetest.get_modpath("mesecons_blinkyplant") then
    override_node_timer("mesecons_blinkyplant:blinky_plant_off")
    override_node_timer("mesecons_blinkyplant:blinky_plant_on")
end

if minetest.get_modpath("moremesecons_adjustable_blinkyplant") then
    override_node_timer("moremesecons_adjustable_blinkyplant:adjustable_blinky_plant_off")
    override_node_timer("moremesecons_adjustable_blinkyplant:adjustable_blinky_plant_on")
end

if minetest.get_modpath("moremesecons_injector_controller") then
    override_node_timer("moremesecons_injector_controller:injector_controller_on")
    override_node_timer("moremesecons_injector_controller:injector_controller_off")
end

if minetest.get_modpath("pipeworks") then
    for a = 0, 1 do
        for b = 0, 1 do
            for c = 0, 1 do
                for d = 0, 1 do
                    for e = 0, 1 do
                        for f = 0, 1 do
                            override_node_timer(("pipeworks:lua_tube%i%i%i%i%i%i"):format(a, b, c, d, e, f))
                        end
                    end
                end
            end
        end
    end
end
