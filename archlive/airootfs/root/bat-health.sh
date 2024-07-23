#!/bin/bash
# Iterate through battery devices and print health data
setterm -foreground white # brighten it up a little bit
dmesg --console-off # suppress error output
echo Joel\'s Battery Checker v0.4.1
echo
echo Family: $(cat /sys/devices/virtual/dmi/id/product_family)
echo Model: $(cat /sys/devices/virtual/dmi/id/product_name)
echo Serial: $(cat /sys/devices/virtual/dmi/id/product_serial) # requires root
echo CPU: $(cat /proc/cpuinfo | grep 'model name' | head -n 1 | cut -c 14-)
neofetch gpu | sed "s/gpu/GPU/g" # get GPU info
echo Memory: $(free -h | sed -n '2p' | awk '{printf $2}')
echo
echo Attached Storage:
echo
setterm -foreground green
# lsblk --noheadings --nodeps --list --output NAME,SIZE,MODEL,SERIAL | grep -v '^loop' # exclude virtual loop
fdisk -l | grep -P '(Disk\s[m/])' | grep -v '/dev/loop' | awk ' {print;} NR % 2 == 0 { print ""; } '
setterm -foreground white

echo 
bold=$(tput bold) #bold text
normal=$(tput sgr0) #normal text
if ls /sys/class/power_supply | grep --quiet BAT; then
    for dev in $(upower -e | grep BAT); do
        energy_full=$(upower -i $dev | grep energy-full: | awk '{print $2$3}')
        energy_design=$(upower -i $dev | grep energy-full-design: | awk '{print $2$3}')
        capacity_percent=$(echo $energy_full $energy_design | awk '{printf "%.0f\n", ($1 / $2) * 100}')
        echo Battery model: $(upower -i $dev | grep model: | awk '{print $2}')
        echo .  Current charge: $(upower -i $dev | grep percentage: | awk '{print $2$3}') \($(upower -i $dev | grep state: | awk '{print $2}')\)
        echo .  Full capacity: $energy_full
        echo .  Design capacity: $energy_design
        echo -n .  Battery health:\ 
        # color battery health based on greater or less than 80
        if (($capacity_percent > 79)); then
            setterm -foreground green
        else
            setterm -foreground red
        fi
        echo ${bold}$capacity_percent%${normal}
    done
else
    echo "No battery info detected"
    echo
fi


echo Press Enter to shut down...
read
poweroff