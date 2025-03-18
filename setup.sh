#!/bin/bash
set -e

LOG_FILE="/var/log/user-data.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "Starting setup script..."

# Ensure network is ready before downloading anything
while ! ping -c 1 -W 1 8.8.8.8; do
    echo "Waiting for internet connection..."
    sleep 5
done

echo "Internet is available. Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

DEVICE_NAME="/dev/xvdf"
MOUNT_POINT="/mnt/data"

# Wait for the volume to be available
while [ ! -e $DEVICE_NAME ]; do
    sleep 1
done

# Check if the device is already formatted
if ! blkid $DEVICE_NAME; then
    echo "Formatting $DEVICE_NAME..."
    mkfs -t ext4 $DEVICE_NAME
fi

# Create mount directory if it doesn't exist
mkdir -p $MOUNT_POINT

# Mount the EBS volume
mount $DEVICE_NAME $MOUNT_POINT

# Change ownership to ec2-user
chown ec2-user:ec2-user $MOUNT_POINT
chmod 777 $MOUNT_POINT

# Add to /etc/fstab to mount on reboot
echo "$DEVICE_NAME $MOUNT_POINT ext4 defaults,nofail 0 2" >> /etc/fstab

echo "Setup script completed."
