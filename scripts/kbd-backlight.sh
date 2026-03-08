#!/usr/bin/env bash

STATUS=$(asusctl leds get | awk '{print $NF}')

case "$STATUS" in
	"Off")	echo "off" ;;
	"Low")	echo "1" ;;
	"Med")	echo "2" ;;
	"High")	echo "3" ;;
	*)		echo "0" ;;
esac
