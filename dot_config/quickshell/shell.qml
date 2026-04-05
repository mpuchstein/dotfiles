//@ pragma UseQApplication

import Quickshell
import "notifications"
import "osd"
import "lock"

ShellRoot {
    NotificationDaemon { id: notifDaemon }
    Bar { notifModel: notifDaemon.trackedNotifications; notifDaemon: notifDaemon }
    Osd {}
    IdleScreen { id: idleScreen }
}
