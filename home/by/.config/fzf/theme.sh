#!/bin/bash

#
# FUZZY FINDER THEME DEFINITION
# ~/.config/fzf/theme.sh
#

# Only apply if fzf is installed
if command -v fzf >/dev/null; then
  # Base options – keep any user‑defined ones
  FZF_OPTS=${FZF_DEFAULT_OPTS:-}

  # Theme definition (array for easy editing)
  theme=(
    --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796
    --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6
    --color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796
    --color=selected-bg:#494d64
    --color=border:#aaaaaa,label:#cccccc
    --color=preview-border:#9999cc,preview-label:#ccccff
    --color=list-border:#669966,list-label:#99cc99
    --color=input-border:#996666,input-label:#ffcccc
    --color=header-border:#6699cc,header-label:#99ccff
    --style=full
  )

  # Join the array into a single string and export
  export FZF_DEFAULT_OPTS="${FZF_OPTS} ${theme[*]}"
fi
