

minetest.register_chatcommand("mesecons_flush", {
	description = "flushes the mesecon actionqueue",
	privs = {server=true},
	func = function(name)
		minetest.log("warning", "Player " .. name .. " flushes mesecon actionqueue")
		mesecon.queue.actions = {}
	end
})
