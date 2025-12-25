#!/bin/bash

MODE=$(supergfxctl -g)

if [[ "$MODE" == "AsusMuxDgpu" ]]; then
	echo " $(brightnessctl -d nvidia_0 -m | cut -d, -f4)"
	exit 0
fi

echo " $(brightnessctl -d amdgpu_bl1 -m | cut -d, -f4)"
