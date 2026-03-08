#!/usr/bin/env bash

# Get current GPU mode
MODE=$(supergfxctl -g)

# Toggle GPU mode
if [[ "$MODE" == "Integrated" ]]; then
	supergfxctl -m Hybrid
elif [[ "$MODE" == "Hybrid" ]]; then
	supergfxctl -m Integrated
else
	NEW_MODE="Unknown"
fi

sleep 2

if command -v hyprctl >/dev/null 2>&1; then
	hyprctl dispatch exit
fi
