# Mesecons Debug Collection

Throttles mesecons if the server is lagging, in particular when mesecons is causing the lag. 

# Overview

This mod can penalizes mesecons activity on a per-mapblock basis, which can help laggy or machine-heavy servers
to be less laggy overall. Penalties are implemented as delays on various events. 

Lag and per-mapblock mesecons usage are tracked over time, in order to calculate how much to penalize each
mapblock, or whether to reduce the penalty. 

The mod defines 3 regimes of lag, with different scales of penalties. 

* If the server steps are not taking much longer than the time allotted for them, the "low penalty" regime will apply.
* If the server steps are taking too long on average, and mesecons usage isn't particularly high, the "medium penalty" 
  regime will apply.
* If the server steps are taking too long on average and mesecons usage is high, or the server steps are taking much too
  long to execute, the "high penalty" regime will apply. 

Each of these regimes has an associated "scale" and "offset". Every time the penalties are re-evaluated, 
they are changed according to this formula:

```lua
    new_penalty = old_penalty + (relative_load * penalty_scale) + penalty_offset
```

Here, relative_load is the ratio of how much time the current mapblock spends doing mesecons, to the mean time 
(spent doing mesecons) across all mapblocks currently running mesecons. This value is currently clamped between 0.1
and 10, to prevent certain edge cases from being penalized too rapidly. A value of 10 would mean that the mapblock 
under consideration is using 10x as much mesecons as the average mapblock.

Note that, depending on the values of `penalty_scale` and `penalty_offset`, the new penalty may be *less* than the old
penalty. This is to allow penalties to reach equilibrium under a constant load, and to taper off over time if the
usage in the mapblock declines, or the regime changes. 

## Settings

* `penalty_clear_cooldown = 120` Seconds that a player has to wait between using the `mesecons_clear_penalty` command
* `max_penalty = 120` Upper limit of the per-mapblock penalty
* `penalty_mapblock_disabled = 110` 
  Completely disable mesecons in a mapblock, if the penalty exceeds this value.
  Set above `max_penalty` to disable this feature. 
* `penalty_check_steps = 50` # of server steps between updating the penalties
* `gc_interval = 61` Seconds after which data about unloaded mapblocks is removed from memory. 
* `hud_refresh_interval = 1` Seconds between updating the client's HUD
* `moderate_lag_ratio = 3`
  Ratio between actual and expected length of a server step at which lag is considered "moderate"
* `high_lag_ratio = 9` Ratio between actual and expected length of a server step at which lag is considered "high"
* `high_load_threshold = 0.33` 
  % of processing a server spends on mesecons at which the mescons load is considered "high".
* `low_penalty_offset = -1` Offset of the penalty in the low-lag regime.
* `low_penalty_scale = 0.1` 
  Scale of the penalty in the low-lag regime. The default values ensure that nothing is penalized in the low-lag regime.
* `medium_penalty_offset = -0.8` Offset of the penalty in the moderate-lag regime.
* `medium_penalty_scale = 0.2` Scale of the penalty in the moderate-lag regime.
* `high_penalty_offset = -0.5` Offset of the penalty in the high-lag regime.
* `high_penalty_scale = 0.5` Scale of the penalty in the high-lag regime. 

## Privs

* **mesecons_debug** Allows execution of mesecon debug chatcommands

## Commands

* `/mesecons_clear_penalty` 
    Clears the penalty for the current mapblock. Users can only execute this every `penalty_clear_cooldown` seconds
* `/mesecons_global_stats` shows the mapblock with the most prominent usage of mesecons activity
* `/mesecons_hud` toggles the hud
* `/mesecons_stats` shows some mesecons stats for the current position


### Admin Commands

All of these commands require the `mesecons_debug` privilege.

* `/create_lag <microseconds> <chance>` 
   Artificially slow down the server by `microseconds` every `chance` server steps. Useful for debugging this mod.
* `/mesecons_debug_get <setting>` Inspect the current value of a setting.
* `/mesecons_debug_set <setting> <value>` Change a setting value. This does *not* save the value between reboots! 
* `/mesecons_disable` Disables mesecons entirely
* `/mesecons_enable` Undoes the above command
* `/mesecons_flush` Flushes the mesecons action queue
* `/mesecons_whitelist_add` adds the current mapblock to the whitelist
* `/mesecons_whitelist_get` shows the list of whitelisted mapblocks
* `/mesecons_whitelist_remove` removes the current mapblock from the whitelist

## Nodes

### Mesecons Lagger

A node which can create `n` microseconds of lag once every `chance` server steps. Useful for debugging this mod.  

### Penalty Controller

Requires the `digiline` mod.

Can query the penalty and usage values of the mapblock it is placed in.

Example code to query it with the luacontroller:

```lua
if event.type == "program" then
  digiline_send("penalty_ctrl", "GET")
end

if event.type == "digiline" and event.channel == "penalty_ctrl" then
  --[[
  event.msg = {
    micros     = 0, -- micros_per_second
    avg_micros = 0, -- avg_micros_per_second
    penalty    = 0, -- in seconds
    whitelisted = false
  }
  --]]
end
```

# License

* textures/penalty_controller_top.png
  * CC BY-SA 3.0 https://cheapiesystems.com/git/digistuff
