import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configPage

    property alias cfg_refreshInterval: refreshSlider.value
    property int cfg_notificationThresholds_0: 80
    property int cfg_notificationThresholds_1: 95

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        // ═══════════════════════════════════════════════════════════════
        // REFRESH SECTION
        // ═══════════════════════════════════════════════════════════════
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Refresh")
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Update interval:")
            Kirigami.FormData.buddyFor: refreshSlider
            spacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true

            RowLayout {
                spacing: Kirigami.Units.largeSpacing
                Layout.fillWidth: true

                QQC2.Slider {
                    id: refreshSlider
                    from: 30
                    to: 300
                    stepSize: 30
                    snapMode: QQC2.Slider.SnapAlways
                    Layout.fillWidth: true

                    background: Rectangle {
                        x: refreshSlider.leftPadding
                        y: refreshSlider.topPadding + refreshSlider.availableHeight / 2 - height / 2
                        width: refreshSlider.availableWidth
                        height: 4
                        radius: 2
                        color: Kirigami.Theme.separatorColor

                        Rectangle {
                            width: refreshSlider.visualPosition * parent.width
                            height: parent.height
                            radius: 2
                            color: Kirigami.Theme.highlightColor
                        }
                    }
                }

                // Value badge
                Rectangle {
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 3.5
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 1.6
                    radius: Kirigami.Units.smallSpacing
                    color: Kirigami.Theme.highlightColor
                    opacity: 0.9

                    QQC2.Label {
                        anchors.centerIn: parent
                        text: formatInterval(refreshSlider.value)
                        font.weight: Font.Medium
                        color: Kirigami.Theme.highlightedTextColor
                    }
                }
            }

            // Tick labels
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: refreshSlider.leftPadding
                Layout.rightMargin: Kirigami.Units.gridUnit * 3.5 + Kirigami.Units.largeSpacing

                QQC2.Label {
                    text: "30s"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    opacity: 0.6
                }
                Item { Layout.fillWidth: true }
                QQC2.Label {
                    text: "2m"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    opacity: 0.6
                }
                Item { Layout.fillWidth: true }
                QQC2.Label {
                    text: "5m"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    opacity: 0.6
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════
        // NOTIFICATIONS SECTION
        // ═══════════════════════════════════════════════════════════════
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Notifications")
        }

        // Warning threshold
        RowLayout {
            Kirigami.FormData.label: i18n("Warning at:")
            spacing: Kirigami.Units.largeSpacing

            Rectangle {
                width: Kirigami.Units.smallSpacing
                height: Kirigami.Units.gridUnit * 1.5
                radius: width / 2
                color: Kirigami.Theme.neutralTextColor
            }

            QQC2.SpinBox {
                id: threshold1Spinner
                from: 50
                to: 94
                value: configPage.cfg_notificationThresholds_0
                onValueChanged: {
                    configPage.cfg_notificationThresholds_0 = value
                    // Ensure warning < critical
                    if (value >= threshold2Spinner.value) {
                        threshold2Spinner.value = Math.min(value + 1, 100)
                    }
                }

                textFromValue: function(value) { return value + "%" }
                valueFromText: function(text) { return parseInt(text) }
            }
        }

        // Critical threshold
        RowLayout {
            Kirigami.FormData.label: i18n("Critical at:")
            spacing: Kirigami.Units.largeSpacing

            Rectangle {
                width: Kirigami.Units.smallSpacing
                height: Kirigami.Units.gridUnit * 1.5
                radius: width / 2
                color: Kirigami.Theme.negativeTextColor
            }

            QQC2.SpinBox {
                id: threshold2Spinner
                from: 51
                to: 100
                value: configPage.cfg_notificationThresholds_1
                onValueChanged: {
                    configPage.cfg_notificationThresholds_1 = value
                    // Ensure critical > warning
                    if (value <= threshold1Spinner.value) {
                        threshold1Spinner.value = Math.max(value - 1, 50)
                    }
                }

                textFromValue: function(value) { return value + "%" }
                valueFromText: function(text) { return parseInt(text) }
            }
        }

        // Subtle hint instead of bulky InlineMessage
        QQC2.Label {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.smallSpacing
            text: i18n("Rate limited to one notification per provider per hour")
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            font.italic: true
            opacity: 0.6
            wrapMode: Text.WordWrap
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // HELPER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════
    function formatInterval(seconds) {
        if (seconds < 60) {
            return seconds + "s"
        } else {
            var mins = Math.floor(seconds / 60)
            var secs = seconds % 60
            if (secs === 0) {
                return mins + "m"
            }
            return mins + "m " + secs + "s"
        }
    }
}
