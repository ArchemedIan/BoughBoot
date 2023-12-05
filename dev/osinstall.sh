#!/bin/bash
NBEnvs=/boot/BB/NBEnvs
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
BBMenuName=unset
BBMenuDescription=unset
NBDevType=unset
NBDevNum=unset
NBBootNum=unset
NBRootNum=unset
NBPrefix=unset
NBOSType=unset
NBnow=0

/dev/mmcblk1p

SDPartitions=()
for SDPart in $(ls /dev/mmcblk0p*)
do
  unset thislabel
  unset thisuuid
  unset thispartuuid
  unset thispartlabel
  unset desc
  thislabel=`blkid $SDPart -o value -s LABEL`
  thisuuid=`blkid $SDPart -o value -s UUID`
  thispartuuid=`blkid $SDPart -o value -s PARTUUID`
  thispartlabel=`blkid $SDPart -o value -s PARTLABEL`
  
  if [ -z "$thislabel" ]; then 
  if [ -z "$thispartlabel" ]; then 
    if [ -z "$thisuuid" ]; then 
      if [ -z "$thispartuuid" ]; then 
        continue
      else
        desc+="partuuid: $thispartuuid "
      fi
    else
      desc+="uuid: $thisuuid "
    fi
  else
    desc+="partlabel: $thispartlabel "
  fi
  else
  desc+="label: $thislabel"
  if [ ! -z "$thispartlabel" ]; then 
    desc+=", partlabel: $thispartlabel "
  fi
  fi
  SDPartitionCount=$((SDPartitionCount+1)) 
  SDPartitions+=("$SDPart")
  SDPartitions+=("$desc")
done


PartitionSelection=$(whiptail --backtitle "BoughBoot Bootmenu Entry Maker" --title "Partition Selection" --menu "Select a Boot Partiton:" $boxheight $width $SDPartitionCount "${SDPartitions[@]}" 3>&1 1>&2 2>&3)
echo $PartitionSelection

