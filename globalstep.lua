
-- enable/disable mesecons entirely

local enabled = true

-- globalstep on/off
for i, globalstep in ipairs(minetest.registered_globalsteps) do
  local info = minetest.callback_origins[globalstep]
  if not info then
    break
  end

  local modname = info.mod

  if modname == "mesecons" then
    local fn = function(dtime)
      if enabled then
        globalstep(dtime)
      end
    end

    minetest.callback_origins[fn] = info
    minetest.registered_globalsteps[i] = fn
  end
end

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


-- mesecons commands

minetest.register_chatcommand("mesecons_enable", {
  description = "enables the mesecons globlastep",
  privs = {server=true},
  func = function()
    enabled = true
    return true, "mesecons enabled"
  end
})

minetest.register_chatcommand("mesecons_disable", {
  description = "disables the mesecons globlastep",
  privs = {server=true},
  func = function()
    enabled = false
    -- flush actions, while we are on it
    mesecon.queue.actions = {}
    return true, "mesecons disabled"
  end
})
