Feel free to modify the scripts if you dont meet the dependencies.
## ap_create:
### It will create NAT'ed AP using one, or two interfaces.
![alt text](https://github.com/krystianbajno/scripts/blob/testing/networking/git.gif "GIF HERE")
This script assumes you use systemd, systemd-newtorkd, iptables, iproute2, dhcpd and hostapd.
## dhcp_create:
### This program creates redirected DHCP network behind a NAT to use for network troubleshooting, file transfers etc.
This script assumes you have dhcpd, systemd, iproute2 and iptables.
## connection_restart.sh
### Its purpose is to completely drop and restart the connection to the defaults no matter what.
This script assumes you have systemd, systemd-networkd running a wpa_supplicant service and iproute2 (for example Arch Linux).
