#!/bin/bash

# fix the numlock indicator
# because output of `$xset q` shows the numlock state as 'off' even if it is set 'on' during early bootup.
sleep 0.1
xdotool key --clearmodifiers Num_Lock
