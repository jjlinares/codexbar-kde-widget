import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

MouseArea {
    id: compactRoot

    readonly property bool inPanel: [PlasmaCore.Types.TopEdge, PlasmaCore.Types.RightEdge,
                                     PlasmaCore.Types.BottomEdge, PlasmaCore.Types.LeftEdge]
                                    .includes(Plasmoid.location)
    readonly property bool hasUsage: root.worstUsage > 0

    Layout.minimumWidth: Kirigami.Units.iconSizes.small
    Layout.minimumHeight: Kirigami.Units.iconSizes.small
    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
    Layout.preferredHeight: Kirigami.Units.iconSizes.medium

    hoverEnabled: true
    onClicked: root.expanded = !root.expanded

    // Brand icon with status color tint
    Image {
        id: brandIcon
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.85
        height: width
        source: "../icons/codexbar.png"
        sourceSize: Qt.size(width, height)
        visible: !compactRoot.hasUsage
    }

    MultiEffect {
        anchors.fill: brandIcon
        source: brandIcon
        visible: compactRoot.hasUsage
        colorization: 1.0
        colorizationColor: root.statusColor
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
