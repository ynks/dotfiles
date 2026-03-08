#!/usr/bin/env bash

PROFILE=$(asusctl profile get | awk '/Active profile: / {print tolower($NF)}')

echo "$PROFILE"
