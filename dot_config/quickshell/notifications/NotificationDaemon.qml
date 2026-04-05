import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../shared" as Shared

Scope {
    id: root

    // Expose for NC popout
    property alias trackedNotifications: server.trackedNotifications
    property bool dnd: false

    // Toast IDs currently showing as popups (capped to avoid overflow)
    readonly property int maxToasts: 4
    property var toastIds: []
    property var timestamps: ({})  // notification id → arrival epoch ms

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true;
            root.timestamps[notification.id] = Date.now();
            root.timestampsChanged();

            // Suppress toasts in DnD mode (still tracked for history)
            if (root.dnd) return;

            // Add to toast list, evict oldest if at capacity
            let ids = root.toastIds.slice();
            if (ids.length >= root.maxToasts) {
                let evicted = ids.shift();
                delete toastTimer.pending[evicted];
            }
            ids.push(notification.id);
            root.toastIds = ids;

            // Schedule toast removal (not notification removal)
            let timeout = notification.expireTimeout > 0 ? notification.expireTimeout * 1000 : 5000;
            if (notification.urgency !== NotificationUrgency.Critical) {
                toastTimer.createTimer(notification.id, timeout);
            }
        }
    }

    // Toast timer manager
    QtObject {
        id: toastTimer
        property var pending: ({})

        function createTimer(id, timeout) {
            pending[id] = Date.now() + timeout;
        }
    }

    Timer {
        interval: 500
        running: root.toastIds.length > 0
        repeat: true
        onTriggered: {
            let now = Date.now();
            let changed = false;
            let ids = root.toastIds.slice();

            for (let id in toastTimer.pending) {
                if (now >= toastTimer.pending[id]) {
                    let idx = ids.indexOf(parseInt(id));
                    if (idx >= 0) { ids.splice(idx, 1); changed = true; }
                    delete toastTimer.pending[id];
                }
            }

            if (changed) root.toastIds = ids;
        }
    }

    // Prune stale timestamps to prevent unbounded growth
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            let tracked = server.trackedNotifications;
            let live = new Set();
            for (let i = 0; i < tracked.values.length; i++)
                live.add(tracked.values[i].id);
            let ts = root.timestamps;
            let pruned = false;
            for (let id in ts) {
                if (!live.has(parseInt(id))) { delete ts[id]; pruned = true; }
            }
            if (pruned) root.timestampsChanged();
        }
    }

    // Toast popup window — shows only active toasts
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData
                WlrLayershell.namespace: "quickshell:notifications"
                surfaceFormat { opaque: false }

                visible: modelData.name === Shared.Config.monitor && root.toastIds.length > 0

                anchors {
                    top: true
                    right: true
                }

                exclusionMode: ExclusionMode.Ignore
                implicitWidth: 380
                implicitHeight: toastColumn.implicitHeight + 20
                color: "transparent"

                margins {
                    right: Shared.Theme.barWidth + 12
                    top: 8
                }

                ColumnLayout {
                    id: toastColumn
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 10
                    anchors.rightMargin: 10
                    width: 360
                    spacing: 8

                    Repeater {
                        model: server.trackedNotifications

                        Loader {
                            required property var modelData
                            active: root.toastIds.indexOf(modelData.id) >= 0
                            visible: active
                            Layout.fillWidth: true

                            sourceComponent: NotificationPopup {
                                notification: modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
