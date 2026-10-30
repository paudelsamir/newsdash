import QtQuick
import qs.Commons
import "../components"
import "../components" as C
import "../catalog.js" as Catalog

Item {
    id: root
    property PaletteBase pt: PaletteBase {
        scale: host && host.prefs && host.prefs.fontScale ? host.prefs.fontScale : 1
    }

    property var host: null
    signal back()
    width: parent ? parent.width : 320
    implicitHeight: col.height

    readonly property string regionId: host && host.prefs && host.prefs.regionId ? host.prefs.regionId : ""

    readonly property var regionChips: {
        var out = []
        for (var i = 0; i < Catalog.REGIONS.length; i++) {
            var r = Catalog.REGIONS[i]
            out.push({ id: r.id, name: r.name })
        }
        return out
    }

    Column {
        id: col
        width: parent.width
        spacing: pt.s(12)

        C.SubHeader {
            width: parent.width
            kicker: "LIBRARY"
            title: "Personalization"
            detail: "Region, interests, and which sources power For you."
            onBack: root.back()
        }

        C.SectionHeader { label: "Region" }

        C.CategorySlider {
            width: parent.width
            activeId: root.regionId
            feeds: root.regionChips
            onSelected: function(id) { if (host) host.applyRegion(id, false) }
        }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            C.SettingRow {
                width: parent.width
                title: "Add regional sources"
                detail: "Pull this region’s local feeds into your list."
                onActivated: if (host && root.regionId) host.applyRegion(root.regionId, true)
            }
        }

        C.SectionHeader { label: "Interests" }

        Flow {
            width: parent.width
            spacing: pt.s(6)
            Repeater {
                model: Catalog.CATEGORIES
                C.Chip {
                    label: modelData.label
                    active: host && host.interests && host.interests.indexOf(modelData.id) >= 0
                    compact: true
                    onClicked: if (host) host.toggleInterest(modelData.id)
                }
            }
        }

        C.SectionHeader { label: "Followed sources" }

        Column {
            width: parent.width
            spacing: pt.s(4)
            Repeater {
                model: host ? host.feeds : []
                C.Card {
                    width: parent.width
                    padding: pt.s(4)
                    interactive: false
                    C.SettingRow {
                        width: parent.width
                        interactive: false
                        title: modelData.name
                        detail: modelData.category || "feed"
                        C.ToggleSwitch {
                            checked: host && host.followed && host.followed.indexOf(modelData.id) >= 0
                            onToggled: function(v) { if (host) host.setFollowed(modelData.id, v) }
                        }
                    }
                }
            }
            }
    }
}
