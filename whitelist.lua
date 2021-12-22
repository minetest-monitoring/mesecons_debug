local filename = minetest.get_worldpath() .. "/mesecons_debug_whiltelist"

function mesecons_debug.load_legacy_whitelist()
    local file = io.open(filename, "r")

    if file then
        local data = file:read("*a")
        local whitelist = minetest.deserialize(data) or {}
        for hash, value in pairs(whitelist) do
            mesecons_debug.storage:set_bool(hash, value)
        end
        file:close()
        os.remove(filename)
    end
end
