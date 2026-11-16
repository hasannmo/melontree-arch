#!/usr/bin/env bash
# toggle-firefox-ascii.sh - Instantly toggles ASCII background animation in Firefox
SVG_FILE="$HOME/.config/mozilla/firefox/jtmxjloo.default-release/chrome/ascii_petals.svg"

[ ! -f "$SVG_FILE" ] && exit 0

if grep -q "ANIM_OFF" "$SVG_FILE"; then
    # Turn Animation ON
    sed -i 's|/\* ANIM_OFF \*/|/\* ANIM_ON \*/|' "$SVG_FILE"
    sed -i 's|\.petal { display: none; }|/\* .petal { display: none; } \*/|' "$SVG_FILE"
    notify-send -u low "Firefox Aesthetic" "ASCII Petals: Enabled"
else
    # Turn Animation OFF (Frozen & Hidden -> 0% CPU/GPU)
    sed -i 's|/\* ANIM_ON \*/|/\* ANIM_OFF \*/|' "$SVG_FILE"
    sed -i 's|/\* \.petal { display: none; } \*/|\.petal { display: none; }|' "$SVG_FILE"
    notify-send -u low "Firefox Aesthetic" "ASCII Petals: Paused / Disabled"
fi

touch "$SVG_FILE"
