#!/bin/bash
### This script assumes you have systemd, systemd-networkd running a wpa_supplicant service and iproute2 (for example Arch Linux).
### Its purpose is to completely drop and restart the connection to the defaults no matter what.
### By Krystian Bajno, 2017
echo By Krystian Bajno
if [ "$EUID" -ne 0 ];
	then echo "Run as a privileged user."
	exit
fi

#### Config
WIRELESS_INTERFACE="wlp2s0"

###
echo -e "Restoring systemd-networkd connection."
echo "Killing processes..."
   2>/dev/null 1>/dev/null killall dhcpcd
echo "Stopping daemons..."
    2>/dev/null 1>/dev/null systemctl stop systemd-networkd
    2>/dev/null 1>/dev/null systemctl stop wpa_supplicant@$WIRELESS_INTERFACE
echo Flushing IP on all interfaces...
for i in $(ls /sys/class/net/); do
	ip addr flush dev $i
done
echo Flushing ARP table on all interfaces...
for i in $(ls /sys/class/net/); do
	ip neighbor flush dev $i
done

if [[ "$(ip link | grep $WIRELESS_INTERFACE >/dev/null; echo $?)" -ne 0 ]]; then
echo Setting $WIRELESS_INTERFACE to managed mode...
	ip link set $WIRELESS_INTERFACE down
	iw dev $WIRELESS_INTERFACE set type managed
	ip link set $WIRELESS_INTERFACE up
fi
echo Rebooting all interfaces...
for i in $(ls /sys/class/net/ -I $WIRELESS_INTERFACE); do
	ip link set $i down
	ip link set $i up
done
sleep 1
echo Starting and enabling systemd-networkd...
    2>/dev/null 1>/dev/null systemctl start systemd-networkd
    2>/dev/null 1>/dev/null systemctl enable systemd-networkd
echo Starting and enabling wpa_supplicant on $WIRELESS_INTERFACE...
    2>/dev/null 1>/dev/null systemctl start wpa_supplicant@$WIRELESS_INTERFACE
    2>/dev/null 1>/dev/null systemctl enable wpa_supplicant@$WIRELESS_INTERFACE
echo Restarting iptables service...
    2>/dev/null 1>/dev/null systemctl restart iptables
echo -e "Done."
exit 0 
