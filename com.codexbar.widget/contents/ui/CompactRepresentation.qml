import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

MouseArea {
    id: compactRoot

    readonly property bool inPanel: [PlasmaCore.Types.TopEdge, PlasmaCore.Types.RightEdge,
                                     PlasmaCore.Types.BottomEdge, PlasmaCore.Types.LeftEdge]
                                    .includes(Plasmoid.location)

    Layout.minimumWidth: Kirigami.Units.iconSizes.small
    Layout.minimumHeight: Kirigami.Units.iconSizes.small
    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
    Layout.preferredHeight: Kirigami.Units.iconSizes.medium

    hoverEnabled: true
    onClicked: root.expanded = !root.expanded

    // Colored circle indicator
    Rectangle {
        id: statusIndicator
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.7
        height: width
        radius: width / 2
        color: root.statusColor
        border.width: 1
        border.color: Kirigami.Theme.textColor
        opacity: 0.9

        // Inner highlight
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.3
            height: width
            radius: width / 2
            color: Qt.lighter(parent.color, 1.3)
            opacity: 0.5
        }
    }

    // Hover effect
    Rectangle {
        anchors.fill: parent
        radius: Kirigami.Units.smallSpacing
        color: Kirigami.Theme.highlightColor
        opacity: compactRoot.containsMouse ? 0.2 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}
