#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# --- sound.sh
# FILE LOCATION : ~/.config/waybar/scripts/sound.sh
# REPOSITORY    : https://github.com/budidak/arch
# AUTHOR        : Burak Yeşilyurt (GITHUB: budidak)
# DESCRIPTION   : Control audio volume and mute status
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
SINK="@DEFAULT_AUDIO_SINK@"

# Get the current volume level of the default audio sink.
# Returns the volume as a string formatted as 'XXX' (e.g., '100', '000')
current_volume() {
  wpctl get-volume "$SINK" | awk '{print $2}' | cut -c1,3,4
}

# Check if the default audio sink is muted.
# Returns 0 if muted, 1 if not muted.
is_audio_muted() {
  (wpctl get-volume "$SINK" | grep -i "muted") >/dev/null
}

if ! command_exist wpctl; then
  log_error "sound.log" "Please check if the following packages are installed on your system: wireplumber"
else
  case "$1" in
  --up)
    is_audio_muted && wpctl set-mute "$SINK" 0
    wpctl set-volume -l 1.0 "$SINK" "$CHANGE"+
    ;;
  --down)
    wpctl set-volume "$SINK" "$CHANGE"-
    if [[ "$(current_volume)" == "000" ]]; then
      wpctl set-mute "$SINK" 1
    fi
    ;;
  --toggle)
    [[ ! "$(current_volume)" == "000" ]] && wpctl set-mute "$SINK" toggle
    ;;
  *)
    show_usage_error "'sound.sh' script failed to run successfully.\
      \nPlease run this script with one of the following flags:\
      \n-> --up\
      \n-> --down\
      \n-> --toggle"
    ;;
  esac
fi
