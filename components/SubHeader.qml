import QtQuick
import qs.Commons
import "." as C

Item {
    id: root
    property PaletteBase pt: PaletteBase { }

    property string title: ""
    property string kicker: ""
    property string detail: ""
    signal back()

    implicitHeight: col.implicitHeight
    width: parent ? parent.width : 200

    Column {
        id: col
        width: parent.width
        spacing: pt.s(8)

        Row {
            spacing: pt.s(8)
            C.IconButton {
                glyph: "\uf053"
                tip: "Back"
                onClicked: root.back()
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: pt.s(1)
                Text {
                    visible: root.kicker !== ""
                    textFormat: Text.PlainText
                    text: root.kicker
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.0
                }
                Text {
                    textFormat: Text.PlainText
                    text: root.title
                    color: pt.fg
                    font.family: pt.font
                    font.pixelSize: pt.title3
                    font.weight: Font.Medium
                }
            }
        }

        Text {
            visible: root.detail !== ""
            width: parent.width
            textFormat: Text.PlainText
            text: root.detail
            color: pt.tertiary
            font.family: pt.font
            font.pixelSize: pt.footnote
            wrapMode: Text.WordWrap
        }
    }
}
