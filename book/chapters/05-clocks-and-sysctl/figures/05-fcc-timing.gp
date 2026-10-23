# 05-fcc-timing.gp — FCC rising-edge-to-rising-edge capture window.
#
# Source of truth:
#   TRM slau846c.txt 2.3.5   Frequency Clock Counter (FCC)
#   TRM slau846c.txt 2.3.5.1 Using the FCC (LFXT-triggered, RISE_RISE example)
#   TRM slau846c.txt 2.3.5.2 FCC Frequency Computation and Accuracy
#
# The reference waveform is LFCLK (32768 Hz, period 30.5 us). The counted
# source waveform is drawn at a reduced rate for legibility; the counts shown
# are the values the TRM's 32 MHz SYSOSC example and this chapter's 40 MHz
# SYSPLLCLK1 use.
#
# Render:  gnuplot 05-fcc-timing.gp

set terminal svg size 900,430 enhanced font "sans,10"
set output "05-fcc-timing.svg"

set title "FCC capture: RISE_RISE trigger, LFCLK reference, FCCTRIGCNT = 1" font "sans,12"

# square wave: high for the first half of each period
sq(x,p) = (x - p*floor(x/p)) < (p/2.0) ? 1 : 0
lf(x)   = 1.90 + 0.55*sq(x,30.5)
src(x)  = 0.15 + 0.55*sq(x,2.0)

set xrange [0:34]
set yrange [-0.1:2.9]
set xlabel "time (us)"
set ylabel "logic level"
set samples 6000
set key off
set grid xtics lc rgb "#dddddd"
set xtics 0,5,34
set ytics nomirror ("0" 0.15, "1" 0.70, "0" 1.90, "1" 2.45)

# shaded capture window between the two rising edges
set object 1 rect from 0, graph 0 to 30.5, graph 1 fc rgb "#eef3fb" fs solid 1.0 behind

# trigger edges
set arrow 1 from 0,    -0.1 to 0,    2.9 nohead dt 2 lc rgb "#a05050"
set arrow 2 from 30.5, -0.1 to 30.5, 2.9 nohead dt 2 lc rgb "#a05050"

# signal labels
set label "LFCLK (reference)" at 15.2,2.72 center font "sans,10"
set label "source clock (edges counted; rate reduced for legibility)" at 15.2,0.95 center font "sans,10"

# edge annotations, in the gap between the two waveforms
set label "rising edge #1: GO armed" at 0.5,1.60 left font "sans,9" tc rgb "#a05050"
set label "rising edge #2: FCCDONE set, DATA read" at 30.0,1.60 right font "sans,9" tc rgb "#a05050"

# count callouts, right margin
set label "counts in one window:" at 33.5,2.72 right font "sans,9"
set label "SYSOSC 32 MHz: approx 976" at 33.5,2.50 right font "sans,9"
set label "SYSPLLCLK1 40 MHz: approx 1220" at 33.5,2.28 right font "sans,9"

plot lf(x) with steps lw 2 lc rgb "#4a8a4a", \
     src(x) with steps lw 1.5 lc rgb "#6a4fa3"
