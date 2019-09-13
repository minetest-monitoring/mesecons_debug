
minetest.register_chatcommand("dump_queue", {
    description = "dumps the current actionqueue to a file for later processing",
    privs = { server = true },
    func = function()
	minetest.log("warning", "[dump_queue] dumping mesecons action-queue")

	local fname = minetest.get_worldpath().."/mesecons_dump_" .. os.date("%Y%m%dT%H%M%S") .. ".json"

	local f = io.open(fname, "w")
	local data_string, err = minetest.write_json(mesecon.queue.actions)
	if err then
		error(err)
	end
	f:write(data_string)
	io.close(f)

	return true, "dumped " .. #mesecon.queue.actions ..
		" actions to " .. fname ..
		" bytes: " .. string.len(data_string)
    end
})
