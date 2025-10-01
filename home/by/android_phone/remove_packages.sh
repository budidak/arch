#!/bin/bash

while IFS= read -r package; do
  result=$(adb uninstall --user 0 "$package")
  if [[ $result == "Failure [-1000]" ]]; then
    echo "Failed to remove: $package"
  fi
done <"$1"

adb shell pm art cleanup
