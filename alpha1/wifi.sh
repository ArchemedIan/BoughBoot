#!/bin/bash
lines=`tput lines`
cols=`tput cols`
export boxheight=`bc <<< "scale=0; ($lines/16)*17"`
export listheight=`bc <<< "scale=0; ($lines/16)*12"`
export width=`bc <<< "scale=0; ($cols/16)*15"`

echo $boxheight $width $listheight

trap "tput rmcup; exit"  SIGHUP SIGINT SIGTERM


tput smcup



IfaceList=()
SSIDList=()
interface=wlan0

while read interface; do                    
    #i=$((i+1))                                  
    type=$(awk '{print $2}' <<< $interface)       
    status=$(awk '{print $3}' <<< $interface)     
    interface=$(awk '{print $1}' <<< $interface)  
    if [[ "$type" == "wifi" ]]; then 
      i=$((i+1))
      IfaceList+=("$interface")
      IfaceList+=("$status")
    fi                                          
done < <(nmcli device | tail -n +2)         


if [[ "$i" == "1" ]]; then
    iface=1 
    interface=${IfaceList[0]}

else

    interface=$(dialog --backtitle "Simple WiFi setup" --title "WiFi Interface List" --menu $boxheight $width $listheight "${IfaceList[@]}" 3>&1 1>&2 2>&3)
fi


dialog --backtitle "WiFi setup" --infobox "Scanning WiFi Networks..." 3 29 #$boxheight $width
if [[ "$iface" -le $i ]]; then
    	maxnamelen=4
	while read ssid; do
        i2=$((i2+1))
        name=$(awk -F: '{printf $1}' <<< $ssid)
        rate=$(awk -F: '{printf $2}' <<< $ssid)
        sec=$(awk -F: '{printf $3}' <<< $ssid| awk '{ print $NF }' )
        bars=$(awk -F: '{printf $4}' <<< $ssid)
        bcount=$(echo -n "$bars"| wc -c)
        bcount=$((4-$bcount))
        x=$bcount
        while [ $x -gt 0 ];
        do
          bars="${bars}-"
          x=$(($x-1))
        done
        i3=$((i3+1))
	thisnamelen=$(echo -n "$name"| wc -c)
        SSIDList+=("$name")
        SSIDList+=("| $rate | $sec | $bars")
    done < <(nmcli --colors no --terse --fields SSID,RATE,SECURITY,BARS d wifi list)
    ssidpick=$(dialog --backtitle "WiFi setup" --title "SSID | RATE | SECURITY | SIGNAL" --menu "Select an SSID" $((${i2}+12)) 78 $((${i2}+24)) "${SSIDList[@]}" 3>&1 1>&2 2>&3)
    if [ -z "$ssidpick" ]; then dialog --backtitle "WiFi setup" --title "Scanning..." --msgbox "No Wifi networks found (or none selected.)" 5 46; exit 0; fi
    password=$(dialog --backtitle "WiFi setup" --title "WiFi Password Request" --passwordbox "Enter Password for $ssidpick:" $boxheight ${width} 3>&1 1>&2 2>&3)
    if [ -z "$password" ]; then exit 0; fi
    output=$(nmcli device wifi connect "$ssidpick" password "$password" ifname "$interface"  ) 
    wget -q --tries=5 --timeout=5 --spider http://google.com &> /dev/null 
    if [[ $? -eq 0 ]]; then
            dialog --backtitle "WiFi setup" --infobox "You're connected." $boxheight $width
            exit 0
    else
            echo "Error. $output" 
            exit 1
    fi
else
    echo "Invalid interface entered. Exiting..."
    exit 2
fi

