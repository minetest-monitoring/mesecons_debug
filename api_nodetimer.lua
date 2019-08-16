

-- node.on_timer wrapper
-- def = { node = "", suffix = "" }
mesecons_debug.register_nodetimer_toggle = function(def)

  local nodedef = minetest.registered_nodes[def.node]

  local old_on_timer = nodedef and nodedef.on_timer

  if not old_on_timer then
    minetest.log(
      "action",
      "[mesecons_debug] invalid definition for " .. def.node
    )
    return
  end

  local enabled = true

  nodedef.on_timer = function(...)
    if enabled then
      return old_on_timer(...)
    else
      -- rerun nodetimer again
      return true
    end
  end

  minetest.register_chatcommand("mesecons_debug_disable_" .. def.suffix, {
    description = "disables the nodetimer for " .. def.node,
    privs = {mesecons_debug=true},
    func = function()
      enabled = false
      return true, "Disabled nodetimer for " .. def.node
    end
  })

  minetest.register_chatcommand("mesecons_debug_enable_" .. def.suffix, {
    description = "enables the nodetimer for " .. def.node,
    privs = {mesecons_debug=true},
    func = function()
      enabled = true
      return true, "Enabled nodetimer for " .. def.node
    end
  })


end
