
-- enable/disable mesecons entirely

local enabled = true


-- execute()
local old_execute = mesecon.queue.execute
mesecon.queue.execute = function(...)
  if enabled then
	 old_execute(...)
  end
end

-- add_action()
local old_add_action = mesecon.queue.add_action
mesecon.queue.add_action = function(...)
  if enabled then
    old_add_action(...)
  end
end


minetest.register_chatcommand("mesecons_enable", {
  description = "enables the mesecons globlastep",
  privs = {mesecons_debug=true},
  func = function()
    enabled = true
    return true, "mesecons enabled"
  end
})

minetest.register_chatcommand("mesecons_disable", {
  description = "disables the mesecons globlastep",
  privs = {mesecons_debug=true},
  func = function()
    enabled = false
    -- flush actions, while we are on it
    mesecon.queue.actions = {}
    return true, "mesecons disabled"
  end
})
