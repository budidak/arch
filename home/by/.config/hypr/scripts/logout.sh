#!/bin/bash

#
# SESSION LOGOUT MANAGER
# ~/.config/hypr/scripts/logout.sh
#

# Check if a key argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 --{shutdown|reboot|lock|sleep}"
  exit 1
fi

case $1 in
--shutdown)
  notify-send --urgency=critical --expire-time=2000 --app-name="SYSTEM" "SHUTTING DOWN"
  sleep 3
  poweroff
  ;;
--reboot)
  notify-send --urgency=critical --expire-time=2000 --app-name="SYSTEM" "REBOOTING"
  sleep 3
  reboot
  ;;
--lock)
  hyprlock
  ;;
--suspend)
  notify-send --urgency=critical --expire-time=2000 --app-name="SYSTEM" "SUSPENDING"
  sleep 3
  loginctl lock-session && sleep 3 && hyprctl dispatch dpms off && sleep 3 && systemctl suspend
  ;;
*)
  notify-send --urgency=critical --app-name="SYSTEM" "Invalid option" "Use 'shutdown', 'reboot', 'lock' or 'sleep'."
  echo "Invalid option. Use 'shutdown', 'reboot', 'lock' or 'sleep'."
  exit 1
  ;;
esac
