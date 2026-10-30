import QtQuick
import qs.Commons
import "../components"
import "../components" as C
import "../newsEngine.js" as Engine
import "../catalog.js" as Catalog
Item {
    id: root

    property PaletteBase pt: PaletteBase {
        scale: host && host.prefs && host.prefs.fontScale ? host.prefs.fontScale : 1
    }

    property var host: null
    property string searchQuery: ""
    property string selectedStream: "all"
    property string selectedCategory: "all"
    property string selectedSource: "all"
    readonly property bool dense: host ? !!host.prefs.dense : false
    readonly property var prefs: host ? host.prefs : ({})

    readonly property var articles: host ? host.articles : []
    readonly property var readMap: host ? host.readMap : ({})
    readonly property var savedMap: host ? host.savedMap : ({})
    readonly property double clock: host ? host.clock : Date.now()
    readonly property int unread: host ? host.unread : 0
    readonly property string locationName: {
        if (!host) return ""
        var id = host.prefs && host.prefs.regionId ? host.prefs.regionId : ""
        var region = id ? Catalog.findRegion(id) : null
        if (!region && host.detectedRegion) region = host.detectedRegion
        return region ? region.name : ""
    }

    readonly property var categories: [
        { id: "all", label: "All" },
        { id: "local", label: "Local" },
        { id: "technology", label: "Technology" },
        { id: "business", label: "Business" },
        { id: "science", label: "Science" },
        { id: "politics", label: "Politics" },
        { id: "world", label: "World" },
        { id: "sports", label: "Sports" },
        { id: "culture", label: "Culture" },
        { id: "blogs", label: "Writing" },
        { id: "linux", label: "Linux" }
    ]
    readonly property var streams: [
        { id: "all", name: "Everything" },
        { id: "news", name: "News" },
        { id: "writing", name: "Blogs / Writing" },
        { id: "research", name: "Papers / Research" }
    ]
    function sourcesForCategory(catId) {
        if (!host || !host.feeds) return [{ id: "all", name: "All sources" }]
        var out = [{ id: "all", name: "All sources" }]
        for (var i = 0; i < host.feeds.length; i++) {
            var f = host.feeds[i]
            if (!f || !f.id) continue
            if (f.enabled === false || f.silenced) continue
            if (root.selectedStream !== "all" && (f.stream || "news") !== root.selectedStream) continue
            if (catId !== "all" && f.category !== catId) continue
            out.push({ id: f.id, name: f.name || f.id })
        }
        return out
    }

    readonly property var currentSources: root.sourcesForCategory(root.selectedCategory)

    readonly property var filtered: {
        var list = Engine.filterArticles(articles, {
            query: searchQuery,
            blocked: host ? host.blocked : [],
            readMap: readMap,
            unreadOnly: !!prefs.hideRead,
            feedId: root.selectedSource === "all" ? "all" : root.selectedSource,
            category: (root.selectedSource === "all" && root.selectedCategory !== "all") ? root.selectedCategory : "",
            stream: root.selectedStream === "all" ? "" : root.selectedStream
        })
        if (prefs.unreadFirst) list = Engine.sortUnreadFirst(list, readMap)
        var cap = parseInt(String(prefs.maxHome != null ? prefs.maxHome : 60), 10)
        if (!isFinite(cap) || cap < 10) cap = 60
        return list.slice(0, cap)
    }

    readonly property var spotlight: Engine.highlights(filtered, readMap, 4)
    readonly property var failed: host && host.failedNames ? host.failedNames : []

    function setCategory(catId) {
        root.selectedCategory = catId
        root.selectedSource = "all"
    }

    function setStream(streamId) {
        root.selectedStream = streamId
        root.selectedCategory = "all"
        root.selectedSource = "all"
    }

    function setSource(sourceId) {
        root.selectedSource = sourceId
    }

    implicitHeight: col.height

    Column {
        id: col
        width: parent.width
        spacing: pt.s(14)

        Item {
            width: parent.width
            height: pt.s(72)

            Column {
                anchors.left: parent.left
                spacing: pt.s(2)

                Text {
                    textFormat: Text.PlainText
                    text: (Engine.greeting(clock) + " · " + Engine.weekdayName(clock)).toUpperCase()
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.8
                }

                Text {
                    textFormat: Text.PlainText
                    text: Engine.monthDay(clock)
                    color: pt.fg
                    font.family: pt.serif
                    font.pixelSize: pt.s(28)
                    font.weight: Font.Medium
                }
                Text {
                    visible: root.locationName !== ""
                    textFormat: Text.PlainText
                    text: root.locationName
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                }
            }

            C.ActionCluster {
                anchors.right: parent.right
                anchors.top: parent.top
                unread: root.unread
                busy: host ? host.loading : false
                onRefreshClicked: if (host) host.refresh()
                onRandomNewsClicked: if (host) host.openRandom("news")
                onRandomWritingClicked: if (host) host.openRandom("writing")
                onReadAllClicked: if (host) host.markAllRead([])
            }
        }

        C.SearchField {
            width: parent.width
            placeholder: "Search all sources"
            onTextEdited: root.searchQuery = text
        }

        C.Card {
            width: parent.width
            padding: pt.s(10)
            tone: "danger"
            visible: failed.length > 0 && root.searchQuery === ""
            Column {
                width: parent.width
                spacing: pt.s(4)
                Text {
                    textFormat: Text.PlainText
                    text: failed.length === 1 ? "One source failed" : (failed.length + " sources failed")
                    color: pt.fg
                    font.family: pt.font
                    font.pixelSize: pt.body
                    font.weight: Font.Medium
                }
                Text {
                    width: parent.width
                    textFormat: Text.PlainText
                    text: failed.slice(0, 4).join(" · ") + (failed.length > 4 ? "…" : "")
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    wrapMode: Text.WordWrap
                }
            }
        }

        C.Card {
            width: parent.width
            padding: pt.s(12)
            visible: prefs.dailyBriefing && spotlight.length > 0 && root.selectedCategory === "all" && root.searchQuery === ""
            Column {
                width: parent.width
                spacing: pt.s(8)
                Text {
                    textFormat: Text.PlainText
                    text: "BRIEFING"
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.0
                }
                    Repeater {
                    model: spotlight
                    Text {
                        width: parent.width
                        textFormat: Text.PlainText
                        text: modelData.title
                        color: pt.fg
                        font.family: pt.font
                        font.pixelSize: pt.body
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                }
            }
        }

        C.Card {
            width: parent.width
            padding: pt.s(10)
            Column {
                width: parent.width
                spacing: pt.s(8)

                C.SectionHeader { label: "Browse and refine" }

                C.FilterRail {
                    label: "Stream"
                    activeId: root.selectedStream
                    items: root.streams
                    onSelected: function(id) { root.setStream(id) }
                }
                C.FilterRail {
                    label: "Topic"
                    visible: root.selectedStream === "all" || root.selectedStream === "news"
                    activeId: root.selectedCategory
                    items: root.categories
                    onSelected: function(id) { root.setCategory(id) }
                }
                C.FilterRail {
                    label: "Source"
                    visible: root.currentSources.length > 1
                    activeId: root.selectedSource
                    items: root.currentSources
                    onSelected: function(id) { root.setSource(id) }
                }
            }
        }

        Column {
            width: parent.width
            spacing: pt.s(8)
            visible: filtered.length > 0

            Column {
                spacing: pt.s(2)
                C.SectionHeader {
                    label: root.selectedSource === "all"
                        ? (root.selectedCategory === "all" ? "Latest" : (root.categories.filter(function(c) { return c.id === root.selectedCategory })[0] || {}).label || root.selectedCategory)
                        : "Stories"
                }
                Text {
                    textFormat: Text.PlainText
                    text: root.selectedSource === "all"
                        ? (root.selectedCategory === "all"
                            ? "Everything from your sources, newest first."
                            : "All stories in this section.")
                        : "From " + ((root.currentSources.filter(function(f) { return f.id === root.selectedSource })[0] || {}).name || root.selectedSource)
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    width: parent.parent.width
                    wrapMode: Text.WordWrap
                }
            }

            Column {
                width: parent.width
                spacing: pt.s(2)

                Repeater {
                    model: filtered

                    C.ArticleRow {
                        width: parent.width
                        article: modelData
                        dense: root.dense
                        isRead: !!(readMap[modelData.id])
                        saved: !!(savedMap[modelData.id])
                        clock: root.clock
                        onOpenRequested: if (host) { host.cursorIndex = index; host.openArticle(modelData) }
                        onSaveRequested: if (host) host.toggleSaved(modelData)
                    }
                }
            }
        }

        C.EmptyState {
            visible: filtered.length === 0
            width: parent.width
            glyph: host && host.loading ? "\uf110" : "\uf1ea"
            title: host && host.loading ? "Fetching feeds…" : (prefs.hideRead ? "You're caught up" : "No stories yet")
            detail: host && host.loading
                ? "Sources are loading in the background."
                : (root.selectedStream === "writing" || root.selectedStream === "research"
                    ? "This lane is optional. Enable Blogs / Writing or Papers / Research later in Settings → Sources."
                    : "Finish setup, add sources, or refresh.")
        }
    }
}
