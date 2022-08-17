
local hud_refresh_interval = mesecons_debug.settings.hud_refresh_interval
mesecons_debug.settings._subscribe_for_modification("hud_refresh_interval",
        function(value) hud_refresh_interval = value end)

local hudid_by_playername = {}

minetest.register_on_leaveplayer(function(player)
    hudid_by_playername[player:get_player_name()] = nil
end)

local function get_info(player)
    local pos = player:get_pos()
    local blockpos = mesecons_debug.get_blockpos(pos)
    local ctx = mesecons_debug.get_context(pos)

    local total = mesecons_debug.avg_total_micros_per_second
    if total == 0 then total = 1 end
    local percent = ctx.avg_micros_per_second * 100 / total

    local txt = ("mesecons @ %s\n"):format(
        minetest.pos_to_string(blockpos)
    )

    if ctx.whitelisted then
        txt = txt .. "whitelisted, no limits"
        return txt, 0x00FFFF
    end

    txt = txt .. ("usage: %.0f us/s .. (%.1f%%) penalty: %.2fs"):format(
        ctx.avg_micros_per_second,
        percent,
        ctx.penalty
    )
    txt = txt .. ("\nlag: %.2f (%s); mesecons load = %s"):format(
        mesecons_debug.avg_lag,
        mesecons_debug.lag_level,
        mesecons_debug.load_level
    )
    if minetest.get_server_max_lag then
        txt = txt .. ("; max_lag: %.2f"):format(
            minetest.get_server_max_lag()
        )
    end
    txt = txt .. ("; #players = %i"):format(
        #minetest.get_connected_players()
    )
    txt = txt .. ("\npenalties enabled = %s; mesecons enabled = %s"):format(
        mesecons_debug.enabled,
        mesecons_debug.mesecons_enabled
    )

    if ctx.penalty <= 1 then
        return txt, 0x00FF00

    elseif ctx.penalty <= 10 then
        return txt, 0xFFFF00

    else
        return txt, 0xFF0000
    end
end

local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < hud_refresh_interval then
        return
    end
    timer = 0

    for _, player in ipairs(minetest.get_connected_players()) do
        local playername = player:get_player_name()
        local hudid = hudid_by_playername[playername]
        local hud_enabled = mesecons_debug.hud_enabled_by_playername[playername]

        if hud_enabled then
            local text, color = get_info(player)
            if hudid then
                player:hud_change(hudid, "text", text)
                player:hud_change(hudid, "number", color)

            else
                hudid_by_playername[playername] = player:hud_add({
                    name = "mesecons_debug:hud",
                    hud_elem_type = "text",
                    position = { x = 0.5, y = 0.8 },
                    alignment = { x = 0, y = 0 },
                    offset = { x = 0, y = 0 },
                    scale = { x = 100, y = 100 },
                    text = text,
                    number = color,
                })
            end
        else
            if hudid then
                local hud_def = player:hud_get(hudid)
                if hud_def.name == "mesecons_debug:hud" then
                    player:hud_remove(hudid)
                end
                hudid_by_playername[playername] = nil
            end
        end
    end
end)
