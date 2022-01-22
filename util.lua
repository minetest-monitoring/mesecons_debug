function mesecons_debug.get_blockpos(pos)
    return {
        x = math.floor(pos.x / 16),
        y = math.floor(pos.y / 16),
        z = math.floor(pos.z / 16)
    }
end

function mesecons_debug.hashpos(pos)
    return minetest.hash_node_position({
        x = math.floor(pos.x / 16),
        y = math.floor(pos.y / 16),
        z = math.floor(pos.z / 16)
    })
end


function mesecons_debug.wait(n)
    local wait_until = minetest.get_us_time() + n
    while minetest.get_us_time() < wait_until do end
end
