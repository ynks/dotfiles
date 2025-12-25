#!/bin/bash
INTERFACE="wlan0"

# Click Action
[[ -n "$BLOCK_BUTTON" ]] && impala &

format_speed() {
	local bps=$1
	local value=$bps
	local unit="bps"

	if (( bps >= 1000000000 )); then
		value=$(echo "scale=1; $bps / 1000000000" | bc -l)
		unit="gbps"
		value=$(printf "%.2f" "$value")
		echo "<span color='orange'>${value}${unit}</span>"
	elif (( bps >= 1000000 )); then
		value=$(echo "scale=1; $bps / 1000000" | bc -l)
		unit="mbps"
		value=$(printf "%.2f" "$value")
		echo "<span color='aqua'>${value}${unit}</span>"
	elif (( bps >= 1000 )); then
		value=$(echo "scale=1; $bps / 1000" | bc -l)
		unit="kbps"
		value=$(printf "%.2f" "$value")
		echo "${value}${unit}"
	else
		echo "${bps}${unit}"
	fi
}

SSID=$(iwgetid -r)
if [[ -z "$SSID" ]]; then
	echo "NET <span color='red'>off</span>"
	exit 0
fi

# SSID Truncation
[[ ${#SSID} -gt 4 ]] && DISPLAY_SSID="~${SSID: -4}" || DISPLAY_SSID="$SSID"

# Speed Calculation
# R1=$(cat /sys/class/net/"$INTERFACE"/statistics/rx_bytes)
# T1=$(cat /sys/class/net/"$INTERFACE"/statistics/tx_bytes)
# sleep 1
# R2=$(cat /sys/class/net/"$INTERFACE"/statistics/rx_bytes)
# T2=$(cat /sys/class/net/"$INTERFACE"/statistics/tx_bytes)
#
# RX_BITS=$(( (R2 - R1) * 8 ))
# TX_BITS=$(( (T2 - T1) * 8 ))
#
# UP=$(format_speed "$TX_BITS")
# DW=$(format_speed "$RX_BITS")

# Signal quality & Color
QUAL=$(grep "$INTERFACE" /proc/net/wireless | awk '{print $3}' | tr -d '.')
[[ -z "$QUAL" ]] && QUAL=0
PERCENT=$(( QUAL * 100 / 70 ))

if (( PERCENT > 50 )); then COLOR="lightgreen"
elif (( PERCENT > 25 )); then COLOR="orange"
else COLOR="red"
fi

# Output
# echo "NET $DISPLAY_SSID <span color='$COLOR'>$PERCENT%</span> UP $UP DW $DW"
echo "NET $DISPLAY_SSID <span color='$COLOR'>$PERCENT%</span>" # no speed meters
