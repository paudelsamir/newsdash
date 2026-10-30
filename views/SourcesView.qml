import QtQuick
import qs.Commons
import "../components"
import "../components" as C
import "../catalog.js" as Catalog
import "../newsEngine.js" as Engine

Item {
    id: root
    property PaletteBase pt: PaletteBase {
        scale: host && host.prefs && host.prefs.fontScale ? host.prefs.fontScale : 1
    }

    property var host: null
    signal back()
    property string customStream: "writing"
    property bool customBusy: false
    property string customMessage: ""
    property string arxivMessage: ""
    property bool arxivBusy: false
    property var arxivResults: []
    readonly property var streamOptions: [
        { id: "news", label: "News" },
        { id: "writing", label: "Writing" },
        { id: "research", label: "Research" },
        { id: "other", label: "Other" }
    ]
    readonly property var recommended: Catalog.recommendedFeeds(host && host.prefs ? host.prefs.regionId : "world")
    readonly property var googleNews: Catalog.find("gnews-" + (host && host.prefs && host.prefs.regionId ? host.prefs.regionId : "world"))
    readonly property string regionName: {
        var id = host && host.prefs ? host.prefs.regionId : ""
        var region = id ? Catalog.findRegion(id) : null
        if (!region && host && host.detectedRegion) region = host.detectedRegion
        return region ? region.name : "your region"
    }

    function addCustomUrl(value) {
        var url = String(value || "").trim()
        if (!url || !host || customBusy) return
        customBusy = true
        customMessage = "Checking feed…"
        host.validateFeedUrl(url, function(ok, message) {
            customBusy = false
            if (!ok) {
                customMessage = message
                return
            }
            host.addFeed({ name: url.replace(/^https?:\/\//, "").split("/")[0], url: url, category: "custom", stream: root.customStream })
            customMessage = "Feed added"
            customUrl.text = ""
        })
    }

    function searchResearch(value) {
        var query = String(value || "").trim()
        if (!query || !host || arxivBusy) return
        arxivBusy = true
        arxivMessage = "Searching arXiv…"
        host.searchArxiv(query, function(err, papers) {
            arxivBusy = false
            arxivResults = papers || []
            arxivMessage = err ? "Could not reach arXiv right now" : (arxivResults.length ? "" : "No papers found")
        })
    }

    width: parent ? parent.width : 320
    implicitHeight: col.height

    Column {
        id: col
        width: parent.width
        spacing: pt.s(12)

        C.SubHeader {
            width: parent.width
            kicker: "LIBRARY"
            title: "Sources and feeds"
            detail: "Toggle feeds on or off. Silenced feeds stay in the list but stop fetching."
            onBack: root.back()
        }

        C.Card {
            width: parent.width
            padding: pt.s(4)
            C.SettingRow {
                width: parent.width
                title: "Google News"
                detail: "Regional headlines for " + root.regionName + "."
                onActivated: {
                    if (!host || !root.googleNews) return
                    var enabled = host.feeds.some(function(feed) { return feed.id === root.googleNews.id })
                    if (enabled) host.removeFeed(root.googleNews.id)
                    else host.addFeed(root.googleNews)
                }
                C.ToggleSwitch {
                    checked: host && root.googleNews && host.feeds && host.feeds.some(function(feed) { return feed.id === root.googleNews.id })
                    onToggled: function(v) {
                        if (!host || !root.googleNews) return
                        var enabled = host.feeds.some(function(feed) { return feed.id === root.googleNews.id })
                        if (v && !enabled) host.addFeed(root.googleNews)
                        else if (!v && enabled) host.removeFeed(root.googleNews.id)
                    }
                }
            }
        }

        C.Card {
            width: parent.width
            padding: pt.s(10)
            Column {
                width: parent.width
                spacing: pt.s(6)
                C.SectionHeader { label: "Recommended starter set" }
                Text {
                    width: parent.width
                    textFormat: Text.PlainText
                    text: "A balanced mix of regional breadth, independent writing, and research."
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    wrapMode: Text.WordWrap
                }
                Text {
                    textFormat: Text.PlainText
                    text: "NEWS"
                    color: pt.quaternary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.8
                }
                Flow {
                    width: parent.width
                    spacing: pt.s(6)
                    Repeater {
                        model: root.recommended.filter(function(feed) { return feed.stream === "news" })
                        C.Chip {
                            label: modelData.name
                            compact: true
                            active: host && host.feeds && host.feeds.some(function(feed) { return feed.id === modelData.id })
                            onClicked: {
                                if (!host) return
                                var exists = host.feeds.some(function(feed) { return feed.id === modelData.id })
                                if (exists) host.removeFeed(modelData.id)
                                else host.addFeed(modelData)
                            }
                        }
                    }
                }
                Text {
                    textFormat: Text.PlainText
                    text: "BLOGS / WRITING"
                    color: pt.quaternary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.8
                }
                Flow {
                    width: parent.width
                    spacing: pt.s(6)
                    Repeater {
                        model: root.recommended.filter(function(feed) { return feed.stream === "writing" })
                        C.Chip {
                            label: modelData.name
                            compact: true
                            active: host && host.feeds && host.feeds.some(function(feed) { return feed.id === modelData.id })
                            onClicked: {
                                if (!host) return
                                var exists = host.feeds.some(function(feed) { return feed.id === modelData.id })
                                if (exists) host.removeFeed(modelData.id)
                                else host.addFeed(modelData)
                            }
                        }
                    }
                }
                Text {
                    textFormat: Text.PlainText
                    text: "PAPERS / RESEARCH"
                    color: pt.quaternary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.8
                }
                Flow {
                    width: parent.width
                    spacing: pt.s(6)
                    Repeater {
                        model: root.recommended.filter(function(feed) { return feed.stream === "research" })
                        C.Chip {
                            label: modelData.name
                            compact: true
                            active: host && host.feeds && host.feeds.some(function(feed) { return feed.id === modelData.id })
                            onClicked: {
                                if (!host) return
                                var exists = host.feeds.some(function(feed) { return feed.id === modelData.id })
                                if (exists) host.removeFeed(modelData.id)
                                else host.addFeed(modelData)
                            }
                        }
                    }
                }
            }
        }

        // Active feeds
        C.SectionHeader { label: "Your feeds" }

        Column {
            width: parent.width
            spacing: pt.s(4)

            Repeater {
                model: host ? host.feeds : []

                C.Card {
                    width: parent.width
                    padding: pt.s(10)
                    interactive: false
                    property var feed: modelData

                    Row {
                        width: parent.width
                        spacing: pt.s(10)

                        Column {
                            width: parent.width - pt.s(50)
                            spacing: pt.s(2)
                            Text {
                                textFormat: Text.PlainText
                                text: feed.name
                                color: pt.fg
                                font.family: pt.font
                                font.pixelSize: pt.body
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            Text {
                                textFormat: Text.PlainText
                                text: (feed.stream || "news") + " · " + (feed.category || "feed") + " · " + feed.url.replace(/^https?:\/\//, "").split("/")[0]
                                color: pt.tertiary
                                font.family: pt.font
                                font.pixelSize: pt.footnote
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        C.ToggleSwitch {
                            anchors.verticalCenter: parent.verticalCenter
                            checked: feed.enabled !== false && !feed.silenced
                            onToggled: function(v) {
                                if (host) host.setFeedEnabled(feed.id, v)
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: pt.s(5)
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            textFormat: Text.PlainText
                            text: "TYPE"
                            color: pt.quaternary
                            font.family: pt.font
                            font.pixelSize: pt.footnote
                            font.weight: Font.DemiBold
                        }
                        Repeater {
                            model: root.streamOptions
                            C.Chip {
                                label: modelData.label
                                compact: true
                                active: (feed.stream || "news") === modelData.id
                                onClicked: if (host) host.setFeedStream(feed.id, modelData.id)
                            }
                        }
                    }
                }
            }
        }

        // Add from catalog
        C.SectionHeader { label: "Add from catalog" }

        Column {
            width: parent.width
            spacing: pt.s(6)

            Repeater {
                model: Catalog.CATEGORIES

                Column {
                    width: parent.width
                    spacing: pt.s(4)

                    Text {
                        textFormat: Text.PlainText
                        text: modelData.label
                        color: pt.secondary
                        font.family: pt.font
                        font.pixelSize: pt.footnote
                        font.weight: Font.DemiBold
                    }

                    Flow {
                        width: parent.width
                        spacing: pt.s(6)

                        Repeater {
                            model: Catalog.byCategory(modelData.id)

                            C.Chip {
                                label: modelData.name
                                compact: true
                                active: host && host.feeds && host.feeds.some(function(f) { return f.id === modelData.id })
                                onClicked: {
                                    if (!host) return
                                    var exists = host.feeds.some(function(f) { return f.id === modelData.id })
                                    if (exists) host.removeFeed(modelData.id)
                                    else host.addFeed(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }

        // Custom URL
        C.SectionHeader { label: "Custom feed URL" }

        C.SegmentedSlider {
            width: parent.width
            title: "What kind of feed is this?"
            detail: "This controls whether it appears with news or writing."
            value: root.customStream
            options: root.streamOptions.map(function(item) { return { key: item.id, label: item.label } })
            onSelected: function(key) { root.customStream = key }
        }

        Column {
            width: parent.width
            spacing: pt.s(8)
            visible: root.customStream === "research"

            C.SectionHeader { label: "Search arXiv" }

            Row {
                width: parent.width
                spacing: pt.s(6)
                C.SearchField {
                    id: arxivQuery
                    width: parent.width - arxivSearchButton.width - parent.spacing
                    placeholder: "quantum computing, transformers, climate"
                    onAccepted: root.searchResearch(text)
                }
                C.PillButton {
                    id: arxivSearchButton
                    label: root.arxivBusy ? "Searching" : "Search"
                    primary: true
                    compact: true
                    enabled: !root.arxivBusy
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: root.searchResearch(arxivQuery.text)
                }
            }

            Text {
                visible: root.arxivMessage !== ""
                width: parent.width
                textFormat: Text.PlainText
                text: root.arxivMessage
                color: pt.tertiary
                font.family: pt.font
                font.pixelSize: pt.footnote
                wrapMode: Text.WordWrap
            }

            Column {
                width: parent.width
                spacing: pt.s(6)
                visible: root.arxivResults.length > 0

                Repeater {
                    model: root.arxivResults

                    C.Card {
                        width: parent.width
                        padding: pt.s(10)
                        property string paperId: Engine.arxivIdFromUrl(modelData.link)
                        property bool added: host && host.feeds && host.feeds.some(function(feed) { return feed.arxivId === paperId })

                        Column {
                            width: parent.width
                            spacing: pt.s(6)
                            Text {
                                width: parent.width
                                textFormat: Text.PlainText
                                text: modelData.title
                                color: pt.fg
                                font.family: pt.font
                                font.pixelSize: pt.body
                                font.weight: Font.Medium
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                            Row {
                                width: parent.width
                                spacing: pt.s(8)
                                Text {
                                    width: parent.width - addButton.width - parent.spacing
                                    textFormat: Text.PlainText
                                    text: "arXiv · " + paperId
                                    color: pt.tertiary
                                    font.family: pt.font
                                    font.pixelSize: pt.footnote
                                    elide: Text.ElideRight
                                }
                                C.PillButton {
                                    id: addButton
                                    label: parent.parent.parent.added ? "Added" : "Add"
                                    compact: true
                                    enabled: !parent.parent.parent.added
                                    onClicked: if (host) host.addArxivPaper(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }

        Row {
            width: parent.width
            spacing: pt.s(6)
            C.SearchField {
                id: customUrl
                width: parent.width - addFeedBtn.width - parent.spacing
                placeholder: "https://example.com/feed.xml"
                onAccepted: root.addCustomUrl(text)
            }
            C.PillButton {
                id: addFeedBtn
                label: root.customBusy ? "Checking" : "Add"
                primary: true
                compact: true
                enabled: !root.customBusy
                anchors.verticalCenter: parent.verticalCenter
                onClicked: root.addCustomUrl(customUrl.text)
            }
        }

        Text {
            visible: root.customMessage !== ""
            width: parent.width
            textFormat: Text.PlainText
            text: root.customMessage
            color: root.customMessage === "Feed added" ? pt.good : pt.tertiary
            font.family: pt.font
            font.pixelSize: pt.footnote
            wrapMode: Text.WordWrap
        }
    }
}
