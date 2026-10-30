import QtQuick
import qs.Commons

// Bottom navigation: Home · For you · Saved · Settings
Rectangle {
    id: root

    property PaletteBase pt: PaletteBase { }

    property string current: "home" // home | foryou | saved | settings
    property bool randomArmed: false
    signal navigated(string page)
    signal randomRequested()

    Timer {
        id: randomConfirmTimer
        interval: 2200
        onTriggered: root.randomArmed = false
    }

    height: pt.s(56)
    color: pt.alpha(pt.bg, 0.92)
    border.width: 0

    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: pt.separator
    }

    Row {
        anchors.centerIn: parent
        spacing: pt.s(4)

        Repeater {
            model: [
                { key: "home",     glyph: "\uf015", label: "Home" },
                { key: "foryou",   glyph: "\uf007", label: "For you" },
                { key: "saved",    glyph: "\uf02e", label: "Saved" },
                { key: "settings", glyph: "\uf013", label: "Settings" },
                { key: "random",  glyph: "\uf522", label: "Random" }
            ]

            delegate: Item {
                width: pt.s(72)
                height: pt.s(48)

                property bool active: root.current === modelData.key

                Rectangle {
                    anchors.centerIn: parent
                    width: pt.s(64)
                    height: pt.s(40)
                    radius: pt.s(10)
                    color: active ? pt.alpha(pt.fg, 0.08) : (navMouse.containsMouse ? pt.fillHover : "transparent")
                    border.width: active ? 1 : 0
                    border.color: pt.alpha(pt.fg, 0.12)
                    Behavior on color { ColorAnimation { duration: pt.fast } }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: pt.s(2)

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        textFormat: Text.PlainText
                        text: modelData.glyph
                        color: active ? pt.fg : pt.tertiary
                        font.family: pt.glyphFont
                        font.pixelSize: pt.body
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        textFormat: Text.PlainText
                        text: modelData.key === "random" && root.randomArmed ? "Confirm?" : modelData.label
                        color: active ? pt.fg : pt.tertiary
                        font.family: pt.font
                        font.pixelSize: pt.s(10)
                        font.weight: active ? Font.Medium : Font.Normal
                    }
                }

                MouseArea {
                    id: navMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.key === "random") {
                            if (root.randomArmed) {
                                root.randomArmed = false
                                randomConfirmTimer.stop()
                                root.randomRequested()
                            } else {
                                root.randomArmed = true
                                randomConfirmTimer.restart()
                            }
                        } else {
                            root.randomArmed = false
                            randomConfirmTimer.stop()
                            root.navigated(modelData.key)
                        }
                    }
                }
            }
        }
    }
}
