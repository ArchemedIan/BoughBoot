#!/bin/sh

dconf load /org/gnome/terminal/legacy/profiles:/ < /root/.config/gnome-terminal-profiles.dconf && rm /root/.config/gnome-terminal-profiles.dconf
systemctl disable /etc/systemd/system/BBFirstRun.service