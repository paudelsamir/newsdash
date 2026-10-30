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

    function hostSet(key, value) { if (host && host.setSetting) host.setSetting(key, value) }

    readonly property int refreshMins: {
        var n = host ? parseInt(String(host.setting ? host.setting("refreshMinutes", "15") : "15"), 10) : 15
        if (!isFinite(n)) n = 15
        return Math.max(5, Math.min(60, n))
    }

    implicitHeight: col.height

    Column {
        id: col
        width: parent.width
        spacing: pt.s(12)

        C.SubHeader {
            width: parent.width
            kicker: "SYSTEM"
            title: "Bar widget"
            detail: "How the capsule looks on the Omarchy bar, and how often feeds refresh."
            onBack: root.back()
        }

        C.SectionHeader { label: "Capsule" }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            Column {
                width: parent.width
                spacing: 0
                C.SettingRow {
                    width: parent.width
                    title: "Show in bar"
                    detail: "Keep the capsule visible without changing your feeds."
                    onActivated: root.hostSet("barVisible", !(host && String(host.setting("barVisible", "true")) !== "false"))
                    C.ToggleSwitch {
                        checked: !(host && String(host.setting("barVisible", "true")) === "false")
                        onToggled: function(v) { root.hostSet("barVisible", v) }
                    }
                }
                C.Hairline { inset: pt.s(12) }
                C.SettingRow {
                    width: parent.width
                    title: "Bar badge"
                    detail: "Choose the unread count source shown in the capsule."
                    interactive: false
                    C.SegmentedSlider {
                        width: pt.s(190)
                        value: host ? String(host.badgeMode) : "always"
                        options: [
                            { key: "icon", label: "Icon" },
                            { key: "dot", label: "Dot" },
                            { key: "when-unread", label: "Unread" },
                            { key: "always", label: "Always" },
                            { key: "foryou", label: "For You" }
                        ]
                        onSelected: function(key) { root.hostSet("showCount", key) }
                    }
                }
            }
        }

        C.Card {
            width: parent.width
            C.SegmentedSlider {
                width: parent.width
                title: "Capsule size"
                detail: "Choose a tighter or more relaxed footprint in the bar."
                value: host ? String(host.setting("barDensity", "regular")) : "regular"
                options: [
                    { key: "compact", label: "Compact" },
                    { key: "regular", label: "Regular" }
                ]
                onSelected: function(key) { root.hostSet("barDensity", key) }
            }
        }

        C.Card {
            width: parent.width
            C.SegmentedSlider {
                width: parent.width
                title: "Capsule tone"
                detail: "Adaptive follows unread state; accent stays expressive; quiet recedes; light uses a white capsule."
                value: host ? String(host.setting("barTone", "adaptive")) : "adaptive"
                options: [
                    { key: "adaptive", label: "Adaptive" },
                    { key: "accent", label: "Accent" },
                    { key: "quiet", label: "Quiet" },
                    { key: "light", label: "Light" }
                ]
                onSelected: function(key) { root.hostSet("barTone", key) }
            }
        }

        C.SectionHeader { label: "Refresh" }

        C.Card {
            width: parent.width
            padding: pt.s(12)
            C.ValueSlider {
                width: parent.width
                title: "Refresh every"
                detail: "Background fetch while the shell is running."
                suffix: "min"
                from: 5
                to: 60
                stepSize: 5
                value: root.refreshMins
                onMoved: function(v) { root.hostSet("refreshMinutes", Math.round(v)) }
            }
        }

        C.Card {
            width: parent.width
            padding: pt.s(12)
            Column {
                width: parent.width
                spacing: pt.s(8)
                Text {
                    width: parent.width
                    textFormat: Text.PlainText
                    text: "Left click opens the panel · Right-click refreshes · Middle click marks all read."
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    wrapMode: Text.WordWrap
                }
                Text {
                    width: parent.width
                    textFormat: Text.PlainText
                    text: "Global shortcut: SUPER + SHIFT + N → omarchy-shell toggle paudelsamir.newsdash"
                    color: pt.quaternary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
