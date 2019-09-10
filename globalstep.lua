
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
    local cooldown = 0
    local fn = function(dtime)
      if cooldown > 0 then
        cooldown = cooldown - 1
        return
      end

      if enabled then
        local max_globalstep_time = tonumber(minetest.settings:get("mesecons_debug_max_globalstep_time")) or 75000
        local cooldown_steps = tonumber(minetest.settings:get("mesecons_debug_cooldown_steps")) or 5
        local autoflush = minetest.settings:get_bool("mesecons_debug_autoflush", false)

        local t0 = minetest.get_us_time()
        globalstep(dtime)
        local t1 = minetest.get_us_time()
        local diff = t1 - t0
        if diff > max_globalstep_time then
          cooldown = cooldown_steps
          minetest.log("warning", "[mesecons_debug] cooldown triggered")
          if autoflush then
            mesecon.queue.actions = {}
          end
        end
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
