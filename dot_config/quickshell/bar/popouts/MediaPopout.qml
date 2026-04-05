import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import "../../shared" as Shared

Item {
    id: root

    implicitWidth: Shared.Theme.popoutWidth
    implicitHeight: col.implicitHeight + Shared.Theme.popoutPadding * 2

    PopoutBackground { anchors.fill: parent }
    MouseArea { anchors.fill: parent }

    readonly property var player: {
        let players = Mpris.players.values;
        for (let i = 0; i < players.length; i++) {
            if (players[i].isPlaying) return players[i];
        }
        return players.length > 0 ? players[0] : null;
    }

    readonly property bool isPlaying: player?.isPlaying ?? false
    readonly property string trackTitle: player?.trackTitle ?? ""
    readonly property string trackArtist: player?.trackArtist ?? ""
    readonly property string trackAlbum: player?.trackAlbum ?? ""
    readonly property string artUrl: player?.trackArtUrl ?? ""
    readonly property real trackLength: player?.length ?? 0
    readonly property real trackPosition: player?.position ?? 0

    // Position doesn't auto-update — emit positionChanged periodically while playing
    Timer {
        interval: 1000
        running: root.isPlaying && root.player !== null
        repeat: true
        onTriggered: { if (root.player) root.player.positionChanged(); }
    }

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Shared.Theme.popoutPadding
        spacing: 10

        // Album art
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: artImg.hasArt ? width * 0.6 : 48
            radius: Shared.Theme.radiusSmall
            color: Shared.Theme.surface0
            clip: true

            Behavior on Layout.preferredHeight { NumberAnimation { duration: Shared.Theme.animNormal; easing.type: Easing.OutCubic } }

            Image {
                id: artImg
                anchors.fill: parent
                source: root.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                visible: hasArt
                property bool hasArt: status === Image.Ready && root.artUrl !== ""
            }

            // Gradient overlay at bottom for readability
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height * 0.4
                visible: artImg.hasArt
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: Qt.alpha(Shared.Theme.mantle, 0.8) }
                }
            }

            // Placeholder icon when no art
            Text {
                anchors.centerIn: parent
                visible: !artImg.hasArt
                text: "\u{f075a}"
                color: Shared.Theme.overlay0
                font.pixelSize: 24
                font.family: Shared.Theme.iconFont
            }
        }

        // Track info
        Text {
            text: root.trackTitle || "No track"
            color: Shared.Theme.text
            font.pixelSize: Shared.Theme.fontLarge
            font.family: Shared.Theme.fontFamily
            font.bold: true
            Layout.fillWidth: true
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        Text {
            visible: text !== ""
            text: root.trackArtist
            color: Shared.Theme.subtext0
            font.pixelSize: Shared.Theme.fontSize
            font.family: Shared.Theme.fontFamily
            Layout.fillWidth: true
            elide: Text.ElideRight
            Layout.topMargin: -6
        }

        // Progress bar
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 4
            radius: 2
            color: Shared.Theme.surface0
            visible: root.trackLength > 0

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: root.trackLength > 0 ? parent.width * Math.min(1, root.trackPosition / root.trackLength) : 0
                radius: 2
                color: Shared.Theme.green
            }

            MouseArea {
                anchors.fill: parent
                onClicked: event => {
                    if (root.player?.canSeek && root.trackLength > 0) {
                        let ratio = event.x / parent.width;
                        let target = ratio * root.trackLength;
                        root.player.position = target;
                    }
                }
            }
        }

        // Time labels
        RowLayout {
            Layout.fillWidth: true
            visible: root.trackLength > 0

            Text {
                text: formatTime(root.trackPosition)
                color: Shared.Theme.overlay0
                font.pixelSize: Shared.Theme.fontSmall
                font.family: Shared.Theme.fontFamily
            }
            Item { Layout.fillWidth: true }
            Text {
                text: formatTime(root.trackLength)
                color: Shared.Theme.overlay0
                font.pixelSize: Shared.Theme.fontSmall
                font.family: Shared.Theme.fontFamily
            }
        }

        // Controls
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            // Previous
            Text {
                text: "\u{f04ae}"
                color: prevMouse.containsMouse ? Shared.Theme.text : Shared.Theme.subtext0
                font.pixelSize: 20
                font.family: Shared.Theme.iconFont
                opacity: root.player?.canGoPrevious ? 1.0 : 0.3
                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: { if (root.player?.canGoPrevious) root.player.previous(); }
                }
            }

            // Play/Pause
            Rectangle {
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                color: playMouse.containsMouse ? Shared.Theme.green : Qt.alpha(Shared.Theme.green, Shared.Theme.opacityMedium)
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "\u{f03e4}" : "\u{f040a}"
                    color: Shared.Theme.crust
                    font.pixelSize: 20
                    font.family: Shared.Theme.iconFont
                }

                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: { if (root.player?.canTogglePlaying) root.player.togglePlaying(); }
                }
            }

            // Next
            Text {
                text: "\u{f04ad}"
                color: nextMouse.containsMouse ? Shared.Theme.text : Shared.Theme.subtext0
                font.pixelSize: 20
                font.family: Shared.Theme.iconFont
                opacity: root.player?.canGoNext ? 1.0 : 0.3
                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: { if (root.player?.canGoNext) root.player.next(); }
                }
            }
        }

        // Player name
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.player?.identity ?? ""
            color: Shared.Theme.surface2
            font.pixelSize: Shared.Theme.fontSmall
            font.family: Shared.Theme.fontFamily
        }
    }

    function formatTime(secs) {
        let m = Math.floor(secs / 60);
        let s = Math.floor(secs % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }
}
