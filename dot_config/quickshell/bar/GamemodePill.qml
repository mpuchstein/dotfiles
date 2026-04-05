import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../shared" as Shared

// Gamemode indicator — visible only when gamemode is active
// Polls `gamemoded --status` every 5 seconds
BarPill {
    id: root

    groupName: ""          // no popout
    accentColor: Shared.Theme.green
    visible: isActive

    property bool isActive: false

    content: [
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "\u{f0522}"   // nf-md-controller_classic
            color: Shared.Theme.green
            font.pixelSize: Shared.Theme.fontLarge
            font.family: Shared.Theme.iconFont
        }
    ]

    Process {
        id: gameProc
        command: ["gamemoded", "--status"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.isActive = this.text.indexOf("is active") >= 0
            }
        }
    }

    function poll() { gameProc.running = false; gameProc.running = true; }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.poll()
    }

    Component.onCompleted: root.poll()
}
