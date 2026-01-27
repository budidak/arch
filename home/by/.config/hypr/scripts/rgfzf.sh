#!/bin/bash

# --- 1. Kontroller ---
dependencies=(fzf rg fd bat tree)
for cmd in "${dependencies[@]}"; do
  if ! command -v $cmd &>/dev/null; then
    echo "HATA: '$cmd' komutu eksik. Lütfen kurunuz."
    exit 1
  fi
done

APP_NAME="fzf-pro-v16"
export TMP_DIR="/tmp/$APP_NAME"
mkdir -p "$TMP_DIR"

# Başlangıç Dizinini Ayarla
START_DIR="${1:-$(pwd)}"
if command -v realpath &>/dev/null; then
  realpath "$START_DIR" >"$TMP_DIR/cwd"
else
  cd "$START_DIR" && pwd >"$TMP_DIR/cwd"
fi

# Temizlik
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# --- 2. Görsel Ayarlar (İKONLAR & RENKLER) ---
export C_RESET=$'\e[0m'
export C_KEY=$'\e[33m'   # Sarı
export C_LBL=$'\e[1;34m' # Mavi

# Ayırıcı Çizgi
SEP_LINE="──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────"

# Keybinds (İkonlu)
export KEYBINDS_STR="${C_SEP}${SEP_LINE}${C_RESET}
 ${C_KEY}CTRL-T${C_RESET}: 📄/📂 File/Dir │ ${C_KEY}CTRL-S${C_RESET}: 🔍 fzf/rg │ ${C_KEY}CTRL-O${C_RESET}: 🧭 Search Scope"

# --- 3. Komut Mantığı ---
export CMD_FZF_FILE="fd --type f --color=always --hidden --follow --exclude .git"
export CMD_FZF_DIR="fd --type d --color=always --hidden --follow --exclude .git"
export RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case --hidden --no-ignore --fixed-strings"

run_cmd() {
  local type=$1
  local query="${*:2}"
  local root
  root=$(cat "$TMP_DIR/cwd")
  cd "$root" || return
  case "$type" in
  "file") eval "$CMD_FZF_FILE" ;;
  "dir") eval "$CMD_FZF_DIR" ;;
  "rg") eval "$RG_PREFIX -- \"$query\" || true" ;;
  esac
}
export -f run_cmd

# --- 4. Navigator Logic (AKILLI GEZİNTİ) ---
nav_handler() {
  local action=$1
  local selection=$2
  local current
  current=$(cat "$TMP_DIR/walker_cwd")

  if [[ "$action" == "up" ]]; then
    # Root koruması
    if [[ "$current" == "/" ]]; then
      cd "$current" && fd --type d --max-depth 1 --color=always --hidden --exclude .git
      return
    fi

    # AKILLI SEÇİM MANTIĞI:
    # 1. Hangi klasörden çıktığımızı bul (basename)
    local child_name=$(basename "$current")
    local parent=$(dirname "$current")

    # 2. Parent'ı kaydet
    echo "$parent" >"$TMP_DIR/walker_cwd"

    # 3. Listeleme:
    # - Önce geldiğimiz klasörü yazdır (Böylece en tepede ve seçili olur)
    # - Sonra diğerlerini yazdır (Geldiğimiz klasörü hariç tutarak)
    echo "$child_name"
    cd "$parent" && fd --type d --max-depth 1 --color=always --hidden --exclude .git --exclude "$child_name"

  elif [[ "$action" == "down" ]]; then
    if [[ -z "$selection" ]]; then
      cd "$current" && fd --type d --max-depth 1 --color=always --hidden --exclude .git
      return
    fi
    local next_dir="$current/$selection"
    if [ -d "$next_dir" ]; then
      echo "$next_dir" >"$TMP_DIR/walker_cwd"
      cd "$next_dir" && fd --type d --max-depth 1 --color=always --hidden --exclude .git
    else
      cd "$current" && fd --type d --max-depth 1 --color=always --hidden --exclude .git
    fi
  else
    # Init durumu
    cd "$current" && fd --type d --max-depth 1 --color=always --hidden --exclude .git
  fi
}
export -f nav_handler

# --- 5. Navigator Preview ---
nav_preview() {
  local selection=$1
  local root
  root=$(cat "$TMP_DIR/walker_cwd")
  if [ -z "$selection" ] || [ -z "$root" ]; then
    echo "Select a directory..."
    return
  fi
  local full_path="$root/$selection"
  if [ -d "$full_path" ]; then
    tree -C "$full_path" | head -50
  else
    echo "Not a directory: $selection"
  fi
}
export -f nav_preview

# --- 6. Seçim Tamamlayıcı ---
finalize_selection() {
  read -r RESULT
  if [ -z "$RESULT" ]; then return; fi
  local expanded="${RESULT/#\~/$HOME}"
  local walker_cwd
  walker_cwd=$(cat "$TMP_DIR/walker_cwd")
  if [ -d "$walker_cwd/$expanded" ]; then
    realpath "$walker_cwd/$expanded" >"$TMP_DIR/cwd"
  elif [ -d "$expanded" ]; then
    realpath "$expanded" >"$TMP_DIR/cwd"
  else
    echo "$walker_cwd" >"$TMP_DIR/cwd"
  fi
}
export -f finalize_selection

# --- 7. WRAPPER (NAVIGATOR - CTRL+O) ---
run_navigator_wrapper() {
  cp "$TMP_DIR/cwd" "$TMP_DIR/walker_cwd"

  # --tiebreak=index: Bizim sıralamamızı (geldiğimiz klasörü en başa koymamızı) korur.
  # --layout=reverse-list: Liste altta, input en altta.
  # --height=100%: Tüm ekranı kapla.

  fzf --ansi --height=100% --border --prompt=" 🧭 Directory (nav) > " \
    --border-label " 👁️ PREVIEW " \
    --layout=reverse-list \
    --tiebreak=index \
    --header="⬅️ Out | ➡️ In | ⏎ Select" \
    --bind "start:reload(bash -c \"nav_handler init\")" \
    --bind "left:reload(bash -c \"nav_handler up\")" \
    --bind "right:reload(bash -c \"nav_handler down {}\")" \
    --bind "alt-up:reload(bash -c \"nav_handler up\")" \
    --bind "alt-right:reload(bash -c \"nav_handler down {}\")" \
    --preview="bash -c \"nav_preview {}\"" \
    --preview-window 'up,50%,border-bottom' \
    --preview-label ' 📂 CONTENT ' \
    --print-query |
    tail -1 | bash -c "finalize_selection"
}
export -f run_navigator_wrapper

# --- 8. FZF Başlatma (ANA PENCERE) ---

fzf --ansi --disabled --multi --tabstop=2 \
  --layout=default \
  --height=100% \
  --border \
  --border-label " 👁️ PREVIEW " \
  --border-label-pos=top \
  --prompt ' 📄 File (fzf) > ' \
  --header "$KEYBINDS_STR" \
  --preview-window 'up,75%,border-bottom' \
  --preview-label " 🔭 SCOPE: $(cat $TMP_DIR/cwd) " \
  \
  --bind "start:reload(bash -c 'run_cmd file')+enable-search" \
  \
  --bind 'ctrl-t:transform:[[ $FZF_PROMPT =~ "File (fzf)" ]] &&
            echo "change-prompt( 📂 Directory (fzf) > )+reload(bash -c \"run_cmd dir\")+clear-query" ||
            ([[ $FZF_PROMPT =~ "Directory (fzf)" ]] &&
            echo "change-prompt( 📄 File (fzf) > )+reload(bash -c \"run_cmd file\")+clear-query" ||
            echo "change-prompt( 📄 File (fzf) > )+reload(bash -c \"run_cmd file\")+enable-search+clear-query")' \
  \
  --bind 'ctrl-s:transform:[[ $FZF_PROMPT =~ "(rg)" ]] &&
            echo "change-prompt( 📄 File (fzf) > )+enable-search+reload(bash -c \"run_cmd file\")+clear-query+unbind(change)" ||
            echo "change-prompt( 📝 File (rg) > )+disable-search+reload(bash -c '\''run_cmd rg "$@"'\'' -- {q})+clear-query+rebind(change)"' \
  \
  --bind 'change:reload(bash -c '\''run_cmd rg "$@"'\'' -- {q})' \
  \
  --bind 'ctrl-o:execute(bash -c run_navigator_wrapper)+transform-border-label:echo " 🔭 SCOPE: $(cat $TMP_DIR/cwd) "+transform:
            [[ $FZF_PROMPT =~ "(rg)" ]] && echo "reload(bash -c '\''run_cmd rg "$@"'\'' -- {q}) " ||
            ([[ $FZF_PROMPT =~ "Directory" ]] && echo "reload(bash -c \"run_cmd dir\")" ||
            echo "reload(bash -c \"run_cmd file\")")' \
  \
  --preview '
        TARGET=$(echo {} | cut -d: -f1);
        ROOT=$(cat "$TMP_DIR/cwd");
        FULLPATH="$ROOT/$TARGET";
        if [ -e "$FULLPATH" ]; then
            if [[ "$FZF_PROMPT" =~ "(rg)" ]]; then
                 LINE=$(echo {} | cut -d: -f2);
                 bat --style=numbers --color=always --highlight-line $LINE --line-range $((LINE>20?LINE-20:0)):$((LINE+20)) "$FULLPATH"
            elif [[ "$FZF_PROMPT" =~ "Directory" ]]; then
                 tree -C "$FULLPATH" | head -100
            else
                 bat --style=numbers --color=always --line-range :100 "$FULLPATH"
            fi
        else
            echo "File not found."
        fi
    ' \
  --bind 'enter:become(
        ROOT=$(cat "$TMP_DIR/cwd");
        FILE=$(echo {1} | cut -d: -f1);
        if [[ "$FZF_PROMPT" =~ "(rg)" ]]; then
            LINE=$(echo {1} | cut -d: -f2);
            nvim "$ROOT/$FILE" +$LINE
        else
            nvim "$ROOT/$FILE"
        fi
    )'
