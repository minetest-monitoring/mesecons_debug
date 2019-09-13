

mesecons_debug.dump_queue = function()
	minetest.log("warning", "[dump_queue] dumping mesecons action-queue")

	local fname = minetest.get_worldpath().."/mesecons_dump_" .. minetest.get_us_time() .. ".json"

	local f = io.open(fname, "w")
	local data_string, err = minetest.write_json(mesecon.queue.actions)
	if err then
		error(err)
	end
	f:write(data_string)
	io.close(f)

	minetest.log("action", "[dump_queue] dumped " .. #mesecon.queue.actions ..
		" actions to " .. fname ..
		" bytes: " .. string.len(data_string)
	)
end
