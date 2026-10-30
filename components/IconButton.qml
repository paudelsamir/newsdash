import QtQuick
import qs.Commons
import qs.Ui

Rectangle {
    id: root

    property PaletteBase pt: PaletteBase { }

    property string glyph: ""
    property string tip: ""
    property bool busy: false
    property bool active: false
    property real size: pt.s(30)
    signal clicked()

    width: size
    height: size
    radius: pt.s(8)
    color: active ? pt.alpha(pt.accent, 0.16)
                  : (mouse.containsMouse ? pt.fillHover : pt.fill)
    border.width: 1
    border.color: active ? pt.alpha(pt.accent, 0.4)
                         : pt.alpha(pt.fg, 0.08)

    Behavior on color { ColorAnimation { duration: pt.durFast } }

    Text {
        id: glyphText
        textFormat: Text.PlainText
        anchors.centerIn: parent
        text: root.glyph
        color: root.active ? pt.accent : pt.secondary
        font.family: pt.glyphFont
        font.pixelSize: pt.body

        RotationAnimator on rotation {
            running: root.busy
            from: 0
            to: 360
            duration: Style.duration(900)
            loops: Animation.Infinite
            onRunningChanged: if (!running) glyphText.rotation = 0
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    PanelToolTip {
        visible: mouse.containsMouse && root.tip !== ""
        text: root.tip
        fontFamily: pt.font
    }
}
