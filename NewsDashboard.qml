import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui
import "newsEngine.js" as Engine
import "components"
import "components" as C
import "pages" as P

// Advanced news panel: Home · For you · Saved · Settings + first-run setup.
// Matches the minimal premium aesthetic from the design screenshots.
Panel {
    id: root

    property PaletteBase pt: PaletteBase {
        scale: hostWidget && hostWidget.prefs && hostWidget.prefs.fontScale ? hostWidget.prefs.fontScale : 1
    }

    moduleName: "paudelsamir.newsdash"
    manageIpc: false

    property var anchorItem: null
    property var hostWidget: null
    readonly property var barIdentity: hostWidget || root
    property bool frosted: hostWidget && hostWidget.prefs ? hostWidget.prefs.frosted !== false : true

    // Pages: home | foryou | saved | settings
    property string page: "home"
    property string settingsSub: ""
    readonly property bool showSetup: hostWidget ? !hostWidget.setupDone : false

    readonly property var articles: hostWidget ? hostWidget.articles : []
    readonly property var readMap: hostWidget ? hostWidget.readMap : ({})
    readonly property var feeds: hostWidget ? hostWidget.feeds : []
    readonly property int unread: hostWidget ? hostWidget.unread : 0
    readonly property double clock: hostWidget ? hostWidget.clock : Date.now()
    readonly property bool loading: hostWidget ? hostWidget.loading : false

    function open() {
        root.controller.show()
        if (hostWidget) hostWidget.refreshIfStale()
    }
    function close() { root.controller.hide() }
    function toggle() {
        if (root.opened) root.close()
        else root.open()
    }
    function switchPanel(direction) {
        if (root.bar && typeof root.bar.switchPanelFrom === "function")
            return root.bar.switchPanelFrom(root.barIdentity, direction)
        return false
    }

    function stepPage(delta) {
        if (root.showSetup) return
        var order = ["home", "foryou", "saved", "settings"]
        var at = order.indexOf(root.page)
        if (at < 0) at = 0
        root.page = order[(at + delta + order.length) % order.length]
        root.settingsSub = ""
        if (root.hostWidget) {
            root.hostWidget.panelPage = root.page
            root.hostWidget.cursorIndex = 0
        }
    }

    onPageChanged: {
        if (root.hostWidget) {
            root.hostWidget.panelPage = root.page
            root.hostWidget.cursorIndex = 0
        }
    }

    // Toast
    property string toast: ""
    property bool toastUndo: false
    Timer { id: toastTimer; interval: 5000; onTriggered: root.toast = "" }
    Connections {
        target: root.hostWidget
        function onMessageSerialChanged() {
            if (!root.opened) return
            root.toast = root.hostWidget.lastMessage
            root.toastUndo = root.hostWidget.lastUndoable
            toastTimer.restart()
        }
    }

    KeyboardPanel {
        id: panel
        anchorItem: root.anchorItem
        owner: root.barIdentity
        bar: root.bar
        open: root.opened
        focusTarget: keyCatcher

        padding: pt.s(14)
            contentWidth: panel.fittedContentWidth(pt.s(440))
            contentHeight: panel.fittedContentHeight(pt.s(740), pt.s(800))

        PanelKeyCatcher {
            id: keyCatcher
            anchors.fill: parent

            onCloseRequested: {
                if (root.settingsSub !== "") root.settingsSub = ""
                else if (root.showSetup) { /* stay */ }
                else root.close()
            }
            onTabRequested: function(direction) { root.switchPanel(direction) }
            onMoveRequested: function(dx, dy) {
                if (dx !== 0) root.stepPage(dx)
                else if (dy !== 0) bodyFlick.flick(0, -dy * 900)
            }
            onTextKey: function(t) {
                if (root.showSetup) return
                if (t === "1") { root.page = "home"; root.settingsSub = "" }
                else if (t === "2") { root.page = "foryou"; root.settingsSub = "" }
                else if (t === "3") { root.page = "saved"; root.settingsSub = "" }
                else if (t === "4") { root.page = "settings"; root.settingsSub = "" }
                else if (t === "h") root.stepPage(-1)
                else if (t === "l") root.stepPage(1)
                else if (t === "j" && root.hostWidget) root.hostWidget.moveCursor(1)
                else if (t === "k" && root.hostWidget) root.hostWidget.moveCursor(-1)
                else if (t === "r" && root.hostWidget) root.hostWidget.refresh()
                else if (t === "m" && root.hostWidget) {
                    var ids = root.articles.map(function(a) { return a.id })
                    root.hostWidget.markAllRead(ids)
                }
                else if (t === "u" && root.hostWidget) root.hostWidget.undo()
                else if (t === "o" && root.hostWidget) root.hostWidget.openCursor()
                else if (t === "s" && root.hostWidget) root.hostWidget.saveCursor()
                else if (t === "c" && root.hostWidget) root.hostWidget.copyCursor()
                else if (t === "y" && root.hostWidget) root.hostWidget.copyCursor()
            }

            // Frosted sheet
            Rectangle {
                visible: root.frosted
                z: -1
                anchors.fill: parent
                anchors.margins: -panel.padding
                radius: pt.s(14)
                color: pt.alpha(pt.bg, 0.88)
                border.width: 1
                border.color: pt.alpha(pt.fg, 0.10)

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: parent.radius - 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: pt.alpha(pt.fg, 0.04) }
                        GradientStop { position: 0.3; color: pt.alpha(pt.fg, 0.0) }
                    }
                }
            }

            Column {
                anchors.fill: parent
                spacing: 0

                // Scrollable body
                Flickable {
                    id: bodyFlick
                    width: parent.width
                    height: parent.height - (root.showSetup ? 0 : navBar.height)
                    contentWidth: width
                    contentHeight: bodyCol.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    flickDeceleration: 2600

                    Column {
                        id: bodyCol
                        width: bodyFlick.width
                        spacing: pt.s(4)

                        opacity: root.opened ? 1 : 0
                        transform: Translate {
                            y: root.opened ? 0 : -pt.s(6)
                            Behavior on y { NumberAnimation { duration: pt.dur; easing.type: Easing.OutCubic } }
                        }
                        Behavior on opacity { NumberAnimation { duration: pt.dur } }

                        // Setup (first run)
                        Loader {
                            width: parent.width
                            height: item ? item.implicitHeight : 0
                            visible: active
                            active: root.showSetup
                            sourceComponent: P.SetupPage {
                                width: bodyCol.width
                                host: root.hostWidget
                                onFinished: function(feedIds, interests, custom, extras) {
                                    if (root.hostWidget) root.hostWidget.completeSetup(feedIds, interests, custom, extras)
                                    root.page = "home"
                                }
                            }
                        }

                        // Main pages
                        Loader {
                            width: parent.width
                            height: item ? item.implicitHeight : 0
                            visible: active
                            active: !root.showSetup && root.page === "home"
                            sourceComponent: P.HomePage {
                                width: bodyCol.width
                                host: root.hostWidget
                            }
                        }
                        Loader {
                            width: parent.width
                            height: item ? item.implicitHeight : 0
                            visible: active
                            active: !root.showSetup && root.page === "foryou"
                            sourceComponent: P.ForYouPage {
                                width: bodyCol.width
                                host: root.hostWidget
                            }
                        }
                        Loader {
                            width: parent.width
                            height: item ? item.implicitHeight : 0
                            visible: active
                            active: !root.showSetup && root.page === "saved"
                            sourceComponent: P.SavedPage {
                                width: bodyCol.width
                                host: root.hostWidget
                            }
                        }
                        Loader {
                            width: parent.width
                            height: item ? item.implicitHeight : 0
                            visible: active
                            active: !root.showSetup && root.page === "settings"
                            sourceComponent: P.SettingsPage {
                                width: bodyCol.width
                                host: root.hostWidget
                                subView: root.settingsSub
                                onOpenSub: function(key) { root.settingsSub = key }
                                onBack: root.settingsSub = ""
                            }
                        }

                        // Bottom padding so content clears the nav
                        Item { width: 1; height: pt.s(8) }
                    }
                }

                // Bottom nav
                C.NavBar {
                    id: navBar
                    width: parent.width
                    visible: !root.showSetup
                    current: root.page
                    onNavigated: function(p) {
                        root.page = p
                        root.settingsSub = ""
                    }
                    onRandomRequested: if (root.hostWidget) root.hostWidget.openRandomAny()
                }
            }

            // Toast banner
            Rectangle {
                id: banner
                readonly property real maxWidth: keyCatcher.width - pt.s(24)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: (root.showSetup ? pt.s(12) : navBar.height + pt.s(8))
                width: Math.min(maxWidth, toastRow.implicitWidth + pt.s(32))
                height: pt.s(36)
                radius: height / 2
                color: Qt.tint(pt.bg, pt.alpha(pt.fg, 0.14))
                border.width: 1
                border.color: pt.alpha(pt.fg, 0.12)
                opacity: root.toast !== "" ? 1 : 0
                visible: opacity > 0
                scale: root.toast !== "" ? 1 : 0.94
                Behavior on opacity { NumberAnimation { duration: pt.dur } }
                Behavior on scale { NumberAnimation { duration: pt.dur; easing.type: Easing.OutCubic } }

                Row {
                    id: toastRow
                    anchors.centerIn: parent
                    spacing: pt.s(12)
                    Text {
                        textFormat: Text.PlainText
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.toast
                        color: pt.label
                        font.family: pt.font
                        font.pixelSize: pt.callout
                        font.weight: Font.Medium
                    }
                    Text {
                        textFormat: Text.PlainText
                        anchors.verticalCenter: parent.verticalCenter
                        visible: root.toastUndo
                        text: "Undo"
                        color: pt.good
                        font.family: pt.font
                        font.pixelSize: pt.callout
                        font.weight: Font.Bold
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -pt.s(8)
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.toast = ""
                                if (root.hostWidget) root.hostWidget.undo()
                            }
                        }
                    }
                }
            }
        }
    }
}
