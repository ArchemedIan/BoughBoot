#!/bin/bash
echo 15032385536B | tee /root/.rootfs_resize
sed 's|echo -e "Old partition table:\\n"|unset newpartition|g' -i /usr/lib/armbian/armbian-resize-filesystem
rm /root/.not_logged_in_yet
echo 'root:BoughBoot' | chpasswd
passwd -u root


hostname -b BoughBoot

apt update

apt install whiptail hostapd dialog gnome gnome-session fonts-dejavu chromium-browser mdadm unar -yy

dpkg-reconfigure gdm3

systemctl set-default graphical.target
mv /etc/gdm3/daemon.conf{,.orig}

cat <<EOF > /etc/gdm3/daemon.conf
# GDM configuration storage
#
# See /usr/share/gdm/gdm.schemas for a list of available options.

[daemon]
# Uncomment the line below to force the login screen to use Xorg
#WaylandEnable=false

# Enabling automatic login
AutomaticLoginEnable = true
AutomaticLogin = root

# Enabling timed login
#  TimedLoginEnable = true
#  TimedLogin = user1
#  TimedLoginDelay = 10

[security]
AllowRoot=true
[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
# More verbose logs
# Additionally lets the X server dump core if it crashes
#Enable=true
EOF
sed "s|auth.*required.*pam_succeed.* root quiet_success|#auth    required        pam_succeed_if.so user != root quiet_success|g" -i /etc/pam.d/gdm-password
sed "s|auth.*required.*pam_succeed.* root quiet_success|#auth    required        pam_succeed_if.so user != root quiet_success|g" -i /etc/pam.d/gdm-autologin

mv /usr/share/desktop-base/debian-logos /usr/share/desktop-base/debian-logos.bak
bakdir=$(pwd)
[ -d /usr/share/plymouth/themes ] || mkdir -p /usr/share/plymouth/themes
cd /usr/share/plymouth/themes
tar xvf /tmp/overlay/plymouth-bb.tar 
[ -d /usr/share/plymouth/themes/bb ] || exit  1
cd $bakdir
sed "s|^Theme=armbian|Theme=bb|g" -i /etc/plymouth/plymouthd.conf
update-initramfs -u

