
globals = {
	"mesecons_debug",
	"mesecon",
	"minetest"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"vector", "ItemStack",
	"dump",

	"monitoring"
}
