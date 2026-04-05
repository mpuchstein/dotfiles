import Quickshell
import QtQuick
import QtQuick.Layouts
import "../shared" as Shared

BarPill {
    groupName: "weather"
    accentColor: Shared.Weather.status === "error" ? Shared.Theme.overlay0 : Shared.Theme.peach

    content: [
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Shared.Weather.status === "error" ? "\u{f0599}" : Shared.Weather.icon
            color: Shared.Weather.status === "error" ? Shared.Theme.overlay0
                : Shared.Weather.status === "stale" ? Shared.Theme.warning
                : Shared.Theme.peach
            font.pixelSize: Shared.Theme.fontLarge
            font.family: Shared.Theme.iconFont
        },
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Shared.Weather.status === "error" ? "N/A"
                : Shared.Weather.status === "loading" ? "…"
                : Shared.Weather.temp
            color: Shared.Weather.status === "error" ? Shared.Theme.overlay0
                : Shared.Weather.status === "stale" ? Shared.Theme.warning
                : Shared.Theme.peach
            font.pixelSize: Shared.Theme.fontSmall
            font.family: Shared.Theme.fontFamily
            font.bold: true
        }
    ]
}
