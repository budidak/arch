# Arch Linux

This is a custom configuration guide for my Arch Linux setup.

## Pre-installation

Acquire the ISO file and the respective signature.
It is recommended to verify the image signature before use.
You need the checksum file to compare results: sha256sums.txt or b2sums.txt

```sh
b2sum -c b2sums.txt
```

Then boot the live environment from USB.

> Note: Arch Linux installation images do not support Secure Boot.

## Installation

```sh
# Load your keyboard for setup.
loadkeys trq
# List block devices including info about filesystems.
lsblk -f
# Erase all magic strings on specified block device.
# `/dev/sd?` for hdd & sata ssd devices
# `/dev/nvme?` for nvme ssd devices
wipefs -a /dev/?
```

Many laptops have a hardware button (or switch) to turn off the wireless card; however, the card can also be blocked by the kernel.
This can be handled by rfkill(8). To show the current status:

```sh
rfkill  # Tool for enabling and disabling wireless devices.
# ID TYPE      DEVICE      SOFT      HARD
#  0 bluetooth hci0   unblocked unblocked
#  1 wlan      phy0   unblocked unblocked
```

- If the card is hard-blocked, use the hardware button (switch) to unblock it.
- If the card is not hard-blocked but soft-blocked, use the following command:

```sh
rfkill unblock wlan0
ip link set `interface` up
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

> To see badsectors on the disk, perform the following test.

```sh
# check and repair a Linux filesystem BEFORE MOUNTING
fsck -c /dev/?
```

If it just stops with a message about end of file, the drive is fine.
This method is also way faster than badblocks even with a single pass.
As the command does a full write, any bad sectors should also be eliminated.

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
mkfs.fat -F 32 --codepage=437 -n "UEFI" /dev/?
mkfs.btrfs --csum "xxhash" -L "ROOT" /dev/?

# check fs integrity for the btrfs filesystem before mounting it.
# /dev/nvme0n1p2 for nvme, /dev/sda2 for sata
btrfs check /dev/?

# btrfs filesystem mount options
BTRFS_OPTS="defaults,rw,noatime,compress=lzo,ssd,discard=async"
# mount btrfs filesystem on /mnt directory
mount -t btrfs -o $BTRFS_OPTS /dev/? /mnt

# create subvolumes on the mounted btrfs filesystem
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs su cr /mnt/@srv
btrfs su cr /mnt/@var
btrfs su cr /mnt/@opt
# list defined subvolumes on /mnt directory
btrfs su list /mnt

# unmount the btrfs filesystem
umount /mnt

# mount the btrfs filesystem again, mounting @ subvolume on /mnt this time.
mount -t btrfs -o $BTRFS_OPTS,subvol=@ /dev/? /mnt

# create directories for the subvolumes
mkdir -p /mnt/{boot,home,.snapshots,srv,var,opt}

# mount subvolumes on matching directories
mount -t btrfs -o $BTRFS_OPTS,subvol=@home /dev/? /mnt/home
mount -t btrfs -o $BTRFS_OPTS,subvol=@snapshots /dev/? /mnt/.snapshots
mount -t btrfs -o $BTRFS_OPTS,subvol=@srv /dev/? /mnt/srv
mount -t btrfs -o $BTRFS_OPTS,subvol=@var /dev/? /mnt/var
mount -t btrfs -o $BTRFS_OPTS,subvol=@opt /dev/? /mnt/opt

# start a new scrub on the btrfs filesystem, /dev/nvme0n1p2
btrfs scrub start /dev/?
btrfs scrub status /dev/?

# efi filesystem mount options
EFI_OPTS="defaults,noatime,usefree,codepage=437,iocharset=utf8,utf8"
# mount boot partition on /mnt/boot directory
# /dev/nvme0n1p1 for nvme, /dev/sda1 for sata
mount -t vfat -o $EFI_OPTS /dev/? /mnt/boot
```

### Connect to an Internet

```sh
iwctl
# device list
# station list
# station <device> scan
# station <device> get-networks
# station <device> connect <ssid>
# ---> Enter password for the selected network
# exit

# check if the device has an assigned IP address
ip a
# You should be able to ping a remote server if you connected successfully.
ping archlinux.org
# query or change system time and date settings
timedatectl
```

### Base installation

```sh
# edit pacman related settings, enable/disable repositories.
vim /etc/pacman.conf
# Edit your mirrors.
vim /etc/pacman.d/mirrorlist
# Force sync repositories.
pacman -Syyu

# ASUS TUFA15 FA507XI LAPTOP:
# CPU: AMD Ryzen9 7940HS w/ AMD Radeon 780M iGPU
# GPU: NVIDIA GeForce RTX 4070
# amd-ucode is needed for CPU
# linux-firmware-amdgpu for iGPU
# linux-firmware-nvidia for GPU
# linux-firmware-mediatek for LAN, WLAN, Bluetooth
pacstrap -K /mnt base base-devel \
                 linux linux-headers \
                 amd-ucode \
                 linux-firmware-amdgpu \
                 linux-firmware-nvidia \
                 linux-firmware-mediatek \
                 polkit iwd neovim
# If you don't want to install `sudo` you can bypass it with:
# pacman -S <packages> --assume-installed=<packages>
# pacstrap -K /mnt <packages> --assume-installed=sudo

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

# Install the packages you need.
pacman -S btrfs-progs curl wget efibootmgr plymouth pacman-contrib cronie
pacman -S texinfo less man-db man-pages bc tree
pacman -S noto-fonts noto-fonts-emoji ttf-hack ttf-hack-nerd
pacman -S pciutils usbutils inetutils dmidecode inxi

# Create a symbolic link for timezone information.
ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
# Sync your hardware clock.
hwclock --systohc

# Edit /etc/locale.gen
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
nvim /etc/systemd/network/10-wireless.network
  # [Match]
  # Name=wlan0
  #
  # [Link]
  # RequiredForOnline=routable
  #
  # [Network]
  # DHCP=yes
  # DNS=9.9.9.9
  # DNS=149.112.112.112

nvim /etc/systemd/network/20-wired.network
  # [Match]
  # Name=enp2s0
  #
  # [Link]
  # RequiredForOnline=routable
  #
  # [Network]
  # DHCP=yes
  # DNS=9.9.9.9
  # DNS=149.112.112.112

# set a password for the root user
passwd

# create a user: by
# -m to create home directory for the user
# -G to add the user to a group
# -s to set shell for the user
useradd -m -G wheel -s /bin/bash by

# set a password for the user `by`
passwd by

# Save the UUID value for the root partition into ROOT_UUID
ROOT_UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)
echo $ROOT_UUID

# Edit /etc/mkinitcpio.conf
# I added `nvidia` related modules since I use it as my primary GPU.
# "btrfs" hook should be between "block" and "filesystems" hooks.
# "plymouth" is needed to show nice animation when booting/shutting down the system.
# "numlock" hook needs `mkinitcpio-numlock (AUR)` package.
# "resume, shutdown, sleep" hooks for cleanup.
# Order of hooks matters.
nvim /etc/mkinitcpio.conf
  # MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
  # BINARIES=()
  # FILES=()
  # HOOKS=(base udev autodetect microcode modconf kms plymouth keyboard keymap consolefont numlock block btrfs filesystems resume shutdown sleep fsck)
  # COMPRESSION="zstd"
  # COMPRESSION_OPTIONS=(-v -5 --long -T0)
  # MODULES_DECOMPRESS="yes"

# I removed the `fallback` from PRESETS and commented the fallback line: To prevent generation of initramfs fallback image.
nvim /etc/mkinitcpio.conf.d/linux.preset
  # ALL_kver="/boot/vmlinuz-linux"
  # PRESETS=('default')
  # default_image="/boot/initramfs-linux.img"

# Create a new initramfs (new kernel image)
mkinitcpio -P

# I don't need any additional bootloader since I use 1 OS on my machine.
# With that reason I continue the installation with EFI Boot stub.
efibootmgr --unicode   # List all efistub entries.
efibootmgr -b 0000 -B  # Delete the record labeled with 0000. (Delete all unneccessary entries 0000, 0001, 0002...)

# Create a new efistub entry.
efibootmgr --create \
           --disk /dev/nvme0n1 \
           --part 1 \
           --label "Arch Linux" \
           --loader "\vmlinuz-linux" \
           --unicode "root=UUID=$ROOT_UUID rw rootflags=subvol=@ loglevel=3 quiet splash \
                      nvidia-drm.modeset=1 nvidia-drm.fbdev=1 NVreg_PreserveVideoMemoryAllocations=1 \
                      initrd=\amd-ucode.img initrd=\initramfs-linux.img"

# exit the chrooted environment
exit

# unmount the filesystem /mnt recursively
umount -R /mnt

# reboot the machine
reboot

# I added/edited following files so far:
# etc/
#     -- mkinitcpio.conf.d/
#         -- linux.preset
#     -- modprobe.d/
#         -- nvidia-pm.conf
#         -- nvidia.conf
#     -- pacman.d/
#         -- mirrorlist
#     -- plymouth/
#         -- plymouthd.conf
#     -- systemd/
#         -- network/
#             -- 10-wireless.network
#             -- 20-wired.network
#         -- system/
#             -- plymouth-wait-for-animation.service
#     -- udev/
#         -- rules.d/
#             -- 80-nvidia-pm.rules
#     -- fstab
#     -- hostname
#     -- hosts
#     -- locale.conf
#     -- locale.gen
#     -- localtime
#     -- mkinitcpio.conf
#     -- pacman.conf
#     -- resolv.conf
#     -- sudoers
#     -- tlp.conf
#     -- vonsole.conf
```

## AFTER REBOOT

```bash
# Enable services
run0 systemctl enable dbus
run0 systemctl enable iwd
run0 systemctl enable systemd-networkd
run0 systemctl enable systemd-resolved

# Start services
run0 systemctl start dbus
run0 systemctl start iwd
run0 systemctl start systemd-networkd
run0 systemctl start systemd-resolved

# Create symbolic link for network connection
run0 ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Adjust power management, and start its services.
run0 pacman -Syu tlp smartmontools ethtool
run0 systemctl enable tlp
run0 tlp start

# Sound and media sessions configuration
run0 pacman -Syu pipewire pipewire-jack pipewire-alsa pipewire-pulse pipewire-audio wireplumber
systemctl enable pipewire --user
systemctl enable wireplumber --user
systemctl enable pipewire-pulse --user
systemctl start pipewire --user
systemctl start wireplumber --user
systemctl start pipewire-pulse --user

# run0 pacman -S sof-firmware
# run0 pacman -S alsa-firmware
# run0 pacman -S sof-tools

# INSTALL ESSENTIAL PACKAGES
run0 pacman -S foot                  # terminal
run0 pacman -S fnott libnotify       # notifier
run0 pacman -S fuzzel                # app runner
run0 pacman -S yazi                  # tui file manager
run0 pacman -S btop                  # process viewer
run0 pacman -S brightnessctl         # screen brightness utility
run0 pacman -S slurp grim swappy     # screenshot utilities
run0 pacman -S wl-clipboard cliphist # clipboard utilities
run0 pacman -S ly                    # greeter
run0 pacman -S nfs-utils             # nfs for network file sharing
run0 pacman -S samba                 # samba for network file sharing
run0 pacman -S poppler poppler-glib  # pdf rendering library
run0 pacman -S bluez blueman bluez-utils bluez-obex # bluetooth utilities
run0 pacman -S rsync    # sync between 2 machines
run0 pacman -S rclone   # sync with cloud provider
run0 pacman -S wireguard-tools openvpn # needed for vpn connection
run0 pacman -S eza      # alternative for `ls`
run0 pacman -S procs    # alternative for `ps`
run0 pacman -S dust     # alternative for `du`
run0 pacman -S ripgrep  # alternative for `grep`
run0 pacman -S bat      # alternative for `cat`
run0 pacman -S fd       # alternative for `find`
run0 pacman -S diskus   # alternative for `du -sf`
run0 pacman -S nushell  # alternative for `bash`
run0 pacman -S fzf  # command line fuzzy finder
run0 pacman -S jq   # command line json processor
run0 pacman -S htmlq  # command line html processor
run0 pacman -S hexyl  # command line hex viewer
run0 pacman -S exiv2  # image metadata manipulation tool
run0 pacman -S gnome-calculator
run0 pacman -S mpv yt-dlp # media player (vlc alternative)

# Other tools that might be useful
run0 pacman -S imagemagick chafa # imv? ueberzugpp?
run0 pacman -S ffmpeg
run0 pacman -S qemu-full # hardware acceleration for emulators
# run0 pacman -S tectonic # required to render LaTeX math expressions
# run0 pacman -S openslide
# run0 pacman -S ufw # not needed since `iptables` already installed)
# run0 pacman -S prettier markdownlint-cli2


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
run0 pacman -S ntfs-3g exfatprogs e2fsprogs
run0 pacman -S gvfs-mtp gvfs-smb gvfs # needed when connecting android with mtp

# INSTALL COMPRESSION ARCHIVING TOOLS
run0 pacman -S lzo lz4 lzop lzip zip unzip 7zip gzip bzip2 xz zstd brotli #lrzip?

# INSTALL DEVELOPMENT TOOLS
run0 pacman -S git gitui
git --version

run0 pacman -S clang gcc
clang --version
gcc --version

run0 pacman -S rustup rust-analyzer
rustup default stable
cargo --version
rustc --version
rustup update
cargo install rustlings
# cargo install ast-grep ??

run0 pacman -S go gopls delve go-tools gofumpt
go version
go telemetry off

run0 pacman -S python uv # python-pip => uv is better than pip
# run0 pacman -S python-debugpy python--pudb
python --version
uv --version

run0 pacman -S jdk-openjdk # maven?
javac --version

run0 pacman -S kotlin
kotlinc --version

run0 pacman -S crun podman podman-compose # podman is the os alternative to docker
crun --version
podman --version
podman-compose --version

run0 pacman -S nodejs deno npm yarn pnpm
deno --version
node --version
npm --version
yarn --version
pnpm --version

run pacman -S nginx  # server
nginx -version

run0 pacman -S sqlite postgresql mariadb # sqlfluff?
sqlite3 --version
postgresql --version
mariab --version

run0 pacman -S lua lua-language-server stylua # luarocks?
lua -v
stylua --version

# run0 pacman -S ruby
# ruby --version
#
# run0 pacman -S php composer
# php --version
#
# run0 pacman -S cpanminus # package manager for `perl`
# cpanm --version
#
# run0 pacman -S julia
# julia --version
#
# run0 pacman -S zig
# zig --version

run0 pacman -S tree-sitter tree-sitter-bash tree-sitter-c tree-sitter-cli tree-sitter-bash tree-sitter-javascript tree-sitter-lua tree-sitter-markdown tree-sitter-python tree-sitter-query tree-sitter-rust tree-sitter-vim tree-sitter-vimdoc

# LAZY VIM
cd ~
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim

# Neovim providers????
# gem install neovim
# run0 pacman -Syu python-neovim
# run0 npm install -g neovim
# run0 cpanm Neovim::Ext --force

# CREATE A VIRTUAL ENVIRONMENT in ~ FOR PYTHON MODULES (to isolate from system packages)
cd ~
python -m venv venv
source venv/bin/activate
(venv) uv install debugpy
(venv) pip install debugpy
(venv) pip install --upgrade pip

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

# HYPRLAND PLUGINS INSTALL
run0 pacman -S make meson cpio glaze
hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
# Enable plugins with the command: `hyprpm enable <plugin-name>`
hyprpm enable hyprexpo
hyprpm enable hyprbars

# GPU TOOLS
run0 pacman -Syu nvidia-open-dkms nvidia-utils nvidia-settings \
                 nvtop libva-nvidia-driver libvdpau libvdpau-va-gl
# If you don't want nvidia:
run0 pacman -Syu mesa mesa-utils glu vulkan-radeon vulkan-tools vulkan-mesa-layers vulkan-icd-loader libvdpau-va-gl

# Enable NVIDIA power services
systemctl enable nvidia-suspend
systemctl enable nvidia-hibernate
systemctl enable nvidia-resume

# This returns 01:00.0, I see that this is the Nvidia device on my machine.
lspci | grep -i nvidia
# 01:00.0 VGA compatible controller: NVIDIA Corporation AD106M [GeForce RTX 4070 Max-Q / Mobile] (rev a1)

# if the output time increases through time: it means nvidia is sleeping when not in use
cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_suspended_time
cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status

lspci | grep -E 'VGA|3D'  # Lists all connected GPUs.
vdpauinfo                 # Shows details about capabilities of the GPU.
lscpu                     # Shows details about the CPU.
nvidia-smi                # Check the status of your NVIDIA GPU.
# lsmod | grep nvidia
# vulkaninfo

# Blocklist nouveau modules, and allow nvidia modules.
# See /etc/modprobe.d/ folder.

# INSTALL `yay` AUR HELPER
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -Sy brave-bin
yay -Sy beekeeper-studio-appimage

# INSTALL `paru` AUR HELPER
run0 pacman -Syyu
mkdir -p ~/aur
cd ~/aur
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
paru --version
paru -S brave-bin
paru -S beekeeper-studio-appimage

# SNAP INSTALL
run0 pacman -S apparmor squashfs-tools xfsprogs autoconf-archive python-docutils
git clone https://aur.archlinux.org/snapd.git
cd snapd
makepkg -si
sudo systemctl enable --now snapd.socket
sudo systemctl enable --now snapd.apparmor.service
sudo ln -s /var/lib/snapd/snap /snap
sudo snap install android-studio --classic
sudo snap install dbeaver-ce

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

### SUSPEND ISSUE == SYSTEM AUTOMATICALLY WAKES UP (not needed anymore)

Check your wakeup table using `cat /proc/acpi/wakeup` and look at **GPP0**. It should say **enabled\*. Using `run0 /bin/sh -c '/bin/echo GPP0 > /proc/acpi/wakeup'` you can set it to**disabled\*. PC should suspend normally then.

If it does then you can use a systemd (if you use it) service to run that command at boot.

```/etc/systemd/system/disable-wakeup.service
[Unit]
Description=Fix for the suspend issue
[Service]
Type=oneshot
ExecStart=/bin/sh -c "echo GPP0 > /proc/acpi/wakeup"
[Install]
WantedBy=multi-user.target
```

```bash
systemctl enable disable-wakeup.service
systemctl start disable-wakeup.service
```

You can try to edit kernel cmd:

```sh
run0 efibootmgr --create --disk /dev/nvme0n1 --part 1 --label "Arch Linux" --loader "\vmlinuz-linux" --unicode "root=UUID=$ROOT_UUID rw loglevel=3 quiet nvidia-drm.modeset=1 initrd=\amd-ucode.img initrd=\initramfs-linux.img nvidia.NVreg_PreserveVideoMemoryAllocations=1 acpi_sleep=nonvs no_console_suspend"
```


```sh
# TODO: Create localization files under /usr/share/i18n/locales/<en_US>
# TODO:
```
