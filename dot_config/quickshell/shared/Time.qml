pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property string clock: Qt.formatDateTime(systemClock.date, Config.clockFormat)
    readonly property string clockSeconds: Qt.formatDateTime(systemClock.date, Config.clockSecondsFormat)
    readonly property date date: systemClock.date

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }
}
