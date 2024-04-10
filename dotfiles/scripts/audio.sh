#!/bin/bash
case $1 in
  --speakerUp)
    wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
    ;;
  --speakerDown)
    wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-
    ;;
  --speakerToggle)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    ;;
  --microphoneToggle)
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    ;;
  *)
    echo "Invalid parameter"
    ;;
esac
