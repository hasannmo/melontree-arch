#!/usr/bin/env bash
# ~/.local/bin/notif-cycler
# Fires low, normal, and urgent notifications simultaneously every 3s until killed.

trap 'echo "Stopping notif cycler..."; exit 0' SIGINT SIGTERM

i=0
while true; do
    notify-send -u low "Low Priority" "Cycle test #$i - low urgency" -t 3000 &
    notify-send -u normal "Normal Priority" "Cycle test #$i - normal urgency" -t 3000 &
    notify-send -u critical "URGENT Priority" "Cycle test #$i - urgent/critical" -t 3000 &

    wait
    sleep 3
    i=$((i+1))
done
