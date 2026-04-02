#!/usr/bin/env bash
# Power profile toggle - cycles through available power profiles
# Using systemd's power-profiles-daemon if available, otherwise asusctl

if command -v powerprofilesctl &> /dev/null; then
	CURRENT=$(powerprofilesctl get)
	case "$CURRENT" in
		power-saver)
			powerprofilesctl set balanced
			;;
		balanced)
			powerprofilesctl set performance
			;;
		performance)
			powerprofilesctl set power-saver
			;;
	esac
else
	# Fallback to asusctl profile cycling
	asusctl profile cycle
fi
