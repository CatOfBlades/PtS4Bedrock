#!/usr/bin/env bash

# Kali Linux Stratum Builder for Bedrock Linux

# Licensing Information
## Copyright 2020 nexxius
##
## Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
## 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
## 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
## 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Creating a Kali Linux Stratum on Bedrock

# Print header
echo "============================"
echo "=== KALI STRATUM BUILDER ==="
echo "============================"

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

if command -v fuseiso >/dev/null 2>&1 ; then
    echo "fuseiso found."
else
    echo "Missing dependency: fuseiso was not found. Please install."
    exit 1
fi

if command -v unsquashfs >/dev/null 2>&1 ; then
    echo "unsquashfs found."
else
    echo "Missing dependency: unsquashfs was not found. Please install."
    exit 1
fi

if command -v wget >/dev/null 2>&1 ; then
    echo "wget found."
else
    echo "Missing dependency: wget was not found. Please install."
    exit 1
fi

# Make sure the Kali stratum doesn't already exist
if [ -d "/bedrock/strata/kali" ]; then
    echo "Kali stratum already exists."
    exit 1
else
    echo "No existing Kali stratum detected."
fi

# Get the latest live Kali x64 image, which at the time of writing is 2020.4.
file="/tmp/kali.iso"
if [ -f "$file" ]; then
    echo "Kali Linux ISO file already exists. Skipping download."
else
    echo "Kali Linux ISO file does not exist. Downloading latest Kali Linux image."
    wget https://cdimage.kali.org/kali-2024.3/kali-linux-2024.3-live-amd64.iso -O /tmp/kali.iso
fi

# Mount the Kali Image
mkdir /tmp/mnt
#mount /tmp/kali.iso /tmp/mnt
fuseiso /tmp/kali.iso /tmp/mnt

# Build the stratum
mkdir /tmp/kalidir
unsquashfs -d /tmp/kalidir /tmp/mnt/live/filesystem.squashfs

sudo brl import kali /tmp/kalidir

rmdir /tmp/mnt
rmdir /tmp/kalidir

# Implement a dpkg Statoverride fix 
#  Statoverride (From https://bedrocklinux.org/1.0beta2/troubleshooting.html)
#    If you get an error about statoverride when using apt/dpkg, it can most likely be resolved
#    by deleting the contents of /var/lib/dpkg/statoverride in the relevant stratum. For example:
#      printf "" > /bedrock/strata/jessie/var/lib/dpkg/statoverride
printf "" > /bedrock/strata/kali/var/lib/dpkg/statoverride

# Enable the Stratum
brl show kali
brl enable kali

# Show that the stratum is there
echo "Done."
echo "Currently enabled strata:"
brl list
