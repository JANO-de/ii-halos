import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

ContentPage {
    id: page
    readonly property int index: 10
    property bool register: parent.register ?? false
    forceWidth: true

    property string hyprmonPath: FileUtils.trimFileProtocol(`${Directories.config}/hypr/hyprmon.lua`)
    property string scriptPath: Quickshell.shellPath("scripts/hyprland/hyprmon_config.py")

    ListModel { id: monitorModel }

    function refreshMonitors() {
        monitorsProc.running = true
    }

    function applyMonitors() {
        const arr = []
        for (let i = 0; i < monitorModel.count; i++) {
            const m = monitorModel.get(i)
            arr.push({
                name: m.name,
                mode: m.mode,
                position: `${m.posX}x${m.posY}`,
                scale: parseFloat(m.scale),
                transform: parseInt(m.transformValue)
            })
        }
        applyProc.command = ["python3", page.scriptPath, "--file", page.hyprmonPath, "--all", JSON.stringify(arr)]
        applyProc.running = true
    }

    Component.onCompleted: refreshMonitors()

    Process {
        id: monitorsProc
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const arr = JSON.parse(text)
                    monitorModel.clear()
                    for (const m of arr) {
                        monitorModel.append({
                            name: m.name,
                            mode: `${m.width}x${m.height}@${Number(m.refreshRate).toFixed(2)}`,
                            posX: m.x,
                            posY: m.y,
                            scale: String(m.scale),
                            transformValue: m.transform
                        })
                    }
                } catch (e) {
                    console.log("[DisplaysConfig] Failed to parse monitors:", e)
                }
            }
        }
    }

    Process {
        id: applyProc
        onExited: (code, status) => {
            if (code !== 0) console.log("[DisplaysConfig] apply failed", code)
        }
    }

    ContentSection {
        icon: "monitor"
        title: Translation.tr("Displays")

        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }
            RippleButton {
                buttonText: Translation.tr("Refresh")
                onClicked: page.refreshMonitors()
            }
            RippleButton {
                buttonText: Translation.tr("Apply")
                onClicked: page.applyMonitors()
            }
        }

        Repeater {
            model: monitorModel
            delegate: ContentSection {
                required property int index
                required property string name
                required property string mode
                required property int posX
                required property int posY
                required property string scale
                required property int transformValue

                icon: "monitor"
                title: name

                ContentSubsection {
                    title: Translation.tr("Mode")
                    tooltip: Translation.tr("WIDTHxHEIGHT@REFRESH")

                    MaterialTextArea {
                        Layout.fillWidth: true
                        wrapMode: TextEdit.NoWrap
                        text: mode
                        onEditingFinished: monitorModel.setProperty(index, "mode", text)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ContentSubsection {
                        Layout.fillWidth: true
                        title: Translation.tr("Position X")

                        MaterialTextArea {
                            Layout.fillWidth: true
                            wrapMode: TextEdit.NoWrap
                            text: String(posX)
                            onEditingFinished: monitorModel.setProperty(index, "posX", parseInt(text) || 0)
                        }
                    }
                    ContentSubsection {
                        Layout.fillWidth: true
                        title: Translation.tr("Position Y")

                        MaterialTextArea {
                            Layout.fillWidth: true
                            wrapMode: TextEdit.NoWrap
                            text: String(posY)
                            onEditingFinished: monitorModel.setProperty(index, "posY", parseInt(text) || 0)
                        }
                    }
                }

                ContentSubsection {
                    title: Translation.tr("Scale")

                    MaterialTextArea {
                        Layout.fillWidth: true
                        wrapMode: TextEdit.NoWrap
                        text: scale
                        onEditingFinished: monitorModel.setProperty(index, "scale", text)
                    }
                }

                ContentSubsection {
                    title: Translation.tr("Transform")
                    tooltip: Translation.tr("0=normal, 1=90, 2=180, 3=270")

                    MaterialTextArea {
                        Layout.fillWidth: true
                        wrapMode: TextEdit.NoWrap
                        text: String(transformValue)
                        onEditingFinished: monitorModel.setProperty(index, "transformValue", parseInt(text) || 0)
                    }
                }
            }
        }
    }
}
