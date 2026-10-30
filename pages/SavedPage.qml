import QtQuick
import qs.Commons
import "../components"
import "../components" as C
import "../newsEngine.js" as Engine

Item {
    id: root
    property PaletteBase pt: PaletteBase {
        scale: host && host.prefs && host.prefs.fontScale ? host.prefs.fontScale : 1
    }

    property var host: null
    property string selectedStream: "all"

    readonly property var articles: host ? host.articles : []
    readonly property var savedMap: host ? host.savedMap : ({})
    readonly property var readMap: host ? host.readMap : ({})
    readonly property double clock: host ? host.clock : Date.now()
    readonly property var streams: [
        { id: "all", name: "Everything" },
        { id: "news", name: "News" },
        { id: "writing", name: "Blogs / Writing" },
        { id: "research", name: "Papers / Research" }
    ]

    readonly property var list: {
        var out = []
        // Prefer live articles that are saved; also surface saved-only stubs if any
        for (var i = 0; i < articles.length; i++) {
            if (savedMap[articles[i].id]
                    && (root.selectedStream === "all" || Engine.articleStream(articles[i]) === root.selectedStream))
                out.push(articles[i])
        }
        // Include orphan saved entries stored as full objects
        if (host && host.savedArticles) {
            for (var j = 0; j < host.savedArticles.length; j++) {
                var a = host.savedArticles[j]
                var found = false
                for (var k = 0; k < out.length; k++) if (out[k].id === a.id) { found = true; break }
                if (!found && (root.selectedStream === "all" || Engine.articleStream(a) === root.selectedStream)) out.push(a)
            }
        }
        out.sort(function(a, c) { return c.published - a.published })
        return out
    }

    implicitHeight: mainCol.height

    Column {
        id: mainCol
        width: parent.width
        spacing: pt.s(14)

        Item {
            width: parent.width
            height: pt.s(64)

            Column {
                spacing: pt.s(2)
            Text {
                textFormat: Text.PlainText
                text: "SAVED"
                color: pt.tertiary
                font.family: pt.font
                font.pixelSize: pt.footnote
                font.weight: Font.DemiBold
                font.letterSpacing: 1.0
            }
            Text {
                textFormat: Text.PlainText
                text: "Read later"
                color: pt.fg
                font.family: pt.font
                font.pixelSize: pt.s(24)
                font.weight: Font.Medium
            }
            Text {
                textFormat: Text.PlainText
                text: list.length === 0 ? "Bookmark stories with the ribbon or right-click"
                                        : list.length + (list.length === 1 ? " story" : " stories") + " waiting"
                color: pt.tertiary
                font.family: pt.font
                font.pixelSize: pt.footnote
            }
            }

            C.ActionCluster {
                anchors.right: parent.right
                anchors.top: parent.top
                unread: host ? host.unread : 0
                busy: host ? host.loading : false
                onRefreshClicked: if (host) host.refresh()
                onRandomNewsClicked: if (host) host.openRandom("news")
                onRandomWritingClicked: if (host) host.openRandom("writing")
                onReadAllClicked: if (host) host.markAllRead([])
            }
        }

        C.Card {
            width: parent.width
            padding: pt.s(10)
            Column {
                width: parent.width
                spacing: pt.s(8)
                C.SectionHeader { label: "Saved streams" }
                C.FilterRail {
                    label: "Stream"
                    activeId: root.selectedStream
                    items: root.streams
                    onSelected: function(id) { root.selectedStream = id }
                }
            }
        }

        C.SectionHeader { label: "Read later" }

        Column {
            width: parent.width
            spacing: pt.s(2)
            visible: list.length > 0

            Repeater {
                model: list

                C.ArticleRow {
                    width: parent.width
                    article: modelData
                    dense: true
                    isRead: !!(readMap[modelData.id])
                    saved: true
                    clock: root.clock
                    onOpenRequested: if (host) host.openArticle(modelData)
                    onSaveRequested: if (host) host.toggleSaved(modelData)
                }
            }
        }

        C.EmptyState {
            visible: list.length === 0
            width: parent.width
            glyph: "\uf02e"
            title: "No saved stories"
            detail: "Right-click a headline or tap the bookmark to save it for later. Everything stays on this machine."
        }
    }
}
