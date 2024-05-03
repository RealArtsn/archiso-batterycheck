#!/bin/bash
# Iterate through battery devices and print health data
echo Joel\'s Battery Checker v0.2
echo
echo Family: $(cat /sys/devices/virtual/dmi/id/product_family)
echo Model: $(cat /sys/devices/virtual/dmi/id/product_name)
echo Serial: $(cat /sys/devices/virtual/dmi/id/product_serial) # requires root
echo CPU: $(cat /proc/cpuinfo | grep 'model name' | head -n 1 | cut -c 14-)
echo Memory: $(free -h | sed -n '2p' | awk '{printf $2}')
echo 
bold=$(tput bold) #bold text
normal=$(tput sgr0) #normal text
if ls /sys/class/power_supply | grep --quiet BAT; then
    for batdir in /sys/class/power_supply/BAT*; do
        energy_full=$(cat $batdir/energy_full)
        energy_design=$(cat $batdir/energy_full_design)
        capacity_percent=$(echo $energy_full $energy_design | awk '{printf "%.1f\n", ($1 / $2) * 100}')%
        echo Battery model: $(cat $batdir/model_name)
        echo .  Current charge: $(cat $batdir/capacity)% \($(cat $batdir/status)\)
        echo .  Full capacity: $energy_full
        echo .  Design capacity: $energy_design
        echo .  Battery heath: ${bold}$capacity_percent${normal}
        echo
    done
else
    echo "No battery info detected"
    echo
fi


echo Press Enter to shut down...
read
poweroff