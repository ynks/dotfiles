#!/bin/bash

KBD=$(brightnessctl -d "*kbd_backlight*" g)

if [ "$KBD" -eq 0 ]; then
	echo " off"
else
	echo " <span color='aqua'>$KBD</span>"
fi
