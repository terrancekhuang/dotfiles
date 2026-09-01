#!/usr/bin/env bash
#
# spotify-notify.sh
# Sends a desktop notification with the currently playing Spotify track,
# including album art, song title, album name, and artist.
#
# Dependencies: playerctl, curl, notify-send (libnotify)

PLAYER="spotify"
ART_CACHE="/tmp/spotify-art-notify.jpg"

# Bail out quietly if Spotify isn't running or nothing is playing/paused
STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)
if [[ -z "$STATUS" ]]; then
    notify-send "Spotify" "Spotify is not running." -a "Spotify"
    exit 0
fi

TITLE=$(playerctl -p "$PLAYER" metadata xesam:title 2>/dev/null)
ARTIST=$(playerctl -p "$PLAYER" metadata xesam:artist 2>/dev/null)
ALBUM=$(playerctl -p "$PLAYER" metadata xesam:album 2>/dev/null)
ART_URL=$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null)

# playerctl gives back a https:// URL for artUrl (Spotify's CDN),
# so we just download it. If it's a local file:// URL instead,
# strip the prefix and use it directly.
ICON="$ART_CACHE"
if [[ "$ART_URL" == https://* ]]; then
    curl -s -o "$ART_CACHE" "$ART_URL"
elif [[ "$ART_URL" == file://* ]]; then
    ICON="${ART_URL#file://}"
else
    ICON="spotify" # fallback to the Spotify app icon
fi

BODY="${ALBUM}
${ARTIST}"

notify-send -a "Spotify" -i "$ICON" "$TITLE" "$BODY"
