import QtQuick
import qs.Commons

// Compact settings line: title + detail, trailing control parked next to the
// text instead of shoved to the far edge of a stretched row.
Item {
    id: root

    property PaletteBase pt: PaletteBase { }

    property string title: ""
    property string detail: ""
    property bool showChevron: false
    property bool interactive: true
    default property alias trailing: trail.data

    signal activated()

    implicitHeight: Math.max(pt.s(44), row.implicitHeight + pt.s(12))
    implicitWidth: parent ? parent.width : 200
    height: implicitHeight
    width: parent ? parent.width : implicitWidth

    Rectangle {
        anchors.fill: parent
        color: mouse.containsMouse && root.interactive ? pt.fillHover : "transparent"
        radius: pt.s(8)
        Behavior on color { ColorAnimation { duration: pt.durFast } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
        z: -1
    }

    Row {
        id: row
        anchors.fill: parent
        anchors.leftMargin: pt.s(10)
        anchors.rightMargin: pt.s(10)
        spacing: pt.s(8)

        Column {
            id: col
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(pt.s(80), parent.width - trail.width - chevron.width - parent.spacing * ((trail.width > 0 ? 1 : 0) + (root.showChevron ? 1 : 0)))
            spacing: pt.s(2)

            Text {
                width: parent.width
                textFormat: Text.PlainText
                text: root.title
                color: pt.label
                font.family: pt.font
                font.pixelSize: pt.body
                font.weight: Font.Medium
                elide: Text.ElideRight
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
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        Item {
            id: trail
            anchors.verticalCenter: parent.verticalCenter
            width: children.length ? Math.max(childrenRect.width, children[0] ? children[0].width : 0) : 0
            height: children.length ? Math.max(childrenRect.height, children[0] ? children[0].height : 0) : 0
        }

        Text {
            id: chevron
            visible: root.showChevron
            width: visible ? implicitWidth : 0
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: "\uf054"
            color: pt.quaternary
            font.family: pt.glyphFont
            font.pixelSize: pt.footnote
        }
    }
}
