import QtQuick
import "../../shared" as Shared

// Rounded left corners, square right (flush against bar)
Item {
    anchors.fill: parent
    clip: true

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width + 22
        radius: 22
        color: Shared.Theme.popoutBackground
        border.width: 1
        border.color: Shared.Theme.borderSubtle
    }
}
