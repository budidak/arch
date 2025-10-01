#!/bin/bash

# Function to display a popup message
function show_popup {
  zenity --info --text="$1" --title="Pomodoro Timer" --timeout=5
}

# Function to run the timer
function run_timer {
  local duration=$1
  local message=$2

  # Start the timer
  sleep $duration

  # Show the popup message
  show_popup "$message"
}

# Main loop
while true; do
  # Work session
  show_popup "Time to work! 1 minutes."
  run_timer 60 "Time's up! Take a 10-second break."

  # Break session
  show_popup "Time for a break! 10 seconds."
  run_timer 10 "Break's over! Time to get back to work."
done
