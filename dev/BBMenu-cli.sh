#!/usr/bin/bash
BBVer=alpha1
bbenv=/boot/BB/BoughBootEnv.txt
nextbootEnv=/boot/BB/NextBootEnv.txt
NBEnvs=/boot/BB/NBEnvs
cd $(dirname "$0")


lines=`tput lines`
cols=`tput cols`
export boxheight=`bc <<< "scale=0; ($lines/16)*17"`
export listheight=`bc <<< "scale=0; ($lines/16)*12"`
export width=`bc <<< "scale=0; ($cols/16)*15"`
echo $boxheight $width $listheight

#systemctl start systemctl disable openvpn.service unattended-upgrades.service armbian-live-patch.service armbian-hardware-monitor.service >/dev/null 2>&1 &
export NEWT_COLORS='
root=brown,black
border=brown,black
window=brown,black
shadow=brown,black
title=brown,black
textbox=brown,black
button=black,brown
actbutton=white,white
checkbox=brown,black
actcheckbox=black,brown
entry=black,brown
label=white,white
listbox=brown,black
actlistbox=black,brown
acttextbox=white,white
helpline=white,white
roottext=brown,black
emptyscale=black,black
fullscale=brown,brown
disentry=white,white
compactbutton=brown,black
actsellistbox=black,brown
sellistbox=white,white

'


Bootmenu () {
    #echo function begin
BBMenuList=()
bootselection=
bootnow=
bootselection=
BootListLines=0
    #for bootEnv in $(ls "$NBEnvs/*.txt")
     while read -d $'\0' bootEnv
    do
        #echo inside for loop
        echo getting bootname for $bootEnv
        export BootListLines=$((BootListLines+1))
        export BBMenuList+=("$(echo $(cat "$bootEnv"| grep BBMenuName=|cut -d '=' -f 2))")
        export BBMenuList+=("$(echo $(cat "$bootEnv" | grep BBMenuDescription=|cut -d '=' -f 2))")

    done< <(find $NBEnvs/*.txt -print0)

        echo
        echo "${BBMenuList[@]}"
        echo
        sleep 3
    if [[ $BootListLines -gt $listheight ]]; then
        BootListLines=$listheight
    fi

    bootselection=$(whiptail --backtitle "BoughBoot Bootmenu Ver: $BBVer" --title "OS List" --menu "Select a Boot Option:" $boxheight $width $BootListLines "${BBMenuList[@]}" 3>&1 1>&2 2>&3)

    if [[ $? -gt 0 ]]; then
        exit 0
    fi

    while read -d $'\0' bootEnv
    do
        if cat "$bootEnv"| grep -e "BBMenuName=$bootselection"
        then
            bootselection=$bootEnv
        fi
    done< <(find $NBEnvs/*.txt -print0)
}

#echo Starting bootmenu
Bootmenu
#echo Finished bootmenu
if [ -z "$bootselection" ]; then exit 0; fi
#echo $bootselection
#cp "$bootselection" "$nextbootEnv"
cat "$bootselection" > "$nextbootEnv"
sync
cat "$nextbootEnv"

sleep 3
reboot




exit 0
SELECTED=($(whiptail --title "SELECT PACKAGES TO INSTALL" --checklist \
"List of packages" 20 100 10 \
"chrome" "browser" OFF \
"pip3" "Python package manager" OFF \
"ksnip" "Screenshot tool" OFF \
"virtualbox" "virtualization software" ON 3>&1 1>&2 2>&3))

COUNTER=0
while [[ ${COUNTER} -le 100 ]]; do
  sleep 1
  COUNTER=$(($COUNTER+10))
  echo ${COUNTER}
done | whiptail --gauge "Running Data Loader" 6 50 ${COUNTER}


echo ${SELECTED[@]}

bootselection=$(whiptail --title "Choose Only One Package" --radiolist \
"List of packages" 20 100 10 \
"chrome" "browser" OFF \
"pip3" "Python package manager" OFF \
"ksnip" "Screenshot tool" OFF \
"virtualbox" "virtualization software" OFF 3>&1 1>&2 2>&3)

echo $bootselection

NEW_USER=$(whiptail --title "input test" --inputbox "Username to be created" 8 40 3>&1 1>&2 2>&3)

whiptail --title "input test" --infobox "NEW_USER = $NEW_USER" 8 78



whiptail --title "theme testing" --msgbox "ðŸŠtesting this thememememememe" 8 78
whiptail --title "CONFIRMATION" --yesno "Should I proceed" 8 78
if [[ $? -eq 0 ]]; then
  whiptail --title "MESSAGE" --msgbox "Process completed successfully." 8 78
elif [[ $? -eq 1 ]]; then
  whiptail --title "MESSAGE" --msgbox "Cancelling Process since user pressed <NO>." 8 78
elif [[ $? -eq 255 ]]; then
  whiptail --title "MESSAGE" --msgbox "User pressed ESC. Exiting the script" 8 78
fi

whiptail --textbox --scrolltext /boot/boot.cmd 18 80

PASSWORD=$(whiptail --title "password test" --passwordbox "Choose a strong password" 8 78 3>&1 1>&2 2>&3)

whiptail --title "password test" --infobox "PASSWORD = $PASSWORD" 8 78
sleep 3

NEW_USER=$(whiptail --title "input test" --inputbox "Username to be created" 8 40 3>&1 1>&2 2>&3)

whiptail --title "input test" --infobox "NEW_USER = $NEW_USER" 8 78
sleep 3
