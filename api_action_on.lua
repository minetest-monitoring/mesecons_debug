

-- node.mesecons.effector.action_on() wrapper
-- def = { node = "", suffix = "" }
mesecons_debug.register_action_on_toggle = function(def)

  local nodedef = minetest.registered_nodes[def.node]

  local old_action_on = nodedef and
    nodedef.mesecons and
    nodedef.mesecons.effector and
    nodedef.mesecons.effector.action_on

  if not old_action_on then
    minetest.log(
      "action",
      "[mesecons_debug] invalid definition for " .. def.node
    )
    return
  end

  local enabled = true

  nodedef.mesecons.effector.action_on = function(...)
    if enabled then
      old_action_on(...)
    end
  end

  minetest.register_chatcommand("mesecons_debug_disable_" .. def.suffix, {
    description = "disables the mesecon action_on() function for " .. def.node,
    privs = {mesecons_debug=true},
    func = function()
      enabled = false
      return true, "Disabled action_on() for " .. def.node
    end
  })

  minetest.register_chatcommand("mesecons_debug_enable_" .. def.suffix, {
    description = "enables the mesecon action_on() function for " .. def.node,
    privs = {mesecons_debug=true},
    func = function()
      enabled = true
      return true, "Enabled action_on() for " .. def.node
    end
  })


end
