#!/bin/bash

# Initialize variables
flag_a=false
flag_b=false

# Parse command line options
while getopts "ab" option; do
  case $option in
  a)
    flag_a=true
    ;;
  b)
    flag_b=true
    ;;
  *)
    echo "Usage: $0 [-a] [-b]"
    exit 1
    ;;
  esac
done

# Shift off the options and arguments
shift $((OPTIND - 1))

# Use the flags
if $flag_a; then
  echo "Flag -a is set."
fi

if $flag_b; then
  echo "Flag -b is set."
fi

# Additional script logic can go here
