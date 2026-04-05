import Quickshell
import QtQuick
import QtQuick.Layouts
import "../shared" as Shared

BarPill {
    groupName: "system"
    accentColor: Shared.Theme.lavender

    content: [
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "\u{f303}"
            color: Shared.Theme.lavender
            font.pixelSize: Shared.Theme.fontLarge + 2
            font.family: Shared.Theme.iconFont
        }
    ]
}
