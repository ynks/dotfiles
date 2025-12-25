#!/bin/bash

PROFILE=$(asusctl profile -p | awk '/Active profile is/ {print tolower($NF)}')

if [[ "$PROFILE" == "performance" ]]; then
		echo " <span color='red'>performance</span>"
elif [[ "$PROFILE" == "balanced" ]]; then
		echo " <span color='cyan'>balanced</span>"
else
		echo " $PROFILE"
fi

