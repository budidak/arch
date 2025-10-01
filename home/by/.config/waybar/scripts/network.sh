#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# --- network.sh
# FILE LOCATION : ~/.config/waybar/scripts/network.sh
# REPOSITORY    : https://github.com/budidak/arch
# AUTHOR        : Burak Yeşilyurt (GITHUB: budidak)
# DESCRIPTION   : Controls network connection on the waybar through `iwd`.
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

# Stop the execution of the script if any command fails
# (i.e., returns a non-zero exit status)
# set -e

# Source common functions
source ~/.config/waybar/scripts/common_functions.sh

# Kill existing Zenity window
pkill -f 'zenity --list --title=Select Network'

# Get the name of the wireless interface
wireless_interface=$(iwctl station list | awk '{print $2}' | grep -Ei "(wlan|wlp)[0-9]")

if ! command_exist iwctl; then
  log_error "network.log" "Please check if the following packages are installed on your system: iwd, zenity"
elif [ -z "$wireless_interface" ]; then
  log_error "network.log" "No wireless interface found."
else
  case "$1" in
  --unconnect)
    connection=$(ip a)
    if echo "$connection" | grep -E "inet .*((eth|enp)|((wlan|wlp)[0-9]))" | grep -qi inet; then
      iwctl station "$wireless_interface" disconnect
      exit 0
    fi
    ;;
  --connect)
    wireless_networks=$(
      iwctl station $wireless_interface scan
      iwctl station $wireless_interface get-networks
    )
    available_networks=$(echo "$wireless_networks" | sed 's/\x1b\[[0-9;]*m//g' | awk 'NR>4 {for(i=1;i<=NF;i++) if ($i ~ /^[A-Za-z0-9]/) print $i}' | grep -vw "psk")

    # Create an array from the available networks
    network_array=()
    while IFS= read -r line; do
      network_array+=("$line")
    done <<<"$available_networks"

    is_network_saved() {
      local network=$1
      iwctl known-networks list | grep -w "$network"
    }

    connect_to_network() {
      local interface=$1
      local network=$2
      local password=$3
      iwctl station "$interface" connect "$network" --passphrase "$password"
    }

    selected_network=$(zenity --list --title="Select Network" --column="Available Networks" "${network_array[@]}" --height=300 --width=300 --ok-label="Connect" --cancel-label="Cancel")

    # Check if a network was selected
    if [ -n "$selected_network" ]; then
      if is_network_saved "$selected_network"; then
        iwctl station "$wireless_interface" connect "$selected_network"
        zenity --info --text="Connected to $selected_network successfully!"
      else
        password=$(zenity --entry --title="Enter Password" --text="Enter the password for $selected_network:" --hide-text)
        if connect_to_network "$wireless_interface" "$selected_network" "$password"; then
          zenity --info --text="Connected to $selected_network successfully!"
        else
          zenity --error --text="Failed to connect to $selected_network. Please check the password."
        fi
      fi
    fi
    ;;
  --vpn)
    # TODO: THIS FEATURE WILL BE IMPLEMENTED AT SOME POINT IN THE FUTURE
    echo "This feature has not been implemented yet"
    ;;
  *)
    show_usage_error "'network.sh' script failed to run successfully.\
      \nPlease run this script with one of the following flags:\
      \n-> connect\
      \n-> unconnect\
      \n-> vpn"
    ;;
  esac
fi
