#!/bin/bash
echo 15032385536B | tee /root/.rootfs_resize
sed 's|echo -e "Old partition table:\\n"|unset newpartition|g' -i /usr/lib/armbian/armbian-resize-filesystem
rm /root/.not_logged_in_yet
echo 'root:BoughBoot' | chpasswd
hostname -b BoughBoot

apt update
apt install whiptail hostapd gpm

bakdir=$(pwd)
[ -d /usr/share/plymouth/themes ] || mkdir -p /usr/share/plymouth/themes
cd /usr/share/plymouth/themes
tar xvf /tmp/overlay/plymouth-bb.tar .
[ -d /usr/share/plymouth/themes/bb ] || exit  1
cd $bakdir
sed "s|^Theme=armbian|Theme=bb|g" -i /etc/plymouth/plymouthd.conf
update-initramfs -u

