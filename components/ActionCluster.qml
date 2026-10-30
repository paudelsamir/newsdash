import QtQuick

Item {
    id: root

    property PaletteBase pt: PaletteBase { }
    property int unread: 0
    property bool busy: false

    signal refreshClicked()
    signal randomNewsClicked()
    signal randomWritingClicked()
    signal readAllClicked()

    implicitWidth: actions.implicitWidth
    implicitHeight: column.implicitHeight

    Column {
        id: column
        width: parent.width
        spacing: pt.s(4)

        Text {
            width: parent.width
            textFormat: Text.PlainText
            text: root.unread > 0 ? root.unread + (root.unread === 1 ? " unread" : " unread") : "caught up"
            horizontalAlignment: Text.AlignRight
            color: root.unread > 0 ? pt.accent : pt.tertiary
            font.family: pt.font
            font.pixelSize: pt.footnote
            font.weight: Font.DemiBold
        }

        Row {
            id: actions
            spacing: pt.s(6)
            anchors.right: parent.right

            Column {
                spacing: pt.s(2)
                IconButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    glyph: "\uf021"
                    busy: root.busy
                    onClicked: root.refreshClicked()
                }
                Text {
                    textFormat: Text.PlainText
                    text: "Refresh"
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.s(8)
                }
            }
            Column {
                spacing: pt.s(2)
                IconButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    glyph: "\uf1ea"
                    onClicked: root.randomNewsClicked()
                }
                Text {
                    textFormat: Text.PlainText
                    text: "Random news"
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.s(8)
                }
            }
            Column {
                spacing: pt.s(2)
                IconButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    glyph: "\uf02d"
                    onClicked: root.randomWritingClicked()
                }
                Text {
                    textFormat: Text.PlainText
                    text: "Random writing"
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.s(8)
                }
            }
            Column {
                spacing: pt.s(2)
                IconButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    glyph: "\uf058"
                    onClicked: root.readAllClicked()
                }
                Text {
                    textFormat: Text.PlainText
                    text: "Read all"
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.s(8)
                }
            }
        }
    }
}