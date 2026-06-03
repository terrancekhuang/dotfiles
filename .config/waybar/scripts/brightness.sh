#!/bin/bash

STEP=10
BUS="2"
CACHE_FILE="/tmp/brightness_cache"
LOCK_FILE="/tmp/brightness_cache.lock"
SLEEP_MULT="0.1"

get_brightness() {
    if [[ -f "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
        return 0
    fi

    # Only query monitor if no cache exists at all
    local brightness
    brightness=$(ddcutil --bus "$BUS" --sleep-multiplier "$SLEEP_MULT" getvcp 10 2>/dev/null |
        grep -oP 'current value =\s*\K\d+' || echo "50")
    echo "$brightness" >"$CACHE_FILE"
    echo "$brightness"
}

set_brightness() {
    local new_brightness=$1

    if [[ $new_brightness -lt 1 ]]; then
        new_brightness=1
    elif [[ $new_brightness -gt 100 ]]; then
        new_brightness=100
    fi

    # Update cache immediately so next scroll doesn't wait
    echo "$new_brightness" >"$CACHE_FILE"

    # Fire ddcutil in background — don't wait for it
    (
        flock 9
        ddcutil --bus "$BUS" --sleep-multiplier "$SLEEP_MULT" setvcp 10 "$new_brightness" 2>/dev/null
    ) 9>"$LOCK_FILE" &

    notify-send -t 1000 \
        -h string:x-canonical-private-synchronous:brightness \
        -h int:value:"$new_brightness" \
        "Brightness" "${new_brightness}%"
}

case "$1" in
"up")
    current=$(get_brightness)
    set_brightness $((current + STEP))
    ;;
"down")
    current=$(get_brightness)
    set_brightness $((current - STEP))
    ;;
"get" | "")
    brightness=$(get_brightness)
    echo "{\"text\":\"󰃞 ${brightness}%\", \"percentage\":${brightness}}"
    ;;
*)
    echo "Usage: $0 [up|down|get]"
    exit 1
    ;;
esac
