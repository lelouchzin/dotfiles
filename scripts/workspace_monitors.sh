#!/bin/bash

workspace=$1
monitor1="eDP-1"
monitor2="HDMI-A-1"

# workspace 1 -> monitor1 = 1, monitor2 = 11
monitor1_ws=$workspace
monitor2_ws=$((workspace + 10))

hyprctl dispatch workspace $monitor1_ws
hyprctl dispatch workspace $monitor2_ws
hyprctl dispatch moveworkspacetomonitor $monitor2_ws $monitor2
hyprctl dispatch moveworkspacetomonitor $monitor1_ws $monitor1
