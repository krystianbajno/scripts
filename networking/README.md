# ap_create:  
### Creates the access point with forwarded NAT.
![alt text](https://github.com/krystianbajno/scripts/blob/testing/networking/git.gif "GIF HERE")   
# dhcp_create:  
### Creates forwarded NAT network with DHCP. 
# connection_restart.sh  
### Drops and restarts the connection to defaults.  

# Dependencies:
### ap_create:
systemd, systemd-newtorkd, iptables, iproute2, dhcpd, hostapd.  
### dhcp_create:
systemd, dhcpd, iproute2 and iptables.
### connection_restart.sh
systemd, systemd-networkd, iproute2  