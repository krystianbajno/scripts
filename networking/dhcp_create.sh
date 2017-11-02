#!/bin/bash
### This script assumes you have dhcpd, systemd, iproute2 and iptables.
### This script creates redirected DHCP network behind a NAT to use for network troubleshooting, file transfers etc.
### By Krystian Bajno, 2017

### Privileges check. Change UID after -ne in case there is another user.
if [ "$EUID" -ne 0 ];
	then echo "[*] Run it as a privileged user."
	exit
fi
#Defaults
target="enp1s0"
server="wlp2s0"

for i in "$@"
do
case $i in
    -s=*|--server=*)
    server="${i#*=}"
    shift 
    ;;
    -t=*|--target=*)
    target="${i#*=}"
    shift
    ;;
    *)

      echo "
      This script creates a redirected DHCP network behind a NAT to use for network troubleshooting,
      fast file transfers, and anything you want.
      Usage:
      If no arguments are specified, the script will read the defaults written to the script.
      -t=target, --target=target - Set the target interface.
      -s=target, --server=server - Set the server interface.
      Any other given argument will print this help.
      By Krystian Bajno, 2017
      "
      exit 0
    ;;
esac
done
if [[ $target == $server ]]; then
    echo "[*] Target can not be the same as server."
    exit 1
fi
### Clean up
function dhcp_restart(){
    echo [*] Killing DHCP server
    killall dhcpd
    echo [*] Restoring DHCP settings
    cp /etc/dhcpd-bak /etc/dhcpd.conf
    echo [*] flushing $target
    ip neighbor flush dev $target
    ip addr flush dev $target
    echo [*] Restarting firewall
    systemctl restart iptables
    echo [*] Disabling ipv4 forwarding
    echo 0 > /proc/sys/net/ipv4/ip_forward
    echo [*] Done

}

## Act as a router
function iptablesRedirection(){
    echo [*] Setting up iptables and v4 forwarding...
    echo 1 > /proc/sys/net/ipv4/ip_forward
    systemctl stop iptables
    echo [*] Overwriting current rules and making backup to iptables.rules.bak...
    cp /etc/iptables/iptables.rules /etc/iptables/iptables.rules.bak
    iptables -F
    iptables -I FORWARD -i $target -o $server -s 10.1.2.0/24 -d $(ip route | grep $server | grep / | cut -d ' ' -f 1) -j ACCEPT
    iptables -I FORWARD -i $server -o $target -s $(ip route | grep $server | grep / | cut -d ' ' -f 1) -d 10.1.2.0/24 -j ACCEPT
    iptables -t nat -A POSTROUTING -o $server -j MASQUERADE 
    iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
}

echo "[*] Using $server, $target."
echo [*] Setting up Interface
ip addr add 10.1.2.1/24 dev $target
sleep 1
echo "[*] Configuring DHCP server settings..."
echo "default-lease-time 600;
max-lease-time 7200;

  subnet 10.1.2.0 netmask 255.255.255.0 {
  range 10.1.2.2 10.1.2.30;
  option routers 10.1.2.1;
  option broadcast-address 10.1.2.255;
  default-lease-time 600;
  max-lease-time 7200;
  }" > /etc/dhcpd-lan.conf
cp /etc/dhcpd.conf /etc/dhcpd-bak
cp /etc/dhcpd-lan.conf /etc/dhcpd.conf
echo [*] Enabling DHCP server.
dhcpd $target &
sleep 1
if [[ "$(ip route | grep $server >/dev/null; echo $?)" -eq 0 ]]; then
    echo "[*] Add redirection to NAT's outside network? y/n"
    read respond
    if [[ "$respond" == "y" || "$respond" == "Y" ]]
        then
        iptablesRedirection;
    fi
fi
echo [*] Done
read -p "[*] Press enter to continue and restore default settings."
dhcp_restart
if [[ $? -eq 0 ]]; then
    exit 0
else
    echo "[*] There was an error."
    exit 1
fi

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