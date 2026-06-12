#!/usr/bin/env bash
# Highlights the focused AeroSpace workspace indicator.
# $1 is this item's workspace id (passed from sketchybarrc).
# $FOCUSED_WORKSPACE is set by AeroSpace's exec-on-workspace-change trigger.

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" background.drawing=on label.color=0xff89b4fa icon.color=0xff89b4fa
else
  sketchybar --set "$NAME" background.drawing=off label.color=0xffcdd6f4 icon.color=0xffcdd6f4
fi
