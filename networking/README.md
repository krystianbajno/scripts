Feel free to modify the scripts if you dont meet the dependencies.
## ap_create:
 This script assumes you use systemd, systemd-newtorkd, iptables, iproute2, dhcpd and hostapd.
# It will create NAT'ed AP using one, or two interfaces.
![alt text](https://github.com/krystianbajno/scripts/blob/master/networking/git.gif "GIF HERE")
## dhcp_create:
 This script assumes you have dhcpd, systemd, iproute2 and iptables.
 This program creates redirected DHCP network behind a NAT to use for network troubleshooting, file transfers etc.
## connection_restart.sh
 This script assumes you have systemd, systemd-networkd running a wpa_supplicant service and iproute2 (for example Arch Linux).
 Its purpose is to completely drop and restart the connection to the defaults no matter what.
