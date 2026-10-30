import QtQuick
import qs.Commons

// Compact labeled slider: title + live value on one line, track full width
// underneath. Click or drag the track; wheel steps.
Item {
    id: root

    property PaletteBase pt: PaletteBase { }

    property string title: ""
    property string detail: ""
    property string suffix: ""
    property real from: 0
    property real to: 100
    property real stepSize: 1
    property real value: from
    property bool live: true
    property real liveValue: value
    property bool dragging: false

    signal moved(real value)
    signal released(real value)

    implicitHeight: col.implicitHeight
    implicitWidth: parent ? parent.width : 200
    width: parent ? parent.width : implicitWidth
    height: implicitHeight

    onValueChanged: if (!root.dragging) liveValue = value

    readonly property real range: Math.max(0.0001, to - from)
    readonly property real clamped: Math.max(from, Math.min(to, liveValue))
    readonly property real progress: (clamped - from) / range

    function snap(v) {
        var s = stepSize > 0 ? stepSize : 1
        var n = from + Math.round((v - from) / s) * s
        return Math.max(from, Math.min(to, n))
    }

    function setFromX(x) {
        var p = Math.max(0, Math.min(1, x / Math.max(1, track.width)))
        var next = root.snap(from + p * range)
        if (next === root.liveValue) return
        root.liveValue = next
        root.moved(next)
    }

    Column {
        id: col
        width: parent.width
        spacing: pt.s(6)

        Row {
            width: parent.width
            spacing: pt.s(8)

            Column {
                width: parent.width - valueLabel.width - parent.spacing
                spacing: pt.s(1)

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

            Text {
                id: valueLabel
                anchors.verticalCenter: parent.verticalCenter
                textFormat: Text.PlainText
                text: Math.round(root.clamped) + (root.suffix ? " " + root.suffix : "")
                color: pt.accent
                font.family: pt.font
                font.pixelSize: pt.body
                font.weight: Font.DemiBold
                font.features: ({ "tnum": 1 })
            }
        }

        Item {
            id: trackWrap
            width: parent.width
            height: pt.s(22)

            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: pt.s(4)
                radius: height / 2
                color: pt.alpha(pt.fg, 0.12)

                Rectangle {
                    height: parent.height
                    width: parent.width * root.progress
                    radius: parent.radius
                    color: pt.accent
                    Behavior on width {
                        enabled: !root.dragging
                        NumberAnimation { duration: pt.durFast; easing.type: Easing.OutCubic }
                    }
                }
            }

            Rectangle {
                id: knob
                width: pt.s(16)
                height: pt.s(16)
                radius: width / 2
                color: pt.fg
                border.width: 2
                border.color: pt.accent
                anchors.verticalCenter: track.verticalCenter
                x: Math.round((track.width - width) * root.progress)
                Behavior on x {
                    enabled: !root.dragging
                    NumberAnimation { duration: pt.durFast; easing.type: Easing.OutCubic }
                }
            }

            MouseArea {
                id: drag
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: function(m) { root.dragging = true; root.setFromX(m.x) }
                onReleased: function() { root.dragging = false; root.released(root.liveValue) }
                onCanceled: function() { root.dragging = false; root.released(root.liveValue) }
                onPositionChanged: function(m) { if (pressed) root.setFromX(m.x) }
                onWheel: function(w) {
                    var dir = w.angleDelta.y > 0 ? 1 : -1
                    var next = root.snap(root.liveValue + dir * root.stepSize)
                    if (next === root.liveValue) return
                    root.liveValue = next
                    root.moved(next)
                    root.released(next)
                }
            }
        }
    }
}
