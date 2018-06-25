#!/bin/bash
### This script is made for ad hoc WPA2 connections.
### This script assumes that you have systemd, wpa_supplicant, iproute2 and dhcpcd on your machine.
###CONFIGURATION
### Specify username.
USERNAME="krystian"
### Or you can change the logged passwords directory
passes="/home/$USERNAME/.config/wifi-passes.txt"
### Store temps in RAM
temporary="/dev/shm/temporarypass.txt"
texteditor="vim"

pattern=" |'"
################

function restartNetwork(){
 2>/dev/null 1>/dev/null echo Stopping systemd-networkd service...
 systemctl stop systemd-networkd
 2>/dev/null 1>/dev/null echo Stopping wpa_supplicant service...
 systemctl stop wpa_supplicant@wlp2s0
 echo Killing wpa_supplicant...
 2>/dev/null 1>/dev/null killall wpa_supplicant
 2>/dev/null 1>/dev/null echo killing systemd-networkd...
 2>/dev/null 1>/dev/null killall systemd-networkd
 echo Disabling systemd-networkd and wpa_supplicant service...
 2>/dev/null 1>/dev/null systemctl disable systemd-networkd
 2>/dev/null 1>/dev/null systemctl disable wpa_supplicant@$interface
}


### Change value after -ne to user with access to network interfaces. By default root.
if [ "$EUID" -ne 0 ];
	then echo "RUN AS PRIVILEGED USER"
	exit
fi
echo "Listing interfaces:"
ls /sys/class/net
echo "Which interface do you wish to use?"
read interface
echo Restart the interface? y/n
read respond2
if [[ "$respond2" == "Y" || "$respond2" == "y" ]] 
then
echo Restarting the interface:
ip link set $interface down
ip link set $interface up
fi
sleep 1
echo Available networks:
iw dev $interface scan | grep SSID
echo cat the wifi log file? y/n
read respond
if [[ "$respond" == "Y" || "$respond" == "y" ]]
then
cat $passes
fi
echo Give the SSID:
read wifissid
echo Give Passphrase:
read passphrase

### If passphrase has a space, then open a text editor.
if [[ $wifissid =~ $pattern ]]
then
 echo "You'll have to specify it manually in file"
 notify-send "You'll have to specify it manually in file"
 echo "Comment out the PSK code and leave out only SSID"
 notify-send "Comment out the PSK code and leave only SSID"
 sleep 3
 touch $temporary
 wpa_passphrase ChangeSSSID $passphrase > $temporary
 $texteditor $temporary
 restartNetwork
 echo Connecting to wifi...
 wpa_supplicant -B -i $interface -c $temporary
 echo Logging wifi...
 date >> $passes
 cat $temporary >> $passes
 echo Cleaning up...
 rm $temporary
else
  restartNetwork
  echo Connecting to wifi...
  wpa_supplicant -i $interface -B -c <(wpa_passphrase $wifissid $passphrase) &&
  echo Logging the credentials to /home/krystian/.config/wifi-passes.txt...
  date >> $passes
  wpa_passphrase $wifissid $passphrase >> $passes
fi
echo Flushing IP...
ip addr flush dev $interface
echo Flushing ARP table...
ip neighbor flush dev $interface
echo Connecting to DHCP server...
dhcpcd &
echo Done.
exit
