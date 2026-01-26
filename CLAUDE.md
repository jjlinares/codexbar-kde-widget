# CodexBar KDE Widget

KDE Plasma 6 widget for displaying AI provider usage from CodexBar CLI.

## CodexBar CLI Reference

### Installation
```bash
# Download from GitHub releases
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
2. For each provider, tries sources in order: **oauth → cli → api**
3. If any source returns data, provider is shown in the widget
4. If all sources fail, provider is silently skipped (with backoff)

### Provider Discovery
No config file needed. The widget automatically discovers which providers work by trying them all. If you have Claude CLI authenticated, Claude shows up. If you have Kiro CLI installed, Kiro shows up. Etc.

### Source Fallback Chain
```
oauth (fast API)
  ↓ fail
cli (spawn CLI process)
  ↓ fail
api (API key)
  ↓ fail
Skip provider (apply backoff)
```

### Providers That Work on Linux
| Provider | Working Source | Requirements |
|----------|---------------|--------------|
| claude | oauth | Claude CLI authenticated |
| codex | cli | Codex CLI installed |
| kiro | cli | kiro-cli installed + AWS Builder ID |
| vertexai | oauth | gcloud auth |
| gemini | api | Gemini CLI credentials |
| copilot | api | API token |
| zai, kimi, minimax, kimik2 | api | API keys |

### Providers NOT Supported on Linux
cursor, amp, augment, factory, opencode (require browser cookies / web source)

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
