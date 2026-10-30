import QtQuick
import qs.Commons

Rectangle {
    id: root

    property PaletteBase pt: PaletteBase { }

    property alias text: input.text
    property string placeholder: "Search headlines"
    signal accepted()
    signal textEdited()

    height: pt.s(36)
    radius: pt.s(10)
    color: pt.fill
    border.width: 1
    border.color: input.activeFocus ? pt.alpha(pt.accent, 0.45) : pt.alpha(pt.fg, 0.08)

    Behavior on border.color { ColorAnimation { duration: pt.dur } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: pt.s(12)
        anchors.rightMargin: pt.s(12)
        spacing: pt.s(8)

        Text {
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: "\uf002"
            color: pt.tertiary
            font.family: pt.glyphFont
            font.pixelSize: pt.callout
        }

        TextInput {
            id: input
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - pt.s(28)
            color: pt.fg
            font.family: pt.font
            font.pixelSize: pt.body
            clip: true
            selectByMouse: true
            onAccepted: root.accepted()
            onTextChanged: root.textEdited()

            Text {
                anchors.fill: parent
                textFormat: Text.PlainText
                text: root.placeholder
                color: pt.tertiary
                font: input.font
                visible: !input.text && !input.activeFocus
            }
        }
    }
}
