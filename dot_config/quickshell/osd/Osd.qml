import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../shared" as Shared

Scope {
    id: root

    PwObjectTracker { objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource] }

    property string osdIcon: ""
    property real osdValue: 0
    property bool osdMuted: false
    property string osdLabel: ""
    property bool osdVisible: false

    function showOsd(icon, value, muted, label) {
        osdIcon = icon;
        osdValue = value;
        osdMuted = muted;
        osdLabel = label;
        osdVisible = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.osdVisible = false
    }

    // Event-driven audio change detection
    property var sinkAudio: Pipewire.defaultAudioSink?.audio ?? null
    property var sourceAudio: Pipewire.defaultAudioSource?.audio ?? null

    Connections {
        target: root.sinkAudio
        function onVolumeChanged() {
            let a = root.sinkAudio;
            if (a) root.showOsd("\u{f057e}", a.volume, a.muted, "Volume");
        }
        function onMutedChanged() {
            let a = root.sinkAudio;
            if (a) root.showOsd(a.muted ? "\u{f057f}" : "\u{f057e}", a.volume, a.muted, a.muted ? "Muted" : "Volume");
        }
    }

    Connections {
        target: root.sourceAudio
        function onVolumeChanged() {
            let a = root.sourceAudio;
            if (a) root.showOsd("\u{f036c}", a.volume, a.muted, "Mic");
        }
        function onMutedChanged() {
            let a = root.sourceAudio;
            if (a) root.showOsd(a.muted ? "\u{f036d}" : "\u{f036c}", a.volume, a.muted, a.muted ? "Mic muted" : "Mic");
        }
    }

    // Brightness monitoring via brightnessctl (auto-disables if no backlight device)
    property real lastBrightness: -1
    property bool hasBrightness: false
    Process {
        id: brightProc
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = this.text.trim().split(",");
                if (parts.length >= 5) {
                    root.hasBrightness = true;
                    let pct = parseInt(parts[4]) / 100;
                    if (root.lastBrightness >= 0 && Math.abs(pct - root.lastBrightness) > 0.005)
                        root.showOsd("\u{f00df}", pct, false, "Brightness");
                    root.lastBrightness = pct;
                }
            }
        }
    }
    Timer {
        interval: 500
        running: root.hasBrightness
        repeat: true
        onTriggered: { brightProc.running = false; brightProc.running = true; }
    }
    Component.onCompleted: { brightProc.running = true; }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData
                WlrLayershell.namespace: "quickshell:osd"
                surfaceFormat { opaque: false }

                visible: modelData.name === Shared.Config.monitor && root.osdVisible

                anchors {
                    top: true
                    right: true
                    bottom: true
                }

                exclusionMode: ExclusionMode.Ignore
                implicitWidth: Shared.Theme.barWidth + Shared.Theme.popoutWidth + 12
                color: "transparent"

                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: Shared.Theme.barWidth + 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: 44
                    height: 180
                    radius: 22
                    color: Shared.Theme.popoutBackground
                    border.width: 1
                    border.color: Shared.Theme.borderSubtle

                    opacity: root.osdVisible ? 1.0 : 0.0
                    scale: root.osdVisible ? 1.0 : 0.95
                    transformOrigin: Item.Right

                    Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.topMargin: 12
                        anchors.bottomMargin: 12
                        spacing: 8

                        // Percentage
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.osdMuted ? "M" : Math.round(root.osdValue * 100)
                            color: root.osdMuted ? Shared.Theme.overlay0 : Shared.Theme.text
                            font.pixelSize: Shared.Theme.fontSmall
                            font.family: Shared.Theme.fontFamily
                            font.bold: true
                        }

                        // Vertical bar (fills bottom-up)
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 6
                            radius: 3
                            color: Shared.Theme.surface0

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: root.osdMuted ? 0 : parent.height * Math.min(1, root.osdValue)
                                radius: 3
                                color: root.osdMuted ? Shared.Theme.overlay0 : Shared.Theme.sky
                                Behavior on height { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
                            }
                        }

                        // Icon
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.osdIcon
                            color: root.osdMuted ? Shared.Theme.overlay0 : Shared.Theme.sky
                            font.pixelSize: 16
                            font.family: Shared.Theme.iconFont
                        }
                    }
                }
            }
        }
    }
}
