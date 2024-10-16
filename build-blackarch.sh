#!/usr/bin/bash

# BlackArch Stratum Builder for Bedrock Linux

# Licensing Information
## Copyright 2020 nexxius
##
## Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
## 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
## 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
## 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Creating a BlackArch Stratum on Bedrock

# Print header
echo "================================="
echo "=== BLACKARCH STRATUM BUILDER ==="
echo "================================="

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
if [ -d "/bedrock/strata/blackarch" ]; then
    echo "BlackArch stratum already exists."
    exit 1
else
    echo "No existing BlackArch stratum detected."
fi

# Get the latest live BlackArch Strap file, available from https://blackarch.org.
file="/tmp/strap.sh"
if [ -f "$file" ]; then
    echo "BlackArch Strap file already exists. Skipping download."
else
    echo "BlackArch Strap file not found. Downloading latest Strap file."
    wget https://blackarch.org/strap.sh -O /tmp/strap.sh
fi

# Set up a base Arch stratum
##brl fetch arch -n blackarch
curl -OJL "https://gitlab.archlinux.org/api/v4/projects/10185/packages/generic/rootfs/20241006.0.268140/base-20241006.0.268140.tar.zst"
mkdir /tmp/arch-bootstrap
tar -C /tmp/arch-bootstrap --extract --file base-20241006.0.268140.tar.zst
sudo brl import blackarch /tmp/arch-bootstrap
sudo rm -rf /tmp/arch-bootstrap

# Install BlackArch in the BlackArch stratum
# Echoing an empty line into pacman.conf prevents a bug where the BlackArch repos are treated as if they belong to another repository.
echo "" >> /bedrock/strata/blackarch/etc/pacman.conf

# Container arch doesn't have bin in the root dir
sudo strat blackarch -r ln -s /usr/bin /bin

chmod +x /tmp/strap.sh
strat -r blackarch /tmp/strap.sh

# Show that the stratum is there
echo "Done."
echo "Currently enabled strata:"
brl list
