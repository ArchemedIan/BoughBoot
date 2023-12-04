#!/bin/bash

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
      i2=$((i2+1)) 
      IfaceList+=("$interface")
      IfaceList+=("$status")
    fi                                          # Ends the if conditional
done < <(nmcli device | tail -n +2)         # Redirects the output of the command nmcli device to the loop.

## If there is only one interface
if [[ "$i" == "1" ]]; then
    iface=1 # Selected interface is the only one
    #clear   # Quick and dirty workaround for make disappear the interface list.
else
    ## Prompts the user for the interface to use.
    #read -p "Select the interface: " iface
    interface=$(whiptail --backtitle "Simple WiFi setup" --title "WiFi Interface List" --menu "Select a WiFi Interface" 24 112 16 "${IfaceList[@]}" 3>&1 1>&2 2>&3)
fi

## If the entered number is valid then...
if [[ "$iface" -le $i ]]; then
    while read ssid; do                    
        i2=$((i2+1))
        name=$(awk -F: '{printf $1}' <<< $ssid)     
        rate=$(aawk -F: '{printf $2}' <<< $ssid)
        sec=$(awk -F: '{printf $3}'| awk '{ print $NF }' <<< $ssid)
        bars=$(awk -F: '{printf $4}' <<< $ssid)
        bcount=$(echo -n "$bars"| wc -c)
        bcount=$((5-$bcount))
        x=$bcount 
        while [ $x -gt 0 ]; 
        do 
          bars="${bars}-"
          x=$(($x-1))
        done
        if [[ "$type" == "wifi" ]]; then 
          i3=$((i3+1)) 
          SSIDList+=("$name")
          SSIDList+=("$rate $sec $bars")
        fi                                          
    done < <(nmcli --colors no --terse --fields SSID,RATE,SECURITY,BARS d wifi list)
    ssidpick=$(whiptail --backtitle "Simple WiFi setup" --title "WiFi SSID List" --menu "Select an SSID" 24 112 16 "${SSIDList[@]}" 3>&1 1>&2 2>&3)
    password=$(whiptail --backtitle "Simple WiFi setup" --title "WiFi Password Request" --passwordbox "Enter Password for $ssidpick:" 24 112 16>&1 1>&2 2>&3)
    
    #read -p "Enter the SSID or BSSID: " b_ssid # Prompts the user for the ESSID/BSSID
    #read -p "Enter the password: " pass # Prompts the user for the password
    output=$(nmcli device wifi connect "$ssidpick" password "$password" ifname "$interface"  ) # Tries to connect
    wget -q --tries=5 --timeout=5 --spider http://google.com &> /dev/null # Is connected to Internet?
    if [[ $? -eq 0 ]]; then
            echo "You're connected." # Is connected to Internet
            exit 0
    else
            echo "Error. $output" # Anything goes wrong
            exit 1
    fi
else
    echo "Invalid interface entered. Exiting..."
    exit 2
fi

## Note 1: this line increments $i
