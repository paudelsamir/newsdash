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

    function commitPhrase() {
        if (phrase.text.trim() && host) {
            host.addBlocked(phrase.text.trim())
            phrase.text = ""
        }
    }

    Column {
        id: col
        width: parent.width
        spacing: pt.s(12)

        C.SubHeader {
            width: parent.width
            kicker: "LIBRARY"
            title: "Blocked topics"
            detail: "Stories whose title or summary contain these phrases are hidden from Home and For you."
            onBack: root.back()
        }

        Row {
            width: parent.width
            spacing: pt.s(6)
            C.SearchField {
                id: phrase
                width: parent.width - addBtn.width - parent.spacing
                placeholder: "Add a phrase to block"
                onAccepted: root.commitPhrase()
            }
            C.PillButton {
                id: addBtn
                label: "Block"
                primary: true
                compact: true
                anchors.verticalCenter: parent.verticalCenter
                onClicked: root.commitPhrase()
            }
        }

        C.SectionHeader {
            visible: host && host.blocked && host.blocked.length > 0
            label: "Hidden phrases"
        }

        Column {
            width: parent.width
            spacing: pt.s(4)
            visible: host && host.blocked && host.blocked.length > 0

            Repeater {
                model: host ? host.blocked : []
                C.Card {
                    width: parent.width
                    padding: pt.s(10)
                    Row {
                        width: parent.width
                        spacing: pt.s(8)
                        Text {
                            width: parent.width - pt.s(36)
                            anchors.verticalCenter: parent.verticalCenter
                            textFormat: Text.PlainText
                            text: modelData
                            color: pt.fg
                            font.family: pt.font
                            font.pixelSize: pt.body
                            elide: Text.ElideRight
                        }
                        C.IconButton {
                            size: pt.s(28)
                            glyph: "\uf00d"
                            tip: "Remove"
                            onClicked: if (host) host.removeBlocked(modelData)
                        }
                    }
                }
            }
        }

        C.EmptyState {
            visible: !host || !host.blocked || host.blocked.length === 0
            width: parent.width
            glyph: "\uf05e"
            title: "No blocked phrases"
            detail: "Add words or topics you never want to see."
        }
    }
}
