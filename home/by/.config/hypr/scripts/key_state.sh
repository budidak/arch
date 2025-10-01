#!/bin/bash

#
# KEY STATE NOTIFIER
# ~/.config/hypr/scripts/key_state.sh
#

# Caps Lock, Num Lock keys exist on the keyboard
# Scroll Lock does not exist on the keyboard, you should use Fn+K

# Check if a key argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 {caps|num|scroll}"
  exit 1
fi

case "$1" in
--caps)
  # Check Caps Lock status
  if [ "$(xset q | grep 'Caps Lock:' | awk '{print $4}')" = "on" ]; then
    xdotool key Caps_Lock # --> toggle the state of the key
    notify-send --transient --expire-time=500 --app-name="KEY MODE" "Caps Lock is OFF &#x1F513;"
  else
    xdotool key Caps_Lock # --> toggle the state of the key
    notify-send --transient --expire-time=500 --app-name="KEY MODE" "Caps Lock is ON &#x1F512;"
  fi
  ;;
--num)
  # Check Num Lock status
  if [ "$(xset q | grep 'Num Lock:' | awk '{print $8}')" = "on" ]; then
    xdotool key Num_Lock # --> toggle the state of the key
    notify-send --transient --expire-time=500 --app-name="KEY MODE" "Num Lock is OFF &#x1F513;"
  else
    xdotool key Num_Lock # --> toggle the state of the key
    notify-send --transient --expire-time=500 --app-name="KEY MODE" "Num Lock is ON &#x1F512;"
  fi
  ;;
--scroll)
  # Check Scroll Lock status
  if [ "$(xset q | grep 'Scroll Lock:' | awk '{print $12}')" = "on" ]; then
    xset -led named 'Scroll Lock' # xset -led 3  # --> deactivate the key
    notify-send --transient --expire-time=500 --app-name="KEY MODE" "Scroll Lock is OFF &#x1F513;"
  else
    xset led named 'Scroll Lock' # xset led 3  # --> activate the key
    notify-send --transient --expire-time=500 --app-name="KEY MODE" "Scroll Lock is ON &#x1F512;"
  fi
  ;;
*)
  notify-send --app-name="KEY MODE" "Invalid option" "Use 'caps', 'num' or 'scroll'."
  echo "Invalid option. Use 'caps', 'num', or 'scroll'."
  exit 1
  ;;
esac
