#!/bin/bash

RELEASE=$1
FAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

echo 15032385536B | tee /root/.rootfs_resize
sed 's|echo -e "Old partition table:\\n"|unset newpartition|g' -i /usr/lib/armbian/armbian-resize-filesystem

# todo: figure out why this doesnt work
hostname -b BoughBoot
# for now:
sed "s|orangepi5-plus|BoughBoot|g" -i etc/hostname
sed "s|orangepi5-plus|BoughBoot|g" -i etc/hosts


apt update
apt install -yy dialog xserver-xorg xinit xfce4 xfce4-session xfce4-goodies lightdm dos2unix
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

rsync -aHSAX -ih /etc/skel/ /root >/dev/null
echo chmod a+x /boot/BB/*.sh > /root/.bashrc
echo alias BBMenu-cli=/boot/BB/BBMenu-cli.sh >> /root/.bashrc
echo alias BBMenu-cli.sh=/boot/BB/BBMenu-cli.sh >> /root/.bashrc
echo alias BBMenu=/boot/BB/BBMenu-cli.sh >> /root/.bashrc
echo alias bbmenu=/boot/BB/BBMenu-cli.sh >> /root/.bashrc
echo alias bb=/boot/BB/BBMenu-cli.sh >> /root/.bashrc
echo alias wifi=/boot/BB/wifi.sh>> /root/.bashrc
echo "alias network=\"echo y| armbian-config main=Network\"">> /root/.bashrc
#echo /boot/BB/BBMenu-cli.sh >> root/.bashrc >> root/.bashrc

rm /root/.not_logged_in_yet
echo 'root:BoughBoot' | chpasswd
passwd -u root
mkdir -p /root/.config/autostart
cp /tmp/overlay/.dialogrc /root/.dialogrc
cp /tmp/overlay/BoughBoot.desktop /root/BoughBoot.desktop
#cp /tmp/overlay/BoughBoot.desktop /etc/xdg/autostart/BoughBoot.desktop
cp /tmp/overlay/BoughBoot.desktop /root/.config/autostart/BoughBoot.desktop
chmod a+x /root/BoughBoot.desktop
#chmod a+x /etc/xdg/autostart/BoughBoot.desktop
chmod a+x /root/.config/autostart/BoughBoot.desktop
chattr +i /root/.config/autostart/BoughBoot.desktop

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

