

minetest.register_chatcommand("mesecons_hud", {
  description = "mesecons_hud on/off",
  func = function(name, params)
    local enable = params == "on"
    mesecons_debug.hud[name] = enable
    if enable then
      return true, "mesecons hud enabled"
    else
      return true, "mesecons hud disabled"
    end
  end
})

minetest.register_chatcommand("mesecons_stats", {
  description = "shows some mesecons stats for the current position",
  func = function(name)
    local player = minetest.get_player_by_name(name)
    if not player then
      return
    end

    local ctx = mesecons_debug.get_context(player:get_pos())
    return true, "Mapblock usage: " .. ctx.avg_micros .. " us/s " ..
      "(across " .. mesecons_debug.context_store_size .." mapblocks)"
  end
})

minetest.register_chatcommand("mesecons_enable", {
  description = "enables the mesecons globlastep",
  privs = {mesecons_debug=true},
  func = function()
    -- flush actions, while we are on it
    mesecon.queue.actions = {}
    mesecons_debug.enabled = true
    return true, "mesecons enabled"
  end
})

minetest.register_chatcommand("mesecons_disable", {
  description = "disables the mesecons globlastep",
  privs = {mesecons_debug=true},
  func = function()
    mesecons_debug.enabled = false
    return true, "mesecons disabled"
  end
})

minetest.register_chatcommand("mesecons_whitelist_get", {
  description = "shows the current mapblock whitelist",
  privs = {mesecons_debug=true},
  func = function(name)
    local whitelist = "mesecons whitelist:\n"
    local count = 0
    for hash, _ in pairs(mesecons_debug.whitelist) do
      whitelist = whitelist .. minetest.pos_to_string(minetest.get_position_from_hash(hash)) .. "\n"
      count = count + 1
    end
    whitelist = whitelist .. string.format("%d mapblocks whitelisted", count)

    return true, whitelist
  end
})

minetest.register_chatcommand("mesecons_whitelist_add", {
  description = "adds the current mapblock to the whitelist",
  privs = {mesecons_debug=true},
  func = function(name)
    local player = minetest.get_player_by_name(name)
    if not player then
      return
    end

    local ppos = player:get_pos()
    local blockpos = mesecons_debug.get_blockpos(ppos)
    local hash = minetest.hash_node_position(blockpos)

    mesecons_debug.whitelist[hash] = true
    mesecons_debug.save_whitelist()

    return true, "mapblock whitlisted"
  end
})

minetest.register_chatcommand("mesecons_whitelist_remove", {
  description = "removes the current mapblock from the whitelist",
  privs = {mesecons_debug=true},
  func = function(name)
    local player = minetest.get_player_by_name(name)
    if not player then
      return
    end

    local ppos = player:get_pos()
    local blockpos = mesecons_debug.get_blockpos(ppos)
    local hash = minetest.hash_node_position(blockpos)

    mesecons_debug.whitelist[hash] = true
    mesecons_debug.save_whitelist()

    return true, "mapblock removed from whitelist"
  end
})
