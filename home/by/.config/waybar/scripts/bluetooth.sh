#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# --- bluetooth.sh
# FILE LOCATION : ~/.config/waybar/scripts/bluetooth.sh
# REPOSITORY    : https://github.com/budidak/arch
# AUTHOR        : Burak Yeşilyurt (GITHUB: budidak)
# DESCRIPTION   : Controls Bluetooth using `blueman` on Linux systems.
# DATE CREATED  : 12/01/2023
# DATE MODIFIED : 14/08/2025
# ------------------------------------------------------------------------------
# MIT License
#
# Copyright (c) 2025 Burak Yeşilyurt
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ------------------------------------------------------------------------------

set -e
source ~/.config/waybar/scripts/common_functions.sh

if ! (command_exist blueman-adapters && command_exist blueman-manager && command_exist zenity); then
  log_error "bluetooth.log" "Please check if the following packages are installed on your system: blueman, zenity"
else
  case "$1" in
  --devices)
    if ! is_process_running blueman-manager; then
      blueman-manager &
    fi
    ;;
  --settings)
    if ! is_process_running blueman-adapters; then
      blueman-adapters &
    fi
    ;;
  --off)
    if (bluetooth off || rfkill block bluetooth) >/dev/null; then
      if is_process_running blueman-manager; then
        pkill -f "/sbin/blueman-manager" || log_error "Failed to stop blueman-manager"
      fi
      if is_process_running blueman-adapters; then
        pkill -f "/sbin/blueman-adapters" || log_error "Failed to stop blueman-adapters"
      fi
    else
      log_error "Failed to turn off Bluetooth"
    fi
    ;;
  *)
    show_usage_error "'bluetooth.sh' script failed to run successfully.\
      \nPlease run this script with one of the following flags:\
      \n-> devices\
      \n-> settings\
      \n-> off"
    ;;
  esac
fi
