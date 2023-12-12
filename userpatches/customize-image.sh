#!/bin/bash
echo 15032385536B | tee /root/.rootfs_resize
sed 's|echo -e "Old partition table:\\n"|unset newpartition|g' -i /usr/lib/armbian/armbian-resize-filesystem
rm /root/.not_logged_in_yet
echo 'root:BoughBoot' | chpasswd
passwd -u root

# todo: figure out why this doesnt work
hostname -b BoughBoot

apt update
apt install -yy whiptail hostapd dialog xserver-xorg xinit xfce4 xfce4-session xfce4-goodies lightdm gnome-terminal
dpkg-reconfigure lightdm
sed "s|auth.*required.*pam_succeed.* root quiet_success|#auth    required        pam_succeed_if.so user != root quiet_success|g" -i /etc/pam.d/lightdm-password
sed "s|auth.*required.*pam_succeed.* root quiet_success|#auth    required        pam_succeed_if.so user != root quiet_success|g" -i /etc/pam.d/lightdm-autologin
mv /etc/lightdm/lightdm.conf{,.orig}
cat <<EOF > /etc/lightdm/lightdm.conf
[LightDM]

[Seat:*]
autologin-user = root
autologin-user-timeout = 0

[XDMCPServer]

[VNCServer]

EOF
cp /tmp/overlay/.dialogrc /root/.dialogrc
mkdir -p /root/.config/autostart
cp /tmp/overlay/bb.desktop /root/.config/autostart/BoughBoot.desktop
dconf load /org/gnome/terminal/legacy/profiles:/ < /tmp/overlay/gnome-terminal-profiles.dconf

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

