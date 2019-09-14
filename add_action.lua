-- replaces the provided add_action from the mesecons mod


-- If add_action with twice the same overwritecheck and same position are called, the first one is overwritten
-- use overwritecheck nil to never overwrite, but just add the event to the queue
-- priority specifies the order actions are executed within one globalstep, highest first
-- should be between 0 and 1
function mesecon.queue:add_action(pos, func, params, time, overwritecheck, priority)
	-- Create Action Table:
	time = time or 0 -- time <= 0 --> execute, time > 0 --> wait time until execution
	priority = priority or 1
	local action = {	pos=mesecon.tablecopy(pos),
				func=func,
				params=mesecon.tablecopy(params or {}),
				time=time,
				owcheck=(overwritecheck and mesecon.tablecopy(overwritecheck)) or nil,
				priority=priority}

	local toremove = nil
	-- Otherwise, add the action to the queue
	if overwritecheck then -- check if old action has to be overwritten / removed:
		for i, ac in ipairs(mesecon.queue.actions) do
			if vector.equals(pos, ac.pos)
			and action.func == ac.func then
			-- and mesecon.cmpAny(overwritecheck, ac.owcheck)) then
				toremove = i
				break
			end
		end
	end

	if (toremove ~= nil) then
		table.remove(mesecon.queue.actions, toremove)
	end

	table.insert(mesecon.queue.actions, action)
end
