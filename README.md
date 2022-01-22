# Mesecons Debug Collection

Allows to throttle mesecons activity per mapblock

# Overview

There is a cpu quota for every mapblock, if that quota is used up
the mesecons contraptions will be slowed down for that mapblock

The current mapblock-stats can be viewed with `/mesecons_hud on`

## Settings

* see `settingtypes.txt`

## Privs

* **mesecons_debug** Allows execution of mesecon debug chatcommands

## Commands

All of these commands require the `mesecons_debug` privilege.

* `/mesecons_hud [on|off]` enables or disables the hud
* `/mesecons_flush` Flushes the action queue
* `/mesecons_enable` Enable the mesecons queue
* `/mesecons_disable` Disables the mesecons queue
* `/mesecons_stats` shows some mesecons stats for the current position
* `/mesecons_global_stats` shows the mapblock with the most prominent usage of mesecons activity
* `/mesecons_whitelist_get` shows the list of whitelisted mapblocks
* `/mesecons_whitelist_add` adds the current mapblock to the whitelist
* `/mesecons_whitelist_remove` removes the current mapblock from the whitelist

## Penalty controller

Can query the penalty and usage values of the placed-in mapblock (requires the `digiline` mod)

Example code to query it with the luacontroller:

```lua
if event.type == "program" then
  digiline_send("penalty_ctrl", "GET")
end

if event.type == "digiline" and event.channel == "penalty_ctrl" then
  --[[
  event.msg = {
    micros = 0,
    avg_micros = 0, -- avg_micros_per_second
    penalty = 0,
    whitelisted = false
  }
  --]]
end
```

# License

* textures/penalty_controller_top.png
  * CC BY-SA 3.0 https://cheapiesystems.com/git/digistuff
