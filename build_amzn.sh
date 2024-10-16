#!/bin/bash
# BlackArch Stratum Builder for Bedrock Linux

# Creating a BlackArch Stratum on Bedrock

# Print header
echo "===================================="
echo "=== AMAZON LINUX STRATUM BUILDER ==="
echo "===================================="

# Check dependencies and permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

if command -v brl >/dev/null 2>&1 ; then
    echo "Bedrock is installed."
else
    echo "Missing dependency: Bedrock Linux was not found. Please install."
    exit 1
fi

if command -v wget >/dev/null 2>&1 ; then
    echo "wget found."
else
    echo "Missing dependency: wget was not found. Please install."
    exit 1
fi

# Make sure the BlackArch stratum doesn't already exist
if [ -d "/bedrock/strata/amzn" ]; then
    echo "amzn stratum already exists."
    exit 1
else
    echo "No existing amzn stratum detected."
fi

echo "pulling amazon linux container image"
wget https://cdn.amazonlinux.com/os-images/2.0.20241001.0/container/amzn2-container-raw-2.0.20241001.0-x86_64.tar.xz
sudo brl import amzn amzn2-container-raw-2.0.20241001.0-x86_64.tar.xz
rm -f amzn2-container-raw-2.0.20241001.0-x86_64.tar.xz

#fix the mount tables
echo "fixing the amazon mtab file"
sudo rm -f /bedrock/strata/amzn/etc/mtab
sudo brl repair amzn

# Show that the stratum is there
echo "Done."
echo "Currently enabled strata:"
brl list
