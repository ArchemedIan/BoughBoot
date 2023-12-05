#!/bin/bash

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
## Restores the screen when the program exits.
trap "tput rmcup; exit"  SIGHUP SIGINT SIGTERM

## Saves the screen contents.
tput smcup

## Clears the screen.
clear
IfaceList=()
SSIDList=()
## Loop through available interfaces.
while read interface; do                    # While reads a line of the output
    #i=$((i+1))                                  # Only God knows what does this (view note 1).
    type=$(awk '{print $2}' <<< $interface)       # Saves the interface type to check if is wifi.
    status=$(awk '{print $3}' <<< $interface)     # Saves the status of the current interface.
    interface=$(awk '{print $1}' <<< $interface)  # Selects the INTEFACE field of the output.
    if [[ "$type" == "wifi" ]]; then # If is a WiFi interface then:
      i=$((i+1)) 
      IfaceList+=("$interface")
      IfaceList+=("$status")
    fi                                          # Ends the if conditional
done < <(nmcli device | tail -n +2)         # Redirects the output of the command nmcli device to the loop.

if [[ $i -gt $listheight ]]; then
    i=$listheight
fi

## If there is only one interface
if [[ "$i" == "1" ]]; then
    iface=1 # Selected interface is the only one
    #clear   # Quick and dirty workaround for make disappear the interface list.
else
    ## Prompts the user for the interface to use.
    #read -p "Select the interface: " iface
    interface=$(whiptail --backtitle "Simple WiFi setup" --title "WiFi Interface List" --menu "Select a WiFi Interface" $boxheight $width $i "${IfaceList[@]}" 3>&1 1>&2 2>&3)
fi

## If the entered number is valid then...
if [[ "$iface" -le $i ]]; then
    whiptail --backtitle "WiFi setup" --title "Scanning..." --msgbox "Scanning WiFi Networks" $boxheight $width $listheight
    while read ssid; do                    
        i2=$((i2+1))
        name=$(awk -F: '{printf $1}' <<< $ssid)     
        rate=$(aawk -F: '{printf $2}' <<< $ssid)
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
         
        SSIDList+=("$name")
        SSIDList+=("| $rate | $sec | $bars")                                      
    done < <(nmcli --colors no --terse --fields SSID,RATE,SECURITY,BARS d wifi list)
    if [[ $i -gt $listheight ]]; then
        i=$i2
    fi
    ssidpick=$(whiptail --backtitle "WiFi setup" --title "SSID | RATE | SECURITY | SIGNAL" --menu "Select an SSID" $boxheight $width $listheight "${SSIDList[@]}" 3>&1 1>&2 2>&3)
    if [ -z "$ssidpick" ]; then whiptail --backtitle "WiFi setup" --title "Error..." --msgbox "No Wifi networks found (or none selected.)" $boxheight $width $i2; exit 0; fi
    password=$(whiptail --backtitle "WiFi setup" --title "WiFi Password Request" --passwordbox "Enter Password for $ssidpick:" $boxheight $width $listheight 3>&1 1>&2 2>&3)
    if [ -z "$password" ]; then exit 0; fi
  
    output=$(nmcli device wifi connect "$ssidpick" password "$password" ifname "$interface"  ) # Tries to connect
    wget -q --tries=5 --timeout=5 --spider http://google.com &> /dev/null # Is connected to Internet?
    if [[ $? -eq 0 ]]; then
            #echo "You're connected." 
            whiptail --backtitle "WiFi setup" --title "Scanning..." --msgbox "You're connected." $boxheight $width $listheight
            exit 0
    else
            echo "Error. $output" 
            exit 1
    fi
else
    echo "Invalid interface entered. Exiting..."
    exit 2
fi

## Note 1: this line increments $i
