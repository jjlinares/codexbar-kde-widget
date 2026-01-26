# CodexBar KDE Widget

KDE Plasma 6 widget that displays real-time AI provider usage (Claude, Codex, Kiro, Gemini, etc.) in your system panel. Shows usage percentages with color-coded thresholds and auto-discovers which providers you have configured.

## Installation

```bash
git clone https://github.com/jjlinares/codexbar-kde-widget
cd codexbar-kde-widget
./scripts/install.sh
```

The install script will:
1. Download and install the `codexbar` CLI to `~/.local/bin/`
2. Install the Plasma widget

After installation, right-click your panel → Add Widgets → search "CodexBar".

## How It Works

The widget automatically discovers which AI providers you have configured by trying each one. No manual configuration needed.

For each provider, it tries sources in order:
1. **oauth** - Fast API authentication (Claude CLI, gcloud, etc.)
2. **cli** - Spawns CLI process (Codex, Kiro)
3. **api** - API key authentication

If a source returns data, the provider appears in the widget. If all sources fail, the provider is silently skipped.

## Configuration

Click the configure button in the widget header to adjust:
- **Refresh interval** - How often to poll providers (default: 60s)
- **Warning threshold** - Usage % for yellow indicator (default: 70%)
- **Critical threshold** - Usage % for red indicator (default: 90%)

## Panel Icon

The panel icon shows a color-coded ring based on your highest usage across all providers:
- **Green** - Below warning threshold
- **Yellow** - Above warning threshold
- **Red** - Above critical threshold

Click the icon to expand and see detailed usage per provider.

## Uninstall

```bash
kpackagetool6 -t Plasma/Applet -r com.codexbar.widget
rm ~/.local/bin/codexbar
```

## Requirements

- KDE Plasma 6
- `codexbar` CLI (installed automatically)
- At least one authenticated AI provider
