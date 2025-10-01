#!/bin/bash

#
# RIPGREP & FUZZY FINDER (rg & fzf)
# ~/.config/hypr/scripts/rgfzf.sh
#

# Switch between Ripgrep mode and fzf filtering mode (CTRL-T)
rm -f /tmp/rg-fzf-{r,f}

RG_PREFIX="rg --column --line-number --no-heading --color=always --ignore-case --hidden --no-ignore "
INITIAL_QUERY="${*:-}"

fzf --ansi --disabled --style=full --multi --tabstop=3 \
  --query "$INITIAL_QUERY" \
  --header-label ' Keybind ' \
  --input-label ' Input ' \
  --bind 'focus:transform-preview-label:[[ -n {} ]] && printf " Previewing [%s] " {}' \
  --bind 'result:transform-list-label:
      if [[ -z $FZF_QUERY ]]; then
         echo " $FZF_MATCH_COUNT items "
      else
         echo " $FZF_MATCH_COUNT matches for [$FZF_QUERY] "
      fi
   ' \
  --bind "start:reload:$RG_PREFIX {q}" \
  --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
  --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
      echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
      echo "unbind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
  --color "hl:-1:underline,hl+:-1:underline:reverse" \
  --prompt '1. ripgrep> ' \
  --delimiter : \
  --header 'CTRL-T: Switch between ripgrep/fzf' \
  --preview 'bat --color=always {1} --highlight-line {2}' \
  --preview-window 'up,60%,border-top,+{2}+3/3,~3' \
  --bind 'enter:become(nvim {1} +{2})'
