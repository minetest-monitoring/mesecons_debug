

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
