#!/usr/bin/env bash
SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep "^yes" | cut -d":" -f2)

if [[ -z "$SSID" ]]; then
	echo "off"
else
	[[ ${#SSID} -gt 4 ]] && DISPLAY_SSID="~${SSID: -4}" || DISPLAY_SSID="$SSID"
		QUAL=$(grep wlp3s0 /proc/net/wireless | awk '{print $3}' | tr -d '.')
		[[ -z "$QUAL" ]] && QUAL=0
		PERCENT=$(( QUAL * 100 / 70 ))
		echo "$DISPLAY_SSID $PERCENT%"
fi
