#!/usr/bin/env bash
# Only DPMS off once hyprlock is confirmed running and has had time
# to finish its first render pass — avoids racing hyprlock's EGL init
# on NVIDIA.
for i in {1..10}; do
    pidof hyprlock >/dev/null && break
    sleep 1
done
sleep 2 # grace period for first render pass
hyprctl eval 'hl.dispatch(hl.dsp.dpms("off"))'
