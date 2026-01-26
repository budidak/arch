# Arch Linux From Scratch

## Pre-installation Steps

Check the hash values to make sure that the file is not corrupted.

```sh
b2sum -c b2sums.txt
```

- Install **Ventoy** to USB drive.
- Copy the ISO file into USB drive.
- Reboot and enter UEFI screen.

> Note: Arch Linux installation images do not support Secure Boot.

## Installation Steps

```sh
# Load keyboard.
loadkeys trq

# Set font.
setfont ter-922b

# List block devices including info about filesystems.
lsblk -f

# Erase all magic strings on specified block device.
wipefs -a /dev/?

# Format ssd. (do not use "shred" or "dd")
nvme format /dev/? --ses=1

rfkill  
# ID TYPE      DEVICE      SOFT      HARD
#  0 bluetooth hci0   unblocked unblocked
#  1 wlan      phy0   unblocked unblocked
```

- If the card is hard-blocked, use the hardware button (switch) to unblock it.
- If the card is not hard-blocked but soft-blocked, use the **rfkill** command to unblock:

```sh
rfkill unblock wlan0

ip link set <interface_name> up # wlan0, enp2s0
```

To verify the boot mode, check the UEFI bitness:

```sh
cat /sys/firmware/efi/fw_platform_size
```

- If the command returns 64, the system is booted in UEFI mode and has a 64-bit x64 UEFI.
- If the command returns 32, the system is booted in UEFI mode and has a 32-bit IA32 UEFI.
While this is supported, it will limit the boot loader choice to those that support mixed mode booting.
- If it returns No such file or directory, the system may be booted in BIOS (or CSM) mode.

If the system did not boot in the mode you desired (UEFI vs BIOS), refer to your motherboard's manual.

### Disk Partition

Any of `fdisk`, `gdisk` or `gparted` can be used for disk partition.

```sh
# USE GPT partition.
# Define 1GB for the EFI, and use the remaining space for the ROOT partition.

fdisk /dev/?
# g: makes the partition `gpt`
# d: delete
# n: new
# t: type (1 for EFI vfat partition, 20 for Linux btrfs root partition)
# p: print
# w: write

# format partitions which were just created
mkfs.fat -c -F 32 --codepage=437 -n UEFI /dev/nvme0n1p1
mkfs.btrfs --csum xxhash -L ROOT /dev/nvme0n1p2

# check fs integrity for the btrfs filesystem before mounting it.
btrfs check /dev/nvme0n1p2

# efi filesystem mount options
EFI_OPTS="defaults,nosuid,nodev,noexec,noatime,umask=0077,fmask=0077,dmask=0077,errors=remount-ro,tz=UTC,codepage=437,iocharset=utf8,utf8"

# btrfs filesystem mount options
BTRFS_OPTS="defaults,noatime,ssd,discard=async,space_cache=v2,compress=zstd:3"

# mount btrfs filesystem on /mnt directory
mount -t btrfs -o $BTRFS_OPTS /dev/nvme0n1p2 /mnt

# create subvolumes on the mounted btrfs filesystem
btrfs subvolume create /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@snapshots
btrfs su cr /mnt/@srv
btrfs su cr /mnt/@var
btrfs su cr /mnt/@opt

# list defined subvolumes on /mnt directory
btrfs su list /mnt

# unmount the btrfs filesystem
umount /mnt

# mount the btrfs filesystem again, mounting @ subvolume on /mnt this time.
mount -t btrfs -o $BTRFS_OPTS,subvol=@ /dev/nvme0n1p2 /mnt

# create directories for the subvolumes
mkdir -p /mnt/{boot,home,.snapshots,srv,var,opt}

# mount subvolumes on matching directories
mount -t btrfs -o $BTRFS_OPTS,subvol=@home /dev/nvme0n1p2 /mnt/home
mount -t btrfs -o $BTRFS_OPTS,subvol=@snapshots /dev/nvme0n1p2 /mnt/.snapshots
mount -t btrfs -o $BTRFS_OPTS,subvol=@srv /dev/nvme0n1p2 /mnt/srv
mount -t btrfs -o $BTRFS_OPTS,subvol=@var /dev/nvme0n1p2 /mnt/var
mount -t btrfs -o $BTRFS_OPTS,subvol=@opt /dev/nvme0n1p2 /mnt/opt

# start a new scrub on the btrfs filesystem, /dev/nvme0n1p2
btrfs scrub start /dev/?
btrfs scrub status /dev/?

# mount boot partition on /mnt/boot directory
mount -t vfat -o $EFI_OPTS /dev/nvme0n1p1 /mnt/boot
```

### Connect to an Internet

```sh
iwctl
# device list
# station list
# station <device> scan
# station <device> get-networks
# station <device> connect <ssid>
#  -> Enter password for the selected network
# exit

# check if the device has an assigned IP address
ip a

# You should be able to ping a remote server if you connected successfully.
ping -c 3 8.8.8.8

# Check if your DNS resolves correctly.
ping -c 3 archlinux.org

# You should sync your time to be able to download packages.
timedatectl
```

### Base installation

```sh
# edit pacman related settings, enable/disable repositories.
vim /etc/pacman.conf

# Edit your mirrors. (You can use "reflector" to automate this)
vim /etc/pacman.d/mirrorlist

# Force sync repositories.
pacman -Syy

# If you don't want to install `sudo` you can bypass it with:
# pacman -S <packages> --assume-installed=<packages>
# pacstrap -K /mnt <packages> --assume-installed=sudo

# ASUS TUFA15 FA507XI LAPTOP:
# CPU: AMD Ryzen9 7940HS w/ AMD Radeon 780M iGPU
# GPU: NVIDIA GeForce RTX 4070
# amd-ucode is needed for CPU
# linux-firmware-amdgpu for iGPU
# linux-firmware-nvidia for GPU
# linux-firmware-mediatek for LAN, WLAN, Bluetooth
pacstrap -K /mnt base base-devel \
                 linux linux-headers \
                 amd-ucode btrfs-progs \
                 linux-firmware-amdgpu \
                 linux-firmware-nvidia \
                 linux-firmware-mediatek \
                 polkit iwd neovim \
                 --assume-installed=sudo

# Generate a fstab file for the mounted filesystem.
genfstab -U /mnt >> /mnt/etc/fstab
```

### CHROOTED ENVIRONMENT

```sh
# Enter the chrooted environment.
arch-chroot /mnt

# edit pacman related settings, enable/disable repositories.
nvim /etc/pacman.conf

# Force sync the repositories
pacman -Syyu

# Create a symbolic link for timezone information.
ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime

# Sync your hardware clock.
hwclock --systohc

# Uncomment the line with a proper locale.
nvim /etc/locale.gen
   # en_GB.UTF-8 UTF-8

# Generate locales.
locale-gen

# Edit /etc/locale.conf
# Write the following lines into this file:
nvim /etc/locale.conf
   # LANG=en_GB.UTF-8
   # LC_COLLATE=C

# Edit /etc/vconsole.conf
# Add your keymap into this file. This is needed for tty sessions.
nvim /etc/vconsole.conf
   # KEYMAP=trq
   # FONT=ter-922b

# Edit /etc/hostname
# The name you write into this file defines your device's name on the network.
nvim /etc/hostname
   # arch

# Edit /etc/hosts
# Write the following IP addresses into this file.
nvim /etc/hosts
   # 127.0.0.1  localhost.localdomain  localhost
   # ::1        localhost.localdomain  localhost
   # 127.0.1.1  arch.localdomain       arch

# Create custom files in /etc/systemd/network/ directory to be able to connect a network.
# You can use the following configurations.
nvim /etc/systemd/network/20-wireless.network
nvim /etc/systemd/network/30-wired.network

# set a password for the root user
passwd

# create a user: by
# -m to create home directory for the user
# -G to add the user to a group
# -s to set shell for the user
useradd -m -G wheel -s /bin/bash by

# set a password for the user `by`
passwd by

--------------------------------

pacman -S efibootmgr
# I don't need any additional bootloader since I use 1 OS on my machine.
# With that reason I continue the installation with EFI Boot stub.
efibootmgr --unicode   # List all efistub entries.
efibootmgr -b 0000 -B  # Delete the record labeled with 0000. (Delete all unneccessary entries 0000, 0001, 0002...)

You can use one of the following:

# ------------------------------
# 1. EFISTUB ENTRY

# Save the UUID value for the root partition into ROOT_UUID
ROOT_UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)
echo $ROOT_UUID

efibootmgr --create \
           --disk /dev/nvme0n1 \
           --part 1 \
           --label "Arch Linux" \
           --loader "\vmlinuz-linux" \
           --unicode "root=UUID=$ROOT_UUID rw rootflags=subvol=@ loglevel=3 quiet splash \
                      initrd=\amd-ucode.img initrd=\initramfs-linux.img"

# ------------------------------
# 2. SYSTEMDBOOT

bootctl install

nvim /boot/loader/loader.conf
# default        arch.conf
# timeout        3
# console-mode   auto
# editor         no

nvim /boot/loader/entries/arch.conf
# title     Arch Linux
# linux     /vmlinuz-linux
# initrd    /amd-ucode.img
# initrd    /initramfs-linux.img
# options   root=UUID=<write_uuid_here> rw rootflags=subvol=@ loglevel=3 quiet splash

# Create a new initramfs (new kernel image)
mkinitcpio -P

# exit the chrooted environment
exit

# unmount the filesystem /mnt recursively
umount -R /mnt

# reboot the machine
reboot
```

## Post-Installation Steps

```bash
run0 systemctl enable --now systemd-homed      --- şifreli dizinler için
run0 systemctl enable --now systemd-timesyncd  --- ntf sunucusu ile senkronizasyon için
run0 systemctl enable --now systemd-networkd   --- ethernet
run0 systemctl enable --now systemd-resolved   --- dns
run0 systemctl enable --now rtkit-daemon       --- ses ve multimedya
systemctl enable --now wireplumber --user      --- ses ve multimedya
systemctl enable --now pipewire --user         --- ses ve multimedya
systemctl enable --now pipewire-pulse --user   --- ses ve multimedya
systemctl enable --now bluetooth               --- bluetooth
systemctl enable ly@tty2                       --- greeter

timedatectl set-ntp true                       --- sync time with ntp
run0 systemctl enable --now iwd                --- iwd daemon
run0 ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf  --- needed for dns

---------------------------------------------------------------

# Install the packages you need.
# wget   -> curl
# cronie -> systemd timers
# dmidecode inxi
pacman -S pacman-contrib curl plymouth
pacman -S texinfo less man-db man-pages
pacman -S noto-fonts noto-fonts-emoji ttf-hack-nerd terminus-font
pacman -S pciutils usbutils inetutils

# Terminal recording tool:
# pacman -S asciinema
asciinema record <name.cast>  # start recording (ends with ^D or exit command)
asciinema play <name.cast>    # play a recording

# Download a theme you like from github:
# https://github.com/adi1090x/plymouth-themes/releases 
# Then extract the archive content:
tar -xzf <theme.tar.gz>
sudo cp -R <theme_dir/> /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -l              # list available themes
sudo plymouth-set-default-theme -R <theme_name> # set default theme by editing /etc/plymouth/plymouthd.conf file.

# Adjust power management, and start its services.
run0 pacman -Syu tlp
run0 systemctl enable tlp
run0 tlp start



1. Apps / Games
   ↓
2. Graphics APIs (OpenGL / Vulkan)
  Vulkan: Video graphics API
  Who provides Vulkan?
    AMD → RADV (Mesa)
    Intel → ANV (Mesa)
    NVIDIA → nvidia proprietary Vulkan driver
   ↓
3. User-space drivers (Mesa, NVIDIA)
  AMD iGPU için MESA zorunlu.
  Mesa: implements OpenGL, Vulkan, EGL, GLX.
        it needs a kernel driver.
        Mesa sürücüsü "radv" = vulkan (AMD)
                      "radeonsi" = opengl (AMD)
                      "iris" = intel
                      "nouveau" = nvidia
  Nvidia: does not use mesa. Replaces everything for NVIDIA GPUs.
        best performance. best vulkan support. required for CUDA.
   ↓
4. Kernel drivers (amdgpu, nouveau, nvidia)
   ↓
5. GPU hardware


# DRIVERS needed for iGPU (amd radeon 780M)
# linux-firmware-amdgpu ✅
# amd-ucode             ✅
# mesa                  ✅ contains radeonsi + VA + VDPAU backends
# vulkan-icd-loader     ✅ Ortak yükleyici zorunlu
# vulkan-radeon         ✅ AMD vulkan sürücüsü (RADV)
# glu                   ✅ AMD OpenGL sürücüsü
# libglvnd              ✅ REQUIRED (çoklu gpu vendor geçişi için)
# libepoxy              ✅ Required by many apps
# libva                 ✅ VA-API loader (video encode/decode)
# libvdpau              ✅ VDPAU loader (va-api üzerinden çalışır)
# libva-utils           ✅ vainfo
# vdpauinfo             ✅ vdpauinfo
# mesa-utils            ✅ glxinfo
# vulkan-tools          ✅ vulkaninfo
# vulkan-mesa-imlicit-layers ✅ gerekli (vulkan loader tarafından otomatik yüklenir)

# libva-nvidia-driver
# linux-firmware-nvidia
# nvidia-open
# nvidia-utils

# Enable NVIDIA power services if you use as primary gpu
systemctl enable nvidia-suspend
systemctl enable nvidia-hibernate
systemctl enable nvidia-resume

# linux-firmware-radeon   ❌ (legacy gpus only)
# mesa-amber              ❌ legacy OpenGL
# libva-intel-driver      ❌ Intel only
# libva-nvidia-driver     ❌ NVIDIA only
# libvdpau-va-gl          ❌ fallback/translation layer
# vulkan-mesa-layers      ❌ gerekli değil (debug için kullanılır, uygulama isterse yüklenir)
# mangohud                ❌ oyunlarda gerekli (opsiyonel)


# DISABLE NVIDIA and NOUVEAU discrete GPUs
# 1. create an efistub entry withoud nvidia parameters.
# 2. remove nvidia related packages from system (linux-firmware-nvidia, libva-nvidia-driver nvidia-open nvidia-utils)
# 3. blacklist nvidia and nouveau drivers in /etc/modprobe.d/blacklist-nvidia.conf = This blocks loading these modules.
# 4. edit your /etc/mkinitcpio.conf file and remove nvidia related MODULES.
# 5. regenerate "initramfs" file by running: mkinitcpio -P
# 6. reboot the machine
# 7. check the status of nvidia cards:

# See the GPUs on the machine (even they are not loaded)
# $ lspci | grep -E "VGA|3D|Display" 
01:00.0 VGA compatible controller: NVIDIA Corporation AD106M [GeForce RTX 4070 Max-Q / Mobile] (rev a1)
65:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Phoenix1 (rev c1)

# Now you know the pci ID of the card (01:00.0 for nvidia here)
# $ cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status
# if this command returns "active" your nvidia card still consuming power even it is not loaded.

# $ cat /sys/bus/pci/devices/0000:01:00.0/power/control ---> this can be on|auto
# we should set this to "auto" to sleep our nvidia card. (stop consuming power)
# $ echo auto | sudo tee /sys/bus/pci/devices/0000:01:00.0/power/control

# Now we should see it is suspended indeed.
cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_suspended_time
cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status
# suspended

# You can also see the loaded modules:
# $ lsmod | grep -E "nvidia|nouveau"
# nvidia_wmi_ec_backlight    12288  0
# video                  81920  4 nvidia_wmi_ec_backlight,asus_wmi,amdgpu,asus_nb_wmi
# wmi                    32768  4 video,nvidia_wmi_ec_backlight,asus_wmi,wmi_bmof

# nvidia_wmi_ec_backlight does not mean your "nvidia|nouveau" modules are loaded! Seeing this is fine.
# if nvidia was active you would see: nvidia nvidia_modeset nvidia_uvm nvidia_drm
# if nouveau was active you would see: nouveau ttm drm_kms_helper

# Test komutları
glxinfo -B
vkcube
vdpauinfo                 # Shows details about capabilities of the GPU.
lscpu                     # Shows details about the CPU.
nvidia-smi                # Check the status of your NVIDIA GPU.
vulkaninfo

------------------------------------------------------------------------

(not installed => smartmontools, ethtool, sof-firmware, alsa-firmware, sof-tools, yt-dlp)

# Sound and media sessions configuration
run0 pacman -Syu pipewire pipewire-jack pipewire-alsa pipewire-pulse pipewire-audio wireplumber

# INSTALL ESSENTIAL PACKAGES
run0 pacman -S foot                  # terminal
run0 pacman -S fnott libnotify       # notifier
run0 pacman -S fuzzel                # app runner
run0 pacman -S yazi                  # tui file manager
run0 pacman -S bottom                # process viewer (alternative to "btop")
run0 pacman -S brightnessctl         # screen brightness utility
run0 pacman -S slurp grim swappy     # screenshot utilities
run0 pacman -S wl-clipboard cliphist # clipboard utilities
run0 pacman -S impala                # tui network manager
run0 pacman -S ly                    # greeter
run0 pacman -S bluez bluetui bluez-utils bluez-obex # bluetooth utilities

run0 pacman -S eza      # alternative for `ls`
run0 pacman -S procs    # alternative for `ps`
run0 pacman -S dust     # alternative for `du`
run0 pacman -S ripgrep  # alternative for `grep`
run0 pacman -S bat      # alternative for `cat`
run0 pacman -S fd       # alternative for `find`
run0 pacman -S diskus   # alternative for `du -sf`
run0 pacman -S fzf  # command line fuzzy finder
run0 pacman -S jq   # command line json processor

run0 pacman -S mpv
run0 pacman -S ffmpeg

run0 pacman -S exiv2  # image metadata manipulation tool
run0 pacman -S wireguard-tools openvpn # needed for vpn connection

run0 pacman -S hexyl  # command line hex viewer
run0 pacman -S nushell  # alternative for `bash`
run0 pacman -S gnome-calculator
run0 pacman -S nfs-utils             # nfs for network file sharing
run0 pacman -S samba                 # samba for network file sharing
run0 pacman -S poppler poppler-glib  # pdf rendering library
run0 pacman -S rsync    # sync between 2 machines
run0 pacman -S rclone   # sync with cloud provider

# Other tools that might be useful
run0 pacman -S imagemagick # chafa # imv? ueberzugpp?
run0 pacman -S qemu-full # hardware acceleration for emulators
# run0 pacman -S tectonic # required to render LaTeX math expressions
# run0 pacman -S openslide
# run0 pacman -S ufw # not needed since `iptables` already installed)


# THEMING
ln -sf "${THEME_DIR}/gtk-4.0/assets" "${HOME}/.config/gtk-4.0/assets" &&
ln -sf "${THEME_DIR}/gtk-4.0/gtk.css" "${HOME}/.config/gtk-4.0/gtk.css" &&
ln -sf "${THEME_DIR}/gtk-4.0/gtk-dark.css" "${HOME}/.config/gtk-4.0/gtk-dark.css"

ln -sf "${THEME_DIR}/gtk-3.0/assets" "${HOME}/.config/gtk-3.0/assets" &&
ln -sf "${THEME_DIR}/gtk-3.0/gtk.css" "${HOME}/.config/gtk-3.0/gtk.css" &&
ln -sf "${THEME_DIR}/gtk-3.0/gtk-dark.css" "${HOME}/.config/gtk-3.0/gtk-dark.css"

bat cache --build
fc-cache -f -v

# INSTALL FILESYSTEMS
run0 pacman -S ntfs-3g exfatprogs     # e2fsprogs
run0 pacman -S gvfs-mtp gvfs-smb gvfs # needed when connecting android with mtp

# INSTALL COMPRESSION ARCHIVING TOOLS
run0 pacman -S unzip 7zip

# INSTALL DEVELOPMENT TOOLS
run0 pacman -S git gitui
git --version

run0 pacman -S rustup # rust-analyzer
rustup default stable
cargo --version
rustc --version
rustup update
cargo install rustlings
# cargo install ast-grep ??

run0 pacman -S go  # gopls delve go-tools gofumpt
go version
go telemetry off

run0 pacman -S python uv # python-pip => uv is better than pip
# run0 pacman -S python-debugpy python--pudb
python --version
uv --version

run0 pacman -S kotlin gradle jdk-openjdk clang gcc 

run0 pacman -S crun podman podman-compose # podman is the os alternative to docker
crun --version
podman --version
podman-compose --version

run0 pacman -S pnpm bun unzip

run pacman -S nginx  # server
nginx -version

run0 pacman -S sqlite postgresql
sqlite3 --version
postgresql --version

run0 pacman -S lua lua-language-server stylua # luarocks?
lua -v
stylua --version
#
# run0 pacman -S zig
# zig --version

run0 pacman -S tree-sitter tree-sitter-bash tree-sitter-c tree-sitter-cli tree-sitter-bash tree-sitter-javascript tree-sitter-lua tree-sitter-markdown tree-sitter-python tree-sitter-query tree-sitter-rust tree-sitter-vim tree-sitter-vimdoc

# LAZY VIM
cd ~
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim

pacman -Syu tmux

# CREATE A VIRTUAL ENVIRONMENT in ~ FOR PYTHON MODULES (to isolate from system packages)
cd ~
python -m venv venv
source venv/bin/activate
(venv) uv install debugpy

# CONFIGURE GITHUB AND SSH
mkdir ~/.ssh
ssh-keygen -t ed25519 -C "your_email@example.com"
  # > Generating public/private ALGORITHM key pair.
  # > Enter a file in which to save the key (/home/YOU/.ssh/id_ALGORITHM):[Press enter]
  # > Enter passphrase (empty for no passphrase): [Type a passphrase]
  # > Enter same passphrase again: [Type passphrase again

# Copy the following files from the repository:
# ~/.gitignore_global
# ~/.gitconfig
# ~/.ssh/config

# Add your PUBLIC ssh key to github (authentication key and signing key)
ssh -T git@github.com # Test SSH connection

# INSTALL HYPRLAND and WAYBAR
run0 pacman -S qt5ct qt6c
run0 pacman -S gtk3 gtk4
run0 pacman -S qt5-wayland qt6-wayland
run0 pacman -S hyprland hypridle hyprcursor hyprpaper hyprlock \
               hyprland-protocols hyprpolkitagent hyprsunset \
               hyprutils hyprpicker waybar \
               xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

# TAKE SNAPSHOT w/ BTRFS
# takes snapshot (the snapshot is stored as a subvolume)
btrfs subvolume snapshot /source /destination
# backup (then you change related subvol or subvolid in /etc/fstab file and then reboot)
run0 cp /etc/fstab /etc/fstab.bak

btrfs filesystem usage /
btrfs filesystem df /

# PACMAN LOCK
# If pacman fails to sync repository (unable to unlock db) try:
run0 find / -name "db.lck" 2>/dev/null 
# (possibly it will return '/var/lib/pacman/db.lck'
run0 rm /var/lib/pacman/db.lck
pacman -Syy
```

```bash
# WIREGUARD CONFIGURATION
# Wireguard settings: assume you name the file as "linux-vpn.conf"
wg-quick up /etc/wireguard/linux-vpn.conf
systemctl enable wg-quick@linux-vpn.service
systemctl start wg-quick@linux-vpn.service
ufw route allow out on wlan0
chown root:root /etc/wireguard/linux-vpn.conf
chmod 0640 /etc/wireguard/linux-vpn.conf
```

```bash
# INSTALL THE PACKAGES
curl -O https://raw.githubusercontent.com/budidak/dotconfig/refs/heads/main/packages.txt  # Download the text file.
pacman -S --needed - < packages.txt  # Install the packages from the text file.
```

#### MOUNT YOUR ANDROID DEVICE THROUGH MTP

The Media Transfer Protocol (MTP) is a protocol that enables us to transfer data between two devices. MTP is primarily used in devices running the Android operating system.

```bash
# `gvfs-mtp` package is needed to run `gio` command.

lsusb | grep -i #<smartphone_etc...>
# Bus 001 Device 006: ID 2717:ff48 Xiaomi Inc. Mi/Redmi series (MTP + ADB)

# Alternatively, you can use `gio` to detect the device.
gio mount -li | grep activation_root
# activation_root=mtp://Xiaomi_Xiaomi_11T_Pro_44beaf3c/

# MOUNT
gio mount "mtp://Xiaomi_Xiaomi_11T_Pro_44beaf3c/"

# Alternatively, MOUNT using [Bus,Device] numbers
gio mount "mtp://[usb:001,006]/"

# ACCESS MOUNTED DEVICES
ls /run/user/1000/gvfs # 1000 for UID

# UNMOUNT
gio mount -u "mtp://Xiaomi_Xiaomi_11T_Pro_44beaf3c/"
```

#### INSTALL FLUTTER

```bash
run0 pacman -S ninja cmake # build tools for `flutter`
# You do not need to install "dart" package, since it's already included in Flutter SDK.
cd ~
git clone https://github.com/flutter/flutter.git
which flutter
which dart
flutter channel stable
flutter channel
flutter doctor --disable-analytics
flutter create `project_name` # this uses default settings

flutter create --description "Only app you need to stay fit" --platforms android \
               --org `org.budidak` --project-name `stay_fit` stay_fit
```

#### ANDROID SDK

Download the following files and place it under **~/Android/Sdk/** (which is set as $ANDROID_HOME environment variable)

- Command Line Tools: <https://developer.android.com/studio#command-tools>
  - unzip this archive, then move the 'cmdline-tools' into ~/android_sdk
  - create a subfolder latest/ inside cmdline-tools/, and move everything in it to cmdline-tools/latest/

```bash
cd ~/android_sdk

# List all available components
sdkmanager --list | grep -i platform-tools
sdkmanager --list | grep -i platforms
sdkmanager --list | grep -i build-tools
sdkmanager --list | grep -i system-images

# Download tools and images
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"
sdkmanager "system-images;android-36;google_apis_playstore;x86_64"

# Create an emulator
echo "no" | avdmanager --verbose create avd --force --name "Android_36" --package "system-images;android-36;google_apis_playstore;x86_64" --tag "google_apis_playstore" --abi "x86_64"

flutter doctor --android-licenses
flutter doctor -v
# flutter config --android-sdk /home/by/android_sdk
# This step is needed if it can't find sdk on the system

# List available emulators
emulator -list-avds

# Open emulator
emulator @Android_36

# Cold start emulator
emulator @Android_36 -no-snapshot-load

# (OPTIONAL)Config your emulator, reference this --> https://developer.android.com/studio/run/emulator-commandline
nvim ~/.android/avd/Android_36.avd/config.ini
# PlayStore.enabled=true
# abi.type=x86_64
# avd.ini.displayname=Pixel 3 API 30
# avd.ini.encoding=UTF-8
# disk.dataPartition.size = 6442450944
# fastboot.chosenSnapshotFile=
# fastboot.forceChosenSnapshotBoot=no
# fastboot.forceColdBoot=no
# fastboot.forceFastBoot=yes
# hw.accelerometer=yes
# hw.arc=false
# hw.audioInput=yes
# hw.battery=yes
# hw.camera.back=webcam0
# hw.camera.front=emulated
# hw.cpu.arch=x86_64
# hw.cpu.ncore=4
# hw.dPad=no
# hw.device.hash2=MD5:8a60718609e0741c7c0cc225f49c5590
# hw.device.manufacturer=Google
# hw.device.name=pixel_3
# hw.gps=yes
# hw.gpu.enabled=yes
# hw.gpu.mode=auto
# hw.initialOrientation=Portrait
# hw.keyboard=yes
# hw.lcd.density=440
# hw.lcd.height=2160
# hw.lcd.width=1080
# hw.mainKeys=no
# hw.ramSize=1536
# hw.sdCard=yes
# hw.sensors.orientation=yes
# hw.sensors.proximity=yes
# hw.trackBall=no
# image.sysdir.1=system-images/android-31/google_apis_playstore/x86_64/
# runtime.network.latency=none
# runtime.network.speed=full
# sdcard.path=/Users/localadm/.android/avd/Pixel_3_API_30.avd/sdcard.img
# sdcard.size=512 MB
# showDeviceFrame=no
# skin.dynamic=yes
# skin.name=1080x2160
# skin.path=_no_skin
# skin.path.backup=_no_skin
# tag.display=Google Play
# tag.id=google_apis_playstore
# vm.heapSize=256
```

#### CONNECT YOUR PHYSICAL DEVICE (WIRELESS DEBUGGING THROUGH ADB)

0. Enable **Developer Mode** on the android device by tapping OS version few times.
1. Connect the adb host computer and the android phone to same network.
2. Connect the device to the host computer with a USB cable.
3. Run `adb devices` command.
4. Set the target device to listen for a TCP/IP connection on port 5555 `adb tcpip 5555`
5. Find the IP address of the android device.
6. Connect to the device by its IP address. Like: `adb connect 192.168.1.160`
7. Now you can remove the USB cable.
8. To end the connection: `adb kill-server`

NOTE: Make sure you enable the following options:

- USB DEBUGGING
- INSTALL VIA USB
