# 4 — The DriverLib lifecycle

You can read `dl_gpio.h` and copy an example. That gets an LED blinking. It
does not tell you what to do when the next peripheral has a function you have
never seen, or why one call has to come before another. This chapter gives you
that: one shape that every peripheral driver follows.

By the end you will be able to open any `dl_*.h` in the SDK and predict the
order in which its functions must be called — without reading the whole header.
You will also have built a blinker whose initialisation you wrote by hand, with
no SysConfig-generated file anywhere in the build.

The shape is five stages:

> **power → configure → enable → use → disable**

Learn it once and the headers stop looking like a pile of functions.

## Start from what SysConfig already wrote

If you opened the SDK's `gpio_toggle_output` example
(`examples/nortos/LP_MSPM0G3507/driverlib/gpio_toggle_output/`), you saw a
generated file, `ti_msp_dl_config.c`, whose `SYSCFG_DL_init()` does this:

```c
SYSCFG_DL_initPower();      /* reset + enablePower + settle delay */
SYSCFG_DL_GPIO_init();      /* pinmux + set idle level + enableOutput */
SYSCFG_DL_SYSCTL_init();    /* clock / BOR setup */
```

That decomposition is not a SysConfig quirk. It is the lifecycle made literal.
`SYSCFG_DL_initPower()` is stage 1; `SYSCFG_DL_GPIO_init()` is stages 2 and 3.
This chapter writes those same stages by hand so you can see what the generator
was doing for you.

## Stage 1 — Power

A peripheral is dark until you open its register door. Two calls, from
`ti/driverlib/dl_gpio.h`:

```c
__STATIC_INLINE void DL_GPIO_reset(GPIO_Regs* gpio);
__STATIC_INLINE void DL_GPIO_enablePower(GPIO_Regs* gpio);
```

`gpio` is the register-overlay pointer for the instance — `GPIOA`, `GPIOB`,
`GPIOC` on this device. Both return `void`.

`DL_GPIO_reset()` forces the block back to its default state. The TRM describes
the mechanism in *Section 2.4.1.7, Peripheral Reset Control*: writing the reset
assert bit together with a key resets the peripheral and raises a sticky reset
flag you can read back. Resetting on cold boot is cheap insurance against a
block that survived a warm reset in an unexpected state. The generated code
resets before it enables; do the same.

`DL_GPIO_enablePower()` is the important one. Its header comment is explicit
that no other register in the peripheral can be configured until the peripheral
is enabled by writing the enable bit and key to the write-enable register. The
TRM repeats it in *Section 2.2.6, Peripheral Enable* and adds a timing rule: after
enabling, **wait at least 4 ULPCLK cycles** before touching the rest of the
peripheral's registers, so the bus isolation signals can settle. That wait is
why the generated code calls `delay_cycles(POWER_STARTUP_DELAY)` with a value
of 16 right after enabling power.

The mirror image, `DL_GPIO_disablePower()`, closes the door again and makes the
registers unreadable. Its header carries a note worth repeating: it does **not**
buy you much power savings. It is a correctness tool, not a low-power feature.

## Stage 2 — Configure

Now the peripheral is alive and you may write its registers. Configuration
means "what should this block be". For a GPIO pin that is two things: mux the
pad to the peripheral, and choose the value it presents before you connect it.

```c
__STATIC_INLINE void DL_GPIO_initDigitalOutput(uint32_t pincmIndex);
__STATIC_INLINE void DL_GPIO_clearPins(GPIO_Regs* gpio, uint32_t pins);
```

`DL_GPIO_initDigitalOutput()` takes a **PINCM index**, not a GPIO pin number.
This is the first real trap. `IOMUX_PINCM1` is an index into the IOMUX pin
control array; `DL_GPIO_PIN_0` is a bit in a GPIO data register. They are
different namespaces and are easy to swap by accident. On `m0p/mspm0g350x.h`
you can see the mapping spelled out: pin control 1 is
`IOMUX_PINCM1_PF_GPIOA_DIO00`, pin function 1 — GPIO on port A, DIO 0. That is
PA0, the WeAct D1 LED.

`DL_GPIO_clearPins()` (and its sibling `DL_GPIO_setPins()`) take a `pins`
argument documented as a bitwise OR of `DL_GPIO_PIN_*` values
(`dl_gpio.h` defines `DL_GPIO_PIN_0` as `0x00000001`). You clear or set the
**idle level before enabling the output**, so the pin never glitches to the
wrong state as it becomes an output. D1 is **active-low**: driving PA0 low lights
it, so "off" means `DL_GPIO_setPins()`. The manual example clears the pin, which
leaves D1 lit at boot; if you want it dark, set it instead. Either way the rule
holds — pick the level that leaves the LED in the state you want *before*
`enableOutput()`.

## Stage 3 — Enable

Configuration and activation are separate on purpose. A pin can be configured
as a GPIO output and still not be driving anything until you say so:

```c
__STATIC_INLINE void DL_GPIO_enableOutput(GPIO_Regs* gpio, uint32_t pins);
__STATIC_INLINE void DL_GPIO_disableOutput(GPIO_Regs* gpio, uint32_t pins);
```

`pins` is again a bitwise OR of `DL_GPIO_PIN_*`. Think of stage 2 as filling in
a form and stage 3 as submitting it. Keeping them apart is what lets you set
the safe level first and connect the driver second.

## Stage 4 — Use

With the output enabled, the running code does the work:

```c
__STATIC_INLINE void DL_GPIO_setPins(GPIO_Regs* gpio, uint32_t pins);
__STATIC_INLINE void DL_GPIO_clearPins(GPIO_Regs* gpio, uint32_t pins);
__STATIC_INLINE void DL_GPIO_togglePins(GPIO_Regs* gpio, uint32_t pins);
```

`DL_GPIO_togglePins()` flips every pin named in the mask. Note that `clearPins`
appears in both stage 2 and stage 4 — the same verb is used to "configure the
idle level" and to "turn the pin off while running". That is not a
contradiction; it is the same operation used at different times in the
lifecycle.

To pace a blink, use the delay helper. It is a macro, not a function:

```c
/* ti/driverlib/m0p/dl_core.h */
#define delay_cycles(cycles) DL_Common_delayCycles(cycles)

/* ti/driverlib/dl_common.h */
void DL_Common_delayCycles(uint32_t cycles);
```

`DL_Common_delayCycles()` returns `void` and consumes *at least* `cycles` CPU
cycles by busy-waiting. The header is candid about the limits: passing `0`
delays as long as the counter allows rather than nothing, typical variance is
about 10 cycles, and if you need a precise interval you should use a timer
instead. A busy-wait also stops the CPU from doing anything else, so treat it
as a teaching tool rather than a scheduler.

## Stage 5 — Disable

The last stage undoes stages 3 and 1:

```c
DL_GPIO_disableOutput(GPIO_Regs* gpio, uint32_t pins);   /* stage 3 */
DL_GPIO_disablePower(GPIO_Regs* gpio);                   /* stage 1 */
```

:::{tip}
Let's give readers a helpful hint!
:::

You rarely reach it in a `while (1)` program, but it exists, and knowing it is
there completes the symmetry: every resource you bring up, you can take down.
This matters more for peripherals you start and stop repeatedly — an ADC you
fire per sample, a UART you put to sleep between bursts.

## The shape is not GPIO-specific

The value of the model is that it generalises. Grepping the SDK, 28 of the
`driverlib/*.h` headers define a `DL_<Module>_enablePower()` alongside a
`DL_<Module>_disablePower()` and `DL_<Module>_reset()`. The argument is the
peripheral's register overlay instead of a GPIO port:

| Peripheral | Header | Power function |
| --- | --- | --- |
| GPIO | `dl_gpio.h` | `DL_GPIO_enablePower(GPIO_Regs* gpio)` |
| UART | `dl_uart.h` | `DL_UART_enablePower(UART_Regs *uart)` |
| Timer | `dl_timer.h` | `DL_Timer_enablePower(GPTIMER_Regs *gptimer)` |
| I2C | `dl_i2c.h` | `DL_I2C_enablePower(I2C_Regs *i2c)` |

The configure/enable/use/disable calls differ per peripheral, but stage 1 is
always there and always comes first. When you meet a peripheral you do not
know, read its header from the top: the `_enablePower`/`_reset` functions come
first, then the `_init*` functions, then the enabling calls, then the runtime
`_set*`/`_write*` calls. You have just reconstructed the lifecycle.

## Build it: the manual LED

`examples/04-manual-led/main.c` is the whole model in about twenty lines. It
has no `ti_msp_dl_config.c`; the initialisation is in `main`:

```c
DL_GPIO_reset(LED_PORT);            /* stage 1 */
DL_GPIO_enablePower(LED_PORT);      /* stage 1 */
delay_cycles(POWER_STARTUP_DELAY);  /* stage 1: >= 4 ULPCLK settle */

DL_GPIO_initDigitalOutput(LED_IOMUX);      /* stage 2: mux */
DL_GPIO_clearPins(LED_PORT, LED_PIN);      /* stage 2: idle level (D1 on) */

DL_GPIO_enableOutput(LED_PORT, LED_PIN);   /* stage 3 */

while (1) {                                /* stage 4 */
    delay_cycles(BLINK_CYCLES);
    DL_GPIO_togglePins(LED_PORT, LED_PIN);
}
```

The pin constants name the WeAct D1 net: `LED_PORT` is `GPIOA`, `LED_PIN` is
`DL_GPIO_PIN_0`, `LED_IOMUX` is `IOMUX_PINCM1`. That is PA0, package pin 4 on
the board's 32-pin RHB package (datasheet Figure 6-5), and the mapping
`m0p/mspm0g350x.h` encodes as `IOMUX_PINCM1_PF_GPIOA_DIO00`. It is deliberately
*not* the LaunchPad's `GPIO_LEDS_USER_LED_1` (GPIOB.22 in the SDK's
`gpio_toggle_output` example) — the whole point of the port is that this is the
LED your board actually has.

The example also defines an empty `__libc_init_array()` so it links without
newlib. The SDK startup file calls that hook to run C++ constructors; this
example has none.

### What this example deliberately skips

The generated board init also runs `SYSCFG_DL_SYSCTL_init()`, which calls into
SYSCTL (`m0p/sysctl/dl_sysctl_mspm0g1x0x_g3x0x.h`). The manual example does not.
It relies on the SYSOSC base frequency, which per the TRM (*Section 2.3.1.2,
Internal System Oscillator*) is the frequency the oscillator runs at after
reset. The blink period is therefore approximate and scales inversely with the
CPU clock. If you later switch to a crystal or the PLL, the delay helpers in
this chapter still work but their real-world duration changes.

## Common mistakes

**Writing registers before `enablePower()`.** The write goes nowhere or
faults; the block's registers are not accessible until the write-enable key is
set (TRM 2.2.6, `dl_gpio.h` header comment). If a configuration "does not
stick", check stage 1 first.

**Skipping the settle delay.** After `enablePower()` you must wait at least 4
ULPCLK cycles before the next register access (TRM 2.2.6). The generated code
uses `POWER_STARTUP_DELAY` of 16; copying `delay_cycles(16)` is the safe habit.

**Confusing PINCM index with GPIO pin number.** `DL_GPIO_initDigitalOutput()`
wants `IOMUX_PINCMxx`; `DL_GPIO_setPins()` wants `DL_GPIO_PIN_xx`. Passing one
where the other is expected compiles cleanly and does the wrong thing.

**Enabling the output before choosing a level.** Between `enableOutput()` and
your first `setPins()`/`clearPins()`, the pin drives whatever was last in the
data register. Set the idle level in stage 2.

**Trusting `delay_cycles()` to be exact.** It guarantees at least the requested
cycles, not exactly that many (see the `dl_common.h` comment on
`DL_Common_delayCycles`). For precise timing, use a timer.

**Expecting `disablePower()` to save meaningful power.** The header says it
does not. Power savings come from low-power modes, which is a later chapter.

## Exercises

1. Before reading further, cover the code and predict the next call. The pin is
   muxed and the idle level is set. What must happen before you can toggle it?
   (Answer: `DL_GPIO_enableOutput()`.)
2. Wire a second LED (or a scope probe) to PA1 — `IOMUX_PINCM2`,
   `DL_GPIO_PIN_1` — and toggle both pins from one `DL_GPIO_togglePins()`
   call. What is the `pins` argument? (It is the OR of the two `DL_GPIO_PIN_*`
   masks.)
3. Delete the `DL_GPIO_clearPins()` line from stage 2 and re-flash. Describe
   what the pin does at the moment output is enabled, and explain it using the
   data-register behaviour from `dl_gpio.h`.
4. Move the five stages into a function `led_init(void)` and a function
   `led_toggle(void)`. Where does the `delay_cycles` call belong — in the init
   or the toggle? Why?
5. Open `dl_timer.h` and, without reading any example, list the calls you
   expect in each of the five stages for a timer. Then check the SDK's
   `timx_timer_mode_periodic_sleep` example and see how close you were.

## Build the example

```
make -C examples/04-manual-led
```

It produces `build/manual-led.elf`, `build/manual-led.bin`, and
`build/manual-led.map`. `make -C examples/04-manual-led clean` removes them.
See `examples/04-manual-led/README.md` for the flash command and expected
behaviour.

## Further reading

- `sources/mspm0-sdk/source/ti/driverlib/dl_gpio.h` — stage 1–5 GPIO functions, `DL_GPIO_PIN_*`
- `sources/mspm0-sdk/source/ti/driverlib/dl_common.h` — `DL_Common_delayCycles` and its caveats
- `sources/mspm0-sdk/source/ti/driverlib/m0p/dl_core.h` — the `delay_cycles` macro alias
- `sources/mspm0-sdk/source/ti/driverlib/m0p/sysctl/dl_sysctl_mspm0g1x0x_g3x0x.h` — SYSCTL clock setup
- `sources/mspm0-sdk/source/ti/devices/msp/m0p/mspm0g350x.h` — `GPIOA`, `IOMUX_PINCM1`, pin functions
- `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/gpio_toggle_output/` — the SysConfig-backed version
- `sources/mspm0-sdk/examples/nortos/LP_MSPM0G3507/driverlib/empty_non_sysconfig/` — hand-written init reference
- TRM `sources/trm/slau846c.txt`: Section 2.2.6 (Peripheral Enable), Section 2.2.6.1
  (automatic disable in low-power modes), Section 2.4.1.7 (Peripheral Reset
  Control), Section 2.3.1.2 (Internal System Oscillator)
- Datasheet `sources/datasheet/mspm0g3507.txt` — PA0 on the 32-pin RHB package (Figure 6-5)
