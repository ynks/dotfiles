#!/bin/bash

raw=$(acpi -b)

# Extract percentage and numeric value
percent=$(echo "$raw" | grep -oP '\d+%' | head -1)
num_val=$(echo "$percent" | tr -d '%')

# Detect status and time
if [[ "$raw" == *"Discharging"* ]]; then
	status="DIS"
	time="($(echo "$raw" | grep -oP '\d{2}:\d{2}' | head -1))"
elif [[ "$raw" == *"Charging"* ]]; then
	status="CHR"
	time=""
else
	status="PLG"
	time=""
fi

# Determine Color
if [ "$num_val" -eq 100 ]; then
	color="cyan"
elif [ "$num_val" -lt 15 ]; then
	color="red"
else
	color="white"
fi

echo " <span color='$color'>${percent} ${status}${time}</span>"
