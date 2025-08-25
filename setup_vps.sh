#!/bin/bash

# ============================================
# User Configuration
# ============================================

# Your GitHub raw script URL
GITHUB_RAW_URL="https://raw.githubusercontent.com/guangwit9/ArgoSB_merge/main/"

# The directory where scripts will be installed on the VPS
INSTALL_DIR="/root/scripts"

# ============================================
# Automated Script Section - No need to modify
# ============================================

# Check if script is run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

echo "Starting VPS setup and file synchronization..."

# Check and install git and python3-pip
echo "Checking dependencies: git and python3-pip..."
apt-get update -y
if ! command -v git &> /dev/null; then
    echo "git not found, installing..."
    apt-get install -y git
fi
if ! dpkg -l | grep -q python3-pip; then
    echo "python3-pip not found, installing..."
    apt-get install -y python3 python3-pip
fi

echo "Installing Python dependencies..."
# Use a full path for python3 to ensure it is found
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 command not found. Exiting."
    exit 1
fi
python3 -m pip install PyYAML

# Create installation directory
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || { echo "Error: Failed to change directory. Exiting."; exit 1; }

# Download script files
echo "Downloading scripts from GitHub..."
curl -sL "${GITHUB_RAW_URL}upload_and_merge.py" -o "upload_and_merge.py"
curl -sL "${GITHUB_RAW_URL}gitlab_uploader.sh" -o "gitlab_uploader.sh"

if [ $? -ne 0 ] || [ ! -s "upload_and_merge.py" ] || [ ! -s "gitlab_uploader.sh" ]; then
    echo "Error: Failed to download one or more scripts. Check your GitHub URL."
    exit 1
fi

# Make scripts executable
chmod +x gitlab_uploader.sh
chmod +x upload_and_merge.py

# Run the main uploader script
echo "Running the main uploader script..."
/bin/bash gitlab_uploader.sh

echo "Setup and synchronization complete."
