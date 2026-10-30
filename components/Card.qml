import QtQuick
import qs.Commons

// Soft surface card used throughout the panel.
Item {
    id: root

    property PaletteBase pt: PaletteBase { }

    property real padding: pt.s(14)
    property real radius: pt.s(12)
    property bool interactive: false
    property bool dimmed: false
    property string tone: "neutral" // neutral | accent | good | danger

    readonly property bool hovered: hover.hovered
    readonly property color toneColor: tone === "accent" ? pt.accent
                                     : tone === "good" ? pt.good
                                     : tone === "danger" ? pt.danger
                                     : pt.fg

    default property alias content: body.data

    signal activated()
    signal secondaryActivated()

    implicitWidth: 0
    implicitHeight: body.implicitHeight + padding * 2
    opacity: dimmed && !hovered ? 0.62 : 1

    Behavior on opacity { NumberAnimation { duration: pt.dur } }

    Rectangle {
        id: surface
        anchors.fill: parent
        radius: root.radius
        color: root.interactive && root.hovered ? pt.fillHover : pt.fill
        border.width: 1
        border.color: root.tone === "neutral"
            ? pt.alpha(pt.fg, root.interactive && root.hovered ? 0.16 : 0.07)
            : pt.alpha(root.toneColor, 0.35)

        Behavior on color { ColorAnimation { duration: pt.durFast } }
        Behavior on border.color { ColorAnimation { duration: pt.durFast } }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            visible: root.tone !== "neutral"
            color: pt.alpha(root.toneColor, 0.08)
        }
    }

    HoverHandler {
        id: hover
        enabled: root.interactive
        cursorShape: Qt.PointingHandCursor
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.interactive
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) root.secondaryActivated()
            else root.activated()
        }
    }

    Column {
        id: body
        x: root.padding
        y: root.padding
        width: root.width - root.padding * 2
        spacing: pt.s(8)
    }
}
