# Mesecons Debug Collection

## Settings

* `mesecons_debug.circuit_breaker` Max time usage per mapblock in micros per 10 seconds.
* `mesecons_debug.dark_timer` Dark time in microseconds: how long the mapblock stays inactive.

## Commands

All of these commands require the `mesecons_debug` privilege.

* `/mesecons_flush`.
* `/mesecons_enable`.
* `/mesecons_disable`.

## Various nodes action_on() effector

* `mesecons_debug_enable_pipeworks_filter`.
* `mesecons_debug_disable_pipeworks_filter`.

* `mesecons_debug_enable_pipeworks_mese_filter`.
* `mesecons_debug_disable_pipeworks_mese_filter`.

* `mesecons_debug_enable_pipeworks_dispenser`.
* `mesecons_debug_disable_pipeworks_dispenser`.

* `mesecons_debug_enable_pipeworks_deployer`.
* `mesecons_debug_disable_pipeworks_deployer`.

* `mesecons_debug_enable_pipeworks_nodebreaker`.
* `mesecons_debug_disable_pipeworks_nodebreaker`.

* `mesecons_debug_enable_constructor_mk1`.
* `mesecons_debug_disable_constructor_mk1`.

* `mesecons_debug_enable_constructor_mk2`.
* `mesecons_debug_disable_constructor_mk2`.

* `mesecons_debug_enable_constructor_mk3`.
* `mesecons_debug_disable_constructor_mk3`.

## Various nodes on_timer() call

* `mesecons_debug_enable_blinky_plant`.
* `mesecons_debug_disable_blinky_plant`.

## Circuit breaker commands

* `mesecons_debug_circuit_breaker_stats` (no priv needed).
* `mesecons_debug_circuit_breaker_stats_reset`.
