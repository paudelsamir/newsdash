import QtQuick
import qs.Commons

Rectangle {
    id: root
    property PaletteBase pt: PaletteBase { }

    property real inset: 0
    height: 1
    color: pt.separator
    x: inset
    width: parent ? parent.width - inset * 2 : 0
}
