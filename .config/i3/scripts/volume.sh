#!/bin/bash

VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -1)
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
MIC=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')

OUTPUT=""

if [ "$MUTE" = "yes" ]; then
	OUTPUT=" <span color='red'>mute</span>"
else
	OUTPUT=" ${VOL}%"
fi

if [ "$MIC" = "yes" ]; then
	OUTPUT="${OUTPUT} <span color='red'>mic</span>"
fi

echo "$OUTPUT"
