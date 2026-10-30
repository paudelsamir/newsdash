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
    property string subView: "" // "" | sources | personalization | blocked | reading | appearance | alerts | keyboard | bar | data

    signal openSub(string key)
    signal back()

    readonly property int feedCount: host && host.feeds ? host.feeds.length : 0
    readonly property int followedCount: host && host.followed ? host.followed.length : 0

    implicitHeight: mainCol.visible ? mainCol.height : (subLoader.item ? subLoader.item.implicitHeight : 0)

    Column {
        id: mainCol
        width: parent.width
        spacing: pt.s(14)
        visible: root.subView === ""

        Column {
            spacing: pt.s(2)
            Text {
                textFormat: Text.PlainText
                text: "SETTINGS"
                color: pt.tertiary
                font.family: pt.font
                font.pixelSize: pt.footnote
                font.weight: Font.DemiBold
                font.letterSpacing: 1.0
            }
            Text {
                textFormat: Text.PlainText
                text: "Settings"
                color: pt.fg
                font.family: pt.font
                font.pixelSize: pt.s(24)
                font.weight: Font.Medium
            }
            Text {
                width: root.width
                textFormat: Text.PlainText
                text: "Sources, reading, alerts, and the bar capsule."
                color: pt.tertiary
                font.family: pt.font
                font.pixelSize: pt.footnote
            }
        }

        C.SectionHeader { label: "Library" }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            Column {
                width: parent.width
                spacing: 0

                C.SettingRow {
                    width: parent.width
                    title: "Sources and feeds"
                    detail: feedCount + " on · add, remove, or silence any of them"
                    showChevron: true
                    onActivated: root.openSub("sources")
                }
                C.Hairline { inset: pt.s(12) }
                C.SettingRow {
                    width: parent.width
                    title: "Personalization"
                    detail: followedCount + " followed · country and interests"
                    showChevron: true
                    onActivated: root.openSub("personalization")
                }
                C.Hairline { inset: pt.s(12) }
                C.SettingRow {
                    width: parent.width
                    title: "Blocked topics"
                    detail: "Hide phrases. Surface what is repeating."
                    showChevron: true
                    onActivated: root.openSub("blocked")
                }
            }
        }

        C.SectionHeader { label: "Reader" }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            Column {
                width: parent.width
                spacing: 0

                C.SettingRow {
                    width: parent.width
                    title: "Reading"
                    detail: "Density, headlines, stories per feed"
                    showChevron: true
                    onActivated: root.openSub("reading")
                }
                C.Hairline { inset: pt.s(12) }
                C.SettingRow {
                    width: parent.width
                    title: "Appearance"
                    detail: "Glass, type size, Home length"
                    showChevron: true
                    onActivated: root.openSub("appearance")
                }
                C.Hairline { inset: pt.s(12) }
                C.SettingRow {
                    width: parent.width
                    title: "Alerts and briefing"
                    detail: "Local news, quiet hours, daily note"
                    showChevron: true
                    onActivated: root.openSub("alerts")
                }
            }
        }

        C.SectionHeader { label: "System" }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            Column {
                width: parent.width
                spacing: 0

                C.SettingRow {
                    width: parent.width
                    title: "Keyboard"
                    detail: "Move, open, save, follow"
                    showChevron: true
                    onActivated: root.openSub("keyboard")
                }
                C.Hairline { inset: pt.s(12) }
                C.SettingRow {
                    width: parent.width
                    title: "Omarchy bar"
                    detail: "Capsule, unread count, refresh cadence"
                    showChevron: true
                    onActivated: root.openSub("bar")
                }
                C.Hairline { inset: pt.s(12) }
                C.SettingRow {
                    width: parent.width
                    title: "Data"
                    detail: "OPML import and export, start over"
                    showChevron: true
                    onActivated: root.openSub("data")
                }
            }
        }

        Text {
            width: parent.width
            textFormat: Text.PlainText
            text: "Saved stories, follows, and blocks stay on this machine under ~/.local/state/newsdash/."
            color: pt.quaternary
            font.family: pt.font
            font.pixelSize: pt.footnote
            wrapMode: Text.WordWrap
        }
    }

    Loader {
        id: subLoader
        width: parent.width
        active: root.subView !== ""
        source: {
            if (root.subView === "sources") return Qt.resolvedUrl("../views/SourcesView.qml")
            if (root.subView === "personalization") return Qt.resolvedUrl("../views/PersonalizationView.qml")
            if (root.subView === "blocked") return Qt.resolvedUrl("../views/BlockedView.qml")
            if (root.subView === "reading") return Qt.resolvedUrl("../views/ReadingView.qml")
            if (root.subView === "appearance") return Qt.resolvedUrl("../views/AppearanceView.qml")
            if (root.subView === "alerts") return Qt.resolvedUrl("../views/AlertsView.qml")
            if (root.subView === "keyboard") return Qt.resolvedUrl("../views/KeyboardView.qml")
            if (root.subView === "bar") return Qt.resolvedUrl("../views/BarView.qml")
            if (root.subView === "data") return Qt.resolvedUrl("../views/DataView.qml")
            return ""
        }
        onLoaded: {
            if (item) {
                item.host = root.host
                if (item.back) item.back.connect(function() { root.back() })
            }
        }
    }
}
