#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1="\[$(tput bold)\]\n"
PS1+="\[$(tput setaf 166)\]\u" # user
PS1+="\[$(tput setaf 15)\]@"
PS1+="\[$(tput setaf 228)\]\h" # host
PS1+="\[$(tput setaf 15)\] :: "
PS1+="\[$(tput setaf 71)\]\w" # working directory
PS1+="\n"
PS1+="\[$(tput setaf 15)\]\$ \[$(tput sgr0)\]" # $ and reset color
export PS1

### TAB SUGGESTIONS ###
#######################
# bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
# bind 'set menu-complete-display-prefix on'
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'

### FUNCTIONS ###
#################
function printInfo() {
  echo -e "$(tput setaf 249)UPTIME: $(uptime -p | gawk '{print $2,$3,$4,$5}')$(tput sgr0)"
}

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

function diff() {
  command diff --color="always" --expand-tabs "$@" | cat
}

### ALIASES ###
###############
# alias cat=bat
alias cc="run0 sync; echo 3 | run0 tee /proc/sys/vm/drop_caches" # Clear buff/cache memory (You can check with free -h)
alias clear="clear && printInfo"
# alias du=dust
# alias find=fd
alias free="free -h"
alias histgrep="history | rg '$1'"
alias l="eza -laxghUMmo --git --icons=auto --sort=Name --time-style='+%Y-%m-%d %H:%M'"
alias pss="procs"
alias rgrep="rg -p"
alias rmorph="run0 pacman -Runsv $(pacman -Qtdq)"
alias tree="tree --dirsfirst -F"
alias n="nvim"
alias watchBattery="run0 watch -n1 tlp-stat -b"
alias watchCpu="watch -n 1 'cat /proc/cpuinfo | grep -i 'mhz''"
alias watchGpu="watch -n 1 nvidia-smi"
alias sleepTimeNvidia="cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_suspended_time"
alias isActiveNvidia="cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status"

alias nvidia-run='env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json'
# nvidia-run mpv --hwdec=nvdec <video_name>
# nvidia-run vkcube
# Fakat aşağıdakinde 4k video açayım prime offload yapılsın diye bekleyemezsin:
# nvidia-run firefox

### EXECUTIONS ###
##################
printInfo # Runs terminal greeter

source /home/by/.config/broot/launcher/bash/br
