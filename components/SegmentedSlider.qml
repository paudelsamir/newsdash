import QtQuick
import qs.Commons

// Discrete option slider: a compact pill with equal segments. Replaces a
// row of separate buttons for things like bar capsule style.
Item {
    id: root

    property PaletteBase pt: PaletteBase { }

    property string title: ""
    property string detail: ""
    property var options: [] // [{ key, label }]
    property string value: ""

    signal selected(string key)

    implicitHeight: col.implicitHeight
    implicitWidth: parent ? parent.width : 200
    width: parent ? parent.width : implicitWidth
    height: implicitHeight

    Column {
        id: col
        width: parent.width
        spacing: pt.s(6)

        Column {
            width: parent.width
            spacing: pt.s(1)
            visible: root.title !== "" || root.detail !== ""

            Text {
                visible: root.title !== ""
                width: parent.width
                textFormat: Text.PlainText
                text: root.title
                color: pt.label
                font.family: pt.font
                font.pixelSize: pt.body
                font.weight: Font.Medium
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

        Rectangle {
            id: track
            width: parent.width
            height: pt.s(32)
            radius: pt.s(8)
            color: pt.fill
            border.width: 1
            border.color: pt.alpha(pt.fg, 0.08)

            Row {
                id: segRow
                anchors.fill: parent
                anchors.margins: pt.s(3)
                spacing: pt.s(2)

                Repeater {
                    model: root.options

                    Item {
                        width: Math.max(pt.s(40), (segRow.width - Math.max(0, root.options.length - 1) * segRow.spacing) / Math.max(1, root.options.length))
                        height: segRow.height

                        readonly property bool active: String(root.value) === String(modelData.key)

                        Rectangle {
                            anchors.fill: parent
                            radius: pt.s(6)
                            color: parent.active ? pt.alpha(pt.accent, 0.22) : (segMouse.containsMouse ? pt.fillHover : "transparent")
                            border.width: parent.active ? 1 : 0
                            border.color: pt.alpha(pt.accent, 0.45)
                            Behavior on color { ColorAnimation { duration: pt.durFast } }
                        }

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - pt.s(6)
                            horizontalAlignment: Text.AlignHCenter
                            textFormat: Text.PlainText
                            text: modelData.label
                            color: parent.active ? pt.accent : pt.secondary
                            font.family: pt.font
                            font.pixelSize: pt.footnote
                            font.weight: parent.active ? Font.DemiBold : Font.Medium
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            id: segMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selected(modelData.key)
                        }
                    }
                }
            }
        }
    }
}
