#!/bin/bash
NBEnvs=/boot/BB/NBEnvs
lines=`tput lines`
cols=`tput cols`
export boxheight=`bc <<< "scale=0; ($lines/16)*17"`
export listheight=`bc <<< "scale=0; ($lines/16)*12"`
export width=`bc <<< "scale=0; ($cols/16)*15"`
echo $boxheight $width $listheight

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
NBnow=1
EMMCdev=/dev/mmcblk0p

layouts=()
layouts+=("1"); devs+=(" partition. (combined rootfs and /boot)")
layouts+=("2"); devs+=(" or more partitions. part1: /boot part2: / (rootfs) 3+:...")
#layouts+=("3"); devs+=(" android? ")
#layouts+=("3"); devs+=(" openwrt? ")

Partlayout=$(whiptail --backtitle "BoughBoot Bootmenu Entry Maker" --title "OS Partition Layout" --menu "Select a layout:" $boxheight $width 6 "${layouts[@]}" 3>&1 1>&2 2>&3)

if [[ "$Partlayout" == "1" ]]; then Partlayout="root"; fi
if [[ "$Partlayout" == "2" ]]; then Partlayout="boot root"; fi


devs=()

EMMCdev=/dev/mmcblk0p
devs+=("EMMC Module")
ls /dev/mmcblk0 && EMMCdevFound="size: `lsblk -ndo SIZE /dev/mmcblk0 | awk '{printf $1}'`" || EMMCdevFound="Not Detected"
devs+=("${EMMCdev}# | $EMMCdevFound")

SDdev=/dev/mmcblk1p
devs+=("SD Card")
ls /dev/mmcblk1 && SDdevFound="size: `lsblk -ndo SIZE /dev/mmcblk1 | awk '{printf $1}'`" || SDdevFound="Not Detected"
devs+=("${SDdev}# | $SDdevFound")

NVMEdev=/dev/nvme0n1p
devs+=("NVME")
ls /dev/mmcblk0 && NVMEdevFound="size: `lsblk -ndo SIZE /dev/nvme0n1 | awk '{printf $1}'`" || NVMEdevFound="Not Detected"
devs+=("${NVMEdev}# | $NVMEdevvFound")

#OTHERdev=/dev/sd
#devs+=("USB")
#devs+=("${OTHERdev}X#")

#devs+=("SATA (Experimental)")
#devs+=("${OTHERdev}X#")


DeviceSelection=$(whiptail --backtitle "BoughBoot Bootmenu Entry Maker" --title "Device Selection" --menu "Select Device OS is on:" $boxheight $width 6 "${devs[@]}" 3>&1 1>&2 2>&3)
if [[ "$DeviceSelection" == "EMMC Module" ]]; then DeviceSelection=$EMMCdev; NBDevType=mmc; NBDevNum=0; fi
if [[ "$DeviceSelection" == "SD Card" ]]; then DeviceSelection=$SDdev; NBDevType=mmc; NBDevNum=1 ; fi
if [[ "$DeviceSelection" == "NVME" ]]; then DeviceSelection=$NVMEdev; NBDevType=nvme NBDevNum=0; fi
#if [[ "$DeviceSelection" == "USB" ]]; then DeviceSelection=$OTHERdev; NBDevType=usb; NBDevNum=uuid ; fi
#if [[ "$DeviceSelection" == "SATA (Experimental)" ]]; then DeviceSelection=$OTHERdev; NBDevType=sata; NBDevNum=uuid ; fi
if [ -z "$DeviceSelection" ]; then echo no device selecton...; exit; fi

#ls /dev/sd[a-z]
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
for BootOrRoot in $Partlayout; do
  PartitionSelection=$(whiptail --backtitle "BoughBoot Bootmenu Entry Maker" --title "Partition Selection" --menu "Select a $BootOrRoot Partiton:" $boxheight $width $SDPartitionCount "${SDPartitions[@]}" 3>&1 1>&2 2>&3)
  if [[ "$BootOrRoot" == "boot" ]]; then NBBootNum=$PartitionSelection fi
  if [[ "$DeviceSelection" == "root" ]]; then 
     NBRootNum=$PartitionSelection
     if [[ "$NBBootNum" == "unset" ]]; then NBBootNum=$PartitionSelection fi
  fi
done



echo 
echo BBMenuName=$BBMenuName
echo BBMenuDescription=$BBMenuDescription
echo NBDevType=$NBDevType
echo NBDevNum=$NBDevNum
echo NBBootNum=$NBBootNum
echo NBRootNum=$NBRootNum
echo NBPrefix=$NBPrefix
echo NBOSType=$NBOSType
echo NBnow=$NBnow
