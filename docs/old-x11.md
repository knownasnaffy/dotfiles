# X11-Only Tools and Configurations

This document lists all X11-specific tools, configurations, and services in the dotfiles that may conflict with Hyprland/Wayland setup and need to be replaced or removed.

## Display & Graphics

### Xorg Server & Tools
- **Packages**: `xorg-server`, `xorg-xinit`, `xorg-xrandr`
- **Purpose**: X11 display server and utilities
- **Replacement**: Wayland compositor (Hyprland)
- **Status**: ❌ X11 only

### X11 Configuration
- **File**: `etc/X11/xorg.config.d/30-touchpad.conf`
- **Purpose**: Touchpad configuration for X11
- **Replacement**: Hyprland input configuration
- **Status**: ❌ X11 only

### Xresources
- **File**: `.config/.Xresources`
- **Purpose**: X11 resource database (colors, fonts)
- **Replacement**: Terminal-specific configs or Hyprland theming
- **Status**: ❌ X11 only

## Notes

1. **Rofi** works with Wayland, but you might want to consider **wofi** or **fuzzel** for better Wayland integration.
2. The setup script should be updated to install Wayland-specific tools instead of X11 ones.
