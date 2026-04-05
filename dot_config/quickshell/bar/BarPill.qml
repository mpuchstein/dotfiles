import QtQuick
import QtQuick.Layouts
import "../shared" as Shared

// Unified segmented-control pill for bar group buttons
Item {
    id: root

    property string groupName: ""
    property color accentColor: Shared.Theme.text
    property alias content: contentArea.data

    readonly property bool isActive: Shared.PopoutState.active === groupName
    readonly property bool isHovered: mouse.containsMouse

    implicitWidth: Shared.Theme.barInnerWidth
    implicitHeight: pill.height

    Rectangle {
        id: pill
        width: parent.width
        height: contentArea.implicitHeight + Shared.Theme.barPadding * 2 + 6
        radius: Shared.Theme.radiusNormal
        color: root.isActive
            ? Qt.alpha(root.accentColor, Shared.Theme.opacityLight)
            : root.isHovered
                ? Shared.Theme.surface1
                : Shared.Theme.surface0
        border.width: root.isActive ? 1 : 0
        border.color: Qt.alpha(root.accentColor, Shared.Theme.opacityMedium)

        Behavior on color { ColorAnimation { duration: Shared.Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Shared.Theme.animFast } }

        ColumnLayout {
            id: contentArea
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            let globalPos = root.mapToItem(null, 0, root.height / 2);
            Shared.PopoutState.toggle(root.groupName, globalPos.y);
        }
    }
}
