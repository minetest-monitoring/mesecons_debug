local MP = minetest.get_modpath("mesecons_debug")

mesecons_debug = {
  enabled = true,
  context_store_size = 0,
  -- playername => true
  hud = {},

  max_usage_micros = 10000
}

dofile(MP.."/privs.lua")
dofile(MP.."/flush.lua")
dofile(MP.."/overrides.lua")
dofile(MP.."/luacontroller.lua")
dofile(MP.."/chatcommands.lua")
dofile(MP.."/hud.lua")

print("[OK] mesecons_debug loaded")
