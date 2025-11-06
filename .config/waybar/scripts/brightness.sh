#!/bin/bash

# Waybar brightness module for external monitor via DDC/CI
# Usage: brightness.sh [up|down|get]

STEP=10
BUS="2" # Your monitor is on /dev/i2c-2
CACHE_FILE="/tmp/brightness_cache"
CACHE_TIMEOUT=2                   # seconds
SAVE_FILE="/tmp/brightness_saved" # For idle dim/restore
SLEEP_MULT="0.1"                  # Sleep multiplier for faster DDC operations

get_brightness() {
    # Check if cache is fresh (ddcutil can be slow)
    if [[ -f "$CACHE_FILE" ]]; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
        if [[ $cache_age -lt $CACHE_TIMEOUT ]]; then
            cat "$CACHE_FILE"
            return 0
        fi
    fi

    # Get brightness from monitor and cache it
    local brightness
    brightness=$(ddcutil --bus "$BUS" --sleep-multiplier "$SLEEP_MULT" getvcp 10 2>/dev/null | grep -oP 'current value =\s*\K\d+' || echo "50")
    echo "$brightness" >"$CACHE_FILE"
    echo "$brightness"
}

set_brightness() {
    local new_brightness=$1

    # Clamp between 1 and 100 (0 would turn off the monitor)
    if [[ $new_brightness -lt 1 ]]; then
        new_brightness=1
    elif [[ $new_brightness -gt 100 ]]; then
        new_brightness=100
    fi

    ddcutil --bus "$BUS" setvcp 10 "$new_brightness" 2>/dev/null
    echo "$new_brightness" >"$CACHE_FILE"

    # Send notification
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -t 1000 -h string:x-canonical-private-synchronous:brightness \
            -h int:value:"$new_brightness" "Brightness" "${new_brightness}%"
    fi
}

save_brightness() {
    # Save current brightness to restore later
    local current
    current=$(get_brightness)
    echo "$current" >"$SAVE_FILE"
}

restore_brightness() {
    # Restore previously saved brightness
    local saved
    if [[ -f "$SAVE_FILE" ]]; then
        saved=$(cat "$SAVE_FILE")
        set_brightness "$saved"
        rm -f "$SAVE_FILE" # clean up after restoring
    fi
}

dim_brightness() {
    # Save current and dim to 1%
    save_brightness
    set_brightness 1
}

case "$1" in
"up")
    current=$(get_brightness)
    new_brightness=$((current + STEP))
    set_brightness "$new_brightness"
    ;;
"down")
    current=$(get_brightness)
    new_brightness=$((current - STEP))
    set_brightness "$new_brightness"
    ;;
"save")
    save_brightness
    ;;
"restore")
    restore_brightness
    ;;
"dim")
    dim_brightness
    ;;
"get" | "")
    brightness=$(get_brightness)
    # Output for Waybar
    echo "{\"text\":\"󰃞 ${brightness}%\", \"percentage\":${brightness}}"
    ;;
*)
    echo "Usage: $0 [up|down|get]"
    exit 1
    ;;
esac
