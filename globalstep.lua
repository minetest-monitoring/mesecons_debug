
-- globalstep on/off
local i = 0
for _, globalstep in ipairs(minetest.registered_globalsteps) do
  local info = minetest.callback_origins[globalstep]
  if not info then
    break
  end

  local modname = info.mod

  if modname == "mesecons" then
    i = i + 1
    -- 1 = execute globalstep
    -- 2 = cooldown globalstep
    if i == 1 then
	    local fn = function(dtime)
	       globalstep(dtime)
	    end

	    minetest.callback_origins[fn] = info
	    minetest.registered_globalsteps[i] = fn
    end
  end
end

-- execute()
local old_execute = mesecon.queue.execute
mesecon.queue.execute = function(...)
  if mesecons_debug.enabled then
	 old_execute(...)
  end
end

-- add_action()
local old_add_action = mesecon.queue.add_action
mesecon.queue.add_action = function(...)
  if mesecons_debug.enabled then
    old_add_action(...)
  end
end


