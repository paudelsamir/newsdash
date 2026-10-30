import QtQuick
import qs.Commons

Rectangle {
    id: root
    property PaletteBase pt: PaletteBase { }

    property string label: ""
    property bool primary: false
    property bool compact: false
    signal clicked()

    height: compact ? pt.s(28) : pt.s(34)
    width: labelText.implicitWidth + pt.s(compact ? 20 : 28)
    radius: height / 2
    color: primary
        ? (mouse.containsMouse ? pt.alpha(pt.accent, 0.88) : pt.accent)
        : (mouse.containsMouse ? pt.fillHover : pt.alpha(pt.fg, 0.07))
    border.width: primary ? 0 : 1
    border.color: pt.alpha(pt.fg, 0.1)

    Text {
        id: labelText
        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: root.label
        color: primary ? pt.onAccent : pt.label
        font.family: pt.font
        font.pixelSize: pt.callout
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
