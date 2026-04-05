import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import "../shared" as Shared

BarPill {
    id: root

    readonly property var player: {
        let players = Mpris.players.values;
        for (let i = 0; i < players.length; i++) {
            if (players[i].isPlaying) return players[i];
        }
        return players.length > 0 ? players[0] : null;
    }

    visible: player !== null
    groupName: "media"
    accentColor: Shared.Theme.green

    content: [
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: {
                if (!root.player) return "\u{f075a}";
                if (root.player.isPlaying) return "\u{f040a}";
                return "\u{f03e4}";
            }
            color: Shared.Theme.green
            font.pixelSize: Shared.Theme.fontLarge
            font.family: Shared.Theme.iconFont
        }
    ]
}
