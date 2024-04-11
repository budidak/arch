# INSTALLATION GUIDE

**Read the contents of this file carefully and use with caution! I am not responsible for any damage that you may cause to your computer. I do not give any guarantee for anything. I created this repository for myself, to remember my own custom setup.**

```bash
loadkeys trq # load your keymaps.

# 1. Connect to the internet.
# Plug the ethernet cable, it connects to a wired network automatically. If you don't have one, you need to connect to a wifi network:
ip a # look for the interface name (e.g. wlan0, wpl2s0...)
rfkill unblock wifi
ip link set ´interface´ up

iwctl
  > device list
  > station ´interface´ get-networks
  > station ´interface´ connect ´ssid´

ip  # check if your interface gets an ip
ping 127.0.0.1  # ping localhost
ping google.com # ping outer domain

# 2. Disk partition
lsblk -f  # look for the device you want to format (e.g. nvme0n1, sda1...)
wipefs -a /dev/nvme0n1
gdisk /dev/nvme0n1
  # gpt table
  # /dev/nvme0n1p1  --  1G                       EFI (ef00)
  # /dev/nvme0n1p2  --  100% of remaining space  LUKS (8309)

modprobe dm-crypt
modprobe dm-mod
mkfs.fat -F 32 -n ESP /dev/nvme0n1p1
cryptsetup luksFormat -v -s 512 -h sha512 /dev/nvme0n1p2
cryptsetup config /dev/nvme0n1p2 --label LUKS
cryptsetup open /dev/nvme0n1p2 enc # opens the encrypted partition with a name "enc"
mkfs.btrfs -L ROOT /dev/mapper/enc
BTRFS_OPTS="rw,noatime,compress=zstd:3,ssd,discard=async"
EFI_OPTS="uid=0,gid=0,fmask=0077,dmask=0077"
mount -o $BTRFS_OPTS /dev/mapper/enc /mnt
btrfs subvolume create /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@snapshots
umount /mnt
mount -o $BTRFS_OPTS,subvol=@ /dev/mapper/enc /mnt
mkdir /mnt/{boot,home,.snapshots}
mount -o $BTRFS_OPTS,subvol=@home /dev/mapper/enc /mnt/home
mount -o $BTRFS_OPTS,subvol=@snapshots /dev/mapper/enc /mnt/.snapshots
mount -o $EFI_OPTS /dev/nvme0n1p1 /mnt/boot

# 3. Installation of base system
pacman -Sy neovim
neovim /etc/pacman.conf # configure pacman
neovim /etc/pacman.d/mirrorlist # configure mirrors

pacstrap -K /mnt base base-devel linux linux-headers linux-firmware amd-ucode dosfstools btrfs-progs cryptsetup lvm2 iwd dhcpcd neovim

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

# 4. Chroot environment
pacman -Syu

ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
hwclock --systohc
hwclock --show

nvim /etc/locale.gen
  # en_US.UTF-8 UTF-8
locale-gen

nvim /etc/locale.conf
  # LANG=en_US.UTF-8
  # LC_COLLATE=C

nvim /etc/vconsole.conf
  # KEYMAP=trq

nvim /etc/hostname
  # arch

nvim /etc/hosts
  # 127.0.0.1   localhost
  # ::1         localhost
  # 127.0.1.1   arch.localdomain   arch

nvim /etc/resolv.conf
  # nameserver 9.9.9.9
  # namerserver 149.112.112.112

chattr +i /etc/resolv.conf # make the resolv.conf immutable

nvim /etc/pacman.conf
  # Color
  # CheckSpace
  # VerbosePkgLists
  # ParallelDownloads = 5
  # ILoveCandy
  # [lib32]
  # Include = /etc/pacman.d/mirrorlist

passwd # define root password

useradd -m -g users -G wheel -s /bin/bash ´username´
passwd ´username´  # define user password
usermod -aG storage,power,audio ´username´

export EDITOR=nvim
visudo  # edit sudoers file
  # %wheel ALL=(ALL:ALL) ALL

# Auto login (optional)
nvim /etc/runit/sv/agetty-tty1/conf
  # GETTY_ARGS="--noclear --autologin ´username´"

nvim /etc/mkinitcpio.conf
  # HOOKS=(...block encrypt lvm2 filesystems)
  # add "encrypt" and "lvm2" between the "block" and "filesystems"
  # make sure "microcode" is in the HOOKS array in /etc/mkinitcpio.conf

# 5. Boot Loader Configuration
EFI_UUID=$(blkid -s UUID -o value /dev/nvme0n1p1)
ROOT_UUID=$(blkid -s UUID -o value /dev/mapper/enc)
LUKS_UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)

# 5.1. Creating an EFISTUB entry
# pacman will directly update the kernel that the EFI firmware will read if you mount the ESP to /boot.
pacman -Syu efibootmgr
efibootmgr --unicode # list all boot entries
efibootmgr -b XXXX -B # delete the XXXX boot entry (optional, change XXXX with the actual boot number)
efibootmgr --create \
--disk /dev/nvme0n1 --part 1 \
--label "Arch Linux EFISTUB" \
--loader /vmlinuz-linux \
--unicode "root=UUID=$ROOT_UUID rw rootflags=subvol=@ loglevel=3 quiet initrd=\amd-ucode.img initrd=\initramfs-linux.img cryptdevice=UUID=$LUKS_UUID:enc"

# 5.2. Using systemd-boot
# Make sure that the system is booted into UEFI mode and UEFI variables are accessible.
efivar --list
ls /sys/firmware/efi/efivars # use if efivar is not installed. If the directory exists, the system is booted into UEFI mode.

bootctl install

nvim /boot/loader/loader.conf
  # default arch.conf
  # timeout 3
  # console-mode keep
  # editor no

nvim /boot/loader/entries/arch.conf
  # title Arch Linux
  # linux /vmlinuz-linux
  # initrd /amd-ucode.img
  # initrd /initramfs-linux.img
  # options root=UUID=$ROOT_UUID rw rootflags=subvol=@ loglevel=3 quiet cryptdevice=UUID=$LUKS_UUID:enc

# 6. Generating the initramfs image.
mkinitcpio -P

# 7. Exit the chroot environment and reboot
exit
umount -R /mnt
reboot
```

## Post Installation

### Common packages you might want to install.

- cmake gcc git go rustup nodejs python typescript npm yarn python-pip code curl wget
- man-pages man-db texinfo
- systemd-resolvconf wireguard-tools ufw openssh
- pipewire pipewire-alsa pipewire-pulse wireplumber
- acpi acpi_call acpid tlp
- slurp grim wl-clipboard (cliphist)
- sway swaybg swayidle swaylock swayimg wlroots foot mako wf-recorder  wlsunset wmenu kanshi fuzzel playerctl polkit xorg-xwayland xdg-desktop-portal-wlr
- pciutils usbutils sysfsutils inetutils net-tools device-mapper efibootmgr os-prober btop
- thunar thunar-volman thunar-archive-plugin thunar-media-tags-plugin gvfs lf tree mpv firefox
- bluez bluez-utils blueman
- cups cups-pdf cups-filters
- zip unzip
- noto-fonts
- ffmpeg ffmpeg4.4
- rsync rclone timeshift



- nvidia nvidia-utils nvidia-settings
- brightnessctl gammastep

- tmux wireshark-qt
- ttf-font-awesome

- cronie
- chrony
- libqalculate qalculate-gtk
- nginx
- postgresql
- xdg-desktop-portal xdg-desktop-portal-gtk
- dunst (mako)
- wayland wayland-protocols sdbus-cpp
- qt5-wayland qt6-wayland qt5ct qt6ct
- waybar
- polkit-kde-agent
- hyprland hypridle hyprlock hyprlang
- xdg-desktop-portal-hyprland

### Other packages

- rabbitmq rabbitmqadmin
- grpc
- redis
- openmpi
- nbd inxi
- alsa-firmware alsa-plugins alsa-utils
- exfat-utils exfatprogs ntfs-3g mtools
- metalog memtest86+-efi nfs-utils mkinitcpio-nfs-utils

## Enable your internet services

```bash
sudo systemctl enable dhcpcd
sudo systemctl enable iwd
sudo systemctl start dhcpcd
sudo systemctl start iwd
```

## Firewall settings

```bash
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw enable
ufw status verbose
# it should be: incoming=deny, outgoing=allowed
```

## Wireguard settings

Copy your configuration file provided by your vpn server into the /etc/wireguard/ folder.

```bash
systemctl enable systemd-resolved
systemctl start systemd-resolved

# assume you name the file as "linux-vpn.conf"
wg-quick up /etc/wireguard/linux-vpn.conf

systemctl enable wg-quick@linux-vpn.service
systemctl start wg-quick@linux-vpn.service

ufw route allow out on wlan0

chown root:root /etc/wireguard/linux-vpn.conf
chmod 0640 /etc/wireguard/linux-vpn.conf
```

## Activate your bluetooth

```bash
sudo systemctl enable bluetoothd
sudo systemctl start bluetoothd
```

## Load your favorite fonts

Download the fonts from **[CommitMono](https://commitmono.com/)**

Unzip the downloaded file and copy the contents into **/usr/share/fonst/commit-mono/** folder. 

Then run:

```bash
fs-cache -f -v

# You can now use your fonts as:
# CommitMono
# CommitMono Bold
# CommitMono Italic
```

## Nvidia related settings

Remember: Wayland does not have support for nvidia packages, use the open source ones if you need.

```bash 
sudo nvim /etc/modprobe.d/nvidia.conf
  # options nvidia-drm modeset=1

sudo nvim /etc/mkinitcpio.conf
  # MODULES=(nvidia nvidia-modeset nvidia-urm nvidia-drm)
sudo nvim /boot/loader/entries/arch.conf
  # nvidia_drm.modeset=1

mkinitcpio -P
```




SUPER + ENTER = open terminal
SUPER SHIFT + Q = kill window

sudo cp /etc/sway/config ~/.config/sway/config
swaymsg input type:keyboard xkb_layout "tr"