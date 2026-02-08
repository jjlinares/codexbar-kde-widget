# PRD: Linux KDE Plasma Widget (Plasmoid)

**Date:** 2026-01-24
**Repository:** https://github.com/jjlinares/codexbar-kde-widget

---

## Problem Statement

### What problem are we solving?

Linux users need a native way to monitor AI provider usage limits (Claude, Codex) that:

1. **Integrates natively** with KDE Plasma desktop
2. **Supports always-visible placement** on desktop or panel
3. **Has no heavy runtime dependencies** — pure QML, no Python required
4. **Works well on Wayland** — native Plasma widgets handle positioning correctly

### Why now?

- Wayland is now the default on KDE Plasma 6 (Ubuntu 24.04+)
- KDE Plasma 6 has mature, well-documented Plasmoid APIs
- User feedback: "I want it visible on my desktop like the disk usage widget"

### Who is affected?

- **Primary users:** Linux/KDE developers using Claude and Codex who want always-visible usage monitoring
- **Secondary users:** Users who prefer native KDE widgets over tray applications

---

## Proposed Solution

### Overview

A native KDE Plasma 6 widget (plasmoid) written in QML that displays AI provider usage. The widget can be placed on the desktop or in a panel, similar to the built-in "Disk Usage" widget. It calls the `codexbar` CLI directly via QProcess, eliminating Python/PyQt6 dependencies entirely.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     KDE Plasma Shell                            │
│                    (Desktop or Panel)                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                    hosts plasmoid
                              │
┌─────────────────────────────┴───────────────────────────────────┐
│            com.codexbar.widget (QML Plasmoid)                   │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────────┐  │
│  │  CompactRep     │  │   FullRep        │  │  DataSource    │  │
│  │  (panel icon)   │  │   (expanded)     │  │  (QProcess)    │  │
│  └─────────────────┘  └──────────────────┘  └────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                    spawns via QProcess
                              │
┌─────────────────────────────┴───────────────────────────────────┐
│ codexbar usage --source oauth --provider claude --json          │
│ codexbar usage --source oauth --provider codex --json           │
└─────────────────────────────────────────────────────────────────┘
```

### User Experience

#### User Flow: Add Widget to Desktop

1. User right-clicks desktop → "Add Widgets..."
2. Searches "CodexBar" or browses "System Information" category
3. Drags widget to desktop
4. Widget shows compact view with provider usage bars
5. Click widget → expands to show full details (session + weekly limits)

#### User Flow: Add Widget to Panel

1. User right-clicks panel → "Add Widgets..."
2. Adds "CodexBar" widget to panel
3. Panel shows compact icon with color indicator
4. Click icon → popup shows full usage details (like Disk Usage widget)

#### User Flow: View Usage (Desktop Placement)

1. Widget always visible on desktop showing:
   - Provider icons (Claude, Codex)
   - Session usage bars with percentages
   - Color coding (green/yellow/red)
2. Click widget → expands to show weekly limits and reset times
3. Click "Dashboard" button → opens provider web dashboard

#### User Flow: Configure Widget

1. Right-click widget → "Configure CodexBar..."
2. Configuration dialog shows:
   - Refresh interval (slider: 30s - 300s, default 60s)
   - Enabled providers (checkboxes)
   - Notification thresholds (80%, 95%)
3. Changes apply immediately

### Design Considerations

- **Follow Disk Usage widget pattern** — Similar layout with title, progress bars, labels
- **Breeze theme integration** — Use Kirigami.Theme colors, no hardcoded colors
- **Compact representation** (panel): Colored circle icon matching worst-case usage
- **Full representation** (desktop/expanded):
  - Title: "CodexBar"
  - Per-provider sections with:
    - Provider icon + name
    - Session: progress bar + percentage + reset time
    - Weekly: progress bar + percentage + reset time
  - "Dashboard" buttons for each provider
- **Color thresholds** (same as tray app):
  - Green: <70%
  - Yellow: 70-90%
  - Red: >90%

---

## End State

When this PRD is complete:

- [x] Native QML plasmoid installable via install script or manual install
- [x] Widget placeable on desktop or panel
- [x] Compact view shows colored icon with worst-case usage indicator
- [x] Full view shows all providers with session + weekly limits
- [x] Progress bars with color coding (green/yellow/red)
- [x] Reset times displayed as relative time ("Resets in 2h 15m")
- [x] "Dashboard" buttons open provider web dashboards
- [x] Configuration UI for refresh interval and notification thresholds
- [x] Desktop notifications at threshold crossings
- [x] No Python/PyQt6 dependency — pure QML + CLI
- [x] Documented installation for KDE Plasma 6 on Ubuntu 24.04+

---

## Acceptance Criteria

### Feature: Widget Placement

- [x] Widget appears in "Add Widgets" dialog under "System Information" category
- [x] Widget can be placed on desktop (resizable)
- [x] Widget can be added to panel
- [x] Widget respects Plasma theme (Breeze light/dark)

### Feature: Compact Representation (Panel)

- [x] Shows colored circle icon (green/yellow/red based on worst usage)
- [x] Tooltip shows: "Claude: 45% | Codex: 72%"
- [x] Click expands to full representation as popup

### Feature: Full Representation (Desktop/Expanded)

- [x] Title bar: "CodexBar" with refresh + settings buttons
- [x] Per provider (Claude, Codex):
  - [x] Provider icon (SVG) + name
  - [x] Session row: label + progress bar + percentage + reset time
  - [x] Weekly row: label + progress bar + percentage + reset time
  - [x] "Dashboard" button opens browser to provider dashboard
- [x] Progress bar colors: green <70%, yellow 70-90%, red >90%
- [x] Reset times as relative ("Resets in 2h 15m")

### Feature: Data Fetching

- [x] Calls `codexbar usage --source oauth --provider <name> --json` via QProcess
- [x] Falls back to `--source cli` if OAuth fails
- [x] Default refresh: 60 seconds
- [x] Exponential backoff on errors (60s → 120s → 240s → max 300s)
- [x] Shows error state with hint ("Run: codexbar auth claude")

### Feature: Configuration

- [x] Right-click → "Configure CodexBar..." opens config dialog
- [x] Settings:
  - [x] Refresh interval (30-300 seconds, default 60)
  - [x] Notification thresholds (list: 80, 95)
  - [x] Enabled providers (claude, codex checkboxes)
- [x] Configuration persists via Plasma's config system

### Feature: Notifications

- [x] KDE notification when threshold crossed (80%, 95%)
- [x] Notification shows provider name and percentage
- [x] Click notification opens provider dashboard
- [x] Rate-limited: max 1 notification per provider per hour

### Feature: Installation

- [x] Installable via: `./scripts/install.sh`
- [x] Install script downloads codexbar CLI with architecture detection
- [x] Install script installs Plasma widget via kpackagetool6

---

## Technical Context

### Technology Choice: QML

**Why QML over alternatives:**

| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| **QML (native plasmoid)** | Native KDE integration, desktop+panel placement, theme support, no runtime deps | Learn Plasma APIs | ✅ Chosen |
| Python + PyQt6 | Reuse existing code | Wayland issues, heavy deps, non-native | ❌ Replace |
| QML + C++ plugin | Full Qt power | Overkill for CLI wrapper | ❌ Unnecessary |
| Conky | Lightweight | No panel integration, config complexity | ❌ Wrong tool |

### Plasmoid Structure

```
codexbar-kde-widget/
├── com.codexbar.widget/
│   ├── metadata.json              # Plasma 6 metadata
│   ├── contents/
│   │   ├── ui/
│   │   │   ├── main.qml           # Entry point (PlasmoidItem)
│   │   │   ├── CompactRepresentation.qml
│   │   │   ├── FullRepresentation.qml
│   │   │   ├── ProviderCard.qml   # Reusable provider display
│   │   │   ├── UsageBar.qml       # Progress bar component
│   │   │   └── configGeneral.qml  # Configuration UI
│   │   ├── config/
│   │   │   ├── config.qml         # Config page registration
│   │   │   └── main.xml           # Config schema (kcfg)
│   │   └── icons/
│   │       ├── codexbar.svg       # Widget icon
│   │       ├── claude.svg         # Provider icon
│   │       └── codex.svg          # Provider icon
├── scripts/
│   └── install.sh                 # Install script (CLI + widget)
├── README.md
└── LICENSE
```

### metadata.json

```json
{
    "KPlugin": {
        "Id": "com.codexbar.widget",
        "Name": "CodexBar",
        "Description": "Monitor AI provider usage limits (Claude, Codex)",
        "Icon": "codexbar",
        "Authors": [{ "Name": "CodexBar Contributors" }],
        "Category": "System Information",
        "Version": "1.0.0",
        "Website": "https://github.com/jjlinares/codexbar-kde-widget",
        "EnabledByDefault": true
    },
    "KPackageStructure": "Plasma/Applet",
    "X-Plasma-API-Minimum-Version": "6.0"
}
```

**Note:** System tray support was removed due to Plasma 6 API limitations with compact representation click handling in the system tray context. The widget works in regular panels and on desktop.

### Key QML APIs

**Important:** The "executable" DataSource engine is from Plasma 5. In Plasma 6, it's available via the `org.kde.plasma.plasma5support` compatibility layer. There is no native Plasma 6 replacement yet.

```qml
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

// Plasma 5 compatibility layer for executable DataSource
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    // Compact view for panel
    compactRepresentation: CompactRepresentation {}

    // Full view for desktop or popup
    fullRepresentation: FullRepresentation {}

    // Tooltip
    toolTipMainText: "CodexBar"
    toolTipSubText: "Claude: 45% | Codex: 72%"

    // Data fetching via executable engine (Plasma 5 compat)
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            var stdout = data["stdout"]
            // Parse JSON from codexbar CLI
            var result = JSON.parse(stdout)
            // Update UI...
            disconnectSource(source)
        }

        function exec(cmd) {
            connectSource(cmd)
        }
    }

    // Configuration access
    property int refreshInterval: plasmoid.configuration.refreshInterval

    Timer {
        interval: root.refreshInterval * 1000
        running: true
        repeat: true
        onTriggered: executable.exec("codexbar usage --source oauth --json")
    }
}
```

### Existing Patterns

- **CLI JSON output:** Provided by CodexBar upstream project
- **Config schema:** Uses Plasma's native configuration system
- **Color thresholds:** 70% warning, 90% critical — hardcoded in UsageBar.qml
- **Relative time formatting:** Implemented in ProviderCard.qml

### Key Files

- `com.codexbar.widget/contents/ui/main.qml` — Entry point, data fetching, state management
- `com.codexbar.widget/contents/ui/FullRepresentation.qml` — Expanded view layout
- `com.codexbar.widget/contents/ui/ProviderCard.qml` — Provider section component
- `com.codexbar.widget/contents/ui/UsageBar.qml` — Color-coded progress bar
- `scripts/install.sh` — Installation script

### System Dependencies

- **KDE Plasma 6** — Host environment (Ubuntu 24.04+ default)
- **Qt 6 / Qt Quick** — QML runtime (bundled with Plasma)
- **plasma5support** — Provides executable DataSource engine (`org.kde.plasma.plasma5support`); bundled with plasma-workspace
- **codexbar CLI** — Pre-built binary in PATH (installed by install.sh)

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| QML learning curve | Medium | Medium | Reference existing widgets (Disk Usage, System Monitor); KDE docs are excellent |
| Executable engine via compat layer | Medium | Low | `org.kde.plasma.plasma5support` is officially supported; many plasmoids use it; monitor for native Plasma 6 replacement |
| CLI not in PATH | Medium | Low | Install script handles CLI installation; show setup hint on error |
| Plasma version fragmentation | Low | Low | Target Plasma 6 only |
| Theme integration issues | Low | Low | Use Kirigami.Theme exclusively; no hardcoded colors |
| plasma5support deprecation | Low | Medium | Layer is stable for Plasma 6.x; if deprecated, migrate to native API when available |

---

## Alternatives Considered

### Alternative 1: Electron-based Widget

- **Pros:** Web tech; familiar to many developers
- **Cons:** Heavy runtime; not native; can't place in panel
- **Decision:** Rejected — defeats purpose of native integration

### Alternative 2: D-Bus Data Source (plasmoid queries external service)

- **Pros:** Reuse logic from other services
- **Cons:** Still need external service running; defeats "reduce dependencies" goal
- **Decision:** Rejected — call CLI directly, no external dependencies

### Alternative 3: C++ Plugin for Data Fetching

- **Pros:** More control; better error handling; native Plasma 6 API
- **Cons:** Compilation required; build complexity; overkill for subprocess wrapper
- **Decision:** Rejected — QML's executable engine (via plasma5support) is sufficient; revisit if native Plasma 6 process API emerges

---

## Non-Goals (v1)

Explicitly out of scope:

- **Cursor/other providers** — Focus on Claude + Codex; expand later
- **Historical charts** — Progress bars only; charts in v2
- **Multi-account support** — Single account per provider
- **GNOME support** — KDE-first; GNOME widget is separate PRD
- **KDE Store publishing** — Manual install first; store submission after validation
- **D-Bus service** — Plasmoid is self-contained; no external API needed
- **Plasma 5 support** — Plasma 6+ only
- **System tray placement** — Plasma 6 API limitations prevent proper click handling in system tray context; use panel or desktop placement instead

---

## Interface Specifications

### CLI Invocation (unchanged)

```bash
codexbar usage --source oauth --provider claude --json
codexbar usage --source oauth --provider codex --json
```

### CLI Output Format (unchanged)

```json
[
  {
    "provider": "claude",
    "source": "oauth",
    "usage": {
      "primary": {
        "usedPercent": 45.0,
        "windowMinutes": 300,
        "resetDescription": "Jan 23 at 6:59PM",
        "resetsAt": "2026-01-23T23:59:59Z"
      },
      "secondary": {
        "usedPercent": 12.0,
        "windowMinutes": 10080,
        "resetDescription": "Jan 27 at 4:59PM",
        "resetsAt": "2026-01-27T21:59:59Z"
      }
    }
  }
]
```

### Configuration Schema (main.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<kcfg xmlns="http://www.kde.org/standards/kcfg/1.0">
  <group name="General">
    <entry name="refreshInterval" type="Int">
      <default>60</default>
      <min>30</min>
      <max>300</max>
    </entry>
    <entry name="notificationThresholds" type="IntList">
      <default>80,95</default>
    </entry>
    <entry name="enableClaude" type="Bool">
      <default>true</default>
    </entry>
    <entry name="enableCodex" type="Bool">
      <default>true</default>
    </entry>
  </group>
</kcfg>
```

---

## Documentation Requirements

- [x] README.md with install instructions
- [x] Troubleshooting: "CLI not found" → install script handles this
- [x] Troubleshooting: "OAuth error" → run `codexbar auth <provider>`

---

## Appendix

### Glossary

- **Plasmoid:** KDE Plasma widget/applet, written in QML
- **Compact Representation:** Small view shown in panel
- **Full Representation:** Expanded view shown on desktop or as popup
- **QProcess:** Qt class for spawning external processes
- **KDE Store:** store.kde.org — community widget repository

### References

**Official Documentation:**
- [Plasma Widget Tutorial](https://develop.kde.org/docs/plasma/widget/) — Official KDE docs
- [Plasma Widget Setup](https://develop.kde.org/docs/plasma/widget/setup/) — Directory structure, metadata.json
- [Plasma Widget Properties](https://develop.kde.org/docs/plasma/widget/properties/) — Compact/full representation, system tray
- [Plasma Widget Configuration](https://develop.kde.org/docs/plasma/widget/configuration/) — Config UI, plasmoid.configuration
- [Porting Plasmoids to KF6](https://develop.kde.org/docs/plasma/widget/porting_kf6/) — Plasma 6 migration, PlasmoidItem

**Community Resources:**
- [Zren's Plasma Widget Tutorial](https://zren.github.io/kde/docs/widget/) — Comprehensive community guide
- [How to write a Plasma 6 applet](https://medium.com/@dhruv8sh_34505/write-an-applet-for-plasma-6-0b8fd3a0334f) — Step-by-step tutorial
- [Official way to execute CLI commands in Plasma 6](https://discuss.kde.org/t/official-way-to-excecute-cli-commands-in-plasma-6-plasmoids/6772) — KDE Discuss thread on executable engine

**Reference Implementations:**
- [Disk Usage Widget Source](https://invent.kde.org/plasma/kdeplasma-addons/-/tree/master/applets/diskquota) — Similar UI pattern
