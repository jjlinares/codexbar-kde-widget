import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.notification

PlasmoidItem {
    id: root

    // Provider IDs from metadata singleton
    readonly property var allProviderIds: ProviderMetadata.getProviderIds()

    // Source fallback order
    readonly property var sourceFallbackOrder: ["oauth", "cli", "api"]
    readonly property int maxBackoffSeconds: 300

    // Provider state maps
    property var providerData: ({})
    property var providerBackoff: ({})
    property var providerErrors: ({})
    property var providerSourceIndex: ({})
    property var lastNotificationTime: ({})

    // Configuration
    readonly property int refreshInterval: Plasmoid.configuration.refreshInterval
    readonly property int warningThreshold: Plasmoid.configuration.warningThreshold
    readonly property int criticalThreshold: Plasmoid.configuration.criticalThreshold

    // Compute worst usage across all providers with data
    readonly property real worstUsage: {
        var worst = 0
        for (var id in providerData) {
            var data = providerData[id]
            if (data && data.usage && data.usage.primary) {
                worst = Math.max(worst, data.usage.primary.usedPercent || 0)
            }
        }
        return worst
    }

    readonly property bool hasAnyProvider: Object.keys(providerData).length > 0

    readonly property color statusColor: {
        if (worstUsage <= 0) return "transparent"  // No color when idle
        if (worstUsage >= criticalThreshold) return Kirigami.Theme.negativeTextColor
        if (worstUsage >= warningThreshold) return Kirigami.Theme.neutralTextColor
        return Kirigami.Theme.positiveTextColor
    }

    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
    toolTipMainText: "CodexBar"
    toolTipSubText: buildTooltipText()
    preferredRepresentation: Plasmoid.formFactor === 0 ? fullRepresentation : compactRepresentation

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            var match = source.match(/--provider\s+(\w+)/)
            if (match && match[1]) {
                handleResponse(match[1], data["stdout"] || "", data["exit code"] || 0)
            }
            disconnectSource(source)
        }

        function exec(cmd) {
            connectSource(cmd)
        }
    }

    Timer {
        id: startupTimer
        interval: 3000
        running: true
        repeat: false
        onTriggered: {
            fetchAllProviders()
            refreshTimer.start()
        }
    }

    Timer {
        id: refreshTimer
        interval: root.refreshInterval * 1000
        running: false
        repeat: true
        onTriggered: fetchAllProviders()
    }

    Notification {
        id: notification
        componentName: "codexbar"
        eventId: "usage-warning"
        title: "CodexBar"
        urgency: Notification.NormalUrgency
    }

    // Startup fetch handled by startupTimer (3s delay for engine readiness)

    function fetchAllProviders(force) {
        for (var i = 0; i < allProviderIds.length; i++) {
            var id = allProviderIds[i]
            var backoff = providerBackoff[id] || 0

            if (!force && backoff > 0) {
                setBackoff(id, backoff - refreshInterval)
            } else {
                if (force) {
                    setBackoff(id, 0)
                    setErrors(id, 0)
                }
                fetchProviderWithSource(id, 0)
            }
        }
    }

    function fetchProviderWithSource(providerId, sourceIndex) {
        setSourceIndex(providerId, sourceIndex)
        var source = sourceFallbackOrder[sourceIndex]
        executable.exec("codexbar usage --provider " + providerId + " --source " + source + " --json")
    }

    function handleResponse(providerId, stdout, exitCode) {
        var sourceIndex = providerSourceIndex[providerId] || 0

        if (exitCode !== 0 || stdout.trim() === "") {
            tryNextSourceOrFail(providerId, sourceIndex)
            return
        }

        var data = parseUsageResponse(stdout)
        if (!data) {
            tryNextSourceOrFail(providerId, sourceIndex)
            return
        }

        var oldData = providerData[providerId]
        setProviderData(providerId, data)
        setErrors(providerId, 0)
        setBackoff(providerId, 0)
        checkThresholds(providerId, data, oldData)
    }

    function tryNextSourceOrFail(providerId, currentSourceIndex) {
        var nextIndex = currentSourceIndex + 1
        if (nextIndex < sourceFallbackOrder.length) {
            fetchProviderWithSource(providerId, nextIndex)
            return
        }

        removeProviderData(providerId)
        var errorCount = (providerErrors[providerId] || 0) + 1
        setErrors(providerId, errorCount)
        var backoff = Math.min(60 * Math.pow(2, errorCount - 1), maxBackoffSeconds)
        setBackoff(providerId, backoff)
    }

    function parseUsageResponse(stdout) {
        try {
            var result = JSON.parse(stdout)
            if (Array.isArray(result) && result.length > 0 && result[0].usage) {
                return result[0]
            }
        } catch (e) {
            console.log("CodexBar: JSON parse error: " + e)
        }
        return null
    }

    // State update helpers (QML requires reassignment to trigger bindings)
    function updateMap(map, id, value) {
        var updated = Object.assign({}, map)
        if (value === undefined) {
            delete updated[id]
        } else {
            updated[id] = value
        }
        return updated
    }

    function setProviderData(id, data) { providerData = updateMap(providerData, id, data) }
    function removeProviderData(id) { providerData = updateMap(providerData, id, undefined) }
    function setBackoff(id, value) { providerBackoff = updateMap(providerBackoff, id, value) }
    function setErrors(id, value) { providerErrors = updateMap(providerErrors, id, value) }
    function setSourceIndex(id, value) { providerSourceIndex = updateMap(providerSourceIndex, id, value) }

    function checkThresholds(provider, newData, oldData) {
        if (!newData || !newData.usage || !newData.usage.primary) return

        var currentPercent = newData.usage.primary.usedPercent || 0
        var oldPercent = (oldData && oldData.usage && oldData.usage.primary)
            ? (oldData.usage.primary.usedPercent || 0) : 0

        // Check critical first, then warning
        if (currentPercent >= criticalThreshold && oldPercent < criticalThreshold) {
            sendNotification(provider, currentPercent, criticalThreshold)
        } else if (currentPercent >= warningThreshold && oldPercent < warningThreshold) {
            sendNotification(provider, currentPercent, warningThreshold)
        }
    }

    function sendNotification(providerId, percent, threshold) {
        var key = providerId + "_" + threshold
        var now = Date.now()
        var lastTime = lastNotificationTime[key] || 0
        var oneHour = 60 * 60 * 1000

        if (now - lastTime < oneHour) {
            return
        }

        var updated = Object.assign({}, lastNotificationTime)
        updated[key] = now
        lastNotificationTime = updated

        var providerName = getProviderDisplayName(providerId)
        notification.text = providerName + " usage at " + Math.round(percent) + "%"
        notification.sendEvent()
    }

    function getProviderDisplayName(providerId) {
        var meta = ProviderMetadata.getProvider(providerId)
        return meta ? meta.displayName : providerId
    }

    // Build tooltip text showing providers with data
    function buildTooltipText() {
        var parts = []
        for (var i = 0; i < allProviderIds.length; i++) {
            var id = allProviderIds[i]
            var data = providerData[id]
            if (data && data.usage && data.usage.primary) {
                var percent = Math.round(data.usage.primary.usedPercent || 0)
                parts.push(getProviderDisplayName(id) + ": " + percent + "%")
            }
        }
        return parts.length > 0 ? parts.join(" | ") : "Scanning providers..."
    }

    function formatRelativeTime(isoString) {
        if (!isoString) return ""

        var resetTime = new Date(isoString)
        var now = new Date()
        var diffMs = resetTime.getTime() - now.getTime()

        if (diffMs <= 0) return "now"

        var diffMins = Math.floor(diffMs / 60000)
        var diffHours = Math.floor(diffMins / 60)
        var diffDays = Math.floor(diffHours / 24)

        if (diffDays > 0) {
            var remainingHours = diffHours % 24
            return diffDays + "d " + remainingHours + "h"
        } else if (diffHours > 0) {
            var remainingMins = diffMins % 60
            return diffHours + "h " + remainingMins + "m"
        } else {
            return diffMins + "m"
        }
    }

    function openDashboard(providerId) {
        var meta = ProviderMetadata.getProvider(providerId)
        if (meta && meta.dashboardURL) {
            Qt.openUrlExternally(meta.dashboardURL)
        }
    }
}
