import QtQuick
import qs.Commons

// A reusable grid tile: an optional header line (status dot, eyebrow label,
// right-aligned meta, plus a slot for hover actions) over free-form content.
//
//   DashboardCard {
//       eyebrow: "Ars Technica"; meta: "2h"; dot: true; interactive: true
//       onActivated: ...
//       Text { text: "Child content goes below the header" }
//   }
//
// Every colour comes from the shell theme, so the card follows light/dark
// switches without any per-theme code. Tones tint the fill and the border.
Item {
    id: root

    property string eyebrow: ""
    property string meta: ""
    property bool dot: false
    property string tone: "neutral"        // neutral | accent | good | danger
    property bool interactive: false
    property bool compact: false
    property bool dimmed: false
    property real padding: compact ? Theme.s(11) : Theme.s(14)

    readonly property bool hovered: hover.hovered
    readonly property color toneColor: tone === "accent" ? Theme.accent
                                     : tone === "good" ? Theme.good
                                     : tone === "danger" ? Theme.danger
                                     : Theme.fg

    default property alias content: body.data
    property alias actions: actionRow.data

    signal activated()
    signal secondaryActivated()

    implicitWidth: 0
    implicitHeight: column.implicitHeight + padding * 2
    opacity: dimmed && !hovered ? 0.62 : 1

    Behavior on opacity { NumberAnimation { duration: Theme.normal } }

    Rectangle {
        id: surface
        anchors.fill: parent
        radius: Theme.s(8)
        color: root.interactive && root.hovered ? Theme.fillHover : Theme.fill
        border.width: 1
        border.color: root.tone === "neutral"
            ? Theme.alpha(Theme.fg, root.interactive && root.hovered ? 0.18 : 0.08)
            : Theme.alpha(root.toneColor, 0.38)

        Behavior on color { ColorAnimation { duration: Theme.normal } }
        Behavior on border.color { ColorAnimation { duration: Theme.normal } }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            visible: root.tone !== "neutral"
            color: Theme.alpha(root.toneColor, 0.10)
        }
    }

    HoverHandler {
        id: hover
        enabled: root.interactive
        cursorShape: Qt.PointingHandCursor
    }

    // Sits under the content, so buttons placed in `actions` or the body win.
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
        id: column
        x: root.padding
        y: root.padding
        width: root.width - root.padding * 2
        spacing: root.compact ? Theme.s(6) : Theme.s(8)

        Item {
            id: header
            visible: root.eyebrow !== "" || root.meta !== "" || root.dot
            width: parent.width
            height: visible ? Math.max(headLeft.implicitHeight, rightRow.implicitHeight, Theme.s(14)) : 0

            Row {
                id: headLeft
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.s(6)

                Rectangle {
                    visible: root.dot
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.s(6)
                    height: width
                    radius: width / 2
                    color: Theme.accent
                }

                Text {
                    id: eyebrowText
                    textFormat: Text.PlainText
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, Math.max(0, header.width - rightRow.implicitWidth - (root.dot ? Theme.s(18) : Theme.s(10))))
                    text: root.eyebrow.toUpperCase()
                    color: root.tone === "neutral" ? Theme.tertiary : root.toneColor
                    font.family: Theme.font
                    font.pixelSize: Theme.footnote
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.0
                    elide: Text.ElideRight
                }
            }

            Row {
                id: rightRow
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.s(6)

                Row {
                    id: actionRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.s(4)
                }

                Text {
                    textFormat: Text.PlainText
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.meta !== ""
                    text: root.meta
                    color: Theme.tertiary
                    font.family: Theme.font
                    font.pixelSize: Theme.caption
                    font.features: ({ "tnum": 1 })
                }
            }
        }

        Column {
            id: body
            width: parent.width
            spacing: root.compact ? Theme.s(4) : Theme.s(6)
        }
    }
}
