import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: usageBar

    property real value: 0  // 0-100
    property int warningThreshold: 70
    property int criticalThreshold: 90

    readonly property color barColor: {
        if (value >= criticalThreshold) return Kirigami.Theme.negativeTextColor
        if (value >= warningThreshold) return Kirigami.Theme.neutralTextColor
        return Kirigami.Theme.positiveTextColor
    }

    implicitHeight: Kirigami.Units.gridUnit * 1.2
    Layout.fillWidth: true

    // Background bar
    Rectangle {
        id: background
        anchors.fill: parent
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        radius: height / 2
        color: Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r,
                              Kirigami.Theme.textColor.g,
                              Kirigami.Theme.textColor.b, 0.2)

        // Filled portion
        Rectangle {
            id: fillBar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 1
            width: Math.max(0, Math.min(parent.width - 2, (parent.width - 2) * (value / 100)))
            radius: height / 2
            color: usageBar.barColor

            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }

        // Percentage text overlay
        QQC2.Label {
            anchors.centerIn: parent
            text: Math.round(value) + "%"
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            font.bold: true
            color: {
                // Use contrasting color based on fill position
                var fillRatio = value / 100
                if (fillRatio > 0.5) {
                    // Text is over filled area - use light color
                    return Qt.lighter(Kirigami.Theme.backgroundColor, 1.5)
                } else {
                    // Text is over background - use normal text color
                    return Kirigami.Theme.textColor
                }
            }
        }
    }
}
