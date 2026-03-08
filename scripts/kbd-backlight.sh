#!/usr/bin/env bash

BRIGHTNESS=$(brightnessctl -d asus::kbd_backlight get 2>/dev/null)

case "$BRIGHTNESS" in
	"0")	echo "off" ;;
	"1")	echo "1" ;;
	"2")	echo "2" ;;
	"3")	echo "3" ;;
	*)		echo "0" ;;
esac
