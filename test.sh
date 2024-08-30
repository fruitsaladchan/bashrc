#!/bin/bash/

# Configuration variables
DRIVE='/dev/sda'
HOSTNAME='host100'
ENCRYPT_DRIVE='TRUE'
DRIVE_PASSPHRASE='a'
ROOT_PASSWORD='a'
USER_NAME='user'
USER_PASSWORD='a'
TIMEZONE='America/New_York'
TMP_ON_TMPFS='TRUE'
KEYMAP='us'
VIDEO_DRIVER="i915"
WIRELESS_DEVICE="wlan0"

setup() {
    local boot_dev="${DRIVE}1"
    local lvm_dev="${DRIVE}2"
    partition_drive "$DRIVE"

    if [ -n "$ENCRYPT_DRIVE" ]; then
        local lvm_part="/dev/mapper/lvm"
        encrypt_drive "$lvm_dev" "${DRIVE_PASSPHRASE:-$(prompt_passphrase)}"
    else
        local lvm_part="$lvm_dev"
    fi

    setup_lvm "$lvm_part" vg00
    format_filesystems "$boot_dev"
    mount_filesystems "$boot_dev"
    install_base
    arch-chroot /mnt ./setup.sh chroot || handle_chroot_failure
}

configure() {
    install_packages
    install_packer
    install_aur_packages
    clean_packages
    update_pkgfile

    set_hostname "$HOSTNAME"
    set_timezone "$TIMEZONE"
    set_locale
    set_keymap
    set_hosts "$HOSTNAME"
    set_fstab "$TMP_ON_TMPFS" "${DRIVE}1"
    set_modules_load
    set_initcpio
    set_daemons "$TMP_ON_TMPFS"
    set_syslinux "${DRIVE}2"
    set_sudoers
    set_slim

    [ -n "$WIRELESS_DEVICE" ] && set_netcfg

    set_root_password "${ROOT_PASSWORD:-$(prompt_password 'root')}"
    create_user "$USER_NAME" "${USER_PASSWORD:-$(prompt_password "$USER_NAME")}"
    update_locate

    rm /setup.sh
}

partition_drive() {
    parted -s "$1" mklabel msdos mkpart primary ext2 1 100M mkpart primary ext2 100M 100% set 1 boot on set 2 LVM on
}

encrypt_drive() {
    echo -en "$2" | cryptsetup -c aes-xts-plain -y -s 512 luksFormat "$1"
    echo -en "$2" | cryptsetup luksOpen "$1" lvm
}

setup_lvm() {
    pvcreate "$1"
    vgcreate "$2" "$1"
    lvcreate -C y -L1G "$2" -n swap
    lvcreate -l '+100%FREE' "$2" -n root
    vgchange -ay
}

format_filesystems() {
    mkfs.ext2 -L boot "$1"
    mkfs.ext4 -L root /dev/vg00/root
    mkswap /dev/vg00/swap
}

mount_filesystems() {
    mount /dev/vg00/root /mnt
    mkdir /mnt/boot
    mount "$1" /mnt/boot
    swapon /dev/vg00/swap
}

install_base() {
    echo 'Server = http://mirrors.kernel.org/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
    pacstrap /mnt base base-devel syslinux
}

install_packages() {
    local packages='alsa-utils aspell-en chromium cpupower gvim mlocate net-tools ntp openssh p7zip pkgfile powertop python python2 rfkill rsync sudo unrar unzip wget zip systemd-sysvcompat zsh grml-zsh-config apache-ant cmake gdb git maven mercurial subversion tcpdump valgrind wireshark-gtk icedtea-web-java7 jdk7-openjdk jre7-openjdk libreoffice-calc libreoffice-en-US libreoffice-gnome libreoffice-impress libreoffice-writer hunspell-en hyphen-en mythes-en mplayer pidgin vlc xscreensaver gparted dosfstools ntfsprogs xorg-apps xorg-server xorg-xinit xterm slim archlinux-themes-slim ttf-dejavu ttf-liberation intel-ucode xf86-input-synaptics'
    
    [ "$VIDEO_DRIVER" = "i915" ] && packages+=' xf86-video-intel libva-intel-driver'
    pacman -Sy --noconfirm $packages
}

install_packer() {
    mkdir /foo && cd /foo
    curl https://aur.archlinux.org/packages/pa/packer/packer.tar.gz | tar xzf -
    cd packer && makepkg -si --noconfirm --asroot
    cd / && rm -rf /foo
}

install_aur_packages() {
    mkdir /foo && export TMPDIR=/foo
    packer -S --noconfirm android-udev chromium-pepper-flash-stable chromium-libpdf-stable
    unset TMPDIR && rm -rf /foo
}

clean_packages() {
    yes | pacman -Scc
}

update_pkgfile() {
    pkgfile -u
}

set_hostname() {
    echo "$1" > /etc/hostname
}

set_timezone() {
    ln -sT "/usr/share/zoneinfo/$1" /etc/localtime
}

set_locale() {
    echo -e 'LANG="en_US.UTF-8"\nLC_COLLATE="C"' > /etc/locale.conf
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
}

set_keymap() {
    echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf
}

set_hosts() {
    echo -e "127.0.0.1 localhost.localdomain localhost $1\n::1 localhost.localdomain localhost $1" > /etc/hosts
}

set_fstab() {
    cat > /etc/fstab <<EOF
/dev/vg00/swap none swap  sw 0 0
/dev/vg00/root / ext4 defaults,relatime 0 1
UUID=$(get_uuid "$2") /boot ext2 defaults,relatime 0 2
EOF
}

set_modules_load() {
    echo 'microcode' > /etc/modules-load.d/intel-ucode.conf
}

set_initcpio() {
    local vid="$VIDEO_DRIVER"
    local encrypt="$([ -n "$ENCRYPT_DRIVE" ] && echo 'encrypt')"
    cat > /etc/mkinitcpio.conf <<EOF
MODULES="ext4 $vid"
HOOKS="base udev autodetect modconf block keymap keyboard $encrypt lvm2 resume filesystems fsck"
EOF
    mkinitcpio -p linux
}

set_daemons() {
    systemctl enable cronie.service cpupower.service ntpd.service slim.service
    [ -n "$WIRELESS_DEVICE" ] && systemctl enable net-auto-wired.service net-auto-wireless.service || systemctl enable dhcpcd@eth0.service
    [ -z "$1" ] && systemctl mask tmp.mount
}

set_syslinux() {
    local lvm_uuid=$(get_uuid "$1")
    cat > /boot/syslinux/syslinux.cfg <<EOF
DEFAULT arch
PROMPT 0
TIMEOUT 50
UI menu.c32
MENU TITLE Arch Linux
LABEL arch
    MENU LABEL Arch Linux
    LINUX ../vmlinuz-linux
    APPEND root=/dev/vg00/root ro $( [ -n "$ENCRYPT_DRIVE" ] && echo "cryptdevice=/dev/disk/by-uuid/$lvm_uuid:lvm" ) resume=/dev/vg00/swap quiet
    INITRD ../initramfs-linux.img
EOF
    syslinux-install_update -iam
}

set_sudoers() {
    cat > /etc/sudoers <<EOF
root ALL=(ALL) ALL
%wheel ALL=(ALL) ALL
%rfkill ALL=(ALL) NOPASSWD: /usr/sbin/rfkill
%network ALL=(ALL) NOPASSWD: /usr/bin/netcfg, /usr/bin/wifi-menu
EOF
    chmod 440 /etc/sudoers
}

set_slim() {
    cat > /etc/slim.conf <<EOF
default_path /bin:/usr/bin:/usr/local/bin
default_xserver /usr/bin/X
xserver_arguments -nolisten tcp vt07
halt_cmd /sbin/poweroff
reboot_cmd /sbin/reboot
suspend_cmd /usr/bin/systemctl hybrid-sleep
login_cmd exec /bin/zsh -l ~/.xinitrc %session
current_theme archlinux-simplyblack
logfile /var/log/slim.log
EOF
}

set_netcfg() {
    cat > /etc/network.d/wired <<EOF
CONNECTION='ethernet'
DESCRIPTION='Ethernet with DHCP'
INTERFACE='eth0'
IP='dhcp'
EOF
    chmod 600 /etc/network.d/wired
    cat > /etc/conf.d/netcfg <<EOF
NETWORKS=()
WIRED_INTERFACE="eth0"
WIRELESS_INTERFACE="$WIRELESS_DEVICE"
EOF
}

set_root_password() {
    echo -en "$1\n$1" | passwd
}

create_user() {
    useradd -m -s /bin/zsh -G adm,systemd-journal,wheel,rfkill,games,network,video,audio,optical,floppy,storage,scanner,power,adbusers,wireshark "$1"
    echo -en "$2\n$2" | passwd "$1"
}

update_locate() {
    updatedb
}

get_uuid() {
    blkid -o export "$1" | grep UUID | awk -F= '{print $2}'
}

prompt_passphrase() {
    echo 'Enter a passphrase to encrypt the disk:'
    stty -echo
    read passphrase
    stty echo
    echo "$passphrase"
}

prompt_password() {
    echo "Enter the password for $1:"
    stty -echo
    read password
    stty echo
    echo "$password"
}

handle_chroot_failure() {
    echo 'ERROR: Something failed inside the chroot, not unmounting filesystems so you can investigate.'
    echo 'Make sure you unmount everything before you try to run this script again.'
}

set -ex

if [ "$1" == "chroot" ]; then
    configure
else
    setup
fi
