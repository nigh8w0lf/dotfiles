# Acer Predator Fan Control GNOME Extension

A minimal GNOME Shell extension for monitoring temperatures on Acer Predator PT515-51 laptops.

## Features

- **Temperature Display**: Shows the maximum temperature from CPU, System, and NVMe sensors in the top panel
- **Color-Coded Temperatures**:
  - 🟢 **Green** (< 70°C): Cool
  - 🟠 **Orange** (70-85°C): Warm  
  - 🔴 **Red** (> 85°C): Hot
- **Dropdown Menu**: Click the panel icon to view individual sensor temperatures
- **Fan Control Note**: Reminds you to use Fn+F keyboard shortcut for fan control

## Monitored Sensors

The extension tracks these key temperature sensors:

| Sensor | Description |
|--------|-------------|
| **CPU** | Intel Core processor temperature |
| **NVMe SSD** | Solid state drive temperature |
| **System** | Acer system/chipset sensors |
| **Chipset** | Intel PCH (Platform Controller Hub) |
| **WiFi** | Intel wireless adapter temperature |

## Installation

Run the provided installation script:

```bash
./install-all.sh
```

This will:
1. Install the `predator-fan` CLI tool
2. Configure the `acer-wmi` kernel module
3. Install this GNOME extension
4. Set up systemd services

## Usage

After installation and logout/login:

1. **Panel Display**: A block icon (■) with temperature appears in the top panel
2. **Click for Details**: Click the icon to see individual sensor readings
3. **Fan Control**: Press **Fn+F** on your keyboard to cycle fan modes:
   - Silent (quiet, cooler)
   - Default (balanced)
   - Overboost (maximum cooling, loudest)

## Troubleshooting

### Extension not showing

```bash
gnome-extensions enable predator-fan@ashwin
```

Or use GNOME Tweaks → Extensions to enable it.

### Colors not working

The temperature colors should update automatically based on the maximum temperature. If they don't appear:

1. Disable and re-enable the extension
2. Restart GNOME Shell (Alt+F2, type 'r', Enter) - only on X11

### Fan control not working

The extension only displays temperatures. Fan control is handled by:
- **Hardware**: Fn+F keyboard shortcut
- **Software**: Requires additional setup with [NBFC-Linux](https://github.com/nbfc-linux/nbfc-linux) or [Linux Predator Module](https://github.com/JafarAkhondali/linux-predator-module)

Note: The acer-wmi kernel module's platform profile interface (`/sys/devices/platform/acer-wmi/platform-profile/`) returns I/O errors on this model, preventing software-based fan control.

## Files

- `extension.js` - Main extension code
- `stylesheet.css` - Styling for the panel indicator and menu
- `metadata.json` - Extension metadata and GNOME version compatibility
- `prefs.js` - Settings/preferences window

## Requirements

- GNOME Shell 45, 46, 47, 48, or 49
- Acer Predator PT515-51 or similar model with acer-wmi kernel module support
- `lm_sensors` package (installed automatically by install script)

## License

This extension is created for personal use on Acer Predator laptops.

## Terminal Setup

### Dropdown Terminal: ddterm

For a quake-style dropdown terminal on GNOME/Wayland, use **ddterm**:

**Installation:**
```bash
# Via GNOME Extensions website:
# https://extensions.gnome.org/extension/3780/ddterm/

# Or via command line:
gnome-extensions install ddterm@amezin.github.com
```

**Features:**
- Works natively on Wayland
- Tabs support
- Resizable by dragging
- Restores tabs after restart
- Command-line control

**Configuration:**
- Enable: `gnome-extensions enable ddterm@amezin.github.com`
- Default shortcut: **F12** (configurable)
- Settings: Right-click in ddterm → Preferences

**Note:** Ghostty's built-in quick terminal doesn't work on GNOME because it requires `wlr-layer-shell-v1` protocol which Mutter (GNOME's compositor) doesn't support. ddterm is the recommended alternative.

## System Configuration

### Window Manager: GNOME + Pop!_OS Shell

This system uses **Pop!_OS Shell** (`pop-shell@system76.com`), a GNOME Shell extension that provides tiling window management.

**Configuration location:** `~/.config/pop-shell/config.json`

#### Key Shortcuts

Pop!_OS Shell provides the following Super key shortcuts:

| Shortcut | Action |
|----------|--------|
| `Super + Enter` | Launch terminal |
| `Super + /` | Show launcher |
| `Super + Arrow Keys` | Move focus between windows |
| `Super + Shift + Arrow Keys` | Move windows |
| `Super + M` | Toggle tiling mode |
| `Super + G` | Toggle window gaps |
| `Super + O` | Toggle orientation (horizontal/vertical) |

**Note:** These shortcuts are managed by the Pop!_OS Shell extension, not a standalone tiling window manager like Sway or Hyprland.

#### Managing Pop!_OS Shell

- Enable/disable: `gnome-extensions enable/disable pop-shell@system76.com`
- Settings: GNOME Settings → Keyboard → Tiling
- Or use: GNOME Tweaks → Extensions → Pop Shell

## Credits

Created for Acer Predator PT515-51 laptops running Fedora Linux.
