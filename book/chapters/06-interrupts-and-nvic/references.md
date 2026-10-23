# Chapter 6 — references

All paths relative to the repository root. SDK pinned to MSPM0 SDK 2.09.00.01.

## DriverLib headers

- `sources/mspm0-sdk/source/ti/driverlib/m0p/dl_interrupt.h` — interrupt-group
  dispatch and runtime vector relocation:
  - `DL_INTERRUPT_GROUP` enum (line 234)
  - `DL_INTERRUPT_GROUPn_IIDX_*` macros (81-158); `DL_INTERRUPT_GROUPn_*` mask
    macros (168-227)
  - `DL_Interrupt_getStatusGroup` (264)
  - `DL_Interrupt_getPendingGroup` (279) — reads `IIDX`
  - `DL_Interrupt_clearGroup` (296)
  - `DL_Interrupt_registerInterrupt` (327) / `DL_Interrupt_unregisterInterrupt`
    (346)
  - header overview note that NVIC/PRIMASK control is CMSIS, not this module
    (49-52)
- `sources/mspm0-sdk/source/ti/driverlib/m0p/dl_interrupt.c` — `SCB->VTOR`
  copy-into-`.vtable` implementation (49-68); 48-vector count (37-40).
- `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h` — the button path:
  - `DL_GPIO_initDigitalInputFeatures` (2007)
  - `DL_GPIO_setLowerPinsPolarity` (2387) / `DL_GPIO_setUpperPinsPolarity` (2400)
  - `DL_GPIO_enableInterrupt` (2578) / `DL_GPIO_disableInterrupt` (2590)
  - `DL_GPIO_getEnabledInterruptStatus` (2628)
  - `DL_GPIO_clearInterruptStatus` (2696)
  - `DL_GPIO_togglePins` (2313) — carried from Chapter 1/4
  - `DL_GPIO_PIN_12` (132); `DL_GPIO_EDGE_POLARITY` per-pin macros (231-...);
    `DL_GPIO_RESISTOR` (1603); `DL_GPIO_WAKEUP` (1627)
- `sources/mspm0-sdk/source/ti/driverlib/m0p/dl_core.h` — `delay_cycles` macro
  (carried from Chapter 4; not re-taught).

## CMSIS (shipped inside the SDK)

- `sources/mspm0-sdk/source/third_party/CMSIS/Core/Include/core_cm0plus.h`:
  - NVIC public aliases (695-703) onto `__NVIC_EnableIRQ` (741),
    `__NVIC_DisableIRQ` (779), `__NVIC_GetEnableIRQ` (760),
    `__NVIC_GetPendingIRQ` (798), `__NVIC_SetPendingIRQ` (817),
    `__NVIC_ClearPendingIRQ` (832), `__NVIC_SetPriority` (850),
    `__NVIC_GetPriority` (874)
  - `SCB->VTOR` field (359-360)
- `sources/mspm0-sdk/source/third_party/CMSIS/Core/Include/cmsis_gcc.h`:
  - `__enable_irq` (196), `__disable_irq` (207), `__get_PRIMASK` (449),
    `__set_PRIMASK` (479), `__WFI` (909)

## Device header and startup

- `sources/mspm0-sdk/source/ti/devices/msp/m0p/mspm0g350x.h`:
  - `IRQn_Type` enum (68-108) — the alias collision (`WWDT0`..`= 0`,
    `GPIOA/GPIOB`.. `= 1`)
  - `__VTOR_PRESENT` (182), `__NVIC_PRIO_BITS` (183)
  - `IOMUX_PINCM1_PF_GPIOA_DIO00` (PA0) and `IOMUX_PINCM34_PF_GPIOA_DIO12` (PA12)
- `sources/mspm0-sdk/source/ti/devices/msp/m0p/startup_system_files/gcc/startup_mspm0g350x_gcc.c`:
  - `GROUP0_IRQHandler` / `GROUP1_IRQHandler` declarations (68-69) and vector
    entries (115-116)
  - `Default_Handler` infinite loop (215)

## Linker script

- `examples/06-nvic-grouping/mspm0g3507.lds` (SDK seed copy) — `.intvecs` at
  `0x00000000` (67-72), `.vtable` at `_vtable_base_address` default
  `0x20200000` (74-79).

## SDK examples

- `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/nvic_interrupt_grouping/`
  — grouped-interrupt seed (`DL_Interrupt_getPendingGroup` + IIDX switch).
- `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/nvic_interrupt_disable/`
  — peripheral-mask vs NVIC-mask lesson and `__WFI`.
- `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/gpio_simultaneous_interrupts/`
  — `GROUP1_IRQHandler` for GPIO switches; `USER_SWITCH_1` is PA12 /
  `IOMUX_PINCM34`, the pin this chapter ports.

## TRM — `sources/trm/slau846c.txt`

- 3.3 — Interrupts and Exceptions (exception states, prioritization,
  preemption/tail-chaining/late-arrival)
- 3.3.1 — Peripheral Interrupts (IRQs); NVIC 32 inputs; hierarchy Figure 3-3
- 3.3.1.1 — Nested Vectored Interrupt Controller (ISER/ICER, ISPR/ICPR,
  priority levels 0/64/128/192, the "mask at the peripheral" wake-up note)
- 3.3.1.2 — Interrupt Groups (INT_GROUP structure Figure 3-4; IIDX read returns
  the highest-priority index and clears RIS/MIS; no intra-group preemption)
- 3.3.1.3 — Wake Up Controller
- 3.3.2 — Interrupt and Exception Table (48 words / 192 bytes)

## Datasheet — `sources/datasheet/mspm0g3507.txt`

- Table 8-7, *Interrupt Vector Number* — NVIC IRQ and GROUP IIDX per peripheral
  (WWDT0/1, DEBUGSS, NVMNW, SYSCTL = IRQ 0; GPIO0/1, COMP0-2, TRNG = IRQ 1;
  TIMG0 = IRQ 16, etc.).

## Figures

- `chapters/figures/06-interrupt-hierarchy.dot` →
  `.svg` (Graphviz). Drawn from TRM 3.3.1 / 3.3.1.2, datasheet Table 8-7, and
  the `IRQn_Type` enum; labels use `dl_interrupt.h` macro names.
- `chapters/figures/06-iidx-dispatch.dot` → `.svg`
  (Graphviz). Drawn from TRM 3.3.1.2 and the `dl_interrupt.h` / `dl_gpio.h`
  calls in `examples/06-nvic-grouping/main.c`.
- `chapters/figures/06-vtable-relocation.dot` → `.svg`
  (Graphviz). Drawn from `dl_interrupt.c:49-68`, the linker script `.vtable`
  placement, `mspm0g350x.h:182`, and a debug build of
  `examples/06-nvic-grouping` with a `DL_Interrupt_registerInterrupt` call
  (`.vtable` `0x20200000`, `0xc0`; `.data`/`.bss` at `0x202000c0`).
- Render command: `make -C figures` (`figures/Makefile`).

## Example

- `examples/06-nvic-grouping/` — `main.c`, `Makefile`, `mspm0g3507.lds`,
  `README.md`. Builds with `make -C examples/06-nvic-grouping`.
