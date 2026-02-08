# Manual Testing Instructions - All Providers

## Prerequisites

1. CodexBar CLI installed and in PATH: `which codexbar`
2. At least Claude authenticated: `codexbar auth claude`
3. Widget installed: `kpackagetool6 -t Plasma/Applet -i com.codexbar.widget`

## Test Cases

### Test 1: Claude + Codex (Default Configuration)

**Steps:**
1. Fresh install the widget (or reset config)
2. Add widget to panel
3. Wait for data fetch (60s default interval)

**Expected:**
- [x] Both Claude and Codex cards visible
- [x] Usage bars show percentages
- [x] Dashboard buttons work
- [x] Tooltip shows "Claude: X% | Codex: Y%"

### Test 2: Enable Cursor Provider

**Steps:**
1. Open widget settings (Configure)
2. Check "Cursor" in provider list
3. Close settings

**Expected:**
- [x] Cursor checkbox appears in settings
- [x] Cursor card appears in widget
- [x] If not authenticated, shows error: "Run: codexbar auth cursor"
- [x] Dashboard button opens cursor.com/dashboard

### Test 3: Enable 5+ Providers (Scroll Test)

**Steps:**
1. Enable 5 or more providers in settings
2. View widget popup

**Expected:**
- [x] All enabled providers visible
- [x] Vertical scrollbar appears when needed
- [x] Cards scroll smoothly
- [x] Performance acceptable

### Test 4: Disable All But One (Validation)

**Steps:**
1. With only one provider enabled
2. Try to uncheck that provider

**Expected:**
- [x] Checkbox remains checked (cannot disable)
- [x] At least one provider always enabled

### Test 5: Fresh Install Defaults

**Steps:**
1. Remove widget config: `rm ~/.config/plasma-org.kde.plasma.desktop-appletsrc` (or relevant section)
2. Reinstall widget
3. Add to panel

**Expected:**
- [x] Claude enabled by default
- [x] Codex enabled by default
- [x] Other providers disabled by default

### Test 6: Provider Icons

**Steps:**
1. Enable each provider one at a time
2. Check icon renders

**Expected:**
- [x] claude.svg - Claude icon with brand color
- [x] codex.svg - Codex icon with brand color
- [x] cursor.svg - Cursor icon
- [x] copilot.svg - GitHub Copilot icon
- [x] gemini.svg - Gemini icon
- [x] kiro.svg - Kiro icon
- [x] amp.svg - Amp icon
- [x] augment.svg - Augment icon
- [x] jetbrains.svg - JetBrains icon
- [x] factory.svg - Factory/Droid icon
- [x] opencode.svg - OpenCode icon
- [x] antigravity.svg - Antigravity icon
- [x] zai.svg - z.ai icon
- [x] minimax.svg - MiniMax icon
- [x] kimi.svg - Kimi icon
- [x] kimik2.svg - Kimi K2 icon
- [x] vertexai.svg - Vertex AI icon
- [x] Fallback colored circle if icon fails to load

### Test 7: Dashboard Button States

**Steps:**
1. Enable JetBrains AI (no dashboard URL)
2. Enable Antigravity (no dashboard URL)
3. Enable Claude (has dashboard URL)

**Expected:**
- [x] JetBrains/Antigravity dashboard buttons disabled (grayed out)
- [x] Claude dashboard button enabled and clickable
- [x] Hover tooltip shows "No dashboard available" for disabled

### Test 8: Notifications

**Steps:**
1. Enable a provider with usage near threshold (e.g., 78%)
2. Wait for usage to cross 80% threshold

**Expected:**
- [x] Notification shows: "[Provider] usage at X%"
- [x] Rate limited to once per provider per hour
- [x] Different providers can each trigger notifications

### Test 9: Compact Representation

**Steps:**
1. Add widget to panel (compact view)
2. Enable 5+ providers

**Expected:**
- [x] Colored circle indicator based on worst usage
- [x] Tooltip shows "Claude: X% | Codex: Y% | Cursor: Z% | +2 more"
- [x] Click expands to full view

## CLI Config Sync Test

**Steps:**
1. Enable/disable provider in widget settings
2. Check CLI config: `cat ~/.codexbar/config.json`

**Expected:**
- [x] Config file updated with enabled/disabled state
- [x] Widget reflects CLI config changes

## Error Handling

**Steps:**
1. Disable network and refresh
2. Kill codexbar process if running

**Expected:**
- [x] Error message: "Fetch failed" or "CLI not found"
- [x] Exponential backoff (60s -> 120s -> 240s -> 300s max)
- [x] Recovery when network restored

## Notes

- Testing requires CodexBar CLI v2.x+ with multi-provider support
- Some providers require authentication before usage data available
- API-based providers (Copilot, Gemini, z.ai) need API keys configured
