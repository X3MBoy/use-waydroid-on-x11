#!/bin/bash

# Waydroid and Weston Uninstallation Script
# This script will remove Waydroid, Weston, associated packages, and custom desktop files and configuration directories.

# Function to check distro
check_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID=$ID
    else
        DISTRO_ID=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    fi

    case "$DISTRO_ID" in
        ubuntu|debian|linuxmint|pop|kali)
            PKG_MANAGER="apt"
            ;;
        fedora|centos|rhel|almalinux|rocky)
            PKG_MANAGER="dnf"
            ;;
        *)
            echo "Unsupported distribution: $DISTRO_ID"
            exit 1
            ;;
    esac
    echo "Detected distribution: $DISTRO_ID"
    echo "Using package manager: $PKG_MANAGER"
}

check_distro

echo "Starting Waydroid and Weston uninstallation..."

# Stop and disable Waydroid service if running
sudo systemctl stop waydroid-container
sudo systemctl disable waydroid-container

# Remove Waydroid package and its dependencies
if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt purge -y waydroid
    sudo apt autoremove -y
    sudo apt purge -y weston
    sudo apt autoremove -y
elif [ "$PKG_MANAGER" = "dnf" ]; then
    sudo dnf remove -y waydroid
    sudo dnf autoremove -y
    sudo dnf remove -y weston
    sudo dnf autoremove -y
fi

# Delete user configuration and cache related to Waydroid
rm -rf ~/.config/waydroid
rm -rf ~/.local/share/waydroid
rm -rf ~/.cache/waydroid

# Remove custom .desktop files (e.g., launchers)
find ~/.local/share/applications -type f -name '*waydroid*.desktop' -exec rm -f {} \;

# Remove any system-wide .desktop files related to Waydroid (if present)
sudo find /usr/share/applications -type f -name '*waydroid*.desktop' -exec rm -f {} \;

# Clean up remaining Waydroid directories (safety check)
sudo rm -rf /var/lib/waydroid
sudo rm -rf /etc/waydroid

echo "Waydroid and related files have been successfully removed from your system."

# Final confirmation
echo "Uninstallation complete. It is recommended to restart your system to apply changes."
