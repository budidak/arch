#!/usr/bin/env bash

# Checks if a command exists on the system
command_exist() {
  command -v "$1" >/dev/null
}

# Checks if a process running
is_process_running() {
  pgrep -f "/sbin/$1" >/dev/null
}

# Logs and pops-up if error occurs
log_error() {
  local output_file="$1"
  local message="$2"
  if command_exist zenity; then
    message="$(echo "$message" | sed "s/, zenity//")"
    zenity --error --text="$message"
  fi
  if [ -d "~/.config/waybar/logs" ]; then
    mkdir -p ~/.config/waybar/logs
    touch ~/.config/waybar/logs/$output_file
    chmod -R +w ~/.config/waybar/logs
  fi
  echo "$(date): $message" >>"~/.config/waybar/logs/$output_file"
  exit 1
}

# Shows usage error
show_usage_error() {
  local message="$1"
  echo -e "\n$message"
  zenity --warning --text="$message"
}
