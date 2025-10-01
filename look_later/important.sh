#!/bin/bash

display_help() {
  echo "Send a notification to all logged-in GUI users."
  echo ""
  echo "Usage: notify-send-all [options] <summary> [body]"
  echo ""
  echo "Options:"
  echo "  -? | --help    This text."
  echo ""
  echo "All options from notify-send are supported, see below..."
  echo
  notify-send --help
  exit 1
}

# Input validation function
sanitize_input() {
  echo "$1" | sed 's/[^a-zA-Z0-9 _-]//g' # Allow only alphanumeric, spaces, underscores, and hyphens
}

while [ $# -gt 0 ]; do
  case $1 in
  -h | --help)
    display_help
    exit 1
    ;;
  *)
    break
    ;;
  esac
done

# Sanitize input
SUMMARY=$(sanitize_input "$1")
BODY=$(sanitize_input "$2")

for SOME_USER in /run/user/*; do
  SOME_USER=$(basename "$SOME_USER")
  if [ "$SOME_USER" = "0" ]; then
    continue # Skip root user
  else
    sudo -u $(id -u -n "$SOME_USER") \
      DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$SOME_USER"/bus notify-send "$SUMMARY" "$BODY"
  fi
done

exit 0
