
-- enable/disable mesecons entirely

local enabled = true
local queue_dump_counter = 0

local step_index = 0

-- globalstep on/off
for i, globalstep in ipairs(minetest.registered_globalsteps) do
  local info = minetest.callback_origins[globalstep]
  if not info then
    break
  end

  local modname = info.mod

  if modname == "mesecons" then
    step_index = step_index + 1
    if step_index > 1 then
	 -- only override first globalstep in mesecons
	break
    end

    local cooldown = 0
    local last_run_time = 0

    local fn = function(dtime)
      if cooldown > 0 then
        cooldown = cooldown - 1
        return
      end

      if enabled then

        local max_globalstep_time = tonumber(minetest.settings:get("mesecons_debug_max_globalstep_time")) or 75000
	local min_delay_time = tonumber(minetest.settings:get("mesecons_debug_min_delay_time")) or 200000
        local cooldown_steps = tonumber(minetest.settings:get("mesecons_debug_cooldown_steps")) or 5
        local autoflush = minetest.settings:get_bool("mesecons_debug_autoflush", false)

	local now = minetest.get_us_time()
	if (now - last_run_time) < min_delay_time then
		-- adhere to min delay
		return
	end

	last_run_time = now

	if queue_dump_counter > 0 then
		-- dump action queue
		mesecons_debug.dump_queue()
		queue_dump_counter = queue_dump_counter - 1
	end

	-- execute with time measurement
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
minetest.register_chatcommand("dump_queue", {
    description = "dumps the current actionqueue to a file for later processing",
    privs = { mesecons_debug = true },
    func = function()
	queue_dump_counter = 10
	return true, "processing.."
    end
})


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
