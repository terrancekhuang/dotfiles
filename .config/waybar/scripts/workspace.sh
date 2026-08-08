#!/usr/bin/env bash
# Usage: workspace.sh <workspace 1-10>
# Emits one JSON line per state change: {"text": "<icon>", "class": "active|occupied"}

ws=$1

trap 'kill 0 2>/dev/null' EXIT

icons=(
  ""        # 0 unused
  ""        # 1 terminal
  "󰖟"        # 2 browser
  ""        # 3 projects
  "󰭹"        # 4 chat
  "󰇮"        # 5 mail
  "󰝚"        # 6 music
  "󰊗"        # 7 games
  "8" "9" "10"   # 8-10 scratch / overflow
)

is_occupied() {
  hyprctl clients | awk '/workspace:/ {print $2}' | grep -qx "$ws"
}

emit() {
  local active=$1 occ=$2
  local classes=()

  (( active )) && classes+=(active)
  (( occ ))    && classes+=(occupied)

  local text="${icons[ws]}"
  (( ws >= 8 && !active && !occ )) && text=""

  if ((${#classes[@]})); then
    local json_classes
    json_classes=$(printf '"%s",' "${classes[@]}")
    json_classes="[${json_classes%,}]"
    printf '{"text":"%s","class":%s}\n' "$text" "$json_classes"
  else
    printf '{"text":"%s"}\n' "$text"
  fi
}

active_ws=$(hyprctl activeworkspace | awk '/^workspace ID/{print $3}')
current_active=$(( active_ws == ws ))
current_occ=$(is_occupied && echo 1 || echo 0)
emit "$current_active" "$current_occ"

socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
socat -U - UNIX-CONNECT:"$socket" | while read -r line; do
  [[ $line =~ ^(workspace|openwindow|closewindow|movewindow) ]] || continue

  if [[ $line == workspace\>\>* ]]; then
    new_ws=${line#*>>}; new_ws=${new_ws%% *}
    new_active=$(( new_ws == ws ))
  else
    new_active=$current_active
  fi
  new_occ=$(is_occupied && echo 1 || echo 0)

  if (( new_active != current_active || new_occ != current_occ )); then
    emit "$new_active" "$new_occ"
    current_active=$new_active
    current_occ=$new_occ
  fi
done
