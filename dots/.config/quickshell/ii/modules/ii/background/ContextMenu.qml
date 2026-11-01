import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import Quickshell

Item {
    id: ctxRoot
    property int screenWidth: 1920
    property int screenHeight: 1080
    property bool shown: false
    property real menuX: 0
    property real menuY: 0
    property bool moreExpanded: false

    width: screenWidth
    height: screenHeight
    visible: shown

    signal activated()

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: ctxRoot.activated()
    }

    Rectangle {
        id: menu
        x: Math.min(ctxRoot.menuX, ctxRoot.width - width - 8)
        y: Math.min(ctxRoot.menuY, ctxRoot.height - height - 8)
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
                property var onTrigger: null
                property bool closeOnClick: true
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
                        if (entry.onTrigger) entry.onTrigger();
                        if (entry.closeOnClick) ctxRoot.activated();
                    }
                }
            }

            Entry {
                icon: "wallpaper"
                label: Translation.tr("Wallpaper selector")
                onTrigger: () => { GlobalStates.wallpaperSelectorOpen = true; }
            }
            Entry {
                icon: "shuffle"
                label: Translation.tr("Random wallpaper")
                onTrigger: () => { Wallpapers.randomFromCurrentFolder(); }
            }
            Entry {
                icon: "settings"
                label: Translation.tr("Settings")
                onTrigger: () => { Quickshell.execDetached(["qs", "-p", Quickshell.shellPath("settings.qml")]); }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Appearance.colors.colLayer0Border
            }

            Entry {
                icon: ctxRoot.moreExpanded ? "expand_less" : "expand_more"
                label: Translation.tr("More tools")
                closeOnClick: false
                onTrigger: () => { ctxRoot.moreExpanded = !ctxRoot.moreExpanded; }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                visible: ctxRoot.moreExpanded

                Entry {
                    icon: "terminal"
                    label: Translation.tr("Terminal")
                    onTrigger: () => { Quickshell.execDetached(["kitty"]); }
                }
                Entry {
                    icon: "folder"
                    label: Translation.tr("File manager")
                    onTrigger: () => { Quickshell.execDetached(["xdg-open", Directories.home]); }
                }
                Entry {
                    icon: "screenshot_region"
                    label: Translation.tr("Screenshot")
                    onTrigger: () => { GlobalStates.regionSelectorOpen = true; }
                }
                Entry {
                    icon: "overview"
                    label: Translation.tr("Overview")
                    onTrigger: () => { GlobalStates.overviewOpen = !GlobalStates.overviewOpen; }
                }
                Entry {
                    icon: "lock"
                    label: Translation.tr("Lock screen")
                    onTrigger: () => { Quickshell.execDetached(["qs", "-c", "ii", "ipc", "call", "lock", "activate"]); }
                }
            }
        }
    }
}
