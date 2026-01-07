#!/bin/bash
# Disconnect from any WiFi network
sudo iwctl station wlan0 disconnect 2>/dev/null

# Stop iwd to prevent conflicts
sudo systemctl stop iwd

# Disable client mode network config
sudo mv /etc/systemd/network/25-wireless.network /etc/systemd/network/25-wireless.network.disabled 2>/dev/null

# Bring up wlan0
sudo ip link set wlan0 up

# Restart networkd (will apply the AP config)
sudo systemctl restart systemd-networkd

# Wait for networkd to settle
sleep 2

# Start hostapd
sudo systemctl start hostapd

echo "Hotspot started on wlan0"
echo "SSID: MyHotspot"
echo "Sharing internet from eno1"
