pragma Singleton
import QtQuick

QtObject {
    // Provider metadata array - contains all 17 providers from CodexBar CLI
    // Each entry: id, displayName, dashboardURL, brandColor, defaultEnabled
    readonly property var providers: [
        {
            id: "claude",
            displayName: "Claude",
            dashboardURL: "https://claude.ai/settings/usage",
            brandColor: "#CC7C5E",
            defaultEnabled: true
        },
        {
            id: "codex",
            displayName: "Codex",
            dashboardURL: "https://chatgpt.com/codex/settings/usage",
            brandColor: "#49A3B0",
            defaultEnabled: true
        },
        {
            id: "cursor",
            displayName: "Cursor",
            dashboardURL: "https://cursor.com/dashboard?tab=usage",
            brandColor: "#00BFA5",
            defaultEnabled: false
        },
        {
            id: "copilot",
            displayName: "Copilot",
            dashboardURL: "https://github.com/settings/copilot",
            brandColor: "#A855F7",
            defaultEnabled: false
        },
        {
            id: "gemini",
            displayName: "Gemini",
            dashboardURL: "https://gemini.google.com",
            brandColor: "#AB87EA",
            defaultEnabled: false
        },
        {
            id: "kiro",
            displayName: "Kiro",
            dashboardURL: "https://app.kiro.dev/account/usage",
            brandColor: "#FF9900",
            defaultEnabled: false
        },
        {
            id: "amp",
            displayName: "Amp",
            dashboardURL: "https://ampcode.com/settings",
            brandColor: "#DC2626",
            defaultEnabled: false
        },
        {
            id: "augment",
            displayName: "Augment",
            dashboardURL: "https://app.augmentcode.com/account/subscription",
            brandColor: "#6366F1",
            defaultEnabled: false
        },
        {
            id: "jetbrains",
            displayName: "JetBrains AI",
            dashboardURL: "",
            brandColor: "#FF3399",
            defaultEnabled: false
        },
        {
            id: "factory",
            displayName: "Droid",
            dashboardURL: "https://app.factory.ai/settings/billing",
            brandColor: "#FF6B35",
            defaultEnabled: false
        },
        {
            id: "opencode",
            displayName: "OpenCode",
            dashboardURL: "https://opencode.ai",
            brandColor: "#3B82F6",
            defaultEnabled: false
        },
        {
            id: "antigravity",
            displayName: "Antigravity",
            dashboardURL: "",
            brandColor: "#60BA7E",
            defaultEnabled: false
        },
        {
            id: "zai",
            displayName: "z.ai",
            dashboardURL: "https://z.ai/manage-apikey/subscription",
            brandColor: "#E85A6A",
            defaultEnabled: false
        },
        {
            id: "minimax",
            displayName: "MiniMax",
            dashboardURL: "https://platform.minimax.io/user-center/payment/coding-plan?cycle_type=3",
            brandColor: "#FE603C",
            defaultEnabled: false
        },
        {
            id: "kimi",
            displayName: "Kimi",
            dashboardURL: "https://www.kimi.com/code/console",
            brandColor: "#FE603C",
            defaultEnabled: false
        },
        {
            id: "kimik2",
            displayName: "Kimi K2",
            dashboardURL: "https://kimi-k2.ai/my-credits",
            brandColor: "#4C00FF",
            defaultEnabled: false
        },
        {
            id: "vertexai",
            displayName: "Vertex AI",
            dashboardURL: "https://console.cloud.google.com/vertex-ai",
            brandColor: "#4285F4",
            defaultEnabled: false
        }
    ]

    // Lookup map for O(1) provider access
    readonly property var providerMap: {
        var map = {}
        for (var i = 0; i < providers.length; i++) {
            map[providers[i].id] = providers[i]
        }
        return map
    }

    function getProvider(providerId) {
        return providerMap[providerId] || null
    }

    function getProviderIds() {
        return Object.keys(providerMap)
    }
}
