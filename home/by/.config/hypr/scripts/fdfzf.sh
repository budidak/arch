#!/bin/bash

#
# FIND & FUZZY FINDER (fd & fzf)
# ~/.config/hypr/scripts/fdfzf.sh
#

rm -f /tmp/rg-fzf-{r,f}

fd | fzf --ansi --multi --tabstop=3 --style=full \
  --prompt 'Files> ' \
  --header-label ' File Type ' \
  --input-label ' Input ' \
  --bind 'result:transform-list-label:
      if [[ -z $FZF_QUERY ]]; then
         echo " $FZF_MATCH_COUNT items "
      else
         echo " $FZF_MATCH_COUNT matches for [$FZF_QUERY] "
      fi
   ' \
  --bind 'focus:transform-preview-label:[[ -n {} ]] && printf " Previewing [%s] " {}' \
  --bind 'focus:+transform-header:file --brief {} || echo "No file selected"' \
  --bind 'ctrl-p:change-preview-window(50%|hidden)' \
  --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ Files ]] &&
      echo "change-prompt(Files> )+reload(fd --type file)" ||
      echo "change-prompt(Directories> )+reload(fd --type directory)"' \
  --preview '[[ -f {} ]] && bat --color=always --style=numbers --line-range=:500 {} || tree -C {}' \
  --bind 'enter:become(nvim {})'
