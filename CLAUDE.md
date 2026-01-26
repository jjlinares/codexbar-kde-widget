# CodexBar KDE Widget

KDE Plasma 6 widget that displays real-time AI provider usage (Claude, Codex, Kiro, Gemini, etc.) in your system panel. Shows usage percentages with color-coded thresholds and auto-discovers which providers you have configured.

## Agent Instructions

**Always use Context7** to verify assumptions or learn about KDE Plasma development:
```
context7 library: /websites/develop_kde
```
Query this before making claims about QML, Plasma APIs, or widget behavior.

## CodexBar CLI Reference

### Installation
```bash
VERSION=$(curl -fsSL "https://api.github.com/repos/steipete/CodexBar/releases/latest" | jq -r '.tag_name')
curl -fsSL "https://github.com/steipete/CodexBar/releases/download/${VERSION}/codexbar-linux-x86_64.tar.gz" -o /tmp/codexbar.tar.gz
tar -xzf /tmp/codexbar.tar.gz -C /tmp
mv /tmp/codexbar ~/.local/bin/
```

### Commands
```bash
codexbar usage --provider claude --source oauth --json   # fetch claude usage
codexbar usage --provider kiro --source cli --json       # fetch kiro usage
codexbar --version                                        # check version
```

### Source Modes (`--source`)
| Source | Description | Linux Support |
|--------|-------------|---------------|
| `oauth` | OAuth API | YES |
| `cli` | CLI PTY/RPC | YES |
| `api` | API key flow | YES |
| `web` | Browser cookies | NO (macOS only) |
| `auto` | Web + fallback | NO (macOS only) |

## Widget Implementation

### How It Works
1. On startup and each refresh, widget tries to fetch usage for ALL 17 providers
2. For each provider, tries sources in order: **oauth -> cli -> api**
3. If any source returns data, provider is shown in the widget
4. If all sources fail, provider is silently skipped (with backoff)

### Provider Discovery
No config file needed. The widget automatically discovers which providers work by trying them all.

### Source Fallback Chain
```
oauth (fast API)
  | fail
cli (spawn CLI process)
  | fail
api (API key)
  | fail
Skip provider (apply backoff)
```

### JSON Response Format
```json
[{
  "provider": "claude",
  "source": "oauth",
  "usage": {
    "primary": { "usedPercent": 28, "windowMinutes": 300, "resetsAt": "..." },
    "secondary": { "usedPercent": 59, "windowMinutes": 10080, "resetsAt": "..." }
  }
}]
```

### Files
- `main.qml` - Core logic, provider fetching, fallback chain
- `FullRepresentation.qml` - Expanded view with provider cards
- `CompactRepresentation.qml` - Panel icon
- `ProviderCard.qml` - Individual provider display
- `ProviderMetadata.qml` - Provider names, icons, dashboard URLs
- `configGeneral.qml` - Settings (refresh interval, notification thresholds)
