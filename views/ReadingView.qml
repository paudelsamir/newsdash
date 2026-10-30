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
    readonly property int perFeed: host ? host.perFeed : 20

    Column {
        id: col
        width: parent.width
        spacing: pt.s(12)

        C.SubHeader {
            width: parent.width
            kicker: "READER"
            title: "Reading"
            detail: "How the list is filtered and how many stories each source keeps."
            onBack: root.back()
        }

        C.SectionHeader { label: "List" }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            Column {
                width: parent.width
                spacing: 0

                C.SettingRow {
                    width: parent.width
                    title: "Unread only"
                    detail: "Hide stories you have already opened."
                    onActivated: if (host) host.setPref("hideRead", !prefs.hideRead)
                    C.ToggleSwitch {
                        checked: !!prefs.hideRead
                        onToggled: function(v) { if (host) host.setPref("hideRead", v) }
                    }
                }
                C.Hairline { inset: pt.s(12) }
                C.SettingRow {
                    width: parent.width
                    title: "Unread first"
                    detail: "Keep unread stories at the top of Home."
                    onActivated: if (host) host.setPref("unreadFirst", !prefs.unreadFirst)
                    C.ToggleSwitch {
                        checked: !!prefs.unreadFirst
                        onToggled: function(v) { if (host) host.setPref("unreadFirst", v) }
                    }
                }
                C.Hairline { inset: pt.s(12) }
                C.SettingRow {
                    width: parent.width
                    title: "Dense list"
                    detail: "Tighter spacing on Home and For you."
                    onActivated: if (host) host.setPref("dense", !prefs.dense)
                    C.ToggleSwitch {
                        checked: !!prefs.dense
                        onToggled: function(v) { if (host) host.setPref("dense", v) }
                    }
                }
                C.Hairline { inset: pt.s(12) }
                C.SettingRow {
                    width: parent.width
                    title: "Mark read on open"
                    detail: "Opening a story marks it read."
                    onActivated: if (host) host.setPref("markOnOpen", !(prefs.markOnOpen !== false))
                    C.ToggleSwitch {
                        checked: prefs.markOnOpen !== false
                        onToggled: function(v) { if (host) host.setPref("markOnOpen", v) }
                    }
                }
            }
        }

        C.SectionHeader { label: "Fetch" }

        C.Card {
            width: parent.width
            padding: pt.s(12)
            C.ValueSlider {
                width: parent.width
                title: "Stories per feed"
                detail: "How many headlines to keep from each source."
                suffix: ""
                from: 5
                to: 50
                stepSize: 5
                value: root.perFeed
                onReleased: function(v) {
                    if (host && host.setSetting) {
                        host.setSetting("perFeed", Math.round(v))
                        if (host.setupDone) host.refresh()
                    }
                }
            }
        }
    }
}
