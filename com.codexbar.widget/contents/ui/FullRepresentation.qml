import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

PlasmaExtras.Representation {
    id: fullRoot

    Layout.minimumWidth: Kirigami.Units.gridUnit * 18
    Layout.minimumHeight: Kirigami.Units.gridUnit * 14
    Layout.preferredWidth: Kirigami.Units.gridUnit * 22
    Layout.preferredHeight: Kirigami.Units.gridUnit * 20

    // Keyboard navigation
    Keys.onEscapePressed: {
        if (root.expanded) {
            root.expanded = false
        }
    }

    header: PlasmaExtras.PlasmoidHeading {
        RowLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Heading {
                text: "CodexBar"
                level: 3
                Layout.fillWidth: true
            }

            PlasmaComponents.ToolButton {
                icon.name: "view-refresh"
                onClicked: root.fetchAllProviders(true)
                PlasmaComponents.ToolTip.text: i18n("Refresh now")
                PlasmaComponents.ToolTip.visible: hovered
                PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
            }

            PlasmaComponents.ToolButton {
                icon.name: "configure"
                onClicked: Plasmoid.internalAction("configure").trigger()
                PlasmaComponents.ToolTip.text: i18n("Configure")
                PlasmaComponents.ToolTip.visible: hovered
                PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
            }
        }
    }

    // ScrollView for when many providers are active
    QQC2.ScrollView {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        contentWidth: availableWidth

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: Kirigami.Units.largeSpacing

            // Dynamic provider cards - only show providers with data
            Repeater {
                model: root.allProviderIds

                ProviderCard {
                    required property string modelData

                    readonly property var meta: ProviderMetadata.getProvider(modelData)
                    readonly property var data: root.providerData[modelData]

                    visible: !!data
                    Layout.fillWidth: true
                    providerName: meta ? meta.displayName : modelData
                    providerIcon: Qt.resolvedUrl("../icons/" + modelData + ".svg")
                    providerData: data || null
                    dashboardUrl: meta ? meta.dashboardURL : ""
                    onOpenDashboard: root.openDashboard(modelData)
                }
            }

            // Spacer
            Item {
                Layout.fillHeight: true
            }

            // No providers found message
            PlasmaExtras.PlaceholderMessage {
                visible: !root.hasAnyProvider
                Layout.fillWidth: true
                text: i18n("Scanning providers...")
                iconName: "view-refresh"
            }
        }
    }
}
