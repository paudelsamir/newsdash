import QtQuick
import qs.Commons

Text {
    id: root
    property PaletteBase pt: PaletteBase { }

    property string label: ""
    textFormat: Text.PlainText
    text: root.label.toUpperCase()
    color: pt.tertiary
    font.family: pt.font
    font.pixelSize: pt.footnote
    font.weight: Font.DemiBold
    font.letterSpacing: 1.1
}
