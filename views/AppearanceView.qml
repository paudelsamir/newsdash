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

    readonly property var prefs: host ? host.prefs : ({})
    readonly property real fontScale: {
        var n = prefs && prefs.fontScale != null ? Number(prefs.fontScale) : 1
        if (!isFinite(n)) n = 1
        return Math.max(0.9, Math.min(1.25, n))
    }
    readonly property int maxHome: {
        var n = prefs && prefs.maxHome != null ? parseInt(String(prefs.maxHome), 10) : 60
        if (!isFinite(n)) n = 60
        return Math.max(20, Math.min(120, n))
    }

    implicitHeight: col.height

    Column {
        id: col
        width: parent.width
        spacing: pt.s(12)

        C.SubHeader {
            width: parent.width
            kicker: "READER"
            title: "Appearance"
            detail: "Panel glass, type size, and how long Home stays."
            onBack: root.back()
        }

        C.SectionHeader { label: "Panel" }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            Column {
                width: parent.width
                spacing: 0
                C.SettingRow {
                    width: parent.width
                    title: "Frosted glass"
                    detail: "Translucent sheet behind the panel."
                    onActivated: if (host) host.setPref("frosted", !(prefs.frosted !== false))
                    C.ToggleSwitch {
                        checked: prefs.frosted !== false
                        onToggled: function(v) { if (host) host.setPref("frosted", v) }
                    }
                }
            }
        }

        C.SectionHeader { label: "Bar capsule" }

        C.Card {
            width: parent.width
            padding: pt.s(12)
            C.SegmentedSlider {
                width: parent.width
                title: "Tone"
                detail: "Set the visual character of the capsule without changing its behavior."
                value: host ? String(host.setting("barTone", "adaptive")) : "adaptive"
                options: [
                    { key: "adaptive", label: "Adaptive" },
                    { key: "accent", label: "Accent" },
                    { key: "quiet", label: "Quiet" },
                    { key: "light", label: "Light" }
                ]
                onSelected: function(key) { if (host) host.setSetting("barTone", key) }
            }
        }

        C.Card {
            width: parent.width
            padding: pt.s(12)
            C.SegmentedSlider {
                width: parent.width
                title: "Density"
                detail: "Choose how much space the capsule occupies in the bar."
                value: host ? String(host.setting("barDensity", "regular")) : "regular"
                options: [
                    { key: "compact", label: "Compact" },
                    { key: "regular", label: "Regular" }
                ]
                onSelected: function(key) { if (host) host.setSetting("barDensity", key) }
            }
        }

        C.SectionHeader { label: "Type" }

        C.Card {
            width: parent.width
            padding: pt.s(12)
            C.SegmentedSlider {
                width: parent.width
                title: "Size"
                detail: "Applies to the panel, not the bar capsule."
                value: root.fontScale <= 0.95 ? "0.9" : (root.fontScale >= 1.15 ? "1.2" : "1")
                options: [
                    { key: "0.9", label: "Small" },
                    { key: "1", label: "Regular" },
                    { key: "1.2", label: "Large" }
                ]
                onSelected: function(key) { if (host) host.setPref("fontScale", Number(key)) }
            }
        }

        C.Card {
            width: parent.width
            padding: pt.s(12)
            C.ValueSlider {
                width: parent.width
                title: "Stories on Home"
                detail: "Cap the list so the panel stays snappy."
                suffix: "max"
                from: 20
                to: 120
                stepSize: 10
                value: root.maxHome
                onReleased: function(v) { if (host) host.setPref("maxHome", Math.round(v)) }
            }
        }
    }
}
