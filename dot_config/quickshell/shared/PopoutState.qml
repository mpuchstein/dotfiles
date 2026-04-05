pragma Singleton

import Quickshell
import QtQuick

Singleton {
    property string active: ""
    property real triggerY: 0

    function toggle(name: string, y: real): void {
        if (active === name) {
            active = "";
        } else {
            active = name;
            triggerY = y;
        }
    }

    function close(): void {
        active = "";
    }
}
