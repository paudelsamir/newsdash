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

    Column {
        id: col
        width: parent.width
        spacing: pt.s(12)

        C.SubHeader {
            width: parent.width
            kicker: "SYSTEM"
            title: "Data"
            detail: "OPML import and export. Everything stays in ~/.local/state/newsdash/."
            onBack: root.back()
        }

        C.SectionHeader { label: "Feeds" }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            Column {
                width: parent.width
                spacing: 0

                C.SettingRow {
                    width: parent.width
                    title: "Copy OPML"
                    detail: "All current feeds, as an OPML outline."
                    onActivated: if (host) host.copyOpml()
                }
                C.Hairline { inset: pt.s(12) }
                C.SettingRow {
                    width: parent.width
                    title: "Import from clipboard"
                    detail: "Paste OPML, then tap here."
                    onActivated: if (host) host.importOpmlClipboard()
                }
            }
        }

        C.SectionHeader { label: "This machine" }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            C.SettingRow {
                width: parent.width
                title: "Start over"
                detail: "Clear sources, saved stories, and run setup again."
                onActivated: if (host) host.resetSetup()
            }
        }
    }
}
