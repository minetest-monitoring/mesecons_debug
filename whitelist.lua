local filename = minetest.get_worldpath() .. "/mesecons_debug_whiltelist"

function mesecons_debug.save_whitelist()
  local file = io.open(filename,"w")
  local data = minetest.serialize(mesecons_debug.whitelist)
  if file and file:write(data) and file:close() then
    return
  else
    minetest.log("error","mesecons_debug: save failed")
    return
  end
end

function mesecons_debug.load_whitelist()
  local file = io.open(filename, "r")

  if file then
    local data = file:read("*a")
    mesecons_debug.whitelist = minetest.deserialize(data) or {}
  end
end
