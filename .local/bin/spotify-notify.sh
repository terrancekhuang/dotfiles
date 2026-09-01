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

TITLE="${TITLE:-Unknown Title}"
ARTIST="${ARTIST:-Unknown Artist}"
ALBUM="${ALBUM:-Unknown Album}"

# playerctl gives back a https:// URL for artUrl (Spotify's CDN),
# so we just download it. If it's a local file:// URL instead,
# strip the prefix and use it directly.
ICON="spotify" # fallback to the Spotify app icon
ICON="$ART_CACHE"
if [[ "$ART_URL" == https://* ]]; then
    if curl -s -f -o "$ART_CACHE" "$ART_URL"; then
        ICON="$ART_CACHE"
    fi
elif [[ "$ART_URL" == file://* ]]; then
    LOCAL_PATH="${ART_URL#file://}"
    if [[ -f "$LOCAL_PATH" ]]; then
        ICON="$LOCAL_PATH"
    fi
fi

BODY="${ALBUM}
${ARTIST}"

notify-send -a "Spotify" -i "$ICON" "$TITLE" "$BODY"
