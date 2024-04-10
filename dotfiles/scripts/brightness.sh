#!/bin/bash
case $1 in
  --screenUp)
    brightnessctl s +5%
    ;;
  --screenDown)
    brightnessctl s 5%-
    ;;
  --keyboardUp)
    brightnessctl -d *::kbd_backlight set +33%
    ;;
  --keyboardDown)
    brightnessctl -d *::kbd_backlight set 33%-
    ;;
  *)
    echo "Invalid parameter"
    ;;
esac
