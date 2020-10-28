
local HUD_POSITION = {x = 0.1, y = 0.8}
local HUD_ALIGNMENT = {x = 1, y = 0}

local hud = {}


minetest.register_on_joinplayer(function(player)
  local hud_data = {}
  hud[player:get_player_name()] = hud_data

  hud_data.txt = player:hud_add({
    hud_elem_type = "text",
    position = HUD_POSITION,
    offset = {x = 0,   y = 0},
    text = "",
    alignment = HUD_ALIGNMENT,
    scale = {x = 100, y = 100},
    number = 0xFF0000
  })

end)


minetest.register_on_leaveplayer(function(player)
  hud[player:get_player_name()] = nil
end)



local function get_info(player)
  local pos = player:get_pos()
  local blockpos = mesecons_debug.get_blockpos(pos)
  local ctx = mesecons_debug.get_context(pos)

  local percent = math.floor(ctx.avg_micros / mesecons_debug.max_usage_micros * 100)

  local txt = "Mesecons @ (" .. blockpos.x .. "/" .. blockpos.y .. "/" .. blockpos.z .. ") "

  if ctx.whitelisted then
    txt  = txt .. "whitelisted, no limits"
    return txt, 0x00FF00
  end

  txt = txt ..
  " usage: " .. ctx.avg_micros .. " us/s .. (" .. percent .. "%) " ..
  "penalty: " .. math.floor(ctx.penalty*10)/10 .. " s"

  if ctx.penalty <= 0.1 then
    return txt, 0x00FF00
  elseif ctx.penalty < 0.5 then
    return txt, 0xFFFF00
  else
    return txt, 0xFF0000
  end
end

local timer = 0
minetest.register_globalstep(function(dtime)
  timer = timer + dtime
  if timer < 1 then
    return
  end
  timer = 0

  for _, player in ipairs(minetest.get_connected_players()) do
    local playername = player:get_player_name()
    local hud_data = hud[playername]
    local hud_enable = mesecons_debug.hud[playername]
    if hud_enable then
      local txt, color = get_info(player)
      player:hud_change(hud_data.txt, "text", txt)
      player:hud_change(hud_data.txt, "color", color)

    elseif hud_enable == false then
      mesecons_debug.hud[playername] = nil
      player:hud_change(hud_data.txt, "text", "")

    end

  end


end)
