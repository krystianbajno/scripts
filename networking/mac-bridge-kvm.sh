#!/bin/bash

# Variables
BRIDGE_NAME="br0"  # Name of the bridge
VM_NAME="your_vm_name"  # Replace with your VM name
SPECIFIED_MAC="00:11:22:33:44:55"  # Replace with your desired MAC address for the VM
HOST_INTERFACE="eth0"  # Replace with your actual host network interface
BACKUP_DIR="/var/backups/kvm-config"  # Directory to store backups

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Backup function for VM XML configuration
backup_vm_config() {
  echo "Backing up current VM configuration..."
  virsh dumpxml $VM_NAME > "$BACKUP_DIR/${VM_NAME}_backup.xml"
  if [ $? -ne 0 ]; then
    echo "Failed to backup VM configuration. Exiting."
    exit 1
  fi
  echo "Backup saved to $BACKUP_DIR/${VM_NAME}_backup.xml"
}

# Verify bridge existence
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

# Get host MAC address
get_host_mac() {
  ip link show $HOST_INTERFACE | awk '/ether/ {print $2}'
}

# Function to swap MAC addresses
swap_mac_addresses() {
  echo "Swapping MAC addresses between host and VM..."
  TEMP_MAC="02:00:00:00:00:01"
  ip link set dev $HOST_INTERFACE address $TEMP_MAC
  sleep 1

  # Set specified MAC for VM
  virsh domif-setmac $VM_NAME vnet0 $SPECIFIED_MAC

  # Set original MAC for host to specified one
  ip link set dev $HOST_INTERFACE address $SPECIFIED_MAC
}

# Ensure VM is using a bridged interface
configure_vm_network() {
  echo "Ensuring VM is in bridged mode..."
  CURRENT_BRIDGE=$(virsh domiflist $VM_NAME | awk '/bridge/ {print $3}')

  if [ "$CURRENT_BRIDGE" != "$BRIDGE_NAME" ]; then
    echo "VM is not using the correct bridge. Configuring..."
    virsh detach-interface $VM_NAME network --type bridge 2>/dev/null
    virsh attach-interface $VM_NAME bridge $BRIDGE_NAME --model virtio --mac $SPECIFIED_MAC
    if [ $? -ne 0 ]; then
      echo "Failed to attach the bridge interface to the VM."
      exit 1
    fi
    echo "VM has been successfully attached to bridge $BRIDGE_NAME."
  else
    echo "VM is already using bridge $BRIDGE_NAME."
  fi
}

# Main script execution
echo "Starting KVM bridged mode setup..."

backup_vm_config
setup_bridge

HOST_MAC=$(get_host_mac)
echo "Host MAC Address: $HOST_MAC"
echo "Specified VM MAC Address: $SPECIFIED_MAC"

if [ "$HOST_MAC" == "$SPECIFIED_MAC" ]; then
  echo "Host MAC address matches the specified VM MAC address. Swapping..."
  swap_mac_addresses
else
  echo "MAC addresses are different. Proceeding with configuration..."
fi

configure_vm_network

echo "Configuration complete. Please verify network settings."
