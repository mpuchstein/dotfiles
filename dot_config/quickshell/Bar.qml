import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import "shared" as Shared
import "bar" as BarComponents
import "bar/popouts" as Popouts

Scope {
    property var notifModel: null
    property var notifDaemon: null

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ]
    }

    property bool popoutOpen: Shared.PopoutState.active !== ""

    // ═══════════════════════════════════════
    // BAR — fixed width, never resizes
    // ═══════════════════════════════════════
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: barWindow
                required property var modelData
                screen: modelData

                // Screens sorted left→right by x position (negative x = leftmost)
                property var sortedScreens: {
                    let s = [];
                    for (let i = 0; i < Quickshell.screens.length; i++) s.push(Quickshell.screens[i]);
                    s.sort((a, b) => a.x - b.x);
                    return s;
                }

                visible: modelData.name === Shared.Config.monitor
                WlrLayershell.namespace: "quickshell:bar"
                surfaceFormat { opaque: !Shared.Theme.transparencyEnabled }

                anchors {
                    top: true
                    right: true
                    bottom: true
                }

                implicitWidth: Shared.Theme.barWidth
                exclusiveZone: Shared.Theme.barWidth
                color: Shared.Theme.barBackground

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: Shared.Theme.barPadding + 2
                    anchors.bottomMargin: Shared.Theme.barPadding + 2
                    anchors.leftMargin: Shared.Theme.barPadding
                    anchors.rightMargin: Shared.Theme.barPadding
                    spacing: Shared.Theme.spacing

                    // ── Top ──────────────────────────────
                    BarComponents.DateTimePill { id: datetimeBtn }

                    BarComponents.WeatherPill { id: weatherBtn }

                    // ── Center (workspaces) ───────────────
                    Item { Layout.fillHeight: true }

                    // Per-monitor workspace groups — sorted left→right by screen position
                    Repeater {
                        model: barWindow.sortedScreens.length

                        delegate: Column {
                            required property int index
                            spacing: Shared.Theme.spacing

                            Rectangle {
                                visible: index > 0
                                width: Shared.Theme.barInnerWidth
                                height: 1
                                color: Shared.Theme.overlay0
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            BarComponents.Workspaces {
                                monitorName: barWindow.sortedScreens[index].name
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // ── Bottom ────────────────────────────
                    BarComponents.GamemodePill {}

                    BarComponents.MediaPill { id: mediaBtn }

                    BarComponents.BarPill {
                        id: notifBtn
                        groupName: "notifications"
                        accentColor: Shared.Theme.mauve

                        property int count: notifModel ? notifModel.values.length : 0

                        content: [
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: notifDaemon?.dnd ? "\u{f009b}" : "\u{f0f3}"
                                color: notifDaemon?.dnd ? Shared.Theme.danger : Shared.Theme.mauve
                                font.pixelSize: Shared.Theme.fontLarge
                                font.family: Shared.Theme.iconFont
                            },
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                visible: notifBtn.count > 0
                                text: notifBtn.count.toString()
                                color: Shared.Theme.text
                                font.pixelSize: Shared.Theme.fontSmall
                                font.family: Shared.Theme.fontFamily
                                font.bold: true
                            }
                        ]
                    }

                    BarComponents.SystemPill { id: systemBtn }
                }
            }
        }
    }

    // ═══════════════════════════════════════
    // POPOUT WINDOW — separate overlay, only exists when open
    // ═══════════════════════════════════════
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: popoutWindow
                required property var modelData
                screen: modelData

                visible: modelData.name === Shared.Config.monitor && (popoutOpen || notifSlot.animating || mediaSlot.animating || weatherSlot.animating || datetimeSlot.animating || systemSlot.animating)
                WlrLayershell.namespace: "quickshell:popout"
                surfaceFormat { opaque: false }

                anchors {
                    top: true
                    right: true
                    bottom: true
                }

                implicitWidth: Shared.Theme.popoutWidth + 12
                exclusionMode: ExclusionMode.Ignore
                focusable: popoutOpen
                color: "transparent"

                margins {
                    right: Shared.Theme.barWidth
                }

                // Escape key = close
                Keys.onEscapePressed: Shared.PopoutState.close()

                // Click on empty area = close
                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: Shared.PopoutState.close()
                }

                // Popout slots
                Item {
                    id: popoutArea
                    anchors.fill: parent

                    PopoutSlot {
                        id: notifSlot
                        name: "notifications"
                        verticalAnchor: "bottom"
                        sourceComponent: Popouts.NotificationCenter { trackedNotifications: notifModel; daemon: notifDaemon }
                    }

                    PopoutSlot {
                        id: mediaSlot
                        name: "media"
                        verticalAnchor: "bottom"
                        sourceComponent: Popouts.MediaPopout {}
                    }

                    PopoutSlot {
                        id: weatherSlot
                        name: "weather"
                        verticalAnchor: "top"
                        sourceComponent: Popouts.WeatherPopout {}
                    }

                    PopoutSlot {
                        id: datetimeSlot
                        name: "datetime"
                        verticalAnchor: "top"
                        sourceComponent: Popouts.CalendarPopout {}
                    }

                    PopoutSlot {
                        id: systemSlot
                        name: "system"
                        verticalAnchor: "bottom"
                        sourceComponent: Popouts.SystemPopout { panelWindow: popoutWindow }
                    }
                }

                // PopoutSlot — anchored to triggering icon, MD3 animation
                component PopoutSlot: Item {
                    id: slot
                    required property string name
                    property alias sourceComponent: loader.sourceComponent
                    property string verticalAnchor: "center"  // "top" | "bottom" | "center"

                    readonly property bool isOpen: Shared.PopoutState.active === name
                    readonly property bool animating: fadeAnim.running || scaleAnim.running || slideAnim.running
                    readonly property real cardH: loader.item?.implicitHeight ?? 400
                    readonly property real cardW: loader.item?.implicitWidth ?? Shared.Theme.popoutWidth

                    readonly property real centerY: Math.max(16, Math.min(
                        popoutArea.height - cardH - 16,
                        (popoutArea.height - cardH) / 2
                    ))

                    anchors.right: parent.right
                    y: {
                        if (verticalAnchor === "top")
                            return Math.max(16, Shared.PopoutState.triggerY);
                        if (verticalAnchor === "bottom")
                            return Math.min(popoutArea.height - cardH - 16,
                                            Shared.PopoutState.triggerY - cardH);
                        return centerY;
                    }
                    width: cardW
                    height: cardH

                    visible: isOpen || animating

                    opacity: isOpen ? 1.0 : 0.0
                    scale: isOpen ? 1.0 : 0.97
                    transformOrigin: Item.Right
                    property real slideX: isOpen ? 0 : 8

                    Behavior on opacity {
                        NumberAnimation { id: fadeAnim; duration: 180; easing.type: Easing.OutCubic }
                    }
                    Behavior on scale {
                        NumberAnimation { id: scaleAnim; duration: 220; easing.type: Easing.OutCubic }
                    }
                    Behavior on slideX {
                        NumberAnimation { id: slideAnim; duration: 220; easing.type: Easing.OutCubic }
                    }

                    transform: Translate { x: slot.slideX }

                    Loader {
                        id: loader
                        active: slot.isOpen || slot.animating
                        width: slot.cardW
                        height: slot.cardH
                    }
                }
            }
        }
    }
}
