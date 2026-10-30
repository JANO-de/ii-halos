import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.models.hyprland

ContentPage {
    id: page
    readonly property int index: 7
    property bool register: parent.register ?? false
    forceWidth: true

    // 3a Gaps, border, rounding
    HyprlandConfigOption { id: gapsInOpt; key: "general:gaps_in" }
    HyprlandConfigOption { id: gapsOutOpt; key: "general:gaps_out" }
    HyprlandConfigOption { id: borderSizeOpt; key: "general:border_size" }
    HyprlandConfigOption { id: roundingOpt; key: "decoration:rounding" }

    ContentSection {
        icon: "aspect_ratio"
        title: Translation.tr("Gaps, border & rounding")

        ConfigSpinBox {
            icon: "unfold_more"
            text: Translation.tr("Gaps in")
            tooltip: Translation.tr("Inner gap between windows")
            from: 0
            to: 50
            stepSize: 1
            value: gapsInOpt.value ?? 0
            onValueChanged: {
                if (gapsInOpt.value === undefined) return
                if (value === gapsInOpt.value) return
                gapsInOpt.setValue(value)
            }
        }
        ConfigSpinBox {
            icon: "unfold_less"
            text: Translation.tr("Gaps out")
            tooltip: Translation.tr("Outer gap between windows and screen edge")
            from: 0
            to: 50
            stepSize: 1
            value: gapsOutOpt.value ?? 0
            onValueChanged: {
                if (gapsOutOpt.value === undefined) return
                if (value === gapsOutOpt.value) return
                gapsOutOpt.setValue(value)
            }
        }
        ConfigSpinBox {
            icon: "border_all"
            text: Translation.tr("Border size")
            tooltip: Translation.tr("Width of the window border")
            from: 0
            to: 10
            stepSize: 1
            value: borderSizeOpt.value ?? 0
            onValueChanged: {
                if (borderSizeOpt.value === undefined) return
                if (value === borderSizeOpt.value) return
                borderSizeOpt.setValue(value)
            }
        }
        ConfigSpinBox {
            icon: "rounded_corner"
            text: Translation.tr("Rounding")
            tooltip: Translation.tr("Corner rounding radius for windows")
            from: 0
            to: 50
            stepSize: 1
            value: roundingOpt.value ?? 0
            onValueChanged: {
                if (roundingOpt.value === undefined) return
                if (value === roundingOpt.value) return
                roundingOpt.setValue(value)
            }
        }
    }

    // 3b Blur, animations
    HyprlandConfigOption { id: blurEnabledOpt; key: "decoration:blur:enabled" }
    HyprlandConfigOption { id: animationsEnabledOpt; key: "animations:enabled" }

    ContentSection {
        icon: "blur_on"
        title: Translation.tr("Blur & animations")

        ConfigSwitch {
            buttonIcon: "blur_on"
            text: Translation.tr("Blur")
            checked: (blurEnabledOpt.value ?? 0) != 0 && blurEnabledOpt.value !== false
            onCheckedChanged: {
                if (blurEnabledOpt.value === undefined) return
                const current = (blurEnabledOpt.value != 0 && blurEnabledOpt.value !== false)
                if (checked === current) return
                blurEnabledOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Enable blur for transparent windows")
            }
        }
        ConfigSwitch {
            buttonIcon: "animation"
            text: Translation.tr("Animations")
            checked: (animationsEnabledOpt.value ?? 0) != 0 && animationsEnabledOpt.value !== false
            onCheckedChanged: {
                if (animationsEnabledOpt.value === undefined) return
                const current = (animationsEnabledOpt.value != 0 && animationsEnabledOpt.value !== false)
                if (checked === current) return
                animationsEnabledOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Enable window and layer animations")
            }
        }
    }

    // 3c Input
    HyprlandConfigOption { id: naturalScrollOpt; key: "input:touchpad:natural_scroll" }
    HyprlandConfigOption { id: kbLayoutOpt; key: "input:kb_layout" }

    ContentSection {
        icon: "keyboard"
        title: Translation.tr("Input")

        ConfigSwitch {
            buttonIcon: "touchpad_mouse"
            text: Translation.tr("Touchpad natural scroll")
            checked: (naturalScrollOpt.value ?? 0) != 0 && naturalScrollOpt.value !== false
            onCheckedChanged: {
                if (naturalScrollOpt.value === undefined) return
                const current = (naturalScrollOpt.value != 0 && naturalScrollOpt.value !== false)
                if (checked === current) return
                naturalScrollOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Scroll in the natural direction on touchpads")
            }
        }

        ContentSubsection {
            title: Translation.tr("Keyboard layout")
            tooltip: Translation.tr("Comma-separated list, e.g. us,es")

            MaterialTextArea {
                Layout.fillWidth: true
                wrapMode: TextEdit.NoWrap
                text: kbLayoutOpt.value !== undefined ? String(kbLayoutOpt.value) : ""
                onEditingFinished: {
                    if (kbLayoutOpt.value === undefined) return
                    if (text === String(kbLayoutOpt.value)) return
                    kbLayoutOpt.setValue(text)
                }
            }
        }
    }

    // 3d Misc
    HyprlandConfigOption { id: vfrOpt; key: "misc:vfr" }
    HyprlandConfigOption { id: vrrOpt; key: "misc:vrr" }
    HyprlandConfigOption { id: animateManualResizesOpt; key: "misc:animate_manual_resizes" }

    ContentSection {
        icon: "more_horiz"
        title: Translation.tr("Misc")

        ConfigSwitch {
            buttonIcon: "speed"
            text: Translation.tr("VFR")
            checked: (vfrOpt.value ?? 0) != 0 && vfrOpt.value !== false
            onCheckedChanged: {
                if (vfrOpt.value === undefined) return
                const current = (vfrOpt.value != 0 && vfrOpt.value !== false)
                if (checked === current) return
                vfrOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Variable frame rate to reduce resource usage")
            }
        }
        ConfigSpinBox {
            icon: "monitor"
            text: Translation.tr("VRR")
            tooltip: Translation.tr("Variable refresh rate (0=off, 1=on, 2=fullscreen only, 3=fullscreen and video)")
            from: 0
            to: 3
            stepSize: 1
            value: vrrOpt.value ?? 0
            onValueChanged: {
                if (vrrOpt.value === undefined) return
                if (value === vrrOpt.value) return
                vrrOpt.setValue(value)
            }
        }
        ConfigSwitch {
            buttonIcon: "aspect_ratio"
            text: Translation.tr("Animate manual resizes")
            checked: (animateManualResizesOpt.value ?? 0) != 0 && animateManualResizesOpt.value !== false
            onCheckedChanged: {
                if (animateManualResizesOpt.value === undefined) return
                const current = (animateManualResizesOpt.value != 0 && animateManualResizesOpt.value !== false)
                if (checked === current) return
                animateManualResizesOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Animate windows when resized manually")
            }
        }
    }
}
