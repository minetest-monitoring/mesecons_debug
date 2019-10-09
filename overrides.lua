
-- enable/disable mesecons entirely

local enabled = true
local reenable_seconds = 0

local cumulative_microseconds = 0
local hit_count = 0

-- execute()
local old_execute = mesecon.queue.execute
mesecon.queue.execute = function(...)
  if enabled then
    local t0 = minetest.get_us_time()
    old_execute(...)
    local t1 = minetest.get_us_time()
    local micros = t1 - t0
    cumulative_microseconds = cumulative_microseconds + micros
  end
end


local timer = 0
minetest.register_globalstep(function(dtime)
  timer = timer + dtime
  if timer < 1 then return end
  timer=0

  local max_micros = tonumber(minetest.settings:get("mesecons_debug.max_micros")) or 100000
  local max_hit_count = tonumber(minetest.settings:get("mesecons_debug.max_hit_count")) or 5

  if cumulative_microseconds > max_micros then
    -- heat up
    hit_count = hit_count + 1
  else
    -- cooldown
    max_hit_count = max_hit_count - 0.1
  end

  cumulative_microseconds = 0


  if hit_count > max_hit_count then
    hit_count = 0
    enabled = false

    minetest.chat_send_all("[circuit-breaker] mesecons are disabled for a minute due to abuse, " ..
      "please fix/optimize your circuits!")

    minetest.log("warning", "[mesecons_debug] circuit-breaker triggered -> disabled for 60 seconds")

    reenable_seconds = 60
  end

  if reenable_seconds > 0 then
    reenable_seconds = reenable_seconds - 1
    if reenable_seconds < 1 then
      -- re-enable again
      enabled = true
    end
  end

end)

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
