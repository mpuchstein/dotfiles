import Quickshell
import QtQuick
import QtQuick.Layouts
import "../shared" as Shared

BarPill {
    groupName: "datetime"
    accentColor: Shared.Theme.teal

    content: [
        Text {
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDateTime(Shared.Time.date, Shared.Config.pillTimeFormat)
            color: Shared.Theme.teal
            font.pixelSize: Shared.Theme.fontLarge
            font.family: Shared.Theme.fontFamily
            font.bold: true
            lineHeight: 1.1
        },
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: Shared.Theme.barInnerWidth * 0.5
            height: 1
            color: Shared.Theme.teal
            opacity: Shared.Theme.opacityLight
        },
        Text {
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDateTime(Shared.Time.date, Shared.Config.pillDateFormat)
            color: Shared.Theme.teal
            font.pixelSize: Shared.Theme.fontSmall
            font.family: Shared.Theme.fontFamily
        }
    ]
}
