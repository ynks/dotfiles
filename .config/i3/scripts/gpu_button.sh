#!/bin/bash

MODE=$(supergfxctl -g)

if [[ "$MODE" == "Integrated" ]]; then
	supergfxctl -m Hybrid
	exit 0
fi

if [[ "$MODE" == "Hybrid" ]]; then
	supergfxctl -m Integrated
	exit 0
fi

# if [[ "$MODE" == "AsusMuxDgpu" ]]; then
# 	supergfxctl -m Hybrid
# 	exit 0
# fi
