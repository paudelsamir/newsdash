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
    property string selectedSection: "local"

    readonly property var articles: host ? host.articles : []
    readonly property var readMap: host ? host.readMap : ({})
    readonly property var savedMap: host ? host.savedMap : ({})
    readonly property var followed: host ? host.followed : []
    readonly property var interests: host ? host.interests : []
    readonly property var prefs: host ? host.prefs : ({})
    readonly property double clock: host ? host.clock : Date.now()
    readonly property bool dense: host ? !!host.prefs.dense : false

    readonly property var followedIds: followed.length
        ? followed
        : (host ? host.feeds.map(function(f) { return f.id }) : [])

    readonly property var sections: [
        { id: "local", name: "Local News" },
        { id: "writing", name: "Blogs / Writing" },
        { id: "research", name: "Recent Papers" }
    ]

    readonly property var list: {
        var options = {
            blocked: host ? host.blocked : [],
            unreadOnly: true,
            readMap: readMap
        }
        if (root.selectedSection === "local") {
            options.followedOnly = true
            options.followed = followedIds
            options.category = "local"
            options.stream = "news"
        } else if (root.selectedSection === "writing") {
            options.followedOnly = true
            options.followed = followedIds
            options.stream = "writing"
        } else {
            options.stream = "research"
        }
        var raw = Engine.filterArticles(articles, options)
        if (!raw.length) {
            options.unreadOnly = false
            raw = Engine.filterArticles(articles, options)
        }
        return Engine.rankForYou(raw, {
            readMap: readMap,
            interests: interests,
            followed: followedIds,
            now: clock,
            limit: 0
        })
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
                text: "FOR YOU"
                color: pt.tertiary
                font.family: pt.font
                font.pixelSize: pt.footnote
                font.weight: Font.DemiBold
                font.letterSpacing: 1.0
            }
            Text {
                textFormat: Text.PlainText
                text: "A short brief"
                color: pt.fg
                font.family: pt.serif
                font.pixelSize: pt.s(24)
                font.weight: Font.Medium
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

        C.SegmentedSlider {
            width: parent.width
            value: root.selectedSection
            options: root.sections.map(function(item) { return { key: item.id, label: item.name } })
            onSelected: function(id) { root.selectedSection = id }
        }

        Column {
            width: parent.width
            spacing: pt.s(8)

            C.SectionHeader {
                label: root.sections.filter(function(item) { return item.id === root.selectedSection })[0].name
            }

            Repeater {
                model: root.list
                C.ArticleRow {
                    width: parent.width
                    article: modelData
                    dense: false
                    isRead: !!(readMap[modelData.id])
                    saved: !!(savedMap[modelData.id])
                    clock: root.clock
                    onOpenRequested: if (host) host.openArticle(modelData)
                    onSaveRequested: if (host) host.toggleSaved(modelData)
                }
            }
        }

        C.EmptyState {
            visible: list.length === 0
            width: parent.width
            title: "Nothing in this lane yet"
            detail: root.selectedSection === "research"
                ? "Enable Papers / Research in Settings → Sources, or wait for arXiv to refresh."
                : root.selectedSection === "writing"
                    ? "Enable Blogs / Writing in Settings → Sources, or add a writing feed."
                    : "Enable local feeds in Settings → Sources, or wait for a refresh."
        }
    }
}
