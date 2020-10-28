local MP = minetest.get_modpath("mesecons_debug")

mesecons_debug = {
  enabled = true,
  -- blockpos-hash => context
  context_store = {},
  context_store_size = 0,

  -- mapblock-hash -> true
  whitelist = {},

  -- playername => true
  hud = {},

  max_usage_micros = 15000
}

dofile(MP.."/functions.lua")
dofile(MP.."/whitelist.lua")
dofile(MP.."/privs.lua")
dofile(MP.."/flush.lua")
dofile(MP.."/context.lua")
dofile(MP.."/overrides.lua")
dofile(MP.."/luacontroller.lua")
dofile(MP.."/chatcommands.lua")
dofile(MP.."/hud.lua")

mesecons_debug.load_whitelist()

print("[OK] mesecons_debug loaded")
