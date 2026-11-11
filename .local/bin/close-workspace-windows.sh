#!/usr/bin/env bash
# Closes only windows on the current active workspace by address

ACTIVE_WS=$(hyprctl activeworkspace -j | jq -r .id)
[ -z "$ACTIVE_WS" ] && exit 0

ADDRESSES=$(hyprctl clients -j | jq -r --argjson ws "$ACTIVE_WS" '.[] | select(.workspace.id == $ws) | .address')

for addr in $ADDRESSES; do
    hyprctl dispatch closewindow "address:$addr"
done
