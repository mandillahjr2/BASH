#!/bin/bash

echo "Stopping Waydroid services..."
waydroid session stop 2>/dev/null

echo "Uninstalling Waydroid..."
if command -v apt &>/dev/null; then
    apt remove --purge waydroid -y
    apt autoremove --purge -y
elif command -v pacman &>/dev/null; then
    pacman -Rns waydroid --noconfirm
elif command -v dnf &>/dev/null; then
    dnf remove waydroid -y
else
    echo "Package manager not detected. Please remove Waydroid manually."
fi

echo "Removing configuration and data..."
rm -rf /var/lib/waydroid ~/.local/share/waydroid ~/.config/waydroid

echo "Removing LXC container..."
lxc-destroy -n waydroid 2>/dev/null

echo "Waydroid has been completely removed."
