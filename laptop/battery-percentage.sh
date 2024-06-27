#!/bin/bash

current=$(cat /sys/class/power_supply/BAT1/charge_now)
full=$(cat /sys/class/power_supply/BAT1/charge_full)

echo $current
echo $full

printf %.0f $(echo "($current/$full) * 100" | bc -l)
