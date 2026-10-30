import QtQuick
import qs.Commons
import "." as C

Item {
    id: root

    property PaletteBase pt: PaletteBase { }
    property string label: ""
    property string activeId: "all"
    property var items: []
    property real labelWidth: pt.s(70)

    signal selected(string id)

    width: parent ? parent.width : 300
    height: pt.s(34)

    Text {
        width: root.labelWidth
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: root.label.toUpperCase()
        color: pt.tertiary
        font.family: pt.font
        font.pixelSize: pt.footnote
        font.weight: Font.DemiBold
        font.letterSpacing: 0.8
    }

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: root.labelWidth + pt.s(8)
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: pt.s(30)
        radius: pt.s(8)
        color: pt.alpha(pt.fg, 0.045)
        border.width: 1
        border.color: pt.alpha(pt.fg, 0.07)

        Flickable {
            id: scroller
            anchors.fill: parent
            anchors.margins: pt.s(3)
            contentWidth: rail.implicitWidth
            flickableDirection: Flickable.HorizontalFlick
            clip: true
            interactive: contentWidth > width
            boundsBehavior: Flickable.StopAtBounds

            Row {
                id: rail
                spacing: pt.s(4)
                height: parent.height

                Repeater {
                    model: root.items

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