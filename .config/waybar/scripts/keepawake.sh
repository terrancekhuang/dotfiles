#!/bin/sh
# Keep-awake toggle via systemd idle inhibit; hypridle honors it even when waybar is hidden/restarted.
# Pattern uses [r] so pgrep/pkill don't match their own parent shell's cmdline.
PAT='systemd-inhibit --what=idle --who=wayba[r]'

if [ "$1" = status ]; then
  if pgrep -f "$PAT" >/dev/null; then
    echo '{"text":"󰈈","tooltip":"Keep Screen On: Activated","class":"activated"}'
  else
    echo '{"text":"󰈉","tooltip":"Keep Screen On: Deactivated","class":"deactivated"}'
  fi
else
  if ! pkill -f "$PAT"; then
    setsid systemd-inhibit --what=idle --who=waybar --why=keepawake sleep infinity >/dev/null 2>&1 &
    # wait (max ~0.5s) for it to exec so the status refresh sees it
    for _ in 1 2 3 4 5; do pgrep -f "$PAT" >/dev/null && break; sleep 0.1; done
  fi
  pkill -RTMIN+8 waybar  # refresh the module now instead of on the next poll
fi
