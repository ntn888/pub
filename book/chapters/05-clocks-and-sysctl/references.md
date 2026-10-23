# Chapter 5 — references

All paths relative to the repository root. SDK pinned to MSPM0 SDK 2.09.00.01.

## DriverLib headers

- `sources/mspm0-sdk/source/ti/driverlib/m0p/dl_sysctl.h` — umbrella that
  selects the device SYSCTL header.
- `sources/mspm0-sdk/source/ti/driverlib/m0p/sysctl/dl_sysctl_mspm0g1x0x_g3x0x.h`
  — every symbol used in this chapter:
  - `DL_SYSCTL_setSYSOSCFreq` (line 1689)
  - `DL_SYSCTL_configSYSPLL` (1812)
  - `DL_SYSCTL_enableSYSPLL` (1823) / `DL_SYSCTL_disableSYSPLL` (1983)
  - `DL_SYSCTL_setMCLKSource` macro (974),
    `DL_SYSCTL_switchMCLKfromSYSOSCtoHSCLK` (1002)
  - `DL_SYSCTL_setMCLKDivider` (1630)
  - `DL_SYSCTL_getMCLKSource` (1657)
  - `DL_SYSCTL_setULPCLKDivider` (1840)
  - `DL_SYSCTL_getClockStatus` (1766)
  - `DL_SYSCTL_setFlashWaitState` (2341)
  - `DL_SYSCTL_configFCC` (2423), `DL_SYSCTL_setFCCPeriods` (2435),
    `DL_SYSCTL_startFCC` (2384), `DL_SYSCTL_isFCCDone` (2399),
    `DL_SYSCTL_readFCC` (2372)
  - types: `DL_SYSCTL_SYSPLLConfig` (318), `DL_SYSCTL_SYSOSC_FREQ` (394),
    `DL_SYSCTL_SYSPLL_INPUT_FREQ` (306), `DL_SYSCTL_SYSPLL_MCLK` (284),
    `DL_SYSCTL_SYSPLL_REF` (292), `DL_SYSCTL_SYSPLL_PDIV` (304),
    `DL_SYSCTL_HSCLK_SOURCE` (475), `DL_SYSCTL_MCLK_SOURCE` (483),
    `DL_SYSCTL_MCLK_DIVIDER` (493), `DL_SYSCTL_ULPCLK_DIV` (428),
    `DL_SYSCTL_FLASH_WAIT_STATE` (772), `DL_SYSCTL_FCC_*` (623–760),
    `DL_SYSCTL_CLK_STATUS_*` (155–201)
- `sources/mspm0-sdk/source/ti/driverlib/m0p/sysctl/dl_sysctl_mspm0g1x0x_g3x0x.c`
  — `DL_SYSCTL_configSYSPLL` (line 41): disables PLL, waits for `SYSPLL_OFF`,
  dereferences `config->inputFreq` as a flash address into `SYSPLLPARAM0/1`,
  enables the PLL, busy-waits for `SYSPLLGOOD`.
- `sources/mspm0-sdk/source/ti/driverlib/m0p/dl_core.h` — `delay_cycles` macro
  (carried over from Chapter 4; not re-taught here).

## SDK examples

- `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/sysctl_mclk_syspll/`
  — PLL settings (`ti_msp_dl_config.c`) and expected FCC ratio / tolerance
  (`ti_msp_dl_config.h`: `FCC_EXPECTED_RATIO 1250`, ±0.3 %).
- `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/sysctl_frequency_clock_counter/`
  — FCC usage and pass/fail computation.
- `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/sysctl_hfxt_run/`
  — HFXT source path (deferred: needs IOMUX pinmux).

## TRM — `sources/trm/slau846c.txt`

- 2.3.1.2 — Internal System Oscillator (SYSOSC)
- 2.3.1.3 — System Phase-Locked Loop (SYSPLL)
- 2.3.1.3.1 — Configuring SYSPLL Output Frequencies (equations for
  `fLOOPIN`, `fVCO`, `CLK0/1/2X`)
- 2.3.2.1 — MCLK (Main Clock) Tree (sources; 80 MHz ceiling)
- 2.3.2.3 — ULPCLK (Low-Power Clock) (≤ 40 MHz; UDIV default divide-by-2)
- 2.3.2.6 — LFCLK (Low-Frequency Clock) (LFOSC is the post-boot default source)
- 2.3.2.8 — HSCLK (High Speed Clock)
- 2.3.3 — Clock Tree
- 2.3.5 — Frequency Clock Counter (FCC)
- 2.3.5.1 — Using the FCC (LFXT/LFCLK-triggered, RISE_RISE; ~976 counts for
  32 MHz SYSOSC)
- 2.3.5.2 — FCC Frequency Computation and Accuracy
- 2.4 — System Controller (SYSCTL)

## Datasheet — `sources/datasheet/mspm0g3507.txt`

- HFXT 4–48 MHz external crystal oscillator; LFXT 32 kHz.
- Pin functions named in the tree (HFXIN/HFXOUT, LFXIN/LFXOUT, CLK_OUT,
  FCC_IN).

## Figures

- `chapters/figures/05-clock-tree.dot` →
  `05-clock-tree.svg` (Graphviz). Drawn from TRM 2.3.2.1, 2.3.2.3, 2.3.2.8,
  2.3.3; node labels use `dl_sysctl_mspm0g1x0x_g3x0x.h` enum names.
- `chapters/figures/05-fcc-timing.gp` →
  `05-fcc-timing.svg` (Gnuplot). Drawn from TRM 2.3.5, 2.3.5.1, 2.3.5.2.
- `chapters/figures/05-logic-analyser.dot` →
  `05-logic-analyser.svg` (Graphviz). Conceptual probe wiring; board pin facts
  (PA1 on P1 pin 16, GND pins, 3.3 V logic) from
  `boards/weact-mspm0g3507srhb.md` ("P1", "Power"); analyser end is generic.
- Render commands: `figures/Makefile` (`make -C figures`).

## External test equipment (not a board or SDK source)

- Logic analyser + sigrok / PulseView and `sigrok-cli` — the second,
  external instrument in *Prove*. Host tools, like PyOCD; no board or SDK
  claim depends on them. The example's PA1 square wave (half period
  `SCOPE_HALF_PERIOD_CYCLES`, see `examples/05-clock-tree/main.c`) is what
  they measure.
- `IOMUX_PINCM2` / `IOMUX_PINCM2_PF_GPIOA_DIO01` (PA1):
  `sources/mspm0-sdk/source/ti/devices/msp/m0p/mspm0g350x.h:421,495`.

