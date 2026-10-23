# Chapter 4 — References

Every path below was opened and verified while writing the chapter. All paths
are relative to the repository root.

## DriverLib headers (API surface)

| Symbol(s) | Header | Notes |
| --- | --- | --- |
| `DL_GPIO_reset`, `DL_GPIO_enablePower`, `DL_GPIO_disablePower` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:1835-1902` | power stage; PWREN/RSTCTL comments |
| `DL_GPIO_initDigitalOutput`, `DL_GPIO_initDigitalOutputFeatures` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:1904-1940` | configure stage; takes PINCM index |
| `DL_GPIO_setPins`, `DL_GPIO_clearPins`, `DL_GPIO_togglePins` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:2277-2316` | use stage |
| `DL_GPIO_enableOutput`, `DL_GPIO_disableOutput` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:2318-2338` | enable/disable stage |
| `DL_GPIO_PIN_0` | `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h:72` | value `0x00000001` |
| `DL_Common_delayCycles` | `sources/mspm0-sdk/source/ti/driverlib/dl_common.h:93` | busy-wait; caveats in comment 73-92 |
| `delay_cycles` macro | `sources/mspm0-sdk/source/ti/driverlib/m0p/dl_core.h:115` | alias for `DL_Common_delayCycles` |
| `DL_UART_*`, `DL_Timer_*`, `DL_I2C_*` power/reset | `dl_uart.h`, `dl_timer.h`, `dl_i2c.h` | pattern across modules; `DL_UART_enablePower` at `dl_uart.h:711`, `DL_Timer_enablePower` at `dl_timer.h:2214`, `DL_I2C_enablePower` at `dl_i2c.h:1069` |
| SYSCTL clock setup (referenced, not taught) | `sources/mspm0-sdk/source/ti/driverlib/m0p/sysctl/dl_sysctl_mspm0g1x0x_g3x0x.h` | included via `m0p/dl_sysctl.h` |

## Device headers

| Symbol | Header | Notes |
| --- | --- | --- |
| `GPIOA`, `GPIOA_BASE` | `sources/mspm0-sdk/source/ti/devices/msp/m0p/mspm0g350x.h:271,325` | register overlay pointer for the instance |
| `IOMUX_PINCM1`, `IOMUX_PINCM1_PF_GPIOA_DIO00` | `sources/mspm0-sdk/source/ti/devices/msp/m0p/mspm0g350x.h:420,485` | PINCM 1, pin function 1 = GPIOA DIO0 |
| device family dispatch | `sources/mspm0-sdk/source/ti/devices/msp/msp.h:57-58`, `sources/mspm0-sdk/source/ti/devices/DeviceFamily.h:154-158` | `__MSPM0G3507__` selects `mspm0g350x.h` |

## SDK examples (canonical usage)

| Example | Path |
| --- | --- |
| SysConfig-backed LED toggle | `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/gpio_toggle_output/` |
| — generated init (`SYSCFG_DL_init` decomposition) | `.../gpio_toggle_output/ti_msp_dl_config.c:47-101` |
| — pin names and board mapping | `.../gpio_toggle_output/ti_msp_dl_config.h:82-96` |
| — LED polarity (WeAct D1 on PA0, active-low) | `examples/04-manual-led/main.c:14-21,44` |
| Hand-written non-SysConfig init | `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/empty_non_sysconfig/` |
| — GNU startup + linker script | `.../empty_non_sysconfig/gcc/startup_mspm0g350x_gcc.c`, `.../empty_non_sysconfig/gcc/mspm0g3507.lds` |
| Suggested project Makefile | `sources/makefile/Makefile` |

## TRM — `sources/trm/slau846c.txt`

| Section | Title | Used for |
| --- | --- | --- |
| 2.2.6 | Peripheral Enable | PWREN key/enable; 4-ULPCLK settle before further register access |
| 2.2.6.1 | Automatic Peripheral Disable in Low Power Modes | why `disablePower` is a correctness tool |
| 2.3.1.2 | Internal System Oscillator (SYSOSC) | base frequency active by default after brownout reset |
| 2.4.1.7 | Peripheral Reset Control | RSTCTL/STAT reset-assert and sticky reset flag |

## Datasheet — `sources/datasheet/mspm0g3507.txt`

| Fact | Evidence |
| --- | --- |
| `PA0` maps to package pin 4 on the 32-pin RHB package | Figure 6-5, 32-Pin RHB (VQFN) top view |
| Board assignment: D1 on PA0 | `boards/weact-mspm0g3507srhb.md:53` |

## Build verification

`make -C examples/04-manual-led` produces `build/manual-led.elf` and
`build/manual-led.bin` with no warnings on GNU Arm GCC 16.1.0
(`arm-none-eabi-gcc (Alpine Linux) 16.1.0`).
