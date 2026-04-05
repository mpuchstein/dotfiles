import Quickshell
import Quickshell.Hyprland
import QtQuick
import "../shared" as Shared

// Rounded-square workspace slots with sliding active highlight.
// Set monitorName to show only workspaces on a specific monitor.
Item {
    id: root

    property string monitorName: ""
    property int wsCount: Shared.Config.workspaceCount

    readonly property int cellSize: Shared.Theme.barInnerWidth - Shared.Theme.barPadding * 2

    readonly property var iconMap: ({
        "mail":    "\u{eb1c}",
        "comms":   "\u{ee59}",
        "element": "\u{f1d7}",
        "joplin":  "\u{f249}",
        "steam":   "\u{f1b6}",
        "spotify": "\u{f1bc}"
    })

    // { id, name } objects for workspaces on this monitor, sorted by name numerically.
    property var monitorWsData: {
        if (!monitorName) return [];
        let all = Hyprland.workspaces, data = [];
        for (let i = 0; i < all.values.length; i++) {
            let ws = all.values[i];
            if (ws.monitor && ws.monitor.name === monitorName)
                data.push({ id: ws.id, name: ws.name });
        }
        data.sort((a, b) => parseInt(a.name) - parseInt(b.name));
        return data;
    }

    // Active workspace ID for this monitor specifically
    property int activeWsId: {
        if (monitorName) {
            let mons = Hyprland.monitors;
            for (let i = 0; i < mons.values.length; i++) {
                if (mons.values[i].name === monitorName)
                    return mons.values[i].activeWorkspace?.id ?? -1;
            }
            return -1;
        }
        let fw = Hyprland.focusedWorkspace;
        return fw ? fw.id : 1;
    }

    implicitWidth: Shared.Theme.barInnerWidth
    implicitHeight: container.height

    Rectangle {
        id: container
        width: parent.width
        height: wsCol.height + padding * 2
        radius: Shared.Theme.radiusNormal
        color: Shared.Theme.surface0

        property int padding: Shared.Theme.barPadding + 2

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: event => {
                if (event.angleDelta.y > 0)
                    Hyprland.dispatch("workspace m-1");
                else
                    Hyprland.dispatch("workspace m+1");
            }
        }

        // Sliding active indicator
        Rectangle {
            id: activeIndicator

            property int targetIndex: {
                if (root.monitorName) {
                    for (let i = 0; i < root.monitorWsData.length; i++) {
                        if (root.monitorWsData[i].id === root.activeWsId) return i;
                    }
                    return 0;
                }
                return Math.max(0, Math.min(root.activeWsId - 1, root.wsCount - 1));
            }
            property var targetItem: wsRepeater.itemAt(targetIndex)

            x: (container.width - width) / 2
            y: targetItem ? targetItem.y + wsCol.y : container.padding
            width: root.cellSize
            height: root.cellSize
            radius: Shared.Theme.radiusSmall
            color: Shared.Theme.red

            Behavior on y {
                NumberAnimation {
                    duration: Shared.Theme.animSlow
                    easing.type: Easing.InOutQuart
                }
            }
        }

        Column {
            id: wsCol
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: container.padding
            spacing: Math.floor(Shared.Theme.spacing / 2)

            Repeater {
                id: wsRepeater
                model: root.monitorName ? root.monitorWsData.length : root.wsCount

                delegate: Item {
                    id: wsItem
                    required property int index

                    width: root.cellSize
                    height: root.cellSize

                    property int wsId: root.monitorName ? root.monitorWsData[index].id : index + 1
                    property string wsName: root.monitorName ? root.monitorWsData[index].name : (index + 1).toString()
                    property bool isActive: root.activeWsId === wsId
                    property bool isOccupied: {
                        let all = Hyprland.workspaces;
                        for (let i = 0; i < all.values.length; i++) {
                            if (all.values[i].id === wsId)
                                return all.values[i].lastIpcObject?.windows > 0;
                        }
                        return false;
                    }

                    Text {
                        anchors.centerIn: parent

                        property string icon: root.iconMap[wsItem.wsName] ?? ""
                        property bool hasIcon: icon !== ""

                        text: hasIcon ? icon : wsItem.wsName
                        color: wsItem.isActive
                            ? Shared.Theme.crust
                            : wsItem.isOccupied
                                ? Shared.Theme.text
                                : Shared.Theme.overlay0
                        font.pixelSize: Shared.Theme.fontLarge
                        font.family: hasIcon ? Shared.Theme.iconFont : Shared.Theme.fontFamily
                        font.bold: !hasIcon && wsItem.isActive

                        Behavior on color {
                            ColorAnimation { duration: Shared.Theme.animFast }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace name:" + wsItem.wsName)
                    }
                }
            }
        }
    }
}
