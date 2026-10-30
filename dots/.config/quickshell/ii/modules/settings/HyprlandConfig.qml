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

    // General
    HyprlandConfigOption { id: allowTearingOpt; key: "general:allow_tearing" }
    HyprlandConfigOption { id: layoutOpt; key: "general:layout" }
    HyprlandConfigOption { id: snapEnabledOpt; key: "general:snap:enabled" }
    HyprlandConfigOption { id: activeBorderOpt; key: "general:col.active_border" }
    HyprlandConfigOption { id: inactiveBorderOpt; key: "general:col.inactive_border" }

    ContentSection {
        icon: "tune"
        title: Translation.tr("General")

        ConfigSwitch {
            buttonIcon: "water_drop"
            text: Translation.tr("Allow tearing")
            checked: (allowTearingOpt.value ?? 0) != 0 && allowTearingOpt.value !== false
            onCheckedChanged: {
                if (allowTearingOpt.value === undefined) return
                const current = (allowTearingOpt.value != 0 && allowTearingOpt.value !== false)
                if (checked === current) return
                allowTearingOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Allow screen tearing for lower latency")
            }
        }

        ConfigSwitch {
            buttonIcon: "grid_view"
            text: Translation.tr("Snap enabled")
            checked: (snapEnabledOpt.value ?? 0) != 0 && snapEnabledOpt.value !== false
            onCheckedChanged: {
                if (snapEnabledOpt.value === undefined) return
                const current = (snapEnabledOpt.value != 0 && snapEnabledOpt.value !== false)
                if (checked === current) return
                snapEnabledOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Snap windows to edges and each other")
            }
        }

        ContentSubsection {
            title: Translation.tr("Layout")
            tooltip: Translation.tr("Window layout algorithm")

            ConfigSelectionArray {
                options: [
                    { "displayName": Translation.tr("Dwindle"), "value": "dwindle" },
                    { "displayName": Translation.tr("Master"), "value": "master" },
                    { "displayName": Translation.tr("Scrolling"), "value": "scrolling" }
                ]
                currentValue: layoutOpt.value !== undefined ? String(layoutOpt.value) : "dwindle"
                onSelected: (newValue) => {
                    if (layoutOpt.value === undefined) return
                    if (String(newValue) === String(layoutOpt.value)) return
                    layoutOpt.setValue(newValue)
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Active border color")
            tooltip: Translation.tr("Hyprland color string, e.g. rgba(33ccffee)")

            MaterialTextArea {
                Layout.fillWidth: true
                wrapMode: TextEdit.NoWrap
                text: activeBorderOpt.value !== undefined ? String(activeBorderOpt.value) : ""
                onEditingFinished: {
                    if (activeBorderOpt.value === undefined) return
                    if (text === String(activeBorderOpt.value)) return
                    activeBorderOpt.setValue(text)
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Inactive border color")
            tooltip: Translation.tr("Hyprland color string, e.g. rgba(595959aa)")

            MaterialTextArea {
                Layout.fillWidth: true
                wrapMode: TextEdit.NoWrap
                text: inactiveBorderOpt.value !== undefined ? String(inactiveBorderOpt.value) : ""
                onEditingFinished: {
                    if (inactiveBorderOpt.value === undefined) return
                    if (text === String(inactiveBorderOpt.value)) return
                    inactiveBorderOpt.setValue(text)
                }
            }
        }
    }

    // 3b Blur, animations
    HyprlandConfigOption { id: blurEnabledOpt; key: "decoration:blur:enabled" }
    HyprlandConfigOption { id: blurSizeOpt; key: "decoration:blur:size" }
    HyprlandConfigOption { id: blurPassesOpt; key: "decoration:blur:passes" }
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
        ConfigSpinBox {
            icon: "blur_on"
            text: Translation.tr("Blur size")
            tooltip: Translation.tr("Blur radius")
            from: 1
            to: 20
            stepSize: 1
            value: blurSizeOpt.value ?? 8
            onValueChanged: {
                if (blurSizeOpt.value === undefined) return
                if (value === blurSizeOpt.value) return
                blurSizeOpt.setValue(value)
            }
        }
        ConfigSpinBox {
            icon: "layers"
            text: Translation.tr("Blur passes")
            tooltip: Translation.tr("Number of blur passes")
            from: 1
            to: 5
            stepSize: 1
            value: blurPassesOpt.value ?? 1
            onValueChanged: {
                if (blurPassesOpt.value === undefined) return
                if (value === blurPassesOpt.value) return
                blurPassesOpt.setValue(value)
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

    // Decoration (shadow, opacity, dim)
    HyprlandConfigOption { id: shadowEnabledOpt; key: "decoration:shadow:enabled" }
    HyprlandConfigOption { id: shadowRangeOpt; key: "decoration:shadow:range" }
    HyprlandConfigOption { id: shadowRenderPowerOpt; key: "decoration:shadow:render_power" }
    HyprlandConfigOption { id: activeOpacityOpt; key: "decoration:active_opacity" }
    HyprlandConfigOption { id: inactiveOpacityOpt; key: "decoration:inactive_opacity" }
    HyprlandConfigOption { id: dimInactiveOpt; key: "decoration:dim_inactive" }
    HyprlandConfigOption { id: dimStrengthOpt; key: "decoration:dim_strength" }

    ContentSection {
        icon: "shadow"
        title: Translation.tr("Decoration")

        ConfigSwitch {
            buttonIcon: "shadow"
            text: Translation.tr("Shadows")
            checked: (shadowEnabledOpt.value ?? 0) != 0 && shadowEnabledOpt.value !== false
            onCheckedChanged: {
                if (shadowEnabledOpt.value === undefined) return
                const current = (shadowEnabledOpt.value != 0 && shadowEnabledOpt.value !== false)
                if (checked === current) return
                shadowEnabledOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Enable drop shadows for windows")
            }
        }
        ConfigSpinBox {
            icon: "shadow"
            text: Translation.tr("Shadow range")
            tooltip: Translation.tr("Shadow size")
            from: 0
            to: 100
            stepSize: 1
            value: shadowRangeOpt.value ?? 4
            onValueChanged: {
                if (shadowRangeOpt.value === undefined) return
                if (value === shadowRangeOpt.value) return
                shadowRangeOpt.setValue(value)
            }
        }
        ConfigSpinBox {
            icon: "gradient"
            text: Translation.tr("Shadow render power")
            tooltip: Translation.tr("Shadow falloff")
            from: 1
            to: 4
            stepSize: 1
            value: shadowRenderPowerOpt.value ?? 3
            onValueChanged: {
                if (shadowRenderPowerOpt.value === undefined) return
                if (value === shadowRenderPowerOpt.value) return
                shadowRenderPowerOpt.setValue(value)
            }
        }

        ConfigSlider {
            buttonIcon: "opacity"
            text: Translation.tr("Active opacity")
            from: 0
            to: 1
            value: activeOpacityOpt.value ?? 1.0
            onValueChanged: {
                if (activeOpacityOpt.value === undefined) return
                if (value === activeOpacityOpt.value) return
                activeOpacityOpt.setValue(value)
            }
        }
        ConfigSlider {
            buttonIcon: "opacity"
            text: Translation.tr("Inactive opacity")
            from: 0
            to: 1
            value: inactiveOpacityOpt.value ?? 1.0
            onValueChanged: {
                if (inactiveOpacityOpt.value === undefined) return
                if (value === inactiveOpacityOpt.value) return
                inactiveOpacityOpt.setValue(value)
            }
        }

        ConfigSwitch {
            buttonIcon: "contrast"
            text: Translation.tr("Dim inactive")
            checked: (dimInactiveOpt.value ?? 0) != 0 && dimInactiveOpt.value !== false
            onCheckedChanged: {
                if (dimInactiveOpt.value === undefined) return
                const current = (dimInactiveOpt.value != 0 && dimInactiveOpt.value !== false)
                if (checked === current) return
                dimInactiveOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Dim inactive windows")
            }
        }
        ConfigSlider {
            buttonIcon: "contrast"
            text: Translation.tr("Dim strength")
            from: 0
            to: 1
            value: dimStrengthOpt.value ?? 0.0
            onValueChanged: {
                if (dimStrengthOpt.value === undefined) return
                if (value === dimStrengthOpt.value) return
                dimStrengthOpt.setValue(value)
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

    // Input advanced
    HyprlandConfigOption { id: repeatDelayOpt; key: "input:repeat_delay" }
    HyprlandConfigOption { id: repeatRateOpt; key: "input:repeat_rate" }
    HyprlandConfigOption { id: sensitivityOpt; key: "input:sensitivity" }
    HyprlandConfigOption { id: followMouseOpt; key: "input:follow_mouse" }
    HyprlandConfigOption { id: leftHandedOpt; key: "input:left_handed" }
    HyprlandConfigOption { id: accelProfileOpt; key: "input:accel_profile" }

    ContentSection {
        icon: "keyboard"
        title: Translation.tr("Keyboard repeat")

        ConfigSpinBox {
            icon: "timer"
            text: Translation.tr("Repeat delay")
            tooltip: Translation.tr("Delay before a key starts repeating (ms)")
            from: 100
            to: 1500
            stepSize: 25
            value: repeatDelayOpt.value ?? 600
            onValueChanged: {
                if (repeatDelayOpt.value === undefined) return
                if (value === repeatDelayOpt.value) return
                repeatDelayOpt.setValue(value)
            }
        }
        ConfigSpinBox {
            icon: "speed"
            text: Translation.tr("Repeat rate")
            tooltip: Translation.tr("Key repeats per second")
            from: 1
            to: 80
            stepSize: 1
            value: repeatRateOpt.value ?? 25
            onValueChanged: {
                if (repeatRateOpt.value === undefined) return
                if (value === repeatRateOpt.value) return
                repeatRateOpt.setValue(value)
            }
        }
    }

    ContentSection {
        icon: "mouse"
        title: Translation.tr("Mouse")

        ConfigSlider {
            buttonIcon: "mouse"
            text: Translation.tr("Sensitivity")
            from: -1
            to: 1
            value: sensitivityOpt.value ?? 0
            onValueChanged: {
                if (sensitivityOpt.value === undefined) return
                if (value === sensitivityOpt.value) return
                sensitivityOpt.setValue(value)
            }
        }
        ConfigSpinBox {
            icon: "visibility"
            text: Translation.tr("Follow mouse")
            tooltip: Translation.tr("Focus follows mouse (0-3)")
            from: 0
            to: 3
            stepSize: 1
            value: followMouseOpt.value ?? 1
            onValueChanged: {
                if (followMouseOpt.value === undefined) return
                if (value === followMouseOpt.value) return
                followMouseOpt.setValue(value)
            }
        }
        ConfigSwitch {
            buttonIcon: "swap_horiz"
            text: Translation.tr("Left-handed")
            checked: (leftHandedOpt.value ?? 0) != 0 && leftHandedOpt.value !== false
            onCheckedChanged: {
                if (leftHandedOpt.value === undefined) return
                const current = (leftHandedOpt.value != 0 && leftHandedOpt.value !== false)
                if (checked === current) return
                leftHandedOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Swap left and right mouse buttons")
            }
        }
        ContentSubsection {
            title: Translation.tr("Accel profile")
            tooltip: Translation.tr("flat or adaptive")

            MaterialTextArea {
                Layout.fillWidth: true
                wrapMode: TextEdit.NoWrap
                text: accelProfileOpt.value !== undefined ? String(accelProfileOpt.value) : ""
                onEditingFinished: {
                    if (accelProfileOpt.value === undefined) return
                    if (text === String(accelProfileOpt.value)) return
                    accelProfileOpt.setValue(text)
                }
            }
        }
    }

    // Layout
    HyprlandConfigOption { id: preserveSplitOpt; key: "dwindle:preserve_split" }
    HyprlandConfigOption { id: smartSplitOpt; key: "dwindle:smart_split" }
    HyprlandConfigOption { id: forceSplitOpt; key: "dwindle:force_split" }
    HyprlandConfigOption { id: pseudoTileOpt; key: "dwindle:pseudotile" }
    HyprlandConfigOption { id: masterOrientationOpt; key: "master:orientation" }

    ContentSection {
        icon: "dashboard"
        title: Translation.tr("Layout")

        ConfigSwitch {
            buttonIcon: "splitscreen"
            text: Translation.tr("Preserve split")
            checked: (preserveSplitOpt.value ?? 0) != 0 && preserveSplitOpt.value !== false
            onCheckedChanged: {
                if (preserveSplitOpt.value === undefined) return
                const current = (preserveSplitOpt.value != 0 && preserveSplitOpt.value !== false)
                if (checked === current) return
                preserveSplitOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Preserve split direction when moving windows")
            }
        }
        ConfigSwitch {
            buttonIcon: "auto_awesome"
            text: Translation.tr("Smart split")
            checked: (smartSplitOpt.value ?? 0) != 0 && smartSplitOpt.value !== false
            onCheckedChanged: {
                if (smartSplitOpt.value === undefined) return
                const current = (smartSplitOpt.value != 0 && smartSplitOpt.value !== false)
                if (checked === current) return
                smartSplitOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Split follows mouse cursor")
            }
        }
        ConfigSwitch {
            buttonIcon: "picture_in_picture"
            text: Translation.tr("Pseudotile")
            checked: (pseudoTileOpt.value ?? 0) != 0 && pseudoTileOpt.value !== false
            onCheckedChanged: {
                if (pseudoTileOpt.value === undefined) return
                const current = (pseudoTileOpt.value != 0 && pseudoTileOpt.value !== false)
                if (checked === current) return
                pseudoTileOpt.setValue(checked)
            }
            StyledToolTip {
                text: Translation.tr("Pseudotile floating windows into tiled")
            }
        }
        ConfigSpinBox {
            icon: "splitscreen"
            text: Translation.tr("Force split")
            tooltip: Translation.tr("0=follow mouse, 1=left, 2=right")
            from: 0
            to: 2
            stepSize: 1
            value: forceSplitOpt.value ?? 0
            onValueChanged: {
                if (forceSplitOpt.value === undefined) return
                if (value === forceSplitOpt.value) return
                forceSplitOpt.setValue(value)
            }
        }
        ContentSubsection {
            title: Translation.tr("Master orientation")
            tooltip: Translation.tr("left, right, top, bottom, center")

            MaterialTextArea {
                Layout.fillWidth: true
                wrapMode: TextEdit.NoWrap
                text: masterOrientationOpt.value !== undefined ? String(masterOrientationOpt.value) : ""
                onEditingFinished: {
                    if (masterOrientationOpt.value === undefined) return
                    if (text === String(masterOrientationOpt.value)) return
                    masterOrientationOpt.setValue(text)
                }
            }
        }
    }

    // Environment
    ContentSection {
        icon: "terminal"
        title: Translation.tr("Environment")

        ContentSubsection {
            title: Translation.tr("Environment variables")
            tooltip: Translation.tr("One per line, e.g. env = XCURSOR_SIZE,24")

            MaterialTextArea {
                Layout.fillWidth: true
                wrapMode: TextEdit.Wrap
                onEditingFinished: {
                    const lines = text.split("\\n").map(l => l.trim()).filter(l => l.length > 0)
                    const envLines = lines.map(l => l.toLowerCase().startsWith("env") ? l : `env = ${l}`)
                    HyprlandConfig.setMany({}, { removeMatching: ["^\\\\s*env\\\\s*="], addLines: envLines })
                }
            }
        }
    }

    // Binds
    ContentSection {
        icon: "keyboard_command_key"
        title: Translation.tr("Binds")

        ContentSubsection {
            title: Translation.tr("Keybinds")
            tooltip: Translation.tr("One per line, e.g. bind = SUPER, Q, exec, kitty")

            MaterialTextArea {
                Layout.fillWidth: true
                wrapMode: TextEdit.Wrap
                onEditingFinished: {
                    const lines = text.split("\\n").map(l => l.trim()).filter(l => l.length > 0)
                    const bindLines = lines.map(l => l.toLowerCase().startsWith("bind") ? l : `bind = ${l}`)
                    HyprlandConfig.setMany({}, { removeMatching: ["^\\\\s*bind\\\\s*="], addLines: bindLines })
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
