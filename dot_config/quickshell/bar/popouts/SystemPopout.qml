import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import "../../shared" as Shared

Item {
    id: root

    implicitWidth: Shared.Theme.popoutWidth
    implicitHeight: Math.min(flickable.contentHeight + Shared.Theme.popoutPadding * 2, Screen.height - 32)

    PopoutBackground { anchors.fill: parent }

    // --- State ---
    readonly property int historySize: 30
    property var cpuHistory: []
    property var memHistory: []
    property var gpuHistory: []

    function pushHistory(arr, val) {
        let a = arr.slice();
        a.push(val);
        if (a.length > historySize) a.shift();
        return a;
    }

    property real cpuVal: 0
    property string memText: "--"
    property real memVal: 0
    property string tempText: "--"
    property int tempVal: 0
    property string gpuText: "--"
    property real gpuUsage: 0
    property int gpuTemp: 0
    property string nvmeTempText: "--"
    property int nvmeTempVal: 0
    property string diskRootText: "--"
    property real diskRootVal: 0
    property string diskDataText: "--"
    property real diskDataVal: 0
    property string updatesText: ""
    property string updatesClass: ""
    property string alhpText: ""
    property string alhpClass: ""
    property string networkIp: "--"
    property string networkIface: "--"
    property bool idleActive: false
    property var panelWindow: null
    property string audioDrawer: ""  // "" = closed, "sink" or "source"

    function thresholdColor(val, warn, crit) {
        if (val >= crit) return Shared.Theme.danger;
        if (val >= warn) return Shared.Theme.warning;
        return Shared.Theme.success;
    }

    function tempColor(t) {
        if (t >= 85) return Shared.Theme.danger;
        if (t >= 70) return Shared.Theme.warning;
        return Shared.Theme.success;
    }

    MouseArea { anchors.fill: parent }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: Shared.Theme.popoutPadding
        contentHeight: col.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: col
        width: flickable.width
        spacing: 6

        // ─── UPDATES ─────────────────────────

        Loader {
            Layout.fillWidth: true
            active: root.updatesClass === "pending" || root.updatesClass === "many"
            visible: active
            sourceComponent: Rectangle {
                implicitHeight: updRow.implicitHeight + 14
                radius: Shared.Theme.radiusSmall
                color: Shared.Theme.surface0

                RowLayout {
                    id: updRow
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10
                    Text { text: "\u{f0ab7}"; color: Shared.Theme.warning; font.pixelSize: 14; font.family: Shared.Theme.iconFont }
                    Text { text: root.updatesText + " updates available"; color: Shared.Theme.text; font.pixelSize: Shared.Theme.fontSize; font.family: Shared.Theme.fontFamily; Layout.fillWidth: true }
                    Text { visible: root.alhpText !== ""; text: "ALHP " + root.alhpText; color: Shared.Theme.overlay0; font.pixelSize: Shared.Theme.fontSize; font.family: Shared.Theme.fontFamily }
                }
            }
        }

        Loader {
            Layout.fillWidth: true
            active: root.updatesClass !== "pending" && root.updatesClass !== "many" && root.updatesClass !== ""
            visible: active
            sourceComponent: RowLayout {
                spacing: 10
                Text { text: "\u{f05e0}"; color: Shared.Theme.success; font.pixelSize: 14; font.family: Shared.Theme.iconFont }
                Text { text: "System up to date"; color: Shared.Theme.overlay0; font.pixelSize: Shared.Theme.fontSize; font.family: Shared.Theme.fontFamily }
            }
        }

        // ─── separator ───
        Rectangle { Layout.fillWidth: true; height: 1; color: Shared.Theme.surface0; Layout.topMargin: 4; Layout.bottomMargin: 4 }

        // ─── STORAGE & PERFORMANCE ───────────

        MetricBar { label: Shared.Config.diskMount1Label; value: root.diskRootText; fill: root.diskRootVal; barColor: thresholdColor(root.diskRootVal * 100, 70, 90); valueColor: thresholdColor(root.diskRootVal * 100, 70, 90) }
        MetricBar { label: Shared.Config.diskMount2Label; value: root.diskDataText; fill: root.diskDataVal; barColor: thresholdColor(root.diskDataVal * 100, 70, 90); valueColor: thresholdColor(root.diskDataVal * 100, 70, 90) }

        Item { implicitHeight: 2 }

        MetricBar {
            label: "CPU"
            value: root.cpuVal.toFixed(0) + "%"
            fill: root.cpuVal / 100
            barColor: thresholdColor(root.cpuVal, 50, 80)
            valueColor: thresholdColor(root.cpuVal, 50, 80)
            suffix: root.tempText
            suffixColor: tempColor(root.tempVal)
            history: root.cpuHistory
        }

        MetricBar {
            label: "Mem"
            value: root.memText
            fill: root.memVal
            barColor: thresholdColor(root.memVal * 100, 60, 85)
            valueColor: thresholdColor(root.memVal * 100, 60, 85)
            history: root.memHistory
        }

        MetricBar {
            label: "GPU"
            value: root.gpuText
            fill: root.gpuUsage / 100
            barColor: thresholdColor(root.gpuUsage, 50, 80)
            valueColor: thresholdColor(root.gpuUsage, 50, 80)
            history: root.gpuHistory
        }

        MetricBar {
            label: "NVMe"
            value: root.nvmeTempText
            fill: root.nvmeTempVal / 100
            barColor: tempColor(root.nvmeTempVal)
            valueColor: tempColor(root.nvmeTempVal)
        }

        // ─── separator ───
        Rectangle { Layout.fillWidth: true; height: 1; color: Shared.Theme.surface0; Layout.topMargin: 4; Layout.bottomMargin: 4 }

        // ─── AUDIO ───────────────────────────

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            VolumeSlider {
                Layout.fillWidth: true
                audio: Pipewire.defaultAudioSink?.audio ?? null
                icon: (!audio || audio.muted) ? "\u{f057f}" : "\u{f057e}"
                label: "Out"
                accentColor: Shared.Theme.sky
                drawerActive: root.audioDrawer === "sink"
                onDrawerToggled: root.audioDrawer = root.audioDrawer === "sink" ? "" : "sink"
            }

            VolumeSlider {
                Layout.fillWidth: true
                audio: Pipewire.defaultAudioSource?.audio ?? null
                icon: (!audio || audio.muted) ? "\u{f036d}" : "\u{f036c}"
                label: "Mic"
                accentColor: Shared.Theme.pink
                drawerActive: root.audioDrawer === "source"
                onDrawerToggled: root.audioDrawer = root.audioDrawer === "source" ? "" : "source"
            }
        }

        // Device drawer
        Loader {
            Layout.fillWidth: true
            active: root.audioDrawer !== ""
            visible: active
            sourceComponent: ColumnLayout {
                spacing: 3

                Repeater {
                    model: Pipewire.nodes

                    Rectangle {
                        id: devItem
                        required property var modelData

                        readonly property bool isSinkDrawer: root.audioDrawer === "sink"
                        readonly property bool matchesFilter: modelData.audio && !modelData.isStream
                            && modelData.isSink === isSinkDrawer
                        readonly property bool isDefault: isSinkDrawer
                            ? Pipewire.defaultAudioSink === modelData
                            : Pipewire.defaultAudioSource === modelData

                        visible: matchesFilter
                        Layout.fillWidth: true
                        implicitHeight: matchesFilter ? 28 : 0
                        radius: Shared.Theme.radiusSmall
                        color: devMouse.containsMouse ? Shared.Theme.surface1 : (isDefault ? Shared.Theme.surface0 : "transparent")

                        Behavior on color { ColorAnimation { duration: Shared.Theme.animFast } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 6

                            Text {
                                text: devItem.isDefault ? "\u{f012c}" : "\u{f0765}"
                                color: devItem.isDefault ? (devItem.isSinkDrawer ? Shared.Theme.sky : Shared.Theme.pink) : Shared.Theme.overlay0
                                font.pixelSize: 12
                                font.family: Shared.Theme.iconFont
                            }
                            Text {
                                text: devItem.modelData.description || devItem.modelData.name
                                color: devItem.isDefault ? Shared.Theme.text : Shared.Theme.subtext0
                                font.pixelSize: Shared.Theme.fontSmall
                                font.family: Shared.Theme.fontFamily
                                font.bold: devItem.isDefault
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: devMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (devItem.isSinkDrawer)
                                    Pipewire.preferredDefaultAudioSink = devItem.modelData;
                                else
                                    Pipewire.preferredDefaultAudioSource = devItem.modelData;
                                root.audioDrawer = "";
                            }
                        }
                    }
                }
            }
        }

        // ─── separator ───
        Rectangle { Layout.fillWidth: true; height: 1; color: Shared.Theme.surface0; Layout.topMargin: 4; Layout.bottomMargin: 4 }

        // ─── NETWORK ─────────────────────────

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "\u{f0bf0}"; color: Shared.Theme.overlay0; font.pixelSize: 14; font.family: Shared.Theme.iconFont }
            Text { text: root.networkIface; color: Shared.Theme.overlay0; font.pixelSize: Shared.Theme.fontSize; font.family: Shared.Theme.fontFamily }
            Item { Layout.fillWidth: true }
            Text { text: root.networkIp; color: Shared.Theme.text; font.pixelSize: Shared.Theme.fontSize; font.family: Shared.Theme.fontFamily; font.bold: true }
        }

        // ─── separator ───
        Rectangle { Layout.fillWidth: true; height: 1; color: Shared.Theme.surface0; Layout.topMargin: 4; Layout.bottomMargin: 4 }

        // ─── SYSTRAY ─────────────────────────

        Flow {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: SystemTray.items

                Rectangle {
                    id: trayItem
                    required property var modelData

                    visible: modelData.status !== Status.Passive
                    width: 32
                    height: 32
                    radius: Shared.Theme.radiusSmall
                    color: trayMouse.containsMouse ? Shared.Theme.surface1 : "transparent"

                    Behavior on color { ColorAnimation { duration: Shared.Theme.animFast } }

                    IconImage {
                        anchors.centerIn: parent
                        source: trayItem.modelData.icon
                        implicitSize: 22
                    }

                    // Tooltip — positioned above icon, clamped to popout width
                    Rectangle {
                        id: tooltip
                        visible: trayMouse.containsMouse && tipText.text !== ""
                        width: Math.min(tipText.implicitWidth + 12, Shared.Theme.popoutWidth - Shared.Theme.popoutPadding * 2)
                        height: tipText.implicitHeight + 8
                        radius: 6
                        color: Shared.Theme.surface0
                        z: 10

                        // Position above the icon, clamp horizontally within the popout
                        y: -height - 4
                        x: {
                            let centered = (trayItem.width - width) / 2;
                            let globalX = trayItem.mapToItem(col, centered, 0).x;
                            let maxX = col.width - width;
                            let clampedGlobalX = Math.max(0, Math.min(globalX, maxX));
                            return centered + (clampedGlobalX - globalX);
                        }

                        Text {
                            id: tipText
                            anchors.centerIn: parent
                            width: parent.width - 12
                            text: trayItem.modelData.tooltipTitle || trayItem.modelData.title || ""
                            color: Shared.Theme.text
                            font.pixelSize: Shared.Theme.fontSmall
                            font.family: Shared.Theme.fontFamily
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    MouseArea {
                        id: trayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                        onClicked: event => {
                            let item = trayItem.modelData;
                            if (event.button === Qt.RightButton || item.onlyMenu) {
                                if (item.hasMenu && root.panelWindow) {
                                    let pos = trayItem.mapToItem(null, trayItem.width / 2, trayItem.height / 2);
                                    item.display(root.panelWindow, pos.x, pos.y);
                                }
                            } else if (event.button === Qt.MiddleButton) {
                                item.secondaryActivate();
                            } else {
                                item.activate();
                            }
                        }

                        onWheel: event => {
                            trayItem.modelData.scroll(event.angleDelta.y, false);
                        }
                    }
                }
            }
        }

        // ─── separator ───
        Rectangle { Layout.fillWidth: true; height: 1; color: Shared.Theme.surface0; Layout.topMargin: 6; Layout.bottomMargin: 6 }

        // ─── ACTIONS ─────────────────────────

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            ActionIcon {
                icon: "\u{f1436}"
                label: "Idle"
                iconColor: root.idleActive ? Shared.Theme.green : Shared.Theme.overlay0
                onActivated: {
                    if (root.idleActive) idleKill.running = true;
                    else idleStart.running = true;
                    root.idleActive = !root.idleActive;
                }
            }

            ActionIcon {
                icon: "\u{f033e}"
                label: "Lock"
                iconColor: Shared.Theme.subtext0
                onActivated: { Shared.PopoutState.close(); lockProc.running = true; }
            }

            Item { Layout.fillWidth: true }

            HoldAction {
                icon: "\u{f0425}"
                label: "Logout"
                iconColor: Shared.Theme.subtext0
                holdColor: Shared.Theme.green
                onConfirmed: { Shared.PopoutState.close(); logoutProc.running = true; }
            }

            HoldAction {
                icon: "\u{f0709}"
                label: "Reboot"
                iconColor: Shared.Theme.peach
                holdColor: Shared.Theme.peach
                onConfirmed: { Shared.PopoutState.close(); rebootProc.running = true; }
            }

            HoldAction {
                icon: "\u{f0425}"
                label: "Off"
                iconColor: Shared.Theme.danger
                holdColor: Shared.Theme.danger
                onConfirmed: { Shared.PopoutState.close(); offProc.running = true; }
            }
        }
    } // ColumnLayout
    } // Flickable

    // ═══════════════════════════════════════
    // COMPONENTS
    // ═══════════════════════════════════════

    component Sparkline: Canvas {
        id: spark
        property var history: []
        property color lineColor: Shared.Theme.overlay0

        onHistoryChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            let ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            if (history.length < 2) return;
            ctx.strokeStyle = Qt.alpha(lineColor, 0.5);
            ctx.lineWidth = 1;
            ctx.beginPath();
            let step = width / (root.historySize - 1);
            let offset = root.historySize - history.length;
            for (let i = 0; i < history.length; i++) {
                let x = (offset + i) * step;
                let y = height - history[i] * height;
                if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
            }
            ctx.stroke();
        }
    }

    component MetricBar: RowLayout {
        property string label
        property string value
        property real fill: 0
        property color barColor: Shared.Theme.green
        property color valueColor: Shared.Theme.text
        property string suffix: ""
        property color suffixColor: Shared.Theme.overlay0
        property var history: null

        Layout.fillWidth: true
        implicitHeight: 22
        spacing: 10

        Text {
            text: parent.label
            color: Shared.Theme.overlay0
            font.pixelSize: Shared.Theme.fontSize
            font.family: Shared.Theme.fontFamily
            Layout.preferredWidth: 40
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 10
            radius: 5
            color: Shared.Theme.surface0

            Sparkline {
                anchors.fill: parent
                visible: history && history.length > 1
                history: parent.parent.history ?? []
                lineColor: barColor
            }

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * Math.min(1, Math.max(0, fill))
                radius: 5
                color: barColor
                opacity: Shared.Theme.opacityFill
                Behavior on width { NumberAnimation { duration: Shared.Theme.animFast; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: Shared.Theme.animNormal } }
            }
        }

        Text {
            text: parent.value
            color: parent.valueColor
            font.pixelSize: Shared.Theme.fontSize
            font.family: Shared.Theme.fontFamily
            font.bold: true
            horizontalAlignment: Text.AlignRight
            Layout.preferredWidth: 86
        }

        Loader {
            active: parent.suffix !== ""
            visible: active
            sourceComponent: Text {
                text: suffix
                color: suffixColor
                font.pixelSize: Shared.Theme.fontSize
                font.family: Shared.Theme.fontFamily
                font.bold: true
            }
        }
    }

    component VolumeSlider: Rectangle {
        id: vs
        property var audio: null
        property string icon
        property string label
        property color accentColor
        property bool drawerActive: false
        signal drawerToggled()

        property real vol: 0
        property bool muted: audio?.muted ?? false

        function updateVol() {
            if (audio && !isNaN(audio.volume) && audio.volume >= 0)
                vol = audio.volume;
        }
        onAudioChanged: { updateVol(); bindRetry.retries = 0; bindRetry.running = true; }
        Connections {
            target: vs.audio
            function onVolumeChanged() { vs.updateVol(); }
        }

        // Retry binding pickup after async PwObjectTracker re-bind
        Timer {
            id: bindRetry
            interval: 300
            running: false
            repeat: true
            property int retries: 0
            onTriggered: {
                vs.updateVol();
                retries++;
                if (vs.vol > 0 || retries >= 5) running = false;
            }
        }

        Layout.fillWidth: true
        implicitHeight: 36
        radius: Shared.Theme.radiusSmall
        color: drawerActive ? Qt.alpha(accentColor, Shared.Theme.opacityLight) : Shared.Theme.surface0
        border.width: drawerActive ? 1 : 0
        border.color: Qt.alpha(accentColor, Shared.Theme.opacityMedium)
        opacity: muted ? 0.45 : 1.0
        clip: true

        Behavior on opacity { NumberAnimation { duration: Shared.Theme.animFast } }
        Behavior on color { ColorAnimation { duration: Shared.Theme.animFast } }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: vs.muted ? 0 : parent.width * Math.min(1, vs.vol)
            radius: Shared.Theme.radiusSmall
            color: Qt.alpha(vs.accentColor, Shared.Theme.opacityMedium)
            Behavior on width { NumberAnimation { duration: Shared.Theme.animFast; easing.type: Easing.OutCubic } }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8
            Text { text: vs.icon; color: vs.accentColor; font.pixelSize: 14; font.family: Shared.Theme.iconFont }
            Text { text: vs.label; color: vs.accentColor; font.pixelSize: Shared.Theme.fontSize; font.family: Shared.Theme.fontFamily }
            Item { Layout.fillWidth: true }
            Text {
                text: vs.muted ? "Muted" : Math.round(vs.vol * 100) + "%"
                color: vs.muted ? Shared.Theme.overlay0 : Shared.Theme.text
                font.pixelSize: Shared.Theme.fontSize
                font.family: Shared.Theme.fontFamily
                font.bold: !vs.muted
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            property bool dragging: false
            property real startX: 0
            property int pressedBtn: Qt.NoButton
            onClicked: event => {
                if (event.button === Qt.MiddleButton) { pavuProc.running = true; return; }
                if (event.button === Qt.RightButton) { if (vs.audio) vs.audio.muted = !vs.audio.muted; return; }
                if (!dragging) vs.drawerToggled();
            }
            onPressed: event => { dragging = false; startX = event.x; pressedBtn = event.button; }
            onPositionChanged: event => {
                if (pressed && pressedBtn === Qt.LeftButton) {
                    if (Math.abs(event.x - startX) > 5) dragging = true;
                    if (dragging && vs.audio) vs.audio.volume = Math.max(0, Math.min(1, event.x / vs.width));
                }
            }
            onWheel: event => {
                if (!vs.audio) return;
                let step = 0.05;
                if (event.angleDelta.y > 0) vs.audio.volume = Math.min(1.0, vs.vol + step);
                else vs.audio.volume = Math.max(0.0, vs.vol - step);
            }
        }
    }

    component ActionIcon: Rectangle {
        property string icon
        property string label
        property color iconColor
        signal activated()

        implicitWidth: actCol.implicitWidth + 16
        implicitHeight: actCol.implicitHeight + 14
        radius: Shared.Theme.radiusSmall
        color: actMouse.containsMouse ? Shared.Theme.surface1 : "transparent"
        border.width: actMouse.containsMouse ? 1 : 0
        border.color: Shared.Theme.surface2

        Behavior on color { ColorAnimation { duration: Shared.Theme.animFast } }

        Column {
            id: actCol
            anchors.centerIn: parent
            spacing: 3
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: icon; color: iconColor; font.pixelSize: 18; font.family: Shared.Theme.iconFont }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: label; color: Shared.Theme.overlay0; font.pixelSize: Shared.Theme.fontSmall; font.family: Shared.Theme.fontFamily }
        }

        MouseArea { id: actMouse; anchors.fill: parent; hoverEnabled: true; onClicked: parent.activated() }
    }

    component HoldAction: Rectangle {
        id: ha
        property string icon
        property string label
        property color iconColor
        property color holdColor: Shared.Theme.red
        signal confirmed()

        readonly property real holdDuration: 800
        property real holdProgress: 0
        property bool holding: false

        implicitWidth: haCol.implicitWidth + 16
        implicitHeight: haCol.implicitHeight + 14
        radius: Shared.Theme.radiusSmall
        color: haMouse.containsMouse ? Shared.Theme.surface1 : "transparent"
        border.width: haMouse.containsMouse || holding ? 1 : 0
        border.color: holding ? Qt.alpha(holdColor, Shared.Theme.opacityStrong) : Shared.Theme.surface2

        Behavior on color { ColorAnimation { duration: Shared.Theme.animFast } }

        // Fill overlay
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * ha.holdProgress
            radius: Shared.Theme.radiusSmall
            color: Qt.alpha(ha.holdColor, Shared.Theme.opacityLight)
        }

        Column {
            id: haCol
            anchors.centerIn: parent
            spacing: 3
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: ha.icon; color: ha.holding ? ha.holdColor : ha.iconColor; font.pixelSize: 18; font.family: Shared.Theme.iconFont }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: ha.holding ? "Hold…" : ha.label; color: ha.holding ? ha.holdColor : Shared.Theme.overlay0; font.pixelSize: Shared.Theme.fontSmall; font.family: Shared.Theme.fontFamily }
        }

        Timer {
            id: holdTimer
            interval: 16
            running: ha.holding
            repeat: true
            onTriggered: {
                ha.holdProgress += interval / ha.holdDuration;
                if (ha.holdProgress >= 1.0) {
                    ha.holding = false;
                    ha.holdProgress = 0;
                    ha.confirmed();
                }
            }
        }

        MouseArea {
            id: haMouse
            anchors.fill: parent
            hoverEnabled: true
            onPressed: { ha.holding = true; ha.holdProgress = 0; }
            onReleased: { ha.holding = false; ha.holdProgress = 0; }
            onCanceled: { ha.holding = false; ha.holdProgress = 0; }
        }
    }

    // ═══════════════════════════════════════
    // DATA FETCHING
    // ═══════════════════════════════════════

    property real prevCpuActive: -1
    property real prevCpuTotal: -1
    Process { id: cpuProc; command: ["sh", "-c", "awk '/^cpu / {print $2+$4, $2+$4+$5}' /proc/stat"]; stdout: StdioCollector {
        onStreamFinished: {
            let p = this.text.trim().split(" ");
            let active = parseFloat(p[0]), total = parseFloat(p[1]);
            if (!isNaN(active) && root.prevCpuTotal > 0) {
                let da = active - root.prevCpuActive;
                let dt = total - root.prevCpuTotal;
                if (dt > 0) { root.cpuVal = (da / dt) * 100; root.cpuHistory = root.pushHistory(root.cpuHistory, root.cpuVal / 100); }
            }
            root.prevCpuActive = active;
            root.prevCpuTotal = total;
        }
    }}

    Process { id: memProc; command: ["sh", "-c", "free -m | awk '/Mem:/ {printf \"%.1f/%.0fG %.4f\", $3/1024, $2/1024, $3/$2}'"]; stdout: StdioCollector {
        onStreamFinished: { let p = this.text.trim().split(" "); if (p.length >= 2) { root.memText = p[0]; root.memVal = parseFloat(p[1]) || 0; root.memHistory = root.pushHistory(root.memHistory, root.memVal); } }
    }}

    Process { id: tempProc; command: ["sh", "-c", "sensors 2>/dev/null | awk '/Tctl:|Tdie:|Package id 0:/ {gsub(/\\+|°C/,\"\",$2); printf \"%d\", $2; exit}'"]; stdout: StdioCollector {
        onStreamFinished: { let v = parseInt(this.text.trim()); if (!isNaN(v)) { root.tempVal = v; root.tempText = v + "°C"; } }
    }}

    Process { id: gpuProc; command: [Shared.Config.gpuScript]; stdout: StdioCollector {
        onStreamFinished: { try {
            let d = JSON.parse(this.text);
            let tt = d.tooltip || "";
            let lines = tt.split("\n");
            let usage = 0, temp = 0, power = 0;
            for (let i = 0; i < lines.length; i++) {
                let v = parseInt(lines[i].replace(/[^0-9]/g, ""));
                if (isNaN(v)) continue;
                if (lines[i].indexOf("Usage") >= 0) usage = v;
                else if (lines[i].indexOf("Temp") >= 0) temp = v;
                else if (lines[i].indexOf("Power") >= 0) power = v;
            }
            root.gpuUsage = usage; root.gpuTemp = temp;
            root.gpuText = usage + "% " + temp + "°C " + power + "W";
            root.gpuHistory = root.pushHistory(root.gpuHistory, usage / 100);
        } catch(e) {} }
    }}

    Process { id: nvmeTempProc; command: ["sh", "-c", "for d in /sys/class/hwmon/hwmon*; do if grep -q nvme \"$d/name\" 2>/dev/null; then awk '{printf \"%d\", $1/1000}' \"$d/temp1_input\" 2>/dev/null; break; fi; done"]; stdout: StdioCollector {
        onStreamFinished: { let v = parseInt(this.text.trim()); if (!isNaN(v) && v > 0) { root.nvmeTempVal = v; root.nvmeTempText = v + "°C"; } }
    }}

    Process { id: diskProc; command: ["sh", "-c",
        "df -h " + Shared.Config.diskMount1 + " --output=pcent,size 2>/dev/null | tail -1 && " +
        "df -h " + Shared.Config.diskMount2 + " --output=pcent,size 2>/dev/null | tail -1 && " +
        "df " + Shared.Config.diskMount1 + " --output=pcent 2>/dev/null | tail -1 && " +
        "df " + Shared.Config.diskMount2 + " --output=pcent 2>/dev/null | tail -1"
    ]; stdout: StdioCollector {
        onStreamFinished: {
            let lines = this.text.trim().split("\n");
            if (lines.length >= 1) root.diskRootText = lines[0].trim().replace(/\s+/g, " of ");
            if (lines.length >= 2) root.diskDataText = lines[1].trim().replace(/\s+/g, " of ");
            if (lines.length >= 3) root.diskRootVal = parseInt(lines[2]) / 100 || 0;
            if (lines.length >= 4) root.diskDataVal = parseInt(lines[3]) / 100 || 0;
        }
    }}

    Process { id: updateProc; command: ["bash", "-c", "set -o pipefail; checkupdates 2>/dev/null | wc -l; echo \":$?\""]; stdout: StdioCollector {
        onStreamFinished: {
            let text = this.text.trim();
            let exitMatch = text.match(/:(\d+)$/);
            let exit = exitMatch ? parseInt(exitMatch[1]) : 1;
            let n = parseInt(text);
            // checkupdates: 0 = updates available, 2 = no updates, anything else = error
            if (exit !== 0 && exit !== 2) return;  // error — keep previous state
            if (isNaN(n) || n === 0) { root.updatesText = ""; root.updatesClass = "uptodate"; }
            else if (n > 50) { root.updatesText = n.toString(); root.updatesClass = "many"; }
            else { root.updatesText = n.toString(); root.updatesClass = "pending"; }
        }
    }}

    Process { id: alhpProc; command: ["sh", "-c", "alhp.utils -j 2>/dev/null || echo '{}'"]; stdout: StdioCollector {
        onStreamFinished: {
            try {
                let d = JSON.parse(this.text);
                let total = d.total || 0;
                let stale = d.mirror_out_of_date || false;
                if (stale) { root.alhpText = "stale"; root.alhpClass = "stale"; }
                else if (total > 0) { root.alhpText = total.toString(); root.alhpClass = "bad"; }
                else { root.alhpText = ""; root.alhpClass = "good"; }
            } catch(e) { root.alhpText = "?"; root.alhpClass = "down"; }
        }
    }}

    Process { id: netProc; command: ["sh", "-c", "ip -4 -o addr show | grep -v '" + Shared.Config.netExcludePattern + "' | head -1 | awk '{split($4,a,\"/\"); print $2 \":\" a[1]}'"]; stdout: StdioCollector {
        onStreamFinished: { let l = this.text.trim(); if (l) { let p = l.split(":"); root.networkIface = p[0] || "--"; root.networkIp = p[1] || "--"; } else { root.networkIface = "Network"; root.networkIp = "Offline"; } }
    }}

    Process { id: pavuProc; command: ["pavucontrol"] }
    Process { id: idleProc; command: ["pgrep", "-x", Shared.Config.idleProcess]; stdout: StdioCollector { onStreamFinished: root.idleActive = this.text.trim().length > 0 } }
    Process { id: idleKill; command: ["killall", Shared.Config.idleProcess] }
    Process { id: idleStart; command: ["sh", "-c", "setsid " + Shared.Config.idleProcess + " > /dev/null 2>&1 &"] }
    Process { id: lockProc; command: [Shared.Config.lockCommand] }
    Process { id: logoutProc; command: Shared.Config.powerActions[1].command }
    Process { id: rebootProc; command: Shared.Config.powerActions[2].command }
    Process { id: offProc; command: Shared.Config.powerActions[3].command }

    function rerun(proc) { proc.running = false; proc.running = true; }
    Timer { interval: 5000; running: true; repeat: true; onTriggered: { rerun(cpuProc); rerun(memProc); rerun(tempProc); rerun(gpuProc); rerun(nvmeTempProc); rerun(idleProc); } }
    Timer { interval: 30000; running: true; repeat: true; onTriggered: { rerun(diskProc); rerun(netProc); } }
    Timer { interval: 300000; running: true; repeat: true; onTriggered: { rerun(updateProc); rerun(alhpProc); } }

    // Stagger initial launches to avoid 9 concurrent process spawns
    Component.onCompleted: {
        rerun(cpuProc); rerun(memProc); rerun(tempProc);
        staggerTimer.running = true;
    }
    Timer {
        id: staggerTimer
        interval: 200
        onTriggered: { rerun(gpuProc); rerun(nvmeTempProc); rerun(idleProc); rerun(diskProc); rerun(netProc); rerun(updateProc); rerun(alhpProc); }
    }
}
