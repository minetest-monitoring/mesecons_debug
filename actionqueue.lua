-- smarter mesecons actionqueue
-- TODO: create PR if ot works properly


-- execute the stored functions on a globalstep
-- if however, the pos of a function is not loaded (get_node_or_nil == nil), do NOT execute the function
-- this makes sure that resuming mesecons circuits when restarting minetest works fine
-- However, even that does not work in some cases, that's why we delay the time the globalsteps
-- start to be execute by 5 seconds
local get_highest_priority = function (actions)
	local highestp = -1
	local highesti
	for i, ac in ipairs(actions) do
		if ac.priority > highestp then
			highestp = ac.priority
			highesti = i
		end
	end

	return highesti
end

local m_time = 0
local resumetime = mesecon.setting("resumetime", 4)
minetest.register_globalstep(function (dtime)
	m_time = m_time + dtime
	-- don't even try if server has not been running for XY seconds; resumetime = time to wait
	-- after starting the server before processing the ActionQueue, don't set this too low
	if (m_time < resumetime) then return end

	if not mesecons_debug.enabled then
		return
	end

	local actions = mesecon.tablecopy(mesecon.queue.actions)
	local actions_now={}

	mesecon.queue.actions = {}

	-- sort actions into two categories:
	-- those toexecute now (actions_now) and those to execute later (mesecon.queue.actions)
	for _, ac in ipairs(actions) do
		if ac.time > 0 then
			ac.time = ac.time - dtime -- executed later
			table.insert(mesecon.queue.actions, ac)
		else
			table.insert(actions_now, ac)
		end
	end

	if #actions_now > 30000 then
		-- too much actions, purge them
		return
	end

	local t0 = minetest.get_us_time()

	while(#actions_now > 0) do -- execute highest priorities first, until all are executed
		local hp = get_highest_priority(actions_now)
		local action = actions_now[hp]

		local t1 = minetest.get_us_time()
		local diff = t1 - t0
		if diff > 75000 then
			-- execute remaining actions in next globalstep
			table.insert(mesecon.queue.actions, 1, action)
		else
			mesecon.queue:execute(action)
			table.remove(actions_now, hp)
		end

	end
end)

