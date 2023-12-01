#!/bin/bash
echo 15032385536B | tee $SDCARD/root/.rootfs_resize
sed 's|echo -e "Old partition table:\\n"|unset newpartition|g' -i $SDCARD/usr/lib/armbian/armbian-resize-filesystem
rm $SDCARD/root/.not_logged_in_yet
#touch /root/.no_rootfs_resize
echo 'root:dockmox' | chpasswd
hostname -b BoughBoot
systemctl disable openvpn.service wpa_supplicant.service unattended-upgrades.service NetworkManager.service NetworkManager-dispatcher.service networking.service armbian-live-patch.service armbian-hardware-monitor.service
apt update
apt install whiptail 
