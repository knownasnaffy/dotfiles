#!/bin/bash
# Stop hostapd
sudo systemctl stop hostapd

# Re-enable client mode
sudo mv /etc/systemd/network/25-wireless.network.disabled /etc/systemd/network/25-wireless.network 2>/dev/null

# Restart iwd
sudo systemctl start iwd

# Restart networkd
sudo systemctl restart systemd-networkd

echo "Hotspot stopped, client mode restored"
