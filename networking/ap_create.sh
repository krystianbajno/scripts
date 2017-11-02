#!/bin/bash
# Creates the access point with forwarded NAT.
### By Krystian Bajno, 2017

###Settings
if [ "$EUID" -ne 0 ];
	then echo "[*] Run as a privileged user"
	exit
fi

## Choose your editor.
chosenEditor="vim"
## Set up virtual MAC
networkMAC="12:34:56:78:ab:ce"
## Set up network
SSID="coolwifi"
PASSPHRASE="777888999"
CHANNEL="7"
###

function setInterfaces(){
	ip link set dev $natinterface down
	systemctl stop wpa_supplicant@$natinterface 2>&1 >/dev/null
	iw dev $natinterface interface add wlan_ap type managed addr $networkMAC
	sleep 1
	ip addr add dev wlan_ap 10.1.2.1/24
	ip link set dev $natinterface up
	ip link set dev wlan_ap up
	### It has to be indented that way.
	echo "default-lease-time 600;
max-lease-time 7200;

subnet 10.1.2.0 netmask 255.255.255.0 {
  range 10.1.2.2 10.1.2.30;
  option routers 10.1.2.1;
  option broadcast-address 10.1.2.255;
  default-lease-time 600;
  max-lease-time 7200;
  }" > /etc/dhcpd-lan.conf

	echo "[*] Backing up dhcpd.conf -> dhcpd-bak"
		cp /etc/dhcpd.conf /etc/dhcpd-bak
	echo [*] Copying DHCP settings to dhcp
		cp /etc/dhcpd-lan.conf /etc/dhcpd.conf
	echo [*] Enabling DHCP server
	dhcpd wlan_ap &
}
function cleanItUp(){
	echo "[*] Do you want to clean up?  y/n"
	read respond
	if [[ "$respond" == "y" || "$respond" == "Y" ]]
		then
			echo [*] Cleaning...
			killall dhcpd >/dev/null 2>&1
			killall hostapd >/dev/null 2>&1
			iw dev wlan_ap del >/dev/null 2>&1
			ip addr flush dev $natinterface >/dev/null 2>&1
			cp /etc/iptables/iptables.bak /etc/iptables/iptables.rules
			cp /etc/hostapd/hostapd-bak /etc/hostapd/hostapd.conf
			cp /etc/dhcpd-bak /etc/dhcpd.conf
			systemctl restart iptables >/dev/null 2>&1
			systemctl restart systemd-networkd >/dev/null 2>&1
			echo [*] Input wireless interface to restore.
			echo $(iw dev | grep Interface | cut -d ' ' -f 2);
			read interface
			systemctl restart wpa_supplicant@$interface >/dev/null 2>&1
			echo [*] Clean.
	else
		echo Goodbye.
	fi
}
function fetchNatInterface(){
	echo [*] Listing wireless interfaces:
    echo $(iw dev | grep Interface | cut -d ' ' -f 2);
	echo [*] Specify wireless ap interface
	read natinterface
	#Get into loop
	while [[ $(iw dev | grep $natinterface | cut -d ' ' -f 2 | grep $natinterface >/dev/null; echo $?) -ne 0 ||  $natinterface == $interface ]]; do
		### Check if is wireless
		if [[ $(iw dev | grep $natinterface | cut -d ' ' -f 2 | grep $natinterface >/dev/null; echo $? ) -ne 0 ]]; then
			### Do while is not wireless
			while [[ $(iw dev | grep $natinterface | cut -d ' ' -f 2 | grep $natinterface >/dev/null ; echo $? ) -ne 0 ]]; do
				echo [*] Interface must be wireless.
				read natinterface
			done;
		fi
		## Check if is the same
		if [ $natinterface == $interface ]; then
			while [ $natinterface == $interface ]; do
				echo [*] Interfaces must differ
				read natinterface
			done
		fi
	done;
}
function fetchWirelessInterface(){
	echo [*] Listing wireless interfaces:
    echo $(iw dev | grep Interface | cut -d ' ' -f 2);
	echo [*] Specify wireless ap interface
	read natinterface
		### Do while not wireless
		while [[ $(iw dev | grep $natinterface | cut -d ' ' -f 2 | grep $natinterface >/dev/null ; echo $? ) -ne 0 ]]; do
			echo [*] Interface must be wireless.
			read natinterface
		done;
}
function modifySettings(){
	echo [*] Backing up hostapd config...
	cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd-bak
	if [[ $? -eq 0 ]]; then
		echo "[*] Copy AP configuration template? y/n"
		read respond4	
		if [[ "$respond4" == "y" || "$respond4" == "Y" ]]; then
		### It has to be indented that way.
			echo "ssid=$SSID 
wpa_passphrase=$PASSPHRASE
interface=wlan_ap
channel=$CHANNEL
driver=nl80211
hw_mode=g
wpa=2" > /etc/hostapd/hostapd.conf
		fi
		echo "[*] Modify the AP settings? y/n"
		read respond3
		if [[ "$respond3" == "y" || "$respond3" == "Y" ]]; then
				$chosenEditor /etc/hostapd/hostapd.conf
		fi
	else
		echo "[*] There was an error."
		cleanItUp
		exit 1
	fi
}

echo [*] Listing interfaces:
ls /sys/class/net
echo [*] Specify forwarding interface with connection to external network:
read interface
### Check if exists
if [[ "$(ip link | grep $interface >/dev/null; echo $?)" -ne 0 ]]; then
		echo Interface doesnt exist
		exit 1
fi
### Check if has connection
if [[ "$(ip route | grep $interface >/dev/null; echo $?)" -eq 0 ]]; then
	fetchNatInterface
	echo [*] Adding and configuring ap interface
	setInterfaces
	echo [*] Setting up iptables and v4 forwarding

##iptables and redirection here
	systemctl stop iptables
	echo [*] Overwriting current rules and making backup to iptables.rules.bak...
	cp /etc/iptables/iptables.rules /etc/iptables/iptables.rules.bak
	echo 1 > /proc/sys/net/ipv4/ip_forward
	iptables -F
	iptables -I FORWARD -i $natinterface -o $interface -s 10.1.2.0/24 -d $(ip route | grep $interface | grep / | cut -d ' ' -f 1) -j ACCEPT
	iptables -I FORWARD -i $interface -o $natinterface -s $(ip route | grep $interface | grep / | cut -d ' ' -f 1) -d 10.1.2.0/24 -j ACCEPT
	iptables -t nat -A POSTROUTING -o $interface -j MASQUERADE 
	iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
	modifySettings
	echo [*] Enabling the Hotspot
	hostapd /etc/hostapd/hostapd.conf -i wlan_ap &
	if [[ $? -ne 0 ]]; then
		echo "[*] Error! Cleaning up."
		cleanItUp 
		exit 1
	fi
	sleep 1
	read -p "[*] Press any key to continue and clean."
	cleanItUp
	exit 0
#In case no connection on interface
else
	echo [*] There is no existing connection on specified interface!
    echo "[*] Do you wish to continue without the forwarding? y/n"
    read respond
	if [[ "$respond" == "y" || "$respond" == "Y" ]]
		then
			fetchWirelessInterface
			setInterfaces
			sleep 1
			modifySettings
			iptables -F
				echo [*] Enabling the HotSpot
				hostapd /etc/hostapd/hostapd.conf -i wlan_ap &
			if [[ $? -ne 0 ]]; then
				echo "[*] Error! Can't start hostapd. Cleaning up."
				cleanItUp
				exit 1 
			fi
	else
		echo "[*] Closing."
		cleanItUp
		exit 1
	fi
	sleep 1
	read -p "[*] Press any key to continue and clean."
	cleanItUp
	exit 0
fi



### hostapd.conf contents
<<COMMENT
ssid=coolwifi
wpa_passphrase=777888999
interface=wlan_ap
channel=7
driver=nl80211
hw_mode=g
wpa=2
COMMENT

#### Contents of dhcpd-lan.conf
<<COMMENT
default-lease-time 600;
max-lease-time 7200;

subnet 10.1.2.0 netmask 255.255.255.0 {
  range 10.1.2.2 10.1.2.30;
  option routers 10.1.2.1;
  option broadcast-address 10.1.2.255;
  default-lease-time 600;
  max-lease-time 7200;
}
COMMENT
