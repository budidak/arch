#!/bin/bash
# rgfzf – fuzzy‑search with ripgrep + fzf
# ~/.config/hypr/scripts/rgfzf.sh

set -euo pipefail

# ---------- sanity checks ----------
for cmd in rg fzf bat nvim; do
  command -v "$cmd" >/dev/null || {
    echo "Error: $cmd not installed" >&2
    exit 1
  }
done

# ---------- temporary files ----------
TMP_R=$(mktemp /tmp/rg-fzf-r.XXXXXX)
TMP_F=$(mktemp /tmp/rg-fzf-f.XXXXXX)
trap 'rm -f "$TMP_R" "$TMP_F"' EXIT

# ---------- ripgrep base command ----------
RG_PREFIX='rg --column --line-number --no-heading --color=always --ignore-case --hidden --no-ignore'

# ---------- initial query ----------
INITIAL_QUERY="${*:-}"

# ---------- toggle helper ----------
toggle_mode() {
  if [[ $FZF_PROMPT =~ ripgrep ]]; then
    # switch to plain fzf (filter existing list)
    echo "rebind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo {q} > $TMP_R; cat $TMP_F"
  else
    # switch back to ripgrep
    echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo {q} > $TMP_F; cat $TMP_R"
  fi
}

# ---------- fzf launch ----------
fzf --ansi \
  --disabled \
  --style=full \
  --multi \
  --tabstop=3 \
  --query "$INITIAL_QUERY" \
  --header-label ' Keybind ' \
  --input-label ' Input ' \
  --bind "focus:transform-preview-label:[[ -n {} ]] && printf ' Previewing [%s] ' {}" \
  --bind "result:transform-list-label:\
        if [[ -z \$FZF_QUERY ]]; then \
            echo ' \$FZF_MATCH_COUNT items '; \
        else \
            echo ' \$FZF_MATCH_COUNT matches for [\$FZF_QUERY] '; \
        fi" \
  --bind "start:reload:$RG_PREFIX {q}" \
  --bind "change:reload:--debounce 200 $RG_PREFIX {q} || true" \
  --bind "ctrl-t:execute-silent(toggle_mode)" \
  --color "hl:-1:underline,hl+:-1:underline:reverse" \
  --prompt '1. ripgrep> ' \
  --delimiter ':' \
  --header 'CTRL‑T: Switch between ripgrep/fzf' \
  --preview 'bat --color=always {1} --highlight-line {2}' \
  --preview-window 'up,60%,border-top,+{2}+3/3,~3' \
  --bind 'enter:become(nvim {1} +{2})'
