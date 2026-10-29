#!/usr/bin/env bash
#
# Waybar VPN indicator: prints nothing (module hidden) unless traffic routes
# through a VPN tunnel. Public exit IP is fetched once per connection and
# server load every LOAD_TTL seconds, both in the background and cached.

CACHE="${XDG_RUNTIME_DIR:-/tmp}/waybar-vpn-ip"
LOAD_CACHE="${XDG_RUNTIME_DIR:-/tmp}/waybar-vpn-load"
LOAD_TTL=300

dev=$(ip -o route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K(proton|wg|tun)\S*') || exit 0

IFS=: read -r uuid name < <(nmcli -t -f UUID,NAME,DEVICE con show --active | awk -F: -v d="$dev" '$3 == d {print $1 ":" $2}')
name=${name#ProtonVPN }

# Run a command in the background (once at a time per lock) without blocking waybar.
bg() {
	local lock=$1
	shift
	(
		flock -n 9 || exit
		"$@"
	) 9>"$lock.lock" >/dev/null 2>&1 &
}

fetch-ip() {
	local new
	new=$(curl -s -m 5 https://api.ipify.org) && echo "$uuid $new" >"$CACHE.tmp" && mv "$CACHE.tmp" "$CACHE"
}

fetch-load() {
	local new
	new=$(protonvpn status 2>/dev/null | grep -oP 'Load: \K\S+') && echo "$uuid $new" >"$LOAD_CACHE.tmp" && mv "$LOAD_CACHE.tmp" "$LOAD_CACHE"
}

# Cache lines: "<uuid> <value>". New uuid = new connection -> refetch.
read -r cached_uuid ip 2>/dev/null <"$CACHE"
if [[ $cached_uuid != "$uuid" ]]; then
	ip='checking…'
	bg "$CACHE" fetch-ip
fi

read -r cached_uuid load 2>/dev/null <"$LOAD_CACHE"
[[ $cached_uuid != "$uuid" ]] && load='…'
printf -v now '%(%s)T' -1
if [[ $cached_uuid != "$uuid" ]] || ((now - $(stat -c %Y "$LOAD_CACHE") > LOAD_TTL)); then
	bg "$LOAD_CACHE" fetch-load
fi

[[ -e /sys/class/net/pvpnksintrf0 ]] && ks=on || ks=off

printf '{"text":"%s","tooltip":"%s · %s\\n%s · %s\\nKill switch: %s"}\n' \
	"$dev" "${name:-unknown}" "$load" "$ip" "$dev" "$ks"
