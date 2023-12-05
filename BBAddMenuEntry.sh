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

devs=()

SDdev=/dev/mmcblk0p
devs+=("SD Card")
ls /dev/mmcblk0 && SDdevFound="Not Detected" || SDdevFound="size: `lsblk -ndo SIZE /dev/mmcblk0 | awk '{printf $1}'`"
devs+=("${SDdev}\# | $SDdevFound")

EMMCdev=/dev/mmcblk1p
devs+=("EMMC Module")
ls /dev/mmcblk0 && EMMCdevFound="Not Detected" || EMMCdevFound="size: `lsblk -ndo SIZE /dev/mmcblk1 | awk '{printf $1}'`"
devs+=("${EMMCdev}\# | $EMMCdevFound")

NVMEdev=/dev/nvme0n1p
devs+=("NVME")
ls /dev/mmcblk0 && NVMEdevFound="Not Detected" || NVMEdevFound="size: `lsblk -ndo SIZE /dev/nvme0n1 | awk '{printf $1}'`"
devs+=("${NVMEdev}\# | $NVMEdevvFound")

OTHERdev=/dev/sd
devs+=("USB,SATA (Experimental)")
devs+=("${OTHERdev}X\#")


DeviceSelection=$(whiptail --backtitle "BoughBoot Bootmenu Entry Maker" --title "Device Selection" --menu "Select Device OS is on:" $boxheight $width 6 "${devs[@]}" 3>&1 1>&2 2>&3)
if [[ "$DeviceSelection" == "SD Card" ]]; then DeviceSelection=$SDdev; NBDevType=mmc; NBDevNum=1 ; fi
if [[ "$DeviceSelection" == "EMMC Module" ]]; then DeviceSelection=$EMMCdev; NBDevType=mmc; NBDevNum=0; fi
if [[ "$DeviceSelection" == "NVME" ]]; then DeviceSelection=$NVMEdev; NBDevType=nvme ; fi
if [[ "$DeviceSelection" == "USB" ]]; then DeviceSelection=$OTHERdev; NBDevType=usb ; fi
if [[ "$DeviceSelection" == "SATA (Experimental)" ]]; then DeviceSelection=$OTHERdev; NBDevType=sata ; fi
if [ -z "$DeviceSelection" ]; then echo no device selecton...; exit; fi


SDPartitions=()
for SDPart in $(ls ${DeviceSelection}*)
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
if [ -z "$PartitionSelection" ]; then echo no partition selecton...; exit; fi
echo $PartitionSelection

