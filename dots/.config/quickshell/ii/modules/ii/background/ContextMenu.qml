import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import Quickshell

Item {
    id: root
    anchors.fill: parent
    visible: root.shown

    property bool shown: false
    property real menuX: 0
    property real menuY: 0
    property bool moreExpanded: false

    signal closed()

    function close() {
        root.shown = false;
        root.moreExpanded = false;
        root.closed();
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: root.close()
    }

    Rectangle {
        id: menu
        x: Math.min(root.menuX, root.width - width - 8)
        y: Math.min(root.menuY, root.height - height - 8)
        width: 230
        implicitHeight: menuColumn.implicitHeight + 16
        color: Appearance.colors.colLayer0
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        radius: Appearance.rounding.normal

        ColumnLayout {
            id: menuColumn
            anchors.fill: parent
            anchors.margins: 8
            spacing: 2

            component Entry: Rectangle {
                id: entry
                property string icon: ""
                property string label: ""
                signal triggered()
                Layout.fillWidth: true
                implicitHeight: 34
                radius: Appearance.rounding.small
                color: entryHover.containsMouse ? Appearance.colors.colLayer1Hover : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    MaterialSymbol {
                        text: entry.icon
                        iconSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colOnLayer0
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: entry.label
                        color: Appearance.colors.colOnLayer0
                        font.pixelSize: Appearance.font.pixelSize.small
                    }
                }

                MouseArea {
                    id: entryHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        entry.triggered();
                        root.close();
                    }
                }
            }

            Entry {
                icon: "wallpaper"
                label: Translation.tr("Wallpaper selector")
                onTriggered: GlobalStates.wallpaperSelectorOpen = true
            }
            Entry {
                icon: "shuffle"
                label: Translation.tr("Random wallpaper")
                onTriggered: Wallpapers.randomFromCurrentFolder()
            }
            Entry {
                icon: "settings"
                label: Translation.tr("Settings")
                onTriggered: Quickshell.execDetached(["qs", "-p", Quickshell.shellPath("settings.qml")])
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Appearance.colors.colLayer0Border
            }

            Entry {
                icon: root.moreExpanded ? "expand_less" : "expand_more"
                label: Translation.tr("More tools")
                onTriggered: root.moreExpanded = !root.moreExpanded
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                visible: root.moreExpanded

                Entry {
                    icon: "terminal"
                    label: Translation.tr("Terminal")
                    onTriggered: Quickshell.execDetached(["kitty"])
                }
                Entry {
                    icon: "folder"
                    label: Translation.tr("File manager")
                    onTriggered: Quickshell.execDetached(["xdg-open", Directories.home])
                }
                Entry {
                    icon: "screenshot_region"
                    label: Translation.tr("Screenshot")
                    onTriggered: GlobalStates.regionSelectorOpen = true
                }
                Entry {
                    icon: "overview"
                    label: Translation.tr("Overview")
                    onTriggered: GlobalStates.overviewOpen = !GlobalStates.overviewOpen
                }
                Entry {
                    icon: "lock"
                    label: Translation.tr("Lock screen")
                    onTriggered: Quickshell.execDetached(["qs", "-c", "ii", "ipc", "call", "lock", "activate"])
                }
            }
        }
    }
}
