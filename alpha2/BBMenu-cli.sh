#!/usr/bin/bash
BBVer=alpha2
BBRoot=/boot/BB
bbenv=$BBRoot/BoughBootEnv.txt
nextbootEnv=$BBRoot/NextBootEnv.txt

[ -h $bbenv ] && bbenv=/BoughBootEnv.txt
[ -h $nextbootEnv ] && nextbootEnv=/NextBootEnv.txt

NBEnvs=$BBRoot/NBEnvs
cd $(dirname "$0")

lines=`tput lines`
cols=`tput cols`
export boxheight=`bc <<< "scale=0; ($lines/16)*13"`
export listheight=`bc <<< "scale=0; ($lines/16)*9"`
export width=`bc <<< "scale=0; ($cols/16)*13"`
echo $boxheight $width $listheight

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
        #echo getting bootname for $bootEnv
        export BootListLines=$((BootListLines+1))
        export BBMenuList+=("$(echo $(cat "$bootEnv"| grep BBMenuName=|cut -d '=' -f 2))")
        export BBMenuList+=("$(echo $(cat "$bootEnv" | grep BBMenuDescription=|cut -d '=' -f 2))")

    done< <(find $NBEnvs/*.txt -print0)

        #echo
        #echo "${BBMenuList[@]}"
        #echo
        #sleep 3
    if [[ $BootListLines -gt $listheight ]]; then
        BootListLines=$listheight
    fi

    bootselection=$(dialog --colors --backtitle "BoughBoot Bootmenu Ver: $BBVer" --title "OS List" --menu "Select a Boot Option:" $boxheight $width $BootListLines "${BBMenuList[@]}" 3>&1 1>&2 2>&3)

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
while :
do
  Bootmenu
  #echo Finished bootmenu
  if [ -z "$bootselection" ]; then continue; fi

  if [[ "$bootselection" == "Exit BoughBoot" ]]; then exit 0; fi
  
  if [[ "$bootselection" == "Setup WiFi" ]]; then source $BBRoot/wifi.sh; continue ; fi

  if [[ "$bootselection" == "Add OS Entry" ]]; then source $BBRoot/BBAddMenuEntry.sh; continue ; fi

  break
done


#echo $bootselection
#cp "$bootselection" "$nextbootEnv"
cat "$bootselection" > "$nextbootEnv"
sync
cat "$nextbootEnv"

sleep 3
reboot




exit 0
SELECTED=($(dialog --title "SELECT PACKAGES TO INSTALL" --checklist \
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
done | dialog --gauge "Running Data Loader" 6 50 ${COUNTER}


echo ${SELECTED[@]}

bootselection=$(dialog --title "Choose Only One Package" --radiolist \
"List of packages" 20 100 10 \
"chrome" "browser" OFF \
"pip3" "Python package manager" OFF \
"ksnip" "Screenshot tool" OFF \
"virtualbox" "virtualization software" OFF 3>&1 1>&2 2>&3)

echo $bootselection

NEW_USER=$(dialog --title "input test" --inputbox "Username to be created" 8 40 3>&1 1>&2 2>&3)

dialog --title "input test" --infobox "NEW_USER = $NEW_USER" 8 78



dialog --title "theme testing" --msgbox "ðŸŠtesting this thememememememe" 8 78
dialog --title "CONFIRMATION" --yesno "Should I proceed" 8 78
if [[ $? -eq 0 ]]; then
  dialog --title "MESSAGE" --msgbox "Process completed successfully." 8 78
elif [[ $? -eq 1 ]]; then
  dialog --title "MESSAGE" --msgbox "Cancelling Process since user pressed <NO>." 8 78
elif [[ $? -eq 255 ]]; then
  dialog --title "MESSAGE" --msgbox "User pressed ESC. Exiting the script" 8 78
fi

dialog --textbox --scrolltext /boot/boot.cmd 18 80

PASSWORD=$(dialog --title "password test" --passwordbox "Choose a strong password" 8 78 3>&1 1>&2 2>&3)

dialog --title "password test" --infobox "PASSWORD = $PASSWORD" 8 78
sleep 3

NEW_USER=$(dialog --title "input test" --inputbox "Username to be created" 8 40 3>&1 1>&2 2>&3)

dialog --title "input test" --infobox "NEW_USER = $NEW_USER" 8 78
sleep 3
