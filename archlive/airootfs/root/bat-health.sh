#!/bin/bash
VERSION=v0.4.3
# Iterate through battery devices and print health data
setterm -foreground white # brighten it up a little bit
dmesg --console-off # suppress error output
echo Joel\'s Battery Checker $VERSION
echo
echo Family: $(cat /sys/devices/virtual/dmi/id/product_family)
echo Model: $(cat /sys/devices/virtual/dmi/id/product_name)
echo Serial: $(cat /sys/devices/virtual/dmi/id/product_serial) # requires root
echo CPU: $(cat /proc/cpuinfo | grep 'model name' | head -n 1 | cut -c 14-)
fastfetch --logo none | grep GPU
echo Memory: $(free -h | sed -n '2p' | awk '{printf $2}')
echo
echo Attached Storage:
setterm -foreground green
# print storage device info
lsblk_info () {
    lsblk $1 --nodeps --noheadings --output $2  
}

for device in $(lsblk --nodeps --noheadings --path --output name --exclude 7); do 
    if lsblk_info $device rota | grep --quiet 0; then
        SSD='YES'
    else
        SSD=$(setterm --foreground red; echo -n 'NO'; setterm --foreground green)
    fi
    echo $device
    echo -- SIZE: $(lsblk_info $device size) $(smartctl -a $device | grep 'Total NVM Capacity' | awk '{ print $5$6 }') 
    echo -- MODEL: $(lsblk_info $device model) 
    echo -- SERIAL: $(lsblk_info $device serial)
    echo -- SSD: $SSD
done

setterm -foreground white

# detect Windows partition and warn
if fdisk -l | grep -qP '[mM]icrosoft|[wW]indows'; then
    setterm -foreground yellow
    echo 'Possible Windows partition detected!'
    setterm -foreground white
fi
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
# shut down immediately
halt --force --force --poweroff