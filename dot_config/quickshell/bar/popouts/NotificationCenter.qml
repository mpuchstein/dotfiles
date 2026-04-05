import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../shared" as Shared

Item {
    id: root

    required property var trackedNotifications
    required property var daemon

    function relativeTime(id) {
        let ts = root.daemon?.timestamps?.[id];
        if (!ts) return "";
        let diff = Math.floor((Date.now() - ts) / 1000);
        if (diff < 60) return "now";
        if (diff < 3600) return Math.floor(diff / 60) + "m";
        if (diff < 86400) return Math.floor(diff / 3600) + "h";
        return Math.floor(diff / 86400) + "d";
    }

    implicitWidth: Shared.Theme.popoutWidth
    implicitHeight: Math.min(600, col.implicitHeight + Shared.Theme.popoutPadding * 2)

    PopoutBackground { anchors.fill: parent }
    MouseArea { anchors.fill: parent }

    // Drives relative timestamp re-evaluation
    Timer { id: tsRefresh; property int tick: 0; interval: 30000; running: true; repeat: true; onTriggered: tick++ }

    // DnD auto-off timer
    Timer {
        id: dndTimer
        property int remaining: 0  // seconds, 0 = indefinite
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            remaining--;
            if (remaining <= 0) {
                running = false;
                if (root.daemon) root.daemon.dnd = false;
            }
        }
    }

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Shared.Theme.popoutPadding
        spacing: 8

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Notifications"
                color: Shared.Theme.text
                font.pixelSize: Shared.Theme.fontLarge
                font.family: Shared.Theme.fontFamily
                font.bold: true
                Layout.fillWidth: true
            }

            // DnD toggle
            Rectangle {
                implicitWidth: dndRow.implicitWidth + 12
                implicitHeight: 24
                radius: 12
                color: root.daemon?.dnd ? Qt.alpha(Shared.Theme.danger, Shared.Theme.opacityLight) : (dndMouse.containsMouse ? Shared.Theme.surface1 : Shared.Theme.surface0)
                border.width: root.daemon?.dnd ? 1 : 0
                border.color: Qt.alpha(Shared.Theme.danger, Shared.Theme.opacityMedium)
                Behavior on color { ColorAnimation { duration: 100 } }

                RowLayout {
                    id: dndRow
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: root.daemon?.dnd ? "\u{f009b}" : "\u{f009a}"; color: root.daemon?.dnd ? Shared.Theme.danger : Shared.Theme.overlay0; font.pixelSize: 12; font.family: Shared.Theme.iconFont }
                    Text { text: "DnD"; color: root.daemon?.dnd ? Shared.Theme.danger : Shared.Theme.overlay0; font.pixelSize: Shared.Theme.fontSmall; font.family: Shared.Theme.fontFamily }
                }

                MouseArea {
                    id: dndMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: { if (root.daemon) root.daemon.dnd = !root.daemon.dnd; }
                }
            }

            // Clear all
            Rectangle {
                visible: root.trackedNotifications.values.length > 0
                implicitWidth: clearRow.implicitWidth + 12
                implicitHeight: 24
                radius: 12
                color: clearMouse.containsMouse ? Shared.Theme.surface1 : Shared.Theme.surface0
                Behavior on color { ColorAnimation { duration: 100 } }

                RowLayout {
                    id: clearRow
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "Clear all"; color: Shared.Theme.overlay0; font.pixelSize: Shared.Theme.fontSmall; font.family: Shared.Theme.fontFamily }
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        let tracked = root.trackedNotifications;
                        for (let i = tracked.values.length - 1; i >= 0; i--)
                            tracked.values[i].dismiss();
                    }
                }
            }
        }

        // DnD schedule (visible when DnD is active)
        Loader {
            Layout.fillWidth: true
            active: root.daemon?.dnd === true
            visible: active
            sourceComponent: RowLayout {
                spacing: 4
                Repeater {
                    model: [
                        { label: "30m", mins: 30 },
                        { label: "1h", mins: 60 },
                        { label: "2h", mins: 120 },
                        { label: "\u{f0026}", mins: 0 }  // infinity = until manual off
                    ]

                    Rectangle {
                        required property var modelData
                        required property int index
                        readonly property bool isActive: {
                            if (modelData.mins === 0) return dndTimer.remaining <= 0;
                            return dndTimer.remaining > 0 && dndTimer.remaining <= modelData.mins * 60;
                        }
                        Layout.fillWidth: true
                        implicitHeight: 22
                        radius: 11
                        color: isActive ? Qt.alpha(Shared.Theme.danger, Shared.Theme.opacityLight) : (schedMouse.containsMouse ? Shared.Theme.surface1 : Shared.Theme.surface0)
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: parent.modelData.label
                            color: parent.isActive ? Shared.Theme.danger : Shared.Theme.overlay0
                            font.pixelSize: Shared.Theme.fontSmall
                            font.family: Shared.Theme.fontFamily
                        }

                        MouseArea {
                            id: schedMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (parent.modelData.mins === 0) {
                                    dndTimer.remaining = 0;  // indefinite
                                } else {
                                    dndTimer.remaining = parent.modelData.mins * 60;
                                    dndTimer.running = true;
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Shared.Theme.surface0 }

        // Empty state
        Text {
            visible: root.trackedNotifications.values.length === 0
            text: "No notifications"
            color: Shared.Theme.overlay0
            font.pixelSize: Shared.Theme.fontSize
            font.family: Shared.Theme.fontFamily
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            Layout.bottomMargin: 20
        }

        // Notification list
        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(480, notifList.implicitHeight)
            contentHeight: notifList.implicitHeight
            clip: true
            visible: root.trackedNotifications.values.length > 0

            ColumnLayout {
                id: notifList
                width: parent.width
                spacing: 6

                Repeater {
                    model: root.trackedNotifications

                    Rectangle {
                        id: notifCard
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: notifContent.implicitHeight + 16
                        radius: Shared.Theme.radiusSmall
                        color: notifMouse.containsMouse ? Shared.Theme.surface1 : Shared.Theme.surface0
                        border.width: modelData.urgency === NotificationUrgency.Critical ? 1 : 0
                        border.color: Shared.Theme.danger

                        Behavior on color { ColorAnimation { duration: 100 } }

                        MouseArea {
                            id: notifMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                let actions = notifCard.modelData.actions;
                                if (actions.length > 0)
                                    actions[0].invoke();
                                else
                                    notifCard.modelData.dismiss();
                            }
                        }

                        ColumnLayout {
                            id: notifContent
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            // App name + close
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                IconImage {
                                    source: notifCard.modelData.appIcon
                                    implicitSize: 14
                                    visible: notifCard.modelData.appIcon !== ""
                                }

                                                Text {
                                    text: notifCard.modelData.appName || "App"
                                    color: Shared.Theme.overlay0
                                    font.pixelSize: Shared.Theme.fontSmall
                                    font.family: Shared.Theme.fontFamily
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    property int tick: tsRefresh.tick
                                    text: root.relativeTime(notifCard.modelData.id)
                                    color: Shared.Theme.surface2
                                    font.pixelSize: Shared.Theme.fontSmall
                                    font.family: Shared.Theme.fontFamily
                                    visible: text !== ""
                                }

                                Text {
                                    text: "\u{f0156}"
                                    color: dismissMouse.containsMouse ? Shared.Theme.danger : Shared.Theme.overlay0
                                    font.pixelSize: 12
                                    font.family: Shared.Theme.iconFont
                                    MouseArea {
                                        id: dismissMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: notifCard.modelData.dismiss()
                                    }
                                }
                            }

                            // Summary
                            Text {
                                visible: text !== ""
                                text: notifCard.modelData.summary
                                color: Shared.Theme.text
                                font.pixelSize: Shared.Theme.fontSize
                                font.family: Shared.Theme.fontFamily
                                font.bold: true
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            // Body
                            Text {
                                visible: text !== ""
                                text: notifCard.modelData.body
                                textFormat: Text.PlainText
                                color: Shared.Theme.subtext0
                                font.pixelSize: Shared.Theme.fontSmall
                                font.family: Shared.Theme.fontFamily
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                            }

                            // Actions
                            RowLayout {
                                visible: notifCard.modelData.actions.length > 0
                                Layout.fillWidth: true
                                spacing: 4

                                Repeater {
                                    model: notifCard.modelData.actions

                                    Rectangle {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        implicitHeight: 24
                                        radius: 4
                                        color: actMouse.containsMouse ? Shared.Theme.surface2 : Shared.Theme.surface1

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.text
                                            color: Shared.Theme.text
                                            font.pixelSize: Shared.Theme.fontSmall
                                            font.family: Shared.Theme.fontFamily
                                        }

                                        MouseArea {
                                            id: actMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: modelData.invoke()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
