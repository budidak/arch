#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

### ENVIRONMENT VARIABLES ###
#############################
export ANDROID_HOME=$HOME/android_sdk
export BUN_INSTALL="$HOME/.bun"
export CARGO_HOME=$HOME/.cargo/bin
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

######################################## NVIDIA #####################################################
# https://wiki.archlinux.org/title/Hardware_video_acceleration                                      #
# NOTE: Comment these if you don't have an NVIDIA GPU or you don't want to run NVIDIA GPU primarily.#
#       Running Wayland on NVIDIA GPU results consuming more power and maybe causes some problems.  #
#####################################################################################################
export NVD_BACKEND=direct               # Hardware video acceleration on Nvidia and Wayland is possible with the nvidia-vaapi-driver. This may solve specific issues in Electron apps.
export __NV_PRIME_RENDER_OFFLOAD=1      # When set to 1, it allows applications to offload rendering tasks to the NVIDIA GPU while the display is still managed by the integrated GPU.
export LIBVA_DRIVER_NAME=nvidia         # Tell applications that use VA-API(Video Acceleration API) to use the NVIDIA for hardware acceleration.
export VDPAU_DRIVER=nvidia              # Indicates that the VDPAU (Video Decode and Presentation API for Unix) should use the NVIDIA for video decoding.
export __GLX_VENDOR_LIBRARY_NAME=nvidia # Directs OpenGL applications to use the NVIDIA driver. This is important for ensuring that OpenGL applications utilize the NVIDIA driver for rendering, which is necessary for proper functionality when using the NVIDIA GPU for offloading.
# This sets the Vulkan ICD (Installable Client Driver) file to the NVIDIA driver. It tells Vulkan applications to use the NVIDIA driver for rendering.
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
export VK_DRIVER_FILES=/usr/share/vulkan/icd.d/nvidia_icd.json
export VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d
# AMD: Vulkan Video support in vulkan-radeon is enabled by default for VCN 2, 3, and 4+ since Mesa 25. To force-enable support on older cards, set:
# export RADV_PERFTEST=video_decode,video_encode
# WARN: For mesa|nouveau drivers
# __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
# __GLX_VENDOR_LIBRARY_NAME=mesa

### PATH ###
############
export PATH="$PATH:$ANDROID_HOME/build-tools/34.0.0"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$BUN_INSTALL/bin"  # bun all-in-one package manager (alternative to npm, yarn, pnpm, deno...)
export PATH="$PATH:$CARGO_HOME/bin"   # binaries installed with `cargo`
export PATH="$PATH:$FLUTTER_HOME/bin" # flutter and dart binaries
# export PATH="$PATH:$GEM_HOME/ruby/3.4.0/bin" # packages installed with `gem`
export PATH="$PATH":"$HOME/.pub-cache/bin" # firebase sdk (after installed FlutterFire CLI)
export PATH="$PATH:$PYTHON_HOME/bin"       # packages installed with `pip` inside python virtual environment

### EXECUTIONS ###
##################
# exec Hyprland  # not necessary after installed `ly`
