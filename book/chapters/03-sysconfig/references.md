# Chapter 3 — references

All paths relative to the repository root. SDK pinned to MSPM0 SDK 2.09.00.01
(`sources/mspm0-sdk`). Every path below was opened while writing the chapter.

## DriverLib headers (API surface)

| Symbol(s) | Header | Notes |
| --- | --- | --- |
| `DL_GPIO_reset` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:1882` | power stage, reset-assert + key |
| `DL_GPIO_enablePower` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:1835` | opens the register interface; PWREN key |
| `DL_GPIO_initDigitalOutput` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:1910` | takes a PINCM index |
| `DL_GPIO_setPins` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:2283` | drives the idle level high (active-low "off") |
| `DL_GPIO_clearPins` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:2298` | idle level low (the generated init uses this) |
| `DL_GPIO_togglePins` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:2313` | runtime toggle |
| `DL_GPIO_enableOutput` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:2324` | connects the pin to the output driver |
| `DL_Common_delayCycles` | `sources/mspm0-sdk/source/ti/driverlib/dl_common.h:93` | busy-wait; caveats in comment |
| `delay_cycles` macro | `sources/mspm0-sdk/source/ti/driverlib/m0p/dl_core.h:115` | alias for `DL_Common_delayCycles` |
| `DL_SYSCTL_setBORThreshold` | `sources/mspm0-sdk/source/ti/driverlib/m0p/sysctl/dl_sysctl_mspm0g1x0x_g3x0x.h:1302` | BOR threshold; `DL_SYSCTL_BOR_THRESHOLD_LEVEL_0` at :820 |
| `DL_SYSCTL_setSYSOSCFreq` | `…dl_sysctl_mspm0g1x0x_g3x0x.h:1689` | `DL_SYSCTL_SYSOSC_FREQ_BASE` at :399; MDIV precondition documented at :1681 |
| `DL_SYSCTL_disableHFXT` | `…dl_sysctl_mspm0g1x0x_g3x0x.h:2000` | covers the "clocks" half of the declaration |
| `DL_SYSCTL_disableSYSPLL` | `…dl_sysctl_mspm0g1x0x_g3x0x.h:1983` | see above |

## Device headers

| Symbol | Header | Notes |
| --- | --- | --- |
| `GPIOA` | `sources/mspm0-sdk/source/ti/devices/msp/m0p/mspm0g350x.h` | register overlay pointer for the port |
| `IOMUX_PINCM1`, `IOMUX_PINCM1_PF_GPIOA_DIO00` | `mspm0g350x.h:420,485` | pin control 1, pin function 1 = GPIOA DIO00 |
| `DL_GPIO_PIN_0` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:72` | value `0x00000001` |

## Generated artifacts — SDK seed (LaunchPad)

- `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/gpio_toggle_output/gpio_toggle_output.syscfg`
  — the declaration (board template line 7; `GPIO1` block lines 19-29).
- `…/gpio_toggle_output/ti_msp_dl_config.c` — `SYSCFG_DL_init` (47-53),
  `initPower` (55-63), `GPIO_init` (65-85), `SYSCTL_init` (89-101).
- `…/gpio_toggle_output/ti_msp_dl_config.h` — `CONFIG_*` (43-44),
  `SYSCONFIG_WEAK` (46-52), includes (54-56), `POWER_STARTUP_DELAY` (73),
  `CPUCLK_FREQ` (77), pin defines (82-96), declarations (101-104).
- `…/gpio_toggle_output/gcc/makefile` — SysConfig CLI stub (8-11), generation
  rule (65-67).
- `sources/mspm0-sdk/examples/nortos/CUSTOM_BOARD/driverlib/empty_mspm0g3507/empty_mspm0g3507.syscfg`
  — the device-only (no board template) example the port follows.

## Generated artifacts — this chapter

- `examples/03-sysconfig-led/03-sysconfig-led.syscfg` — WeAct ported declaration.
- `examples/03-sysconfig-led/ti_msp_dl_config.c` — generated init (hand-ported).
- `examples/03-sysconfig-led/ti_msp_dl_config.h` — generated names (hand-ported).
- `examples/03-sysconfig-led/main.c` — `SYSCFG_DL_init()` + toggle loop.
- `examples/03-sysconfig-led/mspm0g3507.lds` — GNU linker script (SDK file).
- `examples/03-sysconfig-led/README.md` — build/run/expected behavior.

## Figure

- `chapters/figures/03-sysconfig-flow.dot` — source.
- `chapters/figures/03-sysconfig-flow.svg` — rendered by
  `make -C figures` (Graphviz `dot`).

## TRM — `sources/trm/slau846c.txt`

| Section | Title | Used for |
| --- | --- | --- |
| 2.2.6 | Peripheral Enable | registers inaccessible until PWREN key/enable; the settle wait |
| 2.4.1.7 | Peripheral Reset Control | what `DL_GPIO_reset` does |
| 2.3.1.2 | Internal System Oscillator (SYSOSC) | base (32 MHz) is the reset default |

## Datasheet — `sources/datasheet/mspm0g3507.txt`

| Fact | Evidence |
| --- | --- |
| PA0 is on the 32-pin RHB package | Figure 6-5, 32-Pin RHB (VQFN) top view |
| Board pin assignment (D1 on PA0) | `boards/weact-mspm0g3507srhb.md:53` |

## Build verification

`make -C examples/03-sysconfig-led` produces `build/sysconfig-led.elf` and
`build/sysconfig-led.bin` with no warnings, FLASH 504 B / SRAM 0 B.
