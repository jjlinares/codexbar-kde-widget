import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

ColumnLayout {
    id: providerCard

    property string providerName: ""
    property url providerIcon: ""
    property var providerData: null
    property bool hasError: false
    property string errorMessage: ""
    property string dashboardUrl: ""
    property int warningThreshold: 70
    property int criticalThreshold: 90

    readonly property bool hasUsage: !!(providerData && providerData.usage)

    signal openDashboard()

    spacing: Kirigami.Units.smallSpacing

    // Header row with icon, name, and dashboard button
    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        // Provider icon
        Kirigami.Icon {
            source: providerIcon
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            fallback: "application-x-executable"
        }

        // Provider name
        Kirigami.Heading {
            text: providerName
            level: 4
            Layout.fillWidth: true
        }

        // Dashboard button
        PlasmaComponents.ToolButton {
            text: i18n("Dashboard")
            icon.name: "internet-web-browser"
            onClicked: providerCard.openDashboard()
            PlasmaComponents.ToolTip.text: i18n("Open %1 dashboard", providerName)
            PlasmaComponents.ToolTip.visible: hovered
            PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
        }
    }

    // Error state
    Kirigami.InlineMessage {
        visible: hasError
        Layout.fillWidth: true
        type: Kirigami.MessageType.Error
        text: errorMessage
    }

    // Usage content (only when no error)
    ColumnLayout {
        visible: !hasError && providerData !== null
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing

        // Session usage
        ColumnLayout {
            visible: hasUsage && providerData.usage.primary
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true

                QQC2.Label {
                    text: i18n("Session")
                    opacity: 0.8
                }

                Item { Layout.fillWidth: true }

                QQC2.Label {
                    text: getResetTime("primary")
                    opacity: 0.6
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
            }

            UsageBar {
                Layout.fillWidth: true
                value: getUsagePercent("primary")
                warningThreshold: providerCard.warningThreshold
                criticalThreshold: providerCard.criticalThreshold
            }
        }

        // Weekly usage
        ColumnLayout {
            visible: hasUsage && providerData.usage.secondary
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true

                QQC2.Label {
                    text: i18n("Weekly")
                    opacity: 0.8
                }

                Item { Layout.fillWidth: true }

                QQC2.Label {
                    text: getResetTime("secondary")
                    opacity: 0.6
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
            }

            UsageBar {
                Layout.fillWidth: true
                value: getUsagePercent("secondary")
                warningThreshold: providerCard.warningThreshold
                criticalThreshold: providerCard.criticalThreshold
            }
        }
    }

    // Loading state
    PlasmaComponents.BusyIndicator {
        visible: !hasError && providerData === null
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
    }

    // Separator
    Kirigami.Separator {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.smallSpacing
    }

    function getUsagePercent(type) {
        if (!providerData || !providerData.usage || !providerData.usage[type]) {
            return 0
        }
        return providerData.usage[type].usedPercent || 0
    }

    function getResetTime(type) {
        if (!hasUsage || !providerData.usage[type]) return ""

        var resetAt = providerData.usage[type].resetsAt
        if (!resetAt) {
            var desc = providerData.usage[type].resetDescription || ""
            return desc ? i18n("Resets in %1", desc) : ""
        }
        return i18n("Resets in %1", root.formatRelativeTime(resetAt))
    }
}
