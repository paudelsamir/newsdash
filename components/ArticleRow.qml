import QtQuick
import qs.Commons
import "../newsEngine.js" as Engine

// Minimal story line: source · age, then the title. No numbers, no serif, no tint.
Item {
    id: root
    property PaletteBase pt: PaletteBase { }

    property var article: null
    property bool dense: false
    property bool saved: false
    property bool isRead: false
    property double clock: Date.now()

    signal openRequested()
    signal saveRequested()

    readonly property string titleText: article ? article.title : ""
    readonly property string sourceText: article ? article.source : ""
    readonly property string ageText: article ? Engine.timeAgo(article.published, clock) : ""

    implicitHeight: inner.implicitHeight + pt.s(dense ? 10 : 14)
    height: implicitHeight

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(m) {
            if (m.button === Qt.RightButton) root.saveRequested()
            else root.openRequested()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: pt.s(8)
        color: mouse.containsMouse ? pt.fillHover : "transparent"
        Behavior on color { ColorAnimation { duration: pt.durFast } }
    }

    Row {
        id: inner
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: pt.s(8)
        anchors.rightMargin: pt.s(4)
        spacing: pt.s(8)

        Column {
            width: Math.max(pt.s(40), parent.width - bookmark.width - parent.spacing)
            spacing: pt.s(2)

            Text {
                width: parent.width
                textFormat: Text.PlainText
                text: root.sourceText + (root.ageText !== "" ? "  ·  " + root.ageText : "")
                color: pt.tertiary
                font.family: pt.font
                font.pixelSize: pt.footnote
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                width: parent.width
                textFormat: Text.PlainText
                text: root.titleText
                color: pt.fg
                font.family: pt.font
                font.pixelSize: root.dense ? pt.body : pt.callout
                font.weight: Font.Normal
                wrapMode: Text.WordWrap
                maximumLineCount: root.dense ? 2 : 3
                elide: Text.ElideRight
                lineHeight: 1.2
            }
        }

        Text {
            id: bookmark
            anchors.verticalCenter: parent.verticalCenter
            visible: mouse.containsMouse || root.saved
            width: visible ? implicitWidth : 0
            textFormat: Text.PlainText
            text: root.saved ? "\uf02e" : "\uf097"
            color: pt.secondary
            font.family: pt.glyphFont
            font.pixelSize: pt.body

            MouseArea {
                anchors.fill: parent
                anchors.margins: -pt.s(8)
                cursorShape: Qt.PointingHandCursor
                onClicked: root.saveRequested()
            }
        }
    }
}
