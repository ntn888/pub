# Chapter 1 — References

Every path below was opened and verified while writing the chapter. All paths
are relative to the repository root. The board profile is the authority for
board-specific claims; the LP-MSPM0G3507 user's guide is **not** a source for
this board and is not cited (`boards/weact-mspm0g3507srhb.md`, "Sources of
truth for board facts").

## DriverLib headers (API surface)

| Symbol(s) | Header | Notes |
| --- | --- | --- |
| `DL_GPIO_togglePins` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:2313` | the one symbol taught; writes `DOUTTGL31_0`, no RMW; output must be enabled first |
| `DL_Common_delayCycles` | `sources/mspm0-sdk/source/ti/driverlib/dl_common.h:93` | busy-wait; "at least" N cycles, ~10-cycle variance, zero means maximum |
| `delay_cycles` macro | `sources/mspm0-sdk/source/ti/driverlib/m0p/dl_core.h:115` | alias for `DL_Common_delayCycles` |
| `DL_GPIO_PIN_0` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:72` | value `0x00000001` |

The taught symbol `DL_GPIO_togglePins` is listed in the repo's API inventory,
`DISCOVERY.md` (header `dl_gpio.h`), and in `dl_gpio.h` itself. No DriverLib
symbol is invented in this chapter.

Generated functions (`SYSCFG_DL_init`, `SYSCFG_DL_initPower`,
`SYSCFG_DL_GPIO_init`, `SYSCFG_DL_SYSCTL_init`) are SysConfig output, not
DriverLib API; they are described but not claimed as DriverLib.

## Device headers

| Symbol | Header | Notes |
| --- | --- | --- |
| `GPIOA` | `sources/mspm0-sdk/source/ti/devices/msp/m0p/mspm0g350x.h` | register overlay for the port (via `GPIO_LEDS_PORT`) |
| `IOMUX_PINCM1`, `IOMUX_PINCM1_PF_GPIOA_DIO00` | `mspm0g350x.h:420,485` | PINCM 1, pin function 1 = GPIOA DIO0 (PA0) |

## Board sources (board-specific claims)

| Fact | Source |
| --- | --- |
| Board identity, MCU MSPM0G3507SRHBR QFN-32 (RHB) | `boards/weact-mspm0g3507srhb.md`, *Identity* |
| USB-C (J1): power + CH340X serial (PA10 RX / PA11 TX) | `boards/weact-mspm0g3507srhb.md`, *Power*, *Secondary: BSL over USB serial* |
| No onboard debug probe; reader supplies DAP-Link | `boards/weact-mspm0g3507srhb.md`, *Debug and programming* |
| P3 = 4-pin SWD, order 3V3 / SWDIO / SWCLK / GND; SWDIO=PA19, SWCLK=PA20 | `boards/weact-mspm0g3507srhb.md`, *Primary: SWD via external DAP-Link*, *P3* |
| D1 = blue LED on PA0, active-low | `boards/weact-mspm0g3507srhb.md`, *Onboard indicators and controls* |
| SW1 = reset (NRST); SW2 = BSL invoke on PA18, active-low | `boards/weact-mspm0g3507srhb.md`, *Onboard indicators and controls*, *Secondary: BSL over USB serial* |
| No general-purpose user button | `boards/weact-mspm0g3507srhb.md`, *Onboard indicators and controls* |
| No external crystal; internal SYSOSC/LFOSC only | `boards/weact-mspm0g3507srhb.md`, *Clock sources* |
| P1 / P2 header maps, left to right | `boards/weact-mspm0g3507srhb.md`, *P1*, *P2* |
| PA2 (ROSC) not broken out | `boards/weact-mspm0g3507srhb.md`, *Not broken out at all* |
| Seed-example porting rule | `boards/weact-mspm0g3507srhb.md`, *Seed-example porting rule* |
| Underlying drawing for all of the above | `boards/WeAct-MSPM0G3507SRHBCoreBoard_V10 SchDoc.pdf` |

## Commands (each traceable)

| Command | Source |
| --- | --- |
| `make -C examples/01-blink` | `examples/01-blink/Makefile`, `examples/01-blink/README.md` |
| `pyocd load --target MSPM0G3507 build/blink.bin` | `sources/makefile/Makefile` (`PYOCD_TARGET = MSPM0G3507`; `flash:` target) |
| `arm-none-eabi-gcc` toolchain prefix | every `examples/*/Makefile` |

No PyOCD or OpenOCD configuration file exists in this repository, and none is
required: PyOCD auto-detects the CMSIS-DAP probe. The `MSPM0G3507` target name
is taken from `sources/makefile/Makefile`.

## SDK examples (canonical usage)

| Example | Path |
| --- | --- |
| Seed ported by this chapter | `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/gpio_toggle_output/` |
| — seed program | `.../gpio_toggle_output/gpio_toggle_output.c` |
| — seed declaration (LP-pinned) | `.../gpio_toggle_output/gpio_toggle_output.syscfg` |
| — seed generated init | `.../gpio_toggle_output/ti_msp_dl_config.c/.h` |
| Fallback seed (no LED) | `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/empty/` |

## This chapter's example

- `examples/01-blink/main.c` — `SYSCFG_DL_init()` + toggle loop.
- `examples/01-blink/ti_msp_dl_config.c/.h` — committed generated init (ported).
- `examples/01-blink/01-blink.syscfg` — the ported declaration.
- `examples/01-blink/Makefile` — build wiring (GNU Arm).
- `examples/01-blink/mspm0g3507.lds` — GNU linker script (SDK file).
- `examples/01-blink/README.md` — build/flash/expected behavior.

## Figures

- `chapters/figures/01-headers.dot` / `.svg` — P1/P2 maps,
  redrawn from the profile text (not traced from WeAct artwork).
- `chapters/figures/01-swd-wiring.dot` / `.svg` — DAP-Link to
  P3; probe pins generic/placeholder.
- `chapters/figures/01-loop-flow.dot` / `.svg` — the
  build/flash/observe loop.

All three are rendered by `make -C figures` (Graphviz `dot`).

## Build verification

`make -C examples/01-blink` produces `build/blink.elf` and `build/blink.bin`
with no warnings; FLASH 504 B / SRAM 0 B on GNU Arm
(`arm-none-eabi-gcc (Alpine Linux) 16.1.0`).
