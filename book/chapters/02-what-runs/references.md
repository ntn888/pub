# Chapter 2 — References

All paths relative to the repository root. SDK pinned to MSPM0 SDK 2.09.00.01
(`sources/mspm0-sdk`). Every path below was opened, and every quoted excerpt
copied from the file, while writing the chapter.

## DriverLib headers (API surface)

None. This chapter teaches no DriverLib API and calls no `DL_*` function; it is
entirely toolchain (startup code, linker script, map). The example links
`driverlib.a` only so that it matches the seed's link line; no DriverLib symbol
appears in `main.c`.

## Startup code (SDK source tree)

- `sources/mspm0-sdk/source/ti/devices/msp/m0p/startup_system_files/gcc/startup_mspm0g350x_gcc.c`
  — the file this chapter reads. Byte-identical to the seed's copy at
  `.../empty_non_sysconfig/gcc/startup_mspm0g350x_gcc.c` (verified with `diff`).
  - vector table array `interruptVectors`, `.intvecs`, first two words: lines 97-148
  - weak handler aliases to `Default_Handler`: lines 61-91
  - `__libc_init_array` declaration and call: lines 56, 199
  - `_init` weak alias to `initStub`: lines 57-58
  - `Reset_Handler` body (`.data` copy, `.ramfunc` copy, `.bss` zero, commented
    `SystemInit`, `__libc_init_array`, `main`, `HardFault_Handler`): lines 157-210
  - `Default_Handler` trap loop: lines 215-221

## Linker script — seed and example copy

- `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/empty_non_sysconfig/gcc/mspm0g3507.lds`
  - `_Min_Heap_Size` / `_Min_Stack_Size` (defined, not asserted): lines 34-36
  - `MEMORY` regions (FLASH, SRAM, BCR_CONFIG, BSL_CONFIG): lines 39-46
  - "SRAM length must match MPPC/MEMSS config" comment: line 48
  - `REGION_ALIAS` group: lines 50-61
  - `.intvecs` placement + `KEEP`: lines 67-72
  - `.ramfunc` (RAM VMA / FLASH LMA): lines 97-103
  - `.rodata`: lines 105-110
  - `.data` (`LOADADDR`, `AT>`): lines 149-156
  - `.bss`: lines 158-166
  - `.noinit`: lines 168-172
  - `.heap`: lines 174-182
  - `.stack` and `__StackTop`/`__stack`: lines 184-200
- `examples/02-what-runs/mspm0g3507.lds` — byte-identical copy (verified with
  `diff`).

## Seed build wiring

- `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/empty_non_sysconfig/gcc/makefile`
  - `-nostartfiles`, `-l:driverlib.a`, `-T mspm0g3507.lds`, `-Wl,-Map`: lines 29-33
  - `-static`, `-Wl,--gc-sections`: lines 38-39
  - `-lgcc -lc -lm --specs=nano.specs --specs=nosys.specs`: lines 41-45
- `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/empty_non_sysconfig/empty_non_sysconfig.c`
  — the seed's `main` (`SYSCFG_DL_init()`, empty loop).
- Other-toolchain linker files (not used): `.../empty_non_sysconfig/iar/mspm0g3507.icf`,
  `.../empty_non_sysconfig/keil/mspm0g3507.sct`, `.../empty_non_sysconfig/ticlang/mspm0g3507.cmd`.

## This chapter's example and artifact

- `examples/02-what-runs/main.c` — seed plus tagged globals (`g_initialized`,
  `g_zero`, `g_survivor`, `g_banner`, `run_from_ram`, empty `__libc_init_array`).
- `examples/02-what-runs/Makefile` — GNU Arm link line (`-Wl,-Map=...`, `--gc-sections`, `-lgcc`).
- `examples/02-what-runs/build/what-runs.map` — every `.intvecs` / `.ramfunc` /
  `.rodata` / `.data` / `.bss` / `.noinit` / `.heap` / `.stack` excerpt and the
  `interruptVectors`, `__data_load__`, `__StackTop`, `__run_from_ram_veneer`
  lines are quoted from this generated file.
- `examples/02-what-runs/build/what-runs.elf` — `readelf -h` entry point,
  `readelf -S` `NOBITS` on `.bss`/`.noinit`, `objdump -s -j .intvecs` first
  vector words, `nm` symbol addresses.
- `examples/02-what-runs/build/what-runs.bin` — 416 bytes; `g_zero`/`g_survivor`
  absent.
- `examples/02-what-runs/README.md` — build/run/read-the-map checklist.

## Figures

- `chapters/figures/02-memory-map.dot` (+ `.svg`) — regions and the
  four SRAM aliases; source: `mspm0g3507.lds` `MEMORY`/aliases and TRM 1.3/6.2.3.1.
- `chapters/figures/02-reset-flow.dot` (+ `.svg`) — reset to `main`;
  source: `startup_mspm0g350x_gcc.c` and TRM 1.4.
- Both render with `make -C figures` (Graphviz `dot`). No unrenderable figure
  was produced.

## TRM — `sources/trm/slau846c.txt`

| Section | Title | Used for |
| --- | --- | --- |
| 1.3 | Platform Memory Map | top-level Code / SRAM / Peripheral / Subsystem / PPB regions (Table 1-1) |
| 1.3.1 | Code Region | flash + ROM; corrected/uncorrected flash aliases |
| 1.3.2 | SRAM Region | four aliased subregions (Table 1-2); unchecked window; uninitialized-read hazard |
| 1.3.3 | Peripheral Region | peripherals `0x4000.0000`, aliased flash `0x4100.0000-0x41FF.FFFF` (Table 1-3) |
| 1.4 | Boot Configuration | reset fetches SP from `0x0000.0000` and reset vector from `0x0000.0004` |
| 3.3.2 | Interrupt and Exception Table | vector table is 48 words / 192 bytes |
| 6.2.3.1 | Flash Memory Map | NONMAIN corrected base `0x41C0.0000` |

## Datasheet — `sources/datasheet/mspm0g3507.txt`

| Fact | Evidence |
| --- | --- |
| MSPM0G3507 is 128 KB flash, 32 KB SRAM | device table ("MSPM0G3507: 128KB flash, 32KB RAM") |

## Build verification

```
make -C examples/02-what-runs clean && make -C examples/02-what-runs
```

Clean build, no warnings, GNU Arm GCC 16.1.0 (Alpine Linux):
`FLASH 416 B / 128 KB`, `SRAM 56 B / 32 KB`, `BCR_CONFIG 0 B`, `BSL_CONFIG 0 B`.
