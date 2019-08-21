
-- "circuit break" mapblocks in which mesecons took too long to execute
-- TODO: toggleable hud with current cpu usage

-- sample/reset interval
local sample_interval = 10

-- util
-- minetest.hash_node_position(get_blockpos(pos))
local function get_blockpos(pos)
	return {x = math.floor(pos.x / 16),
	        y = math.floor(pos.y / 16),
	        z = math.floor(pos.z / 16)}
end


-- per block cpu time usage in micros
local per_block_time_usage = {}

-- max per block cpu time usage in micros
local max_per_block_time_usage = {}

-- disabled/dark mapblocks
local dark_mapblocks = {}

-- switch off setting
local max_time_setting
local dark_time

function update_settings()
  max_time_setting = tonumber( minetest.settings:get("mesecons_debug.circuit_breaker") or "75000" )
  dark_time = tonumber( minetest.settings:get("mesecons_debug.dark_time") or "30000000" )
end

update_settings()

-- periodic timer
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < sample_interval then return end
	timer=0

  -- reset time usage
  per_block_time_usage = {}

  -- update settings, if changed
  update_settings()

end)

-- mesecon mod overrides
local old_execute = mesecon.queue.execute
mesecon.queue.execute = function(self, action)
  local blockpos = get_blockpos(action.pos)
  local hash = minetest.hash_node_position(blockpos)
  local t0 = minetest.get_us_time()

  local dark_timer = dark_mapblocks[hash]
  if dark_timer and dark_timer < t0 then
    -- timeout expired, disable mapblock throttling
    dark_mapblocks[hash] = nil
    dark_timer = nil
  end

  local time_usage = per_block_time_usage[hash] or 0

  old_execute(self, action)
  local t1 = minetest.get_us_time()
  local diff = t1 -t0
  time_usage = time_usage + diff

  -- update max stats
  if (max_per_block_time_usage[hash] or 0) < time_usage then
    max_per_block_time_usage[hash] = time_usage
  end

  if time_usage > max_time_setting and not dark_timer then
    -- time usage exceeded, throttle mapblock
    dark_mapblocks[hash] = t1 + dark_time
    minetest.log("warning", "[mesecons_debug] throttled mapblock at " ..
        minetest.pos_to_string(action.pos))
  end

  -- update time usage
  per_block_time_usage[hash] = time_usage
end

local old_add_action = mesecon.queue.add_action
mesecon.queue.add_action = function(self, pos, func, params, time, overwritecheck, priority)
	time = time or 0
	local blockpos = get_blockpos(pos)
	local hash = minetest.hash_node_position(blockpos)

	local dark_timer = dark_mapblocks[hash]
	if dark_timer then
		-- throttle add actions
		time = time + 1
	end

	old_add_action(self, pos, func, params, time, overwritecheck, priority)
end


-- chat commands

minetest.register_chatcommand("mesecons_debug_circuit_breaker_stats", {
  description = "shows the stats for the current mapblock",
  func = function(name)
    local player = minetest.get_player_by_name(name)
    local pos = player:get_pos()
    local blockpos = get_blockpos(pos)
    local hash = minetest.hash_node_position(blockpos)
    local time_usage = max_per_block_time_usage[hash] or 0

    local t0 = minetest.get_us_time()
    local dark_timer = dark_mapblocks[hash]

    local msg = "Max-time usage: " .. time_usage .. " micro-seconds " ..
      "(sampled over " .. sample_interval .. " seconds)"

    if dark_timer and dark_timer > t0 then
      msg = msg .. " [Mapblock throttled!]"
    end

    return true, msg
  end
})

minetest.register_chatcommand("mesecons_debug_circuit_breaker_stats_reset", {
  description = "resets the max stats",
  privs = {mesecons_debug=true},
  func = function()
    max_per_block_time_usage = {}
    dark_mapblocks = {}
    return true, "circuit breaker stats cleared!"
  end
})
