import QtQuick
import QtQuick.Layouts
import "../../shared" as Shared

Item {
    id: root

    implicitWidth: Shared.Theme.popoutWidth
    implicitHeight: col.implicitHeight + Shared.Theme.popoutPadding * 2

    PopoutBackground { anchors.fill: parent }

    property int viewMonth: new Date().getMonth()
    property int viewYear: new Date().getFullYear()
    property int todayDay: Shared.Time.date.getDate()
    property int todayMonth: Shared.Time.date.getMonth()
    property int todayYear: Shared.Time.date.getFullYear()

    readonly property bool isViewingToday: viewMonth === todayMonth && viewYear === todayYear

    function prevMonth() { if (viewMonth === 0) { viewMonth = 11; viewYear--; } else viewMonth--; }
    function nextMonth() { if (viewMonth === 11) { viewMonth = 0; viewYear++; } else viewMonth++; }
    function goToday() { viewMonth = todayMonth; viewYear = todayYear; }
    function daysInMonth(m, y) { return new Date(y, m + 1, 0).getDate(); }
    function firstDayOfWeek(m, y) {
        let d = new Date(y, m, 1).getDay();
        if (Shared.Config.weekStartsMonday)
            return d === 0 ? 6 : d - 1;
        return d;
    }

    MouseArea {
        anchors.fill: parent
        onWheel: event => {
            if (event.angleDelta.y > 0) root.prevMonth();
            else root.nextMonth();
        }
    }

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Shared.Theme.popoutPadding
        spacing: Shared.Theme.popoutSpacing

        Text {
            text: Shared.Time.clockSeconds
            color: Shared.Theme.text
            font.pixelSize: 28
            font.family: Shared.Theme.fontFamily
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 2
        }

        Text {
            text: Qt.formatDateTime(Shared.Time.date, Shared.Config.dateFormat)
            color: Shared.Theme.subtext0
            font.pixelSize: Shared.Theme.fontSize
            font.family: Shared.Theme.fontFamily
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            height: 1
            color: Shared.Theme.surface0
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "\u{f0141}"
                color: navPrev.containsMouse ? Shared.Theme.text : Shared.Theme.subtext0
                font.pixelSize: 16
                font.family: Shared.Theme.iconFont
                MouseArea { id: navPrev; anchors.fill: parent; hoverEnabled: true; onClicked: root.prevMonth() }
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: new Date(root.viewYear, root.viewMonth, 1).toLocaleDateString(Qt.locale(), "MMMM yyyy")
                color: Shared.Theme.text
                font.pixelSize: Shared.Theme.fontSize
                font.family: Shared.Theme.fontFamily
                font.bold: true
                MouseArea { anchors.fill: parent; onClicked: root.goToday() }
            }

            Rectangle {
                visible: !root.isViewingToday
                implicitWidth: todayLabel.implicitWidth + 10
                implicitHeight: 20
                radius: 10
                color: todayMouse.containsMouse ? Shared.Theme.surface1 : Shared.Theme.surface0
                Behavior on color { ColorAnimation { duration: 100 } }
                Text {
                    id: todayLabel
                    anchors.centerIn: parent
                    text: "Today"
                    color: Shared.Theme.blue
                    font.pixelSize: Shared.Theme.fontSmall
                    font.family: Shared.Theme.fontFamily
                }
                MouseArea { id: todayMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.goToday() }
            }

            Text {
                text: "\u{f0142}"
                color: navNext.containsMouse ? Shared.Theme.text : Shared.Theme.subtext0
                font.pixelSize: 16
                font.family: Shared.Theme.iconFont
                MouseArea { id: navNext; anchors.fill: parent; hoverEnabled: true; onClicked: root.nextMonth() }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Repeater {
                model: Shared.Config.dayHeaders
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Shared.Theme.overlay0
                    font.pixelSize: Shared.Theme.fontSmall
                    font.family: Shared.Theme.fontFamily
                }
            }
        }

        Grid {
            id: calGrid
            Layout.fillWidth: true
            columns: 7
            spacing: 0

            property int numDays: root.daysInMonth(root.viewMonth, root.viewYear)
            property int startDay: root.firstDayOfWeek(root.viewMonth, root.viewYear)

            Repeater {
                model: calGrid.startDay + calGrid.numDays + (7 - (calGrid.startDay + calGrid.numDays) % 7) % 7

                Item {
                    required property int index
                    property int day: index - calGrid.startDay + 1
                    property bool isValid: day >= 1 && day <= calGrid.numDays
                    property bool isToday: isValid && day === root.todayDay && root.viewMonth === root.todayMonth && root.viewYear === root.todayYear
                    property bool isWeekend: {
                        let col = index % 7;
                        if (Shared.Config.weekStartsMonday)
                            return col >= 5;  // Sa=5, Su=6
                        return col === 0 || col === 6;  // Su=0, Sa=6
                    }

                    width: calGrid.width / 7
                    height: 28

                    Rectangle {
                        anchors.centerIn: parent
                        width: 24; height: 24; radius: 12
                        color: parent.isToday ? Shared.Theme.blue : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: parent.isValid ? parent.day.toString() : ""
                        color: parent.isToday ? Shared.Theme.crust
                            : parent.isWeekend && parent.isValid ? Shared.Theme.overlay0
                            : parent.isValid ? Shared.Theme.text
                            : "transparent"
                        font.pixelSize: Shared.Theme.fontSmall
                        font.family: Shared.Theme.fontFamily
                        font.bold: parent.isToday
                    }
                }
            }
        }
    }
}
