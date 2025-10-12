#!/bin/bash

CONFIG_FILE="$HOME/.config/bat/config"

CURRENT_THEME="$(cat $CONFIG_FILE | grep -w 'theme' | awk -F'=' '{print $2}' | xargs)"
echo "Current theme for bat: $CURRENT_THEME"

if [ "$CURRENT_THEME" == "Catppuccin Macchiato" ]; then
  echo "Changing from dark to light"
  sed -i 's/"Catppuccin Macchiato"/"Catppuccin Latte"/' "$CONFIG_FILE"
else
  echo "Changing from light to dark"
  sed -i 's/"Catppuccin Latte"/"Catppuccin Macchiato"/' "$CONFIG_FILE"
fi

# Güncellenmiş tema bilgisini tekrar oku
CURRENT_THEME="$(grep -w 'theme' "$CONFIG_FILE" | awk -F'=' '{print $2}')"
echo "Current theme for bat after toggle: $CURRENT_THEME"
