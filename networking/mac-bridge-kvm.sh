#!/bin/bash

# Variables
BRIDGE_NAME="br0"  # Bridge interface name
VM_NAME="your_vm_name"  # Replace with your VM name
SPECIFIED_MAC="00:11:22:33:44:55"  # Replace with desired VM MAC
HOST_INTERFACE="eth0"  # Replace with your host's network interface

# Check for root permissions
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

# Create a backup of the current VM configuration
backup_vm_config() {
  echo "Creating a backup of the VM configuration..."
  virsh dumpxml $VM_NAME > "/var/backups/kvm-config/${VM_NAME}_backup.xml"
  if [ $? -ne 0 ]; then
    echo "Failed to backup VM configuration. Exiting."
    exit 1
  fi
  echo "Backup created at /var/backups/kvm-config/${VM_NAME}_backup.xml"
}

# Get the current MAC address of the host
get_host_mac() {
  ip link show $HOST_INTERFACE | awk '/ether/ {print $2}'
}

# Setup the network bridge if it doesn't exist
setup_bridge() {
  if ! ip link show "$BRIDGE_NAME" &> /dev/null; then
    echo "Creating bridge $BRIDGE_NAME..."
    ip link add name $BRIDGE_NAME type bridge
    ip link set $BRIDGE_NAME up
    ip link set $HOST_INTERFACE master $BRIDGE_NAME
  else
    echo "Bridge $BRIDGE_NAME already exists."
  fi
}

# Swap MAC addresses between the host and VM
swap_mac_addresses() {
  echo "Swapping MAC addresses between host and VM..."
  TEMP_MAC="02:00:00:00:00:01"  # Temporary MAC to avoid conflict
  HOST_MAC=$(get_host_mac)

  # Temporarily change host MAC to avoid conflict
  ip link set dev $HOST_INTERFACE down
  ip link set dev $HOST_INTERFACE address $TEMP_MAC
  ip link set dev $HOST_INTERFACE up

  # Set the VM's MAC address to the original host MAC
  virsh domif-setmac $VM_NAME vnet0 $HOST_MAC

  # Set host MAC to the specified VM MAC
  ip link set dev $HOST_INTERFACE down
  ip link set dev $HOST_INTERFACE address $SPECIFIED_MAC
  ip link set dev $HOST_INTERFACE up

  echo "MAC addresses have been swapped. Host now uses $SPECIFIED_MAC."
  echo "VM now uses $HOST_MAC."
}

# Ensure the VM is using the bridge
configure_vm_network() {
  echo "Configuring VM to use bridged mode..."
  CURRENT_BRIDGE=$(virsh domiflist $VM_NAME | awk '/bridge/ {print $3}')

  if [ "$CURRENT_BRIDGE" != "$BRIDGE_NAME" ]; then
    echo "Configuring VM network interface to use bridge $BRIDGE_NAME..."
    virsh detach-interface $VM_NAME network --type bridge 2>/dev/null
    virsh attach-interface $VM_NAME bridge $BRIDGE_NAME --model virtio --mac $SPECIFIED_MAC
    if [ $? -ne 0 ]; then
      echo "Failed to attach bridge interface to VM. Exiting."
      exit 1
    fi
    echo "VM is now using bridge $BRIDGE_NAME with MAC $SPECIFIED_MAC."
  else
    echo "VM is already using the correct bridge."
  fi
}

# DHCP Configuration Hint
configure_dhcp() {
  echo "Configuring DHCP for VM..."
  # Ensure the VM gets a new IP from DHCP. This step may require custom network service restarts or interactions.
  echo "Consider restarting the network service on the VM to obtain an IP address using DHCP (if applicable)."
  echo "Alternatively, you can configure a static IP if you know the network parameters."
}

# Main Execution
echo "Starting the setup for swapping MAC addresses and configuring KVM bridged mode..."

# Ensure necessary directories exist for backups
mkdir -p /var/backups/kvm-config

backup_vm_config
setup_bridge

HOST_MAC=$(get_host_mac)
echo "Current Host MAC Address: $HOST_MAC"
echo "Desired VM MAC Address: $SPECIFIED_MAC"

if [ "$HOST_MAC" == "$SPECIFIED_MAC" ]; then
  echo "Host MAC address matches the specified MAC for the VM. Swapping addresses..."
  swap_mac_addresses
else
  echo "Host and specified VM MAC addresses differ. Configuring VM directly..."
  configure_vm_network
fi

configure_dhcp

echo "Configuration completed. Verify network connectivity and make adjustments if necessary."
