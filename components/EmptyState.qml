import QtQuick
import qs.Commons

Column {
    id: root
    property PaletteBase pt: PaletteBase { }

    property string glyph: "\uf1ea"
    property string title: "Nothing here yet"
    property string detail: ""
    spacing: pt.s(8)
    width: parent ? parent.width : 200

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.PlainText
        text: root.glyph
        color: pt.quaternary
        font.family: pt.glyphFont
        font.pixelSize: pt.s(28)
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.85
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.PlainText
        text: root.title
        color: pt.secondary
        font.family: pt.font
        font.pixelSize: pt.body
        font.weight: Font.Medium
        wrapMode: Text.WordWrap
    }

    Text {
        visible: root.detail !== ""
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.85
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.PlainText
        text: root.detail
        color: pt.tertiary
        font.family: pt.font
        font.pixelSize: pt.footnote
        wrapMode: Text.WordWrap
    }
}
