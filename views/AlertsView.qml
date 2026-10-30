import QtQuick
import qs.Commons
import "../components"
import "../components" as C

Item {
    id: root
    property PaletteBase pt: PaletteBase {
        scale: host && host.prefs && host.prefs.fontScale ? host.prefs.fontScale : 1
    }

    property var host: null
    signal back()
    width: parent ? parent.width : 320
    implicitHeight: col.height

    readonly property var prefs: host ? host.prefs : ({})
    readonly property int notifyAt: {
        var n = prefs && prefs.notifyAt != null ? parseInt(String(prefs.notifyAt), 10) : 5
        if (!isFinite(n)) n = 5
        return Math.max(1, Math.min(30, n))
    }

    Column {
        id: col
        width: parent.width
        spacing: pt.s(12)

        C.SubHeader {
            width: parent.width
            kicker: "READER"
            title: "Alerts and briefing"
            detail: "Quiet hours and desktop notifications."
            onBack: root.back()
        }

        C.SectionHeader { label: "Home" }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            Column {
                width: parent.width
                spacing: 0

                C.SettingRow {
                    width: parent.width
                    title: "Daily briefing"
                    detail: "A short highlight card at the top of Home."
                    onActivated: if (host) host.setPref("dailyBriefing", !prefs.dailyBriefing)
                    C.ToggleSwitch {
                        checked: !!prefs.dailyBriefing
                        onToggled: function(v) { if (host) host.setPref("dailyBriefing", v) }
                    }
                }
            }
        }

        C.SectionHeader { label: "Notifications" }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            Column {
                width: parent.width
                spacing: 0

                C.SettingRow {
                    width: parent.width
                    title: "Quiet hours"
                    detail: "No notifications from 22:00 to 07:00."
                    onActivated: if (host) host.setPref("quietHours", !prefs.quietHours)
                    C.ToggleSwitch {
                        checked: !!prefs.quietHours
                        onToggled: function(v) { if (host) host.setPref("quietHours", v) }
                    }
                }
                C.Hairline { inset: pt.s(12) }
                C.SettingRow {
                    width: parent.width
                    title: "Notify on unread"
                    detail: "Desktop notice after a refresh crosses the threshold."
                    onActivated: if (host) host.setPref("notifyUnread", !prefs.notifyUnread)
                    C.ToggleSwitch {
                        checked: !!prefs.notifyUnread
                        onToggled: function(v) { if (host) host.setPref("notifyUnread", v) }
                    }
                }
            }
        }

        C.Card {
            width: parent.width
            padding: pt.s(12)
            visible: !!prefs.notifyUnread
            C.ValueSlider {
                width: parent.width
                title: "Notify at"
                detail: "Unread count that triggers a notification."
                suffix: ""
                from: 1
                to: 30
                stepSize: 1
                value: root.notifyAt
                onReleased: function(v) { if (host) host.setPref("notifyAt", Math.round(v)) }
            }
        }
    }
}
