#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# --- screen.sh
# FILE LOCATION : ~/.config/waybar/scripts/screen.sh
# REPOSITORY    : https://github.com/budidak/arch
# AUTHOR        : Burak Yeşilyurt (GITHUB: budidak)
# DESCRIPTION   : Adjust screen brightness and temperature levels
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

CHANGE="2%"
TEMPERATURE=3000
if ! command_exist brightnessctl; then
  log_error "brightness.log" "Please check if the following packages are installed on your system: brightnessctl"
else
  case "$1" in
  --up)
    [ $(brightnessctl get) -lt 200 ] && brightnessctl -q set "$CHANGE"+
    ;;
  --down)
    [ $(brightnessctl get) -gt 5 ] && brightnessctl -q -n5 set "$CHANGE"-
    ;;
  --toggle)
    (pgrep hyprsunset && pkill -9 hyprsunset) || hyprsunset -t $TEMPERATURE >/dev/null 2>&1 &
    ;;
  *)
    show_usage_error "'brightness.sh' script failed to run successfully.\
      \nPlease run this script with one of the following flags:\
      \n-> --up\
      \n-> --down\
      \n-> --toggle"
    ;;
  esac
fi
