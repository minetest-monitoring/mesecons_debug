local filename = minetest.get_worldpath() .. "/mesecons_debug_whiltelist"
local file = io.open(filename, "r")

if file then
    local data = file:read("*a")
    local whitelist = minetest.deserialize(data) or {}
    for hash, _ in pairs(whitelist) do
        mesecons_debug.storage:set_string(hash, "1")
    end
    file:close()
    os.remove(filename)
end
