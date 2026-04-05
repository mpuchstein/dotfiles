import Quickshell.Hyprland
import QtQuick
import "../shared" as Shared

// Compact active window title, rotated vertically to fit the narrow bar
Item {
    id: root

    readonly property string title: {
        let w = Hyprland.focusedWindow;
        if (!w) return "";
        let t = w.title || "";
        let c = w.wlClass || "";
        // Show class if title is too long or empty
        if (t.length === 0) return c;
        if (t.length > 30) return c || t.substring(0, 20);
        return t;
    }

    visible: title !== ""
    implicitWidth: Shared.Theme.barInnerWidth
    implicitHeight: Math.min(label.implicitWidth + 8, 120)

    Text {
        id: label
        anchors.centerIn: parent
        rotation: -90
        width: root.implicitHeight
        text: root.title
        color: Shared.Theme.subtext0
        font.pixelSize: Shared.Theme.fontSmall
        font.family: Shared.Theme.fontFamily
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter

        Behavior on text {
            enabled: false  // no animation on text change
        }
    }

    opacity: title !== "" ? 0.7 : 0
    Behavior on opacity { NumberAnimation { duration: Shared.Theme.animFast } }
}
