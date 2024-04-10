#!/bin/bash
case $1 in
  --shutdown)
    notify-send -u critical "System is going to shut down!"
    sleep 1
    systemctl poweroff
    ;;
  --reboot)
    notify-send -u critical "System is going to reboot!"
    sleep 1
    systemctl reboot
    ;;
  --hibernate)
    notify-send -u critical "System will hibernate now!"
    sleep 1
    systemctl hibernate
    ;;
  --lock)
    loginctl lock-session
    ;;
  --suspend)
    notify-send -u low "This feature is not implemented yet!"
    # notify-send -u critical "System will be suspended by now!"
    # sleep 1
    # systemctl suspend
    ;;
  *)
    echo "Invalid parameter"
    ;;
esac
