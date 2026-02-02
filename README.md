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

> **Note:** After adding the widget to your panel, you may need to restart plasmashell (`kquitapp6 plasmashell && plasmashell &`) for it to start fetching data.

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

## Troubleshooting

**Widget shows "Scanning providers..." with no data:**
- Restart plasmashell: `kquitapp6 plasmashell && plasmashell &`
- This is needed after first install or after updating widget files

**Check if codexbar CLI works:**
```bash
codexbar usage --provider claude --source oauth --json
```
If this returns JSON with usage data, the CLI is fine and the issue is the widget.

**View widget logs:**
```bash
journalctl --user -b -t plasmashell | grep -i codex
```

**Test widget in a standalone window** (bypasses panel issues):
```bash
plasmawindowed com.codexbar.widget
```
If the standalone window shows data but the panel doesn't, restart plasmashell.

**No providers showing up:**
Make sure you're authenticated with at least one provider (e.g. logged in to Claude CLI, Codex CLI, etc.). The widget tries oauth → cli → api sources for each provider and only displays ones that return data.

## Requirements

- KDE Plasma 6
- `codexbar` CLI (installed automatically)
- At least one authenticated AI provider
