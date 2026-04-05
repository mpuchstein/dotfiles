import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../shared" as Shared

// Single notification card
Rectangle {
    id: root

    required property var notification

    implicitWidth: 360
    implicitHeight: content.implicitHeight + 20
    radius: Shared.Theme.radiusNormal
    color: Shared.Theme.popoutBackground
    border.width: 1
    border.color: notification.urgency === NotificationUrgency.Critical ? Qt.alpha(Shared.Theme.danger, Shared.Theme.opacityMedium) : Shared.Theme.borderSubtle

    // Entrance animation
    opacity: 0
    scale: 0.95
    Component.onCompleted: { opacity = 1; scale = 1; }

    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    // Dismiss on click
    MouseArea {
        anchors.fill: parent
        onClicked: root.notification.dismiss()
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        // Header: icon + app name + close
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            IconImage {
                source: root.notification.appIcon
                implicitSize: 18
                visible: root.notification.appIcon !== ""
            }

            Text {
                text: root.notification.appName || "Notification"
                color: Shared.Theme.overlay0
                font.pixelSize: Shared.Theme.fontSmall
                font.family: Shared.Theme.fontFamily
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: "\u{f0156}"
                color: closeMouse.containsMouse ? Shared.Theme.danger : Shared.Theme.overlay0
                font.pixelSize: 14
                font.family: Shared.Theme.iconFont
                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.notification.dismiss()
                }
            }
        }

        // Summary (title)
        Text {
            visible: text !== ""
            text: root.notification.summary
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
            text: root.notification.body
            textFormat: Text.PlainText
            color: Shared.Theme.subtext0
            font.pixelSize: Shared.Theme.fontSmall
            font.family: Shared.Theme.fontFamily
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            maximumLineCount: 4
            elide: Text.ElideRight
        }

        // Image
        Image {
            visible: root.notification.image !== ""
            source: root.notification.image
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            fillMode: Image.PreserveAspectCrop
            Layout.topMargin: 2
        }

        // Actions
        RowLayout {
            visible: root.notification.actions.length > 0
            Layout.fillWidth: true
            Layout.topMargin: 2
            spacing: 6

            Repeater {
                model: root.notification.actions

                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 28
                    radius: 6
                    color: actMouse.containsMouse ? Shared.Theme.surface1 : Shared.Theme.surface0

                    Behavior on color { ColorAnimation { duration: 100 } }

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

    // Urgency accent bar on left edge
    Rectangle {
        visible: root.notification.urgency === NotificationUrgency.Critical
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 1
        anchors.topMargin: root.radius
        anchors.bottomMargin: root.radius
        width: 3
        color: Shared.Theme.danger
    }
}
