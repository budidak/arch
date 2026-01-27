#!/usr/bin/env bash

CHANGE="2%"
SINK="@DEFAULT_AUDIO_SINK@"

current_volume() {
   wpctl get-volume "$SINK" | awk '{print $2}' | cut -c1,3,4
}

is_audio_muted() {
   (wpctl get-volume "$SINK" | grep -i "muted") >/dev/null
}

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
esac
