# Mesecons Debug Collection

Allows to throttle mesecons activity per mapblock

# Overview

There is a cpu quota for every mapblock, if that quota is used up
the mesecons contraptions will be slowed down for that mapblock

The current mapblock-stats can be viewed with `/mesecons_hud on`

## Settings

* none yet

## Privs

* **mesecons_debug** Allows execution of mesecon debug chatcommands

## Commands

All of these commands require the `mesecons_debug` privilege.

* `/mesecons_hud [on|off]` enables or disables the hud
* `/mesecons_flush` Flushes the action queue
* `/mesecons_enable` Enable the mesecons queue
* `/mesecons_disable` Disables the mesecons queue
* `/mesecons_stats` shows some mesecons stats for the current position
* `/mesecons_whitelist_get` shows the list of whitelisted mapblocks
* `/mesecons_whitelist_add` adds the current mapblock to the whitelist
* `/mesecons_whitelist_remove` removes the current mapblock from the whitelist
