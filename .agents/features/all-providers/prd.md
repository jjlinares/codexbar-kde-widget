# PRD: Support All CodexBar Providers

**Date:** 2026-01-25
**Repository:** https://github.com/jjlinares/codexbar-kde-widget

---

## Problem Statement

Widget only supports Claude and Codex. CodexBar CLI supports 17 providers. Users want to see all their enabled providers.

---

## Solution

Read enabled providers from CLI config (`~/.codexbar/config.json`) and display them. No provider management in widget - users use CLI to enable/disable providers.

### How it works

1. Widget runs `codexbar config dump --json` on startup and refresh
2. Displays a ProviderCard for each provider where `enabled: true`
3. Fetches usage data for enabled providers via `codexbar usage --provider {id} --source oauth --json`

### Config dialog

Only two settings:
- Refresh interval (30-300s)
- Notification thresholds (warning %, critical %)

No provider toggles - that's the CLI's job.

---

## Acceptance Criteria

- [ ] Widget displays all enabled providers from CLI config
- [ ] Each provider shows: name, icon, usage bars, dashboard button
- [ ] ScrollView when > 4 providers enabled
- [ ] Provider icons for all 17 providers
- [ ] Config dialog has refresh interval and notification settings only

---

## Provider List

claude, codex, cursor, copilot, gemini, kiro, amp, augment, jetbrains, factory, opencode, antigravity, zai, minimax, kimi, kimik2, vertexai

---

## Technical Notes

- CLI config location: `~/.codexbar/config.json`
- Read config: `codexbar config dump --json`
- Fetch usage: `codexbar usage --provider {id} --source oauth --json`
- Use hardcoded properties per provider (QML scoping issues with dynamic ListModel)
