import QtQuick
import qs.Commons

Rectangle {
    id: root
    property PaletteBase pt: PaletteBase { }

    property bool checked: false
    signal toggled(bool value)

    width: pt.s(40)
    height: pt.s(22)
    radius: height / 2
    color: checked ? pt.accent : pt.alpha(pt.fg, 0.15)
    Behavior on color { ColorAnimation { duration: pt.durFast } }

    Rectangle {
        width: pt.s(16)
        height: pt.s(16)
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: checked ? parent.width - width - pt.s(3) : pt.s(3)
        color: pt.bg
        Behavior on x { NumberAnimation { duration: pt.durFast; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: pt.durFast } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
