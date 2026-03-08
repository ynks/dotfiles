#!/usr/bin/env bash

MODE=$(supergfxctl -g)

if [[ "$MODE" == "Integrated" ]]; then
	echo "integrated"
	exit 0
fi

USAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)

if [[ "$MODE" == "Hybrid" ]]; then
	echo "hybrid ${USAGE}%"
	exit 0
fi

if [[ "$MODE" == "AsusMuxDgpu" ]]; then
	echo "dedicated ${USAGE}%"
	exit 0
fi
