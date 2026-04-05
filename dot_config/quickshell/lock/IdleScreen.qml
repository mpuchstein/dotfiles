import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../shared" as Shared

// Custom apex-neon idle screen
// Activated by hypridle via: quickshell -c ~/.config/quickshell/lock/
// Dismissed by any key/mouse input → triggers hyprlock
Scope {
    id: root

    property bool active: false

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData

                visible: root.active && modelData.name === Shared.Config.monitor
                WlrLayershell.namespace: "quickshell:idle"
                WlrLayershell.layer: WlrLayer.Overlay
                surfaceFormat { opaque: true }
                focusable: true

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                // Dismiss on any input
                Keys.onPressed: root.dismiss()
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: false
                    onClicked: root.dismiss()
                }

                // Full black backdrop
                Rectangle {
                    anchors.fill: parent
                    color: "#050505"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        // Large clock — apex-neon cyan, breathing opacity
                        Text {
                            id: clockText
                            Layout.alignment: Qt.AlignHCenter
                            text: Qt.formatDateTime(new Date(), Shared.Config.clockSecondsFormat)
                            color: "#00eaff"
                            font.pixelSize: 96
                            font.family: Shared.Theme.fontFamily
                            font.weight: Font.Light
                            font.letterSpacing: -2

                            // Breathing animation on opacity
                            SequentialAnimation on opacity {
                                running: root.active
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.55; duration: 2800; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 1.0;  duration: 2800; easing.type: Easing.InOutSine }
                            }
                        }

                        // Date — dim grey, understated
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: Qt.formatDateTime(new Date(), "dddd, d MMMM")
                            color: "#404040"
                            font.pixelSize: 18
                            font.family: Shared.Theme.fontFamily
                            font.letterSpacing: 2
                        }
                    }

                    // Clock update timer
                    Timer {
                        interval: 1000
                        running: root.active
                        repeat: true
                        onTriggered: clockText.text = Qt.formatDateTime(new Date(), Shared.Config.clockSecondsFormat)
                    }
                }
            }
        }
    }

    function show() { active = true; }
    function dismiss() {
        active = false;
        lockProc.running = true;
    }

    Process { id: lockProc; command: [Shared.Config.lockCommand] }
}
