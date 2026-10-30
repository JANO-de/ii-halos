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
    readonly property int index: 9
    property bool register: parent.register ?? false
    forceWidth: true

    property string profilesDir: FileUtils.trimFileProtocol(`${Directories.config}/illogical-impulse/profiles`)
    property string configPath: FileUtils.trimFileProtocol(`${Directories.config}/illogical-impulse/config.json`)
    property string shellOverridesPath: FileUtils.trimFileProtocol(`${Directories.config}/hypr/hyprland/shellOverrides/main.lua`)
    property var profileNames: []
    property string newProfileName: ""

    function refreshProfiles() {
        listProc.running = true
    }

    function safeName(name: string): bool {
        return /^[A-Za-z0-9_-]+$/.test(name)
    }

    Component.onCompleted: refreshProfiles()

    Process {
        id: listProc
        command: ["bash", "-c", "cd \"$1\" 2>/dev/null && for f in *.json; do [ -f \"$f\" ] && echo \"${f%.json}\"; done", "bash", page.profilesDir]
        stdout: StdioCollector {
            onStreamFinished: {
                const names = text.trim().length > 0 ? text.trim().split("\n") : []
                page.profileNames = names
            }
        }
    }

    ContentSection {
        icon: "bookmark"
        title: Translation.tr("Profiles")

        ContentSubsection {
            title: Translation.tr("Save current as profile")
            tooltip: Translation.tr("Name: letters, numbers, - and _ only")

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                MaterialTextArea {
                    Layout.fillWidth: true
                    wrapMode: TextEdit.NoWrap
                    text: page.newProfileName
                    onTextChanged: page.newProfileName = text
                }
                RippleButton {
                    implicitWidth: 80
                    implicitHeight: 36
                    buttonText: Translation.tr("Save")
                    onClicked: {
                        if (!page.safeName(page.newProfileName)) return
                        Quickshell.execDetached(["mkdir", "-p", page.profilesDir])
                        Quickshell.execDetached(["cp", page.configPath, `${page.profilesDir}/${page.newProfileName}.json`])
                        Quickshell.execDetached(["cp", page.shellOverridesPath, `${page.profilesDir}/${page.newProfileName}.lua`])
                        page.newProfileName = ""
                        page.refreshProfiles()
                    }
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Saved profiles")

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: page.profileNames
                    delegate: RowLayout {
                        required property string modelData
                        Layout.fillWidth: true
                        spacing: 8

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData
                            color: Appearance.colors.colOnSurface
                        }
                        RippleButton {
                            implicitWidth: 70
                            implicitHeight: 32
                            buttonText: Translation.tr("Load")
                            onClicked: {
                                Quickshell.execDetached(["cp", `${page.profilesDir}/${modelData}.json`, page.configPath])
                                Quickshell.execDetached(["cp", `${page.profilesDir}/${modelData}.lua`, page.shellOverridesPath])
                                Quickshell.execDetached(["hyprctl", "reload"])
                            }
                        }
                        RippleButton {
                            implicitWidth: 70
                            implicitHeight: 32
                            buttonText: Translation.tr("Delete")
                            onClicked: {
                                Quickshell.execDetached(["rm", "-f", `${page.profilesDir}/${modelData}.json`, `${page.profilesDir}/${modelData}.lua`])
                                page.refreshProfiles()
                            }
                        }
                    }
                }
            }
        }
    }
}
