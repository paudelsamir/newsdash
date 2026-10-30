import QtQuick
import qs.Commons

Rectangle {
    id: root

    property PaletteBase pt: PaletteBase { }

    property string label: ""
    property string count: ""
    property bool active: false
    property bool compact: false
    signal clicked()

    height: compact ? pt.s(24) : pt.s(28)
    width: row.implicitWidth + pt.s(compact ? 16 : 20)
    radius: height / 2
    color: active ? pt.alpha(pt.accent, 0.18)
                  : (mouse.containsMouse ? pt.fillHover : pt.fill)
    border.width: 1
    border.color: active ? pt.alpha(pt.accent, 0.45) : pt.alpha(pt.fg, 0.08)

    Behavior on color { ColorAnimation { duration: pt.durFast } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: pt.s(5)

        Text {
            textFormat: Text.PlainText
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.active ? pt.accent : pt.secondary
            font.family: pt.font
            font.pixelSize: pt.footnote
            font.weight: Font.Medium
        }

        Text {
            textFormat: Text.PlainText
            anchors.verticalCenter: parent.verticalCenter
            visible: root.count !== ""
            text: root.count
            color: root.active ? pt.accent : pt.tertiary
            font.family: pt.font
            font.pixelSize: pt.footnote
            font.features: ({ "tnum": 1 })
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
