#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

### ENVIRONMENT VARIABLES ###
#############################
export ANDROID_HOME=$HOME/android_sdk
export BUN_INSTALL="$HOME/.bun"
export CARGO_HOME=$HOME/.cargo
export CARGO_TARGET_DIR=$CARGO_HOME/target
export CGO_ENABLED=1
export CHROME_EXECUTABLE=brave
export EDITOR=nvim
export FLUTTER_HOME=$HOME/flutter
## export GEM_HOME=$HOME/.local/share/gem # not needed if you don't use Ruby
export GOPATH=$HOME/go
export GOROOT=/usr/lib/go
export JAVA_HOME=/usr/lib/jvm/default
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"
export PYTHON_HOME=$HOME/venv
export RUSTUP_HOME=$HOME/.rustup
export TERMINAL=foot
export THEME_DIR="$HOME/.config/themes/catppuccin-macchiato-blue-standard+default/"

# Use iGPU for video acceleration
export LIBVA_DRIVER_NAME=radeonsi

# Vulkan applications use iGPU for rendering
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json

# OpenGL applications use iGPU for rendering
export MESA_LOADER_DRIVER_OVERRIDE=radeonsi

### PATH ###
############
export PATH="$CARGO_HOME/bin:$PATH" # binaries installed with `cargo`
export PATH="$PATH:$ANDROID_HOME/build-tools/34.0.0"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$BUN_INSTALL/bin"       # bun all-in-one package manager (alternative to npm, yarn, pnpm, deno...)
export PATH="$PATH:$FLUTTER_HOME/bin"      # flutter and dart binaries
export PATH="$PATH":"$HOME/.pub-cache/bin" # firebase sdk (after installed FlutterFire CLI)
export PATH="$PATH:$PYTHON_HOME/bin"       # packages installed with `pip` inside python virtual environment

### EXECUTIONS ###
##################
# exec Hyprland  # not necessary after installed `ly`

source /home/by/.config/broot/launcher/bash/br
