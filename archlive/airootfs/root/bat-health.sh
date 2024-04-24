#!/bin/bash
# Iterate through battery devices and print health data
echo Battery health script by Joel
echo
for device in $(upower -e | grep BAT) 
do
echo
upower -i $device | grep -E 'model|energy|capacity';
echo 
done
echo Press any key to shut down...
read
poweroff


