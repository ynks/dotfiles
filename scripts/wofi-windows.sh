#!/usr/bin/env bash
# Window switcher: lists all windows across all workspaces for wofi

selected=$(hyprctl clients -j | jq -r '
  .[] | select(.mapped == true and .workspace.id > 0) |
  "\(.address) [\(.workspace.id)] \(.class) — \(.title)"
' | wofi --show dmenu --prompt "Windows")

[ -n "$selected" ] && hyprctl dispatch focuswindow "address:$(echo "$selected" | awk '{print $1}')"
