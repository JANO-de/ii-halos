import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: page
    readonly property int index: 7
    property bool register: parent.register ?? false
    forceWidth: true

    ContentSection {
        icon: "window"
        title: Translation.tr("Hyprland")

        // Controls added in Step 3
    }
}
