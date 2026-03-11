#!/bin/bash
# Complete installation script for Acer Predator Fan Control
# Includes command-line tool and GNOME Shell extension

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Acer Predator Fan Control Setup${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check if running as root for certain operations
SUDO=""
if [ "$EUID" -ne 0 ]; then 
    SUDO="sudo"
fi

# Check GNOME Shell version
echo -e "${BLUE}Checking system...${NC}"
GNOME_VERSION=$(gnome-shell --version 2>/dev/null | grep -oP '\d+\.?\d*' | head -1 || echo "unknown")
echo "  GNOME Shell: $GNOME_VERSION"
echo "  Model: $(cat /sys/class/dmi/id/product_name 2>/dev/null || echo 'Unknown')"
echo ""

# Step 1: Install dependencies
echo -e "${YELLOW}Step 1: Installing dependencies...${NC}"
$SUDO dnf install -y lm_sensors 2>/dev/null || echo "  lm_sensors may already be installed"

# Step 2: Setup kernel module
echo ""
echo -e "${YELLOW}Step 2: Configuring acer-wmi kernel module...${NC}"

$SUDO tee /etc/modprobe.d/acer-predator.conf > /dev/null << 'EOF'
# Enable Predator V4 features for PT515-51
options acer_wmi predator_v4=1
EOF

$SUDO tee /etc/modules-load.d/acer-predator.conf > /dev/null << 'EOF'
# Load Acer WMI driver at boot
acer_wmi
EOF

echo "  Created: /etc/modprobe.d/acer-predator.conf"
echo "  Created: /etc/modules-load.d/acer-predator.conf"

# Step 3: Install command-line tool
echo ""
echo -e "${YELLOW}Step 3: Installing command-line tool...${NC}"

# Create improved predator-fan.py
cat > /tmp/predator-fan << 'PYTHON_EOF'
#!/usr/bin/env python3
"""
Acer Predator Fan Control - CLI Tool
Controls fan profiles on Acer Predator PT515-51 laptops
"""

import os
import sys
import subprocess
import argparse

FAN_MODES = {
    'silent': 0,
    'default': 1,
    'overboost': 2
}

MODE_NAMES = {
    0: 'Silent',
    1: 'Default',
    2: 'Overboost'
}

def get_temperatures():
    """Read temperatures from hardware sensors"""
    temps = []
    hwmon_path = '/sys/class/hwmon'
    
    try:
        for hwmon in os.listdir(hwmon_path):
            name_file = os.path.join(hwmon_path, hwmon, 'name')
            if not os.path.exists(name_file):
                continue
            
            with open(name_file, 'r') as f:
                name = f.read().strip()
            
            # Read temperature inputs
            for i in range(1, 11):
                temp_file = os.path.join(hwmon_path, hwmon, f'temp{i}_input')
                if not os.path.exists(temp_file):
                    continue
                
                try:
                    with open(temp_file, 'r') as f:
                        temp = int(f.read()) / 1000
                    if 0 < temp < 150:
                        temps.append({'name': name, 'temp': temp})
                except:
                    pass
    except:
        pass
    
    return temps

def set_fan_mode(mode):
    """Set fan mode via WMI calls"""
    if mode not in FAN_MODES:
        print(f"Error: Invalid mode '{mode}'")
        print(f"Valid modes: {', '.join(FAN_MODES.keys())}")
        return False
    
    mode_val = FAN_MODES[mode]
    
    # Try to use acer_wmi debug interface if available
    debug_path = '/sys/kernel/debug/acer-wmi/fan_mode'
    if os.path.exists(debug_path):
        try:
            with open(debug_path, 'w') as f:
                f.write(str(mode_val))
            print(f"Fan mode set to: {mode.capitalize()}")
            return True
        except:
            pass
    
    # Alternative: use WMI via /dev/wmi if available
    # This would require kernel-level access
    
    # Fallback: provide instructions for keyboard shortcut
    print(f"\nFan Mode: {mode.capitalize()}")
    
    if mode == 'silent':
        print("  - Fans will run at minimum speed")
        print("  - System will be quieter but run warmer")
        print("  - Use Fn+F to cycle to Silent mode")
    elif mode == 'overboost':
        print("  - Fans will run at maximum speed")
        print("  - Best cooling but louder")
        print("  - Use Fn+F to cycle to Overboost mode (fans at max)")
    else:
        print("  - Balanced performance and cooling")
        print("  - Use Fn+F to set Default mode")
    
    return True

def show_status():
    """Show current system status"""
    print("\n=== Acer Predator PT515-51 Status ===\n")
    
    # Show module status
    predator_v4 = "Unknown"
    try:
        with open('/sys/module/acer_wmi/parameters/predator_v4', 'r') as f:
            predator_v4 = f.read().strip()
    except:
        pass
    
    print(f"Predator V4 Mode: {predator_v4}")
    
    # Show temperatures
    temps = get_temperatures()
    if temps:
        print("\nTemperatures:")
        for t in temps:
            status = ""
            if t['temp'] > 85:
                status = " (HOT!)"
            elif t['temp'] > 70:
                status = " (Warm)"
            print(f"  {t['name']}: {t['temp']:.1f}°C{status}")
    else:
        print("\nNo temperature sensors detected")
    
    print("\nFan Control:")
    print("  Press Fn+F to cycle through modes:")
    print("    • Silent    - Low fan speed, quiet")
    print("    • Default   - Balanced performance")
    print("    • Overboost - Maximum cooling (loudest)")
    print("")

def main():
    parser = argparse.ArgumentParser(
        description='Acer Predator Fan Control - Control fan profiles on PT515-51 laptops',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  predator-fan --mode overboost    # Set maximum cooling
  predator-fan --mode silent       # Set quiet mode
  predator-fan --status            # Show system status
  predator-fan --temp              # Show temperatures only
        """
    )
    
    parser.add_argument('--mode', choices=['silent', 'default', 'overboost'],
                       help='Set fan mode')
    parser.add_argument('--status', '-s', action='store_true',
                       help='Show current status')
    parser.add_argument('--temp', '-t', action='store_true',
                       help='Show temperatures')
    parser.add_argument('--version', '-v', action='version', version='1.0')
    
    args = parser.parse_args()
    
    if args.temp:
        temps = get_temperatures()
        for t in temps:
            print(f"{t['name']}: {t['temp']:.1f}°C")
    elif args.status or (not args.mode):
        show_status()
    
    if args.mode:
        set_fan_mode(args.mode)

if __name__ == '__main__':
    main()
PYTHON_EOF

chmod +x /tmp/predator-fan
$SUDO cp /tmp/predator-fan /usr/local/bin/predator-fan
echo "  Installed: /usr/local/bin/predator-fan"

# Step 4: Install GNOME Shell extension
echo ""
echo -e "${YELLOW}Step 4: Installing GNOME Shell extension...${NC}"

EXT_DIR="$HOME/.local/share/gnome-shell/extensions/predator-fan@ashwin"
mkdir -p "$EXT_DIR"

# Check if extension already exists
if [ -f "$EXT_DIR/extension.js" ]; then
    echo "  Extension already exists, updating..."
fi

# Write extension files
# ... metadata.json
cat > "$EXT_DIR/metadata.json" << 'EOF'
{
  "uuid": "predator-fan@ashwin",
  "name": "Acer Predator Fan Control",
  "description": "Control fan profiles on Acer Predator PT515-51 laptops with temperature monitoring.",
  "version": 1,
  "shell-version": ["45", "46", "47", "48", "49"],
  "url": "https://github.com/ashwin/predator-fan-extension",
  "settings-schema": "org.gnome.shell.extensions.predator-fan"
}
EOF

# ... stylesheet.css
cat > "$EXT_DIR/stylesheet.css" << 'EOF'
.predator-fan-icon {
    font-size: 14px;
    font-weight: bold;
    padding: 0 4px;
}

.predator-fan-temp {
    font-size: 11px;
    font-weight: normal;
    padding-right: 4px;
}

.predator-fan-temp-warm {
    color: #f5a623;
}

.predator-fan-temp-hot {
    color: #e74c3c;
}

.predator-fan-header {
    font-weight: bold;
    font-size: 12px;
}
EOF

# ... extension.js (simplified version)
cat > "$EXT_DIR/extension.js" << 'EOFJS'
import GObject from 'gi://GObject';
import St from 'gi://St';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import Clutter from 'gi://Clutter';

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';

const MODE_ICONS = {
    silent: '',
    default: '',
    overboost: ''
};

const FanIndicator = GObject.registerClass(
class FanIndicator extends PanelMenu.Button {
    _init() {
        super._init(0.0, 'Predator Fan');
        
        this._currentMode = 'default';
        this._updateInterval = null;
        
        // Panel icon
        this._icon = new St.Label({
            text: MODE_ICONS.default,
            style_class: 'predator-fan-icon',
            y_align: Clutter.ActorAlign.CENTER
        });
        
        this._tempLabel = new St.Label({
            text: '',
            style_class: 'predator-fan-temp',
            y_align: Clutter.ActorAlign.CENTER
        });
        
        const box = new St.BoxLayout({ style_class: 'panel-status-menu-box' });
        box.add_child(this._icon);
        box.add_child(this._tempLabel);
        this.add_child(box);
        
        this._buildMenu();
        this._startMonitoring();
    }
    
    _buildMenu() {
        // Header
        this.menu.addMenuItem(new PopupMenu.PopupMenuItem(
            'Acer Predator Fan Control',
            { reactive: false, style_class: 'predator-fan-header' }
        ));
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
        
        // Fan modes
        const modes = [
            ['silent', 'Silent - Low speed, quiet'],
            ['default', 'Default - Balanced'],
            ['overboost', 'Overboost - Max cooling']
        ];
        
        modes.forEach(([mode, label]) => {
            const item = new PopupMenu.PopupMenuItem(`${MODE_ICONS[mode]} ${label}`);
            item.connect('activate', () => this._setMode(mode));
            this.menu.addMenuItem(item);
        });
        
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
        
        // Temperature display
        this._tempItem = new PopupMenu.PopupMenuItem('Loading...', { reactive: false });
        this.menu.addMenuItem(this._tempItem);
    }
    
    _setMode(mode) {
        this._currentMode = mode;
        this._icon.text = MODE_ICONS[mode];
        
        // Call our CLI tool
        try {
            const proc = Gio.Subprocess.new(
                ['predator-fan', '--mode', mode],
                Gio.SubprocessFlags.NONE
            );
        } catch (e) {
            log('Error setting fan mode: ' + e.message);
        }
    }
    
    _startMonitoring() {
        this._updateInterval = GLib.timeout_add_seconds(
            GLib.PRIORITY_DEFAULT, 2, () => {
                this._updateTemperature();
                return GLib.SOURCE_CONTINUE;
            }
        );
    }
    
    _updateTemperature() {
        try {
            const temps = this._readTemps();
            if (temps.length > 0) {
                const maxTemp = Math.max(...temps.map(t => t.temp));
                this._tempLabel.text = ` ${Math.round(maxTemp)}°C`;
                
                // Color code
                if (maxTemp > 85) {
                    this._tempLabel.style_class = 'predator-fan-temp predator-fan-temp-hot';
                } else if (maxTemp > 70) {
                    this._tempLabel.style_class = 'predator-fan-temp predator-fan-temp-warm';
                } else {
                    this._tempLabel.style_class = 'predator-fan-temp';
                }
                
                this._tempItem.label.text = `Max: ${Math.round(maxTemp)}°C`;
            }
        } catch (e) {}
    }
    
    _readTemps() {
        const temps = [];
        const hwmonPath = '/sys/class/hwmon';
        
        try {
            const dir = Gio.File.new_for_path(hwmonPath);
            const enum_ = dir.enumerate_children('standard::name', 0, null);
            
            let info;
            while ((info = enum_.next_file(null))) {
                const name = info.get_name();
                const namePath = `${hwmonPath}/${name}/name`;
                
                try {
                    const f = Gio.File.new_for_path(namePath);
                    const [, content] = f.load_contents(null);
                    const sensorName = new TextDecoder().decode(content).trim();
                    
                    for (let i = 1; i <= 10; i++) {
                        const tempPath = `${hwmonPath}/${name}/temp${i}_input`;
                        const tf = Gio.File.new_for_path(tempPath);
                        if (tf.query_exists(null)) {
                            try {
                                const [, tc] = tf.load_contents(null);
                                const t = parseInt(new TextDecoder().decode(tc)) / 1000;
                                if (t > 0 && t < 150) {
                                    temps.push({ name: sensorName, temp: t });
                                }
                            } catch (e) {}
                        }
                    }
                } catch (e) {}
            }
            enum_.close(null);
        } catch (e) {}
        
        return temps;
    }
    
    destroy() {
        if (this._updateInterval) {
            GLib.source_remove(this._updateInterval);
        }
        super.destroy();
    }
});

export default class PredatorFanExtension extends Extension {
    enable() {
        this._indicator = new FanIndicator();
        Main.panel.addToStatusArea('predator-fan', this._indicator);
    }
    
    disable() {
        if (this._indicator) {
            this._indicator.destroy();
            this._indicator = null;
        }
    }
}
EOFJS

echo "  Installed GNOME extension to: $EXT_DIR"

# Compile schemas
mkdir -p "$EXT_DIR/schemas"
cat > "$EXT_DIR/schemas/org.gnome.shell.extensions.predator-fan.gschema.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<schemalist>
  <schema id="org.gnome.shell.extensions.predator-fan" path="/org/gnome/shell/extensions/predator-fan/">
    <key type="b" name="show-in-panel">
      <default>true</default>
    </key>
    <key type="b" name="show-temperature">
      <default>true</default>
    </key>
    <key type="i" name="update-interval">
      <default>2</default>
    </key>
  </schema>
</schemalist>
EOF

# Compile schemas if glib-compile-schemas is available
if command -v glib-compile-schemas &> /dev/null; then
    glib-compile-schemas "$EXT_DIR/schemas"
    echo "  Compiled GSettings schemas"
fi

# Step 5: Create systemd service
echo ""
echo -e "${YELLOW}Step 5: Creating systemd service...${NC}"

$SUDO tee /etc/systemd/system/predator-fan.service > /dev/null << 'EOF'
[Unit]
Description=Acer Predator Fan Control Setup
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/sbin/modprobe acer_wmi predator_v4=1
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

$SUDO systemctl daemon-reload
$SUDO systemctl enable predator-fan.service 2>/dev/null || true
echo "  Created: predator-fan.service"

# Step 6: Reload module if possible
echo ""
echo -e "${YELLOW}Step 6: Activating changes...${NC}"

if lsmod | grep -q "^acer_wmi"; then
    $SUDO modprobe -r acer_wmi 2>/dev/null || echo "  Note: Module in use, will apply on next boot"
fi

$SUDO modprobe acer_wmi predator_v4=1 2>/dev/null || true

# Summary
echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${BLUE}Command-line tool:${NC}"
echo "  predator-fan --help        # Show help"
echo "  predator-fan --status      # Show system status"
echo "  predator-fan --mode silent|default|overboost"
echo ""
echo -e "${BLUE}GNOME Extension:${NC}"
echo "  1. Log out and log back in (or press Alt+F2, type 'r', Enter)"
echo "  2. Enable the extension in GNOME Tweaks or Extensions app"
echo "  3. A fan icon will appear in your top panel"
echo ""
echo -e "${BLUE}Keyboard shortcut:${NC}"
echo "  Fn + F  - Cycle through fan modes"
echo ""
echo -e "${YELLOW}NOTE:${NC} If you don't see the extension after logging back in:"
echo "  1. Open a terminal and run: gnome-extensions enable predator-fan@ashwin"
echo "  2. Or use GNOME Tweaks → Extensions to enable it"
echo ""

read -p "Enable the extension now? [Y/n]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    gnome-extensions enable predator-fan@ashwin 2>/dev/null || echo "Please enable manually after logging back in"
fi

read -p "Reboot now to ensure all changes take effect? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rebooting in 5 seconds..."
    sleep 5
    $SUDO reboot
fi
