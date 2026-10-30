import QtQuick
import qs.Commons
import "." as C

// Horizontal chip slider for categories or sources.
Item {
    id: root

    property PaletteBase pt: PaletteBase { }

    property string title: ""
    property string activeId: "all"
    property var items: []
    property var feeds: items
    signal selected(string id)

    implicitHeight: col.implicitHeight
    width: parent ? parent.width : 200

    Column {
        id: col
        width: parent.width
        spacing: pt.s(6)

        Row {
            visible: root.title !== ""
            width: parent.width
            spacing: pt.s(8)

            Text {
                textFormat: Text.PlainText
                anchors.verticalCenter: parent.verticalCenter
                text: root.title.toUpperCase()
                color: pt.tertiary
                font.family: pt.font
                font.pixelSize: pt.footnote
                font.weight: Font.DemiBold
                font.letterSpacing: 1.0
            }

        }

        Flickable {
            width: parent.width
            height: pt.s(36)
            contentWidth: chipRow.implicitWidth
            flickableDirection: Flickable.HorizontalFlick
            clip: true
            interactive: chipRow.implicitWidth > parent.width
            boundsBehavior: Flickable.StopAtBounds

            Row {
                id: chipRow
                spacing: pt.s(6)
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: root.feeds

                    C.Chip {
                        label: modelData.name || modelData.label || modelData.id
                        active: root.activeId === modelData.id
                        compact: true
                        onClicked: root.selected(modelData.id)
                    }
                }
            }
        }
    }
}