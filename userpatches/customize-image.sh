#!/bin/bash

RELEASE=$1
FAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

echo 15032385536B | tee /root/.rootfs_resize
sed 's|echo -e "Old partition table:\\n"|unset newpartition|g' -i /usr/lib/armbian/armbian-resize-filesystem
rm /root/.not_logged_in_yet
echo 'root:BoughBoot' | chpasswd
passwd -u root

# todo: figure out why this doesnt work
hostname -b BoughBoot

apt update
apt install -yy dialog xserver-xorg xinit xfce4 xfce4-session xfce4-goodies lightdm gnome-terminal dconf-cli
dpkg-reconfigure lightdm

sed "s|auth.*required.*pam_succeed.* root quiet_success|#auth    required        pam_succeed_if.so user != root quiet_success|g" -i /etc/pam.d/lightdm-autologin
mv /etc/lightdm/lightdm.conf{,.orig}
cat << EOF > /etc/lightdm/lightdm.conf
[LightDM]

[Seat:*]
autologin-user = root
autologin-user-timeout = 0

[XDMCPServer]

[VNCServer]

EOF
cat << EOF > /etc/systemd/system/BBFirstRun.service

[Unit]
Description=BB first run 
Wants=network-online.target
After=network.target network-online.target
ConditionPathExists=/boot/BB/BBFirstRun.sh

[Service]
Type=idle
RemainAfterExit=yes
ExecStartpre=chmod a+x /boot/BB/BBFirstRun.sh
ExecStart=/boot/BB/BBFirstRun.sh
TimeoutStartSec=2min

[Install]
WantedBy=multi-user.target

EOF
systemctl daemon-reload
systemctl enable /etc/systemd/system/BBFirstRun.service

cp /tmp/overlay/.dialogrc /root/.dialogrc
#mkdir -p /root/.config/autostart
cp /tmp/overlay/BoughBoot.desktop /etc/xdg/autostart/BoughBoot.desktop || exit 1
cp /tmp/overlay/gnome-terminal-profiles.dconf /root/.config/gnome-terminal-profiles.dconf

# plymouth boot Theme
mv /usr/share/desktop-base/debian-logos /usr/share/desktop-base/debian-logos.bak
bakdir=$(pwd)
[ -d /usr/share/plymouth/themes ] || mkdir -p /usr/share/plymouth/themes
cd /usr/share/plymouth/themes
tar xvf /tmp/overlay/plymouth-bb.tar 
[ -d /usr/share/plymouth/themes/bb ] || exit  1
cd $bakdir
sed "s|^Theme=armbian|Theme=bb|g" -i /etc/plymouth/plymouthd.conf
update-initramfs -u

