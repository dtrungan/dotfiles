# Arch Linux installation guide

This is my personal guide for installing Arch Linux, whether on real hardware or in a virtual machine. While tailored to my setup, I believe it can still be helpful if you're starting from scratch.

I also recommend reading the official Arch Linux installation [guide](https://wiki.archlinux.org/title/Installation_guide). The process offers valuable insight into how Linux systems work.

## Pre-installation

### Verify EFI-enabled BIOS

This guide assumes you're using a system with EFI-enabled BIOS. To verify:

```
# ls /sys/firmware/efi/efivars
```

If this directory exists, EFI is enabled and you're good to go.

### Connect to the internet

To connect to WiFi, use the interactive `iwctl` utility:

#### Launch the interactive `iwd` shell

```
# iwctl
```

#### List wireless devices

```
[iwd]# device list
```

This shows your wireless interface (e.g., `wlan0`, `wlp2s0`). Replace `DEVICE` with your actual device name in the next steps.

#### Scan for and list available Wi-Fi networks

```
[iwd]# station DEVICE scan
[iwd]# station DEVICE get-networks
```

#### Connect to a Wi-Fi network

```
[iwd]# station DEVICE connect SSID
```

Replace `SSID` with your network's name. If it's password-protected, you'll be prompted to enter it.

#### Exit `iwd` shell

```
[iwd]# exit
```

Check your connection:

```
# ping 8.8.8.8
```

### Partition the disks

We'll refer to your primary disk as `sda`. Confirm it:

```
# lsblk
```

We'll assume a 256GB disk with only Arch Linux installed. Create these four partitions:

* `/dev/sda1` boot partition (1G).
* `/dev/sda2` root partition (50G).
* `/dev/sda3` home partition (100G).
* `/dev/sda4` data partition (rest of the disk).

Start partitioning:

```
# gdisk /dev/sda
```

#### Clear existing partition table

```
Command: o
This will create a new empty GUID partition table (GPT). Proceed? (Y/N): y
```

#### Create EFI system partition (`/boot/efi`)

```
Command: n
Partition number (default): ENTER
First sector (default): ENTER
Last sector (+size or sector): +1G
Hex code or GUID (default 8300): ef00
```

#### Create root partition (`/`)

```
Command: n
Partition number (default): ENTER
First sector (default): ENTER
Last sector (+size or sector): +50G
Hex code or GUID (default 8300): 8304
```

#### Create home partition (`/home`)

```
Command: n
Partition number (default): ENTER
First sector (default): ENTER
Last sector (+size or sector): +100G
Hex code or GUID (default 8300): 8302
```

#### Create data partition

```
Command: n
Partition number (default): ENTER
First sector (default): ENTER
Last sector (+size or sector): ENTER
Hex code or GUID (default 8300): ENTER
```

#### Save and exit

```
Command: w
This will write the partition table to disk and exit. Proceed? (Y/N): y
```

#### Format partitions

```
# mkfs.fat -F32 /dev/sda1
# mkfs.ext4 /dev/sda2
# mkfs.ext4 /dev/sda3
# mkfs.ext4 /dev/sda4
```

#### Mount partitions

```
# mount /dev/sda2 /mnt
# mkdir -p /mnt/{boot/efi,home}
# mount /dev/sda1 /mnt/boot/efi
# mkdir /dev/sda3 /mnt/home
```

If you run the `lsblk` command you should see something like this:

```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 238.5G  0 disk
├─sda1   8:1    0     1G  0 part /mnt/boot/efi
├─sda2   8:2    0    50G  0 part /mnt
├─sda3   8:3    0   100G  0 part /mnt/home
└─sda4   8:4    0  87.5G  0 part
```

## Installation

### Update the system clock

```
# timedatectl set-ntp true
```

### Install packages

```
# pacstrap /mnt base base-devel linux linux-firmware vim
```

Replace `vim` with `nano` if you prefer.

### Generate fstab

```
# genfstab -U /mnt >> /mnt/etc/fstab
```

## Add basic configuration

### Enter the new system

```
# arch-chroot /mnt
```

### Set up locale

```
# vim /etc/locale.gen
```

Uncomment your preferred locale, e.g.:

```
en_US.UTF-8 UTF-8
```

Generate locale:

```
# locale-gen
```

Create locale configuration:

```
# vim /etc/locale.conf
```

Add:

```
LANG=en_US.UTF-8
LANGUAGE=en_US
LC_ALL=C
```

Set keyboard layout:

```
# vim /etc/vconsole.conf
```

Add:

```
KEYMAP=us
```

### Set timezone

Using `Asia/Saigon` as example:

```
# ln -sf /usr/share/zoneinfo/Asia/Saigon /etc/localtime
# hwclock —-systohc
```

### Enable SSH, DHCP and NetworkManager

These services will be started automatically when the system boots up.

```
# pacman -S openssh dhcpcd networkmanager network-manager-applet
# systemctl enable sshd
# systemctl enable dhcpcd
# systemctl enable NetworkManager
```

### Install bootloader

```
# pacman -S grub efibootmgr
# grub-install --efi-directory=/boot/efi --bootloader-id="Arch Linux"
# grub-mkconfig -o /boot/grub/grub.cfg
```

If dual booting with Windows, do this before generating GRUB config:

```
# pacman -S os-prober fuse3
# vim /etc/default/grub
```

Uncomment:

```
GRUB_DISABLE_OS_PROBER=false
```

This enables `os-prober` so GRUB can detect Windows during boot configuration.

### Set hostname

Assuming your computer is known as "arch":

```
# echo arch > /etc/hostname
```

### Configure hosts file

```
# vim /etc/hosts
```

And add this content to the file:

```
127.0.0.1    localhost.localdomain   localhost
::1          localhost.localdomain   localhost
127.0.0.1    arch.localdomain        arch
```

Replace "arch" with your computer name.

### Install additional packages

```
# pacman -S intel-ucode git xdg-user-dirs
# pacman -S alsa-firmware alsa-plugins alsa-utils pavucontrol pipewire-pulse wireplumber pipewire-alsa pipewire-jack sof-firmware
```

### Set root password

```
# passwd
```

### Exit and reboot

```
# exit
# umount -R /mnt
# reboot
```

## Post-install configuration

Now your computer has restarted and in the login window on the tty1 console you can log in with the root user and the password chosen in the previous step.

### Create a user

Assuming your chosen user is "arch":

```
useradd -m -g users -G wheel,storage,power,audio arch
passwd arch
```

### Give root privileges

```
# EDITOR=vim visudo
```

Uncomment:

```
%wheel ALL=(ALL:ALL) ALL
```

### Login in as the new user

```
# su - thinkpad
$ xdg-user-dirs-update
```

### Install AUR package manager

In this guide we'll install [yay](https://github.com/Jguer/yay) as the AUR package manager.

To install `yay`, run the following commands:

```
$ mkdir Repositories
$ cd Repositories
$ git clone https://aur.archlinux.org/yay.git
$ cd yay
$ makepkg -si
```

### Make Pacman look cooler

To enhance the appearance of Pacman, edit its configuration file to enable colored output and add a fun animation.

```
$ sudo vim /etc/pacman.conf
```

Then, uncomment the `Color` option and add the `ILoveCandy` option just below it.

### Manage Bluetooth

```
$ sudo pacman -S bluez bluez-utils blueman
$ sudo systemctl enable bluetooth
```

### Improve laptop battery consumption

```
$ sudo pacman -S tlp tlp-rdw powertop acpi thermald
$ sudo systemctl enable tlp
$ sudo systemctl mask systemd-rfkill.service
$ sudo systemctl mask systemd-rfkill.socket
$ sudo systemctl enable thermald
```

## UI related step

### Install graphical environment and i3

For this guide, we will install i3 as the window manager for our Arch Linux setup. i3 is a lightweight and highly configurable tiling window manager that allows you to manage windows efficiently using keyboard shortcuts. More about [i3 here](https://i3wm.org/).

```
$ sudo pacman -S xorg i3
```

### Install display manager

```
$ sudo pacman -S ly
$ sudo systemctl enable ly
```

### Install some basic fonts

```
$ sudo pacman -S noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra
$ sudo pacman -S ttf-bitstream-vera ttf-dejavu ttf-liberation ttf-opensans
```

### Install i3 utilities and GUI apps

```
$ sudo pacman -S kitty nautilus dmenu firefox
```

### Apply previous settings

```
$ sudo reboot
```

## Ricing

I use [GNU Stow](https://www.gnu.org/software/stow/) to manage my dotfiles by creating symbolic links between this repository and the appropriate locations in my home directory.

To set up the dotfiles:

```
$ git clone https://github.com/dtrungan/dotfiles.git
$ cd dotfiles
$ stow -t ~ .bashrc .config .tmux.conf
```

As for the `etc` directory, it only contains my custom touchpad configuration. Since it targets system-wide settings, I copy it directly to the root directory:

```
$ sudo cp -r etc /
```