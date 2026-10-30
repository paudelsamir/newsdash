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
            title: "Keyboard"
            detail: "Shortcuts while the panel is focused."
            onBack: root.back()
        }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            Column {
                width: parent.width
                spacing: 0

                Repeater {
                    model: [
                        { keys: "1 – 4", action: "Home · For you · Saved · Settings" },
                        { keys: "h / l", action: "Previous / next page" },
                        { keys: "r", action: "Refresh feeds" },
                        { keys: "m", action: "Mark visible as read" },
                        { keys: "o", action: "Open top story" },
                        { keys: "s", action: "Save / unsave top story" },
                        { keys: "u", action: "Undo last mark-read" },
                        { keys: "Esc", action: "Back or close panel" }
                    ]

                    Column {
                        width: parent.width
                        C.Hairline {
                            visible: index > 0
                            inset: pt.s(12)
                        }
                        C.SettingRow {
                            width: parent.width
                            interactive: false
                            title: modelData.action
                            detail: modelData.keys
                        }
                    }
                }
            }
        }

        Text {
            width: parent.width
            textFormat: Text.PlainText
            text: "Bind a global shortcut in Hyprland, e.g.\no.bind(\"SUPER + SHIFT + N\", \"News\", \"omarchy-shell toggle paudelsamir.newsdash\")"
            color: pt.quaternary
            font.family: pt.font
            font.pixelSize: pt.footnote
            wrapMode: Text.WordWrap
        }
    }
}
