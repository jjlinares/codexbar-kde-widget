# CodexBar KDE Plasma Widget

A native KDE Plasma 6 widget (plasmoid) that monitors AI provider usage limits for Claude and Codex. Displays session and weekly usage with color-coded progress bars.

![Plasma 6](https://img.shields.io/badge/KDE_Plasma-6.0+-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **Color-coded usage bars**: Green (<70%), Yellow (70-90%), Red (>90%)
- **Desktop placement**: Full widget view always visible
- **Panel placement**: Compact colored icon that expands on click
- **Reset time display**: Shows time until limits reset (e.g., "Resets in 2h 15m")
- **Dashboard buttons**: Quick links to provider usage dashboards
- **KDE notifications**: Alerts when usage crosses configurable thresholds
- **OAuth + CLI fallback**: Automatic fallback if OAuth fails

## Requirements

- **KDE Plasma 6** (Ubuntu 24.04+, Fedora 40+, Arch, etc.)

## Installation

```bash
git clone https://github.com/jjlinares/codexbar-kde-widget.git
cd codexbar-kde-widget
./scripts/install.sh
```

The install script automatically:
- Detects your architecture (x86_64 or aarch64)
- Downloads and installs the `codexbar` CLI to `~/.local/bin/`
- Installs the Plasma widget

### Authenticate with providers

```bash
codexbar auth claude
codexbar auth codex
```

### Add to Desktop or Panel

1. Right-click on your desktop or panel
2. Select **Add Widgets...**
3. Search for **CodexBar**
4. Drag the widget to your desktop or panel

## Uninstall

```bash
kpackagetool6 -t Plasma/Applet -r com.codexbar.widget
rm ~/.local/bin/codexbar
```

## Configuration

Right-click the widget and select **Configure CodexBar...** to access:

- **Refresh interval**: How often to fetch usage data (30-300 seconds)
- **Enabled providers**: Toggle Claude and/or Codex
- **Notification thresholds**: Usage percentages that trigger notifications (default: 80%, 95%)

## Project Structure

```
codexbar-kde-widget/
├── com.codexbar.widget/        # Plasmoid package
│   ├── metadata.json           # Widget metadata
│   └── contents/
│       ├── ui/                 # QML components
│       ├── config/             # Configuration schema
│       └── icons/              # SVG icons
├── scripts/
│   └── install.sh              # Installation script
├── README.md
└── LICENSE
```

## Troubleshooting

### "CLI not found" error

```bash
# Check if codexbar is available
which codexbar

# If not found, download and install it
curl -L https://github.com/steipete/CodexBar/releases/latest/download/codexbar-linux-x86_64.tar.gz | tar xz -C ~/.local/bin/

# Ensure ~/.local/bin is in PATH
export PATH="$HOME/.local/bin:$PATH"
```

### "Run: codexbar auth claude" error

```bash
codexbar auth claude
codexbar auth codex
```

### Widget not appearing in Add Widgets

```bash
# Verify installation
kpackagetool6 -t Plasma/Applet -l | grep codexbar

# Restart Plasma shell
kquitapp6 plasmashell && kstart plasmashell
```

### Data not updating

```bash
# Test CLI directly
codexbar usage --source oauth --provider claude --json
```

## Development

### Testing changes

```bash
# Update existing installation
kpackagetool6 -t Plasma/Applet -u com.codexbar.widget

# Restart Plasma to pick up changes
kquitapp6 plasmashell && kstart plasmashell
```

### How it works

The widget calls the `codexbar` CLI to fetch usage data:

```bash
codexbar usage --source oauth --provider claude --json
codexbar usage --source oauth --provider codex --json
```

On OAuth failure, it falls back to `--source cli`. Errors trigger exponential backoff (60s → 120s → 240s → 300s max).

## For Plasma 5 Users

This widget requires KDE Plasma 6. For Plasma 5, use the Python-based tray application:

```bash
pipx install codexbar-tray
codexbar-tray
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Related

- [CodexBar](https://github.com/steipete/CodexBar) - macOS menu bar app + CLI (upstream)
