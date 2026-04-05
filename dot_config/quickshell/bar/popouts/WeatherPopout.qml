import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../shared" as Shared

Item {
    id: root

    implicitWidth: Shared.Theme.popoutWidth
    implicitHeight: col.implicitHeight + Shared.Theme.popoutPadding * 2

    PopoutBackground { anchors.fill: parent }
    MouseArea { anchors.fill: parent }

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Shared.Theme.popoutPadding
        spacing: 6

        // ─── Header ───
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text {
                text: Shared.Weather.location
                color: Shared.Theme.text
                font.pixelSize: 18
                font.family: Shared.Theme.fontFamily
                font.bold: true
                Layout.fillWidth: true
            }
            Text {
                text: Shared.Weather.icon
                color: Shared.Theme.peach
                font.pixelSize: 24
                font.family: Shared.Theme.iconFont
            }
            Text {
                text: Shared.Weather.temp
                color: Shared.Theme.peach
                font.pixelSize: 18
                font.family: Shared.Theme.fontFamily
                font.bold: true
            }
        }

        Text {
            text: {
                if (Shared.Weather.status === "error") return "Unable to fetch weather data";
                if (Shared.Weather.status === "stale") return Shared.Weather.description + "  ·  stale";
                if (Shared.Weather.status === "loading") return "Loading…";
                return Shared.Weather.description;
            }
            color: Shared.Weather.status === "error" ? Shared.Theme.danger
                : Shared.Weather.status === "stale" ? Shared.Theme.warning
                : Shared.Theme.overlay0
            font.pixelSize: Shared.Theme.fontSmall
            font.family: Shared.Theme.fontFamily
        }

        // ─── separator ───
        Rectangle { Layout.fillWidth: true; height: 1; color: Shared.Theme.surface0; Layout.topMargin: 4; Layout.bottomMargin: 4 }

        // ─── Conditions ───
        ConditionRow { label: "Feels like"; value: Shared.Weather.feelsLike }
        ConditionRow { label: "Humidity"; value: Shared.Weather.humidity }
        ConditionRow { label: "Wind"; value: Shared.Weather.wind }

        // ─── separator ───
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            Layout.topMargin: 2
            Layout.bottomMargin: 6
            height: 1
            color: Shared.Theme.surface0
        }

        // ─── Forecast ───
        Text {
            text: "Forecast"
            color: Shared.Theme.overlay0
            font.pixelSize: Shared.Theme.fontSize
            font.family: Shared.Theme.fontFamily
            font.bold: true
            Layout.bottomMargin: 2
        }

        Repeater {
            model: Shared.Weather.forecast

            RowLayout {
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 22
                spacing: 8

                Text {
                    text: modelData.day
                    color: Shared.Theme.overlay0
                    font.pixelSize: Shared.Theme.fontSize
                    font.family: Shared.Theme.fontFamily
                    Layout.preferredWidth: 36
                }
                Text {
                    text: Shared.Weather.weatherIcon(modelData.code)
                    color: Shared.Theme.peach
                    font.pixelSize: 14
                    font.family: Shared.Theme.iconFont
                }
                Text {
                    text: modelData.desc
                    color: Shared.Theme.surface2
                    font.pixelSize: Shared.Theme.fontSmall
                    font.family: Shared.Theme.fontFamily
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Text {
                    text: modelData.low + "°"
                    color: Shared.Theme.sky
                    font.pixelSize: Shared.Theme.fontSize
                    font.family: Shared.Theme.fontFamily
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: 28
                }
                Text {
                    text: modelData.high + "°"
                    color: Shared.Theme.peach
                    font.pixelSize: Shared.Theme.fontSize
                    font.family: Shared.Theme.fontFamily
                    font.bold: true
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: 28
                }
            }
        }
    }

    component ConditionRow: RowLayout {
        property string label
        property string value
        Layout.fillWidth: true
        implicitHeight: 22
        spacing: 10
        Text { text: parent.label; color: Shared.Theme.overlay0; font.pixelSize: Shared.Theme.fontSize; font.family: Shared.Theme.fontFamily; Layout.fillWidth: true }
        Text { text: parent.value; color: Shared.Theme.text; font.pixelSize: Shared.Theme.fontSize; font.family: Shared.Theme.fontFamily; font.bold: true }
    }
}
