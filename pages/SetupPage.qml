import QtQuick
import qs.Commons
import "../components"
import "../components" as C
import "../catalog.js" as Catalog

// First-run onboarding: region → interests → sources → reading prefs
Item {
    id: root
    property PaletteBase pt: PaletteBase { }

    property var host: null
    property int step: 0

    property string regionId: ""
    property var selectedInterests: []
    property var selectedFeedIds: []
    property var customFeeds: []
    property string customStream: "writing"
    property bool customBusy: false
    property string customMessage: ""
    property bool wantBriefing: true
    property bool wantDense: false
    property bool wantNotify: false
    property bool seeded: false

    signal finished(var feedIds, var interests, var custom, var extras)

    readonly property var hints: host && host.localeHints ? host.localeHints : ({
        locale: Qt.locale().name,
        offsetMin: -new Date().getTimezoneOffset()
    })
    readonly property var detected: Catalog.detectRegion(hints)
    readonly property var region: Catalog.findRegion(regionId) || detected
    readonly property int totalSelected: selectedFeedIds.length + customFeeds.length
    readonly property var setupCategories: {
        var order = ["local", "blogs", "research", "technology", "science", "business", "politics", "world", "sports", "culture", "linux"]
        var out = []
        for (var i = 0; i < order.length; i++) {
            for (var j = 0; j < Catalog.CATEGORIES.length; j++) {
                if (Catalog.CATEGORIES[j].id === order[i]) out.push(Catalog.CATEGORIES[j])
            }
        }
        return out
    }

    Component.onCompleted: seed()

    function seed() {
        if (seeded) return
        seeded = true
        var r = detected
        regionId = r ? r.id : "world"
        selectedInterests = ["local", "blogs", "technology", "world", "research"]
        selectedFeedIds = Catalog.suggestFeeds(selectedInterests, regionId, hints)
    }

    function setRegion(id) {
        regionId = id
        selectedFeedIds = Catalog.suggestFeeds(selectedInterests, id, hints)
    }

    function addCustomFeed(name, url) {
        url = String(url || "").trim()
        if (!url) return false
        if (!/^https?:\/\//i.test(url)) url = "https://" + url
        name = String(name || "").trim()
        for (var i = 0; i < customFeeds.length; i++)
            if (customFeeds[i].url === url) return true
        customFeeds = customFeeds.concat([{ name: name, url: url, stream: customStream }])
        return true
    }

    function submitCustomFeed(value) {
        var url = String(value || "").trim()
        if (!url || customBusy) return
        if (!host || !host.validateFeedUrl) {
            if (addCustomFeed("", url)) customUrl.text = ""
            return
        }
        customBusy = true
        customMessage = "Checking feed…"
        host.validateFeedUrl(url, function(ok, message) {
            customBusy = false
            if (!ok) {
                customMessage = message
                return
            }
            addCustomFeed("", url)
            customMessage = "Feed added"
            customUrl.text = ""
        })
    }

    function removeCustomFeed(index) {
        var next = customFeeds.slice()
        next.splice(index, 1)
        customFeeds = next
    }

    function toggleInterest(id) {
        var i = selectedInterests.indexOf(id)
        var next = selectedInterests.slice()
        if (i >= 0) next.splice(i, 1)
        else next.push(id)
        selectedInterests = next
    }

    function toggleFeed(id) {
        var i = selectedFeedIds.indexOf(id)
        var next = selectedFeedIds.slice()
        if (i >= 0) next.splice(i, 1)
        else next.push(id)
        selectedFeedIds = next
    }

    function resuggest() {
        selectedFeedIds = Catalog.suggestFeeds(selectedInterests, regionId, hints)
    }

    function commit() {
        var ids = selectedFeedIds.slice()
        if (ids.length === 0 && customFeeds.length === 0)
            ids = Catalog.suggestFeeds(selectedInterests, regionId, hints)
        root.finished(ids, selectedInterests, customFeeds, {
            regionId: regionId,
            prefs: {
                dailyBriefing: wantBriefing,
                dense: wantDense,
                notifyUnread: wantNotify,
                unreadFirst: false
            }
        })
    }

    implicitHeight: mainCol.height

    Column {
        id: mainCol
        width: parent.width
        spacing: pt.s(18)

        Row {
            spacing: pt.s(6)
            Repeater {
                model: 4
                Rectangle {
                    width: pt.s(36)
                    height: pt.s(4)
                    radius: 2
                    color: index <= root.step ? pt.accent : pt.alpha(pt.fg, 0.12)
                    Behavior on color { ColorAnimation { duration: pt.durFast } }
                }
            }
        }

        // Step 0 - region
        Column {
            width: parent.width
            spacing: pt.s(14)
            visible: root.step === 0

            Column {
                spacing: pt.s(6)
                width: parent.width
                Text {
                    textFormat: Text.PlainText
                    text: "Your briefing"
                    color: pt.fg
                    font.family: pt.serif
                    font.pixelSize: pt.s(26)
                    font.weight: Font.Medium
                }
                Text {
                    width: parent.width
                    textFormat: Text.PlainText
                    text: "A private news reader on this machine. We guessed your region from the system locale and timezone - confirm it so the right local sources are suggested."
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    wrapMode: Text.WordWrap
                }
            }

            C.Card {
                width: parent.width
                padding: pt.s(14)
                tone: "accent"
                Column {
                    width: parent.width
                    spacing: pt.s(8)
                    Text {
                        textFormat: Text.PlainText
                        text: "DETECTED"
                        color: pt.accent
                        font.family: pt.font
                        font.pixelSize: pt.footnote
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.1
                    }
                    Text {
                        textFormat: Text.PlainText
                        text: (root.region ? root.region.name : "International")
                        color: pt.fg
                        font.family: pt.serif
                        font.pixelSize: pt.s(22)
                        font.weight: Font.Medium
                    }
                    Text {
                        width: parent.width
                        textFormat: Text.PlainText
                        text: root.detected && root.regionId === root.detected.id
                            ? "Matched from locale and clock. Google News plus regional papers will be suggested next."
                            : "Using your pick. Local headlines will follow this region."
                        color: pt.secondary
                        font.family: pt.font
                        font.pixelSize: pt.footnote
                        wrapMode: Text.WordWrap
                    }
                }
            }

            C.SectionHeader { label: "Region" }

            Flow {
                width: parent.width
                spacing: pt.s(6)
                Repeater {
                    model: Catalog.REGIONS
                    C.Chip {
                        label: modelData.name
                        compact: true
                        active: root.regionId === modelData.id
                        onClicked: root.setRegion(modelData.id)
                    }
                }
            }

            Row {
                anchors.right: parent.right
                spacing: pt.s(8)
                C.PillButton {
                    label: "Continue"
                    primary: true
                    onClicked: root.step = 1
                }
            }
        }

        // Step 1 - interests
        Column {
            width: parent.width
            spacing: pt.s(14)
            visible: root.step === 1

            Column {
                spacing: pt.s(4)
                width: parent.width
                Text {
                    textFormat: Text.PlainText
                    text: "What do you care about?"
                    color: pt.fg
                    font.family: pt.serif
                    font.pixelSize: pt.s(22)
                    font.weight: Font.Medium
                }
                Text {
                    width: parent.width
                    textFormat: Text.PlainText
                    text: "Local is on because of your region. Add a few more - we suggest sources on the next screen."
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    wrapMode: Text.WordWrap
                }
            }

            Flow {
                width: parent.width
                spacing: pt.s(8)
                Repeater {
                    model: Catalog.CATEGORIES
                    C.Chip {
                        label: modelData.label
                        active: root.selectedInterests.indexOf(modelData.id) >= 0
                        onClicked: root.toggleInterest(modelData.id)
                    }
                }
            }

            Row {
                anchors.right: parent.right
                spacing: pt.s(8)
                C.PillButton {
                    label: "Back"
                    onClicked: root.step = 0
                }
                C.PillButton {
                    label: "Continue"
                    primary: true
                    onClicked: {
                        root.resuggest()
                        root.step = 2
                    }
                }
            }
        }

        // Step 2 - sources
        Column {
            width: parent.width
            spacing: pt.s(14)
            visible: root.step === 2

            Column {
                spacing: pt.s(4)
                width: parent.width
                Text {
                    textFormat: Text.PlainText
                    text: "Choose your sources"
                    color: pt.fg
                    font.family: pt.serif
                    font.pixelSize: pt.s(22)
                    font.weight: Font.Medium
                }
                Text {
                    width: parent.width
                    textFormat: Text.PlainText
                    text: totalSelected + " selected · suggested for " + (root.region ? root.region.name : "you") + ". Deselect anything you don't want."
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    wrapMode: Text.WordWrap
                }
            }

            Row {
                spacing: pt.s(8)
                C.PillButton {
                    label: "Use suggestions"
                    compact: true
                    onClicked: root.resuggest()
                }
                C.PillButton {
                    label: "Clear"
                    compact: true
                    onClicked: root.selectedFeedIds = []
                }
            }

            C.Card {
                width: parent.width
                padding: pt.s(4)
                C.SettingRow {
                    width: parent.width
                    title: "Google News"
                    detail: "Regional headlines for " + (root.region ? root.region.name : "your region") + "."
                    onActivated: if (root.region) root.toggleFeed("gnews-" + root.region.id)
                    C.ToggleSwitch {
                        checked: root.region && root.selectedFeedIds.indexOf("gnews-" + root.region.id) >= 0
                        onToggled: function(v) {
                            if (!root.region) return
                            var id = "gnews-" + root.region.id
                            var selected = root.selectedFeedIds.indexOf(id) >= 0
                            if (v && !selected) root.toggleFeed(id)
                            else if (!v && selected) root.toggleFeed(id)
                        }
                    }
                }
            }

            Text {
                width: parent.width
                textFormat: Text.PlainText
                text: "YOUR OWN FEEDS"
                color: pt.tertiary
                font.family: pt.font
                font.pixelSize: pt.footnote
                font.weight: Font.DemiBold
                font.letterSpacing: 1.1
            }

            Text {
                width: parent.width
                textFormat: Text.PlainText
                text: "Paste any RSS or Atom URL - a blog, a newsletter, a paper."
                color: pt.quaternary
                font.family: pt.font
                font.pixelSize: pt.footnote
                wrapMode: Text.WordWrap
            }

            C.SegmentedSlider {
                width: parent.width
                title: "Feed type"
                detail: "Writing is the default for personal sites and essays."
                value: root.customStream
                options: [
                    { key: "news", label: "News" },
                    { key: "writing", label: "Writing" },
                    { key: "research", label: "Papers / Research" },
                    { key: "other", label: "Other" }
                ]
                onSelected: function(key) { root.customStream = key }
            }

            Row {
                spacing: pt.s(6)
                C.SearchField {
                    id: customUrl
                    width: parent.parent.width - pt.s(100)
                    placeholder: "RSS / Atom URL"
                    onAccepted: root.submitCustomFeed(customUrl.text)
                }
                C.PillButton {
                    label: root.customBusy ? "Checking" : "Add"
                    primary: true
                    enabled: !root.customBusy
                    onClicked: root.submitCustomFeed(customUrl.text)
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

            Repeater {
                model: root.customFeeds
                delegate: Item {
                    width: parent.width
                    height: pt.s(36)
                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        textFormat: Text.PlainText
                        text: (index + 1) + ". " + (modelData.name || modelData.url)
                        color: pt.fg
                        font.family: pt.font
                        font.pixelSize: pt.normal
                        elide: Text.ElideRight
                        width: parent.width - pt.s(70)
                    }
                    MouseArea {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: pt.s(64)
                        height: parent.height
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.removeCustomFeed(index)
                        Text {
                            anchors.centerIn: parent
                            textFormat: Text.PlainText
                            text: "Remove"
                            color: pt.danger
                            font.family: pt.font
                            font.pixelSize: pt.footnote
                        }
                    }
                }
            }

            Repeater {
                model: root.setupCategories

                Column {
                    width: parent.width
                    spacing: pt.s(6)
                    visible: Catalog.byCategory(modelData.id, root.regionId).length > 0
                             && (modelData.id === "local" || root.selectedInterests.indexOf(modelData.id) >= 0 || modelData.id === "world" || modelData.id === "blogs")

                    C.SectionHeader { label: modelData.id === "local" ? ("Local · " + (root.region ? root.region.name : "")) : modelData.label }

                    Flow {
                        width: parent.width
                        spacing: pt.s(6)

                        Repeater {
                            model: Catalog.byCategory(modelData.id, root.regionId)

                            C.Chip {
                                label: modelData.name
                                active: root.selectedFeedIds.indexOf(modelData.id) >= 0
                                compact: true
                                onClicked: root.toggleFeed(modelData.id)
                            }
                        }
                    }
                }
            }

            Row {
                spacing: pt.s(8)
                C.PillButton {
                    label: "Back"
                    onClicked: root.step = 1
                }
                C.PillButton {
                    label: totalSelected === 0 ? "Pick at least one" : "Continue"
                    primary: true
                    onClicked: {
                        if (totalSelected === 0) return
                        root.step = 3
                    }
                }
            }
        }

        // Step 3 - reading prefs + start
        Column {
            width: parent.width
            spacing: pt.s(14)
            visible: root.step === 3

            Column {
                spacing: pt.s(4)
                width: parent.width
                Text {
                    textFormat: Text.PlainText
                    text: "How you read"
                    color: pt.fg
                    font.family: pt.serif
                    font.pixelSize: pt.s(22)
                    font.weight: Font.Medium
                }
                Text {
                    width: parent.width
                    textFormat: Text.PlainText
                    text: "All of this can change later in Settings. Stories, follows, and blocks stay in ~/.local/state/newsdash/."
                    color: pt.tertiary
                    font.family: pt.font
                    font.pixelSize: pt.footnote
                    wrapMode: Text.WordWrap
                }
            }

            C.Card {
                width: parent.width
                padding: pt.s(4)
                Column {
                    width: parent.width
                    spacing: 0
                    C.SettingRow {
                        width: parent.width
                        title: "Daily briefing"
                        detail: "A short strip of highlights on Home."
                        interactive: true
                        onActivated: root.wantBriefing = !root.wantBriefing
                        C.ToggleSwitch {
                            checked: root.wantBriefing
                            onToggled: function(v) { root.wantBriefing = v }
                        }
                    }
                    C.Hairline { inset: pt.s(12) }
                    C.SettingRow {
                        width: parent.width
                        title: "Dense list"
                        detail: "Tighter rows if you scan a lot."
                        interactive: true
                        onActivated: root.wantDense = !root.wantDense
                        C.ToggleSwitch {
                            checked: root.wantDense
                            onToggled: function(v) { root.wantDense = v }
                        }
                    }
                    C.Hairline { inset: pt.s(12) }
                    C.SettingRow {
                        width: parent.width
                        title: "Notify when unread piles up"
                        detail: "Desktop ping after a refresh. Quiet overnight if you turn that on later."
                        interactive: true
                        onActivated: root.wantNotify = !root.wantNotify
                        C.ToggleSwitch {
                            checked: root.wantNotify
                            onToggled: function(v) { root.wantNotify = v }
                        }
                    }
                }
            }

            Text {
                width: parent.width
                textFormat: Text.PlainText
                text: totalSelected + " sources · " + selectedInterests.length + " interests · " + (root.region ? root.region.name : "International")
                color: pt.quaternary
                font.family: pt.font
                font.pixelSize: pt.footnote
            }

            Row {
                spacing: pt.s(8)
                C.PillButton {
                    label: "Back"
                    onClicked: root.step = 2
                }
                C.PillButton {
                    label: "Start reading"
                    primary: true
                    onClicked: root.commit()
                }
            }
        }
    }
}
