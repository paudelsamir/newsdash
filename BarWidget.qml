import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "components"
import qs.Ui
import "newsEngine.js" as Engine
import "catalog.js" as Catalog

// Bar capsule (unchanged visual design) + data owner for the advanced panel.
// Fetches feeds, keeps read/saved/followed state in ~/.local/state/newsdash/state.json.
BarWidget {
    id: root

    property PaletteBase pt: PaletteBase { }

    moduleName: "paudelsamir.newsdash"

    // ---- paths -----------------------------------------------------------

    readonly property string home: Quickshell.env("HOME") || ""
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || home + "/.local/state") + "/newsdash"
    readonly property string statePath: stateDir + "/state.json"

    // ---- settings --------------------------------------------------------

    property var _feedsOverride: null
    readonly property var localeHints: {
        var tz = ""
        var lang = ""
        try { tz = Quickshell.env("TZ") || "" } catch (e) {}
        try { lang = Quickshell.env("LANG") || Quickshell.env("LC_ALL") || "" } catch (e2) {}
        var loc = ""
        try { loc = Qt.locale().name || "" } catch (e3) {}
        return {
            tz: tz,
            lang: lang,
            locale: loc || lang,
            offsetMin: -new Date().getTimezoneOffset()
        }
    }
    readonly property var detectedRegion: Catalog.detectRegion(localeHints)
    readonly property var feeds: {
        if (_feedsOverride && _feedsOverride.length)
            return Engine.normalizeFeeds(_feedsOverride)
        var raw = setting("feeds", "")
        if (raw && String(raw).trim() !== "")
            return Engine.normalizeFeeds(raw)
        return Engine.normalizeFeeds(Catalog.feedsFromIds(Catalog.defaultSelection(localeHints)))
    }
    readonly property string badgeMode: {
        var v = String(setting("showCount", "always"))
        if (v === "icon" || v === "dot" || v === "when-unread" || v === "foryou") return v
        if (v === "never") return "icon"
        return "always"
    }
    readonly property bool barVisible: String(setting("barVisible", "true")) !== "false"
    readonly property string barTone: {
        var v = String(setting("barTone", "adaptive"))
        return v === "accent" || v === "quiet" || v === "light" ? v : "adaptive"
    }
    readonly property string barDensity: String(setting("barDensity", "regular")) === "compact" ? "compact" : "regular"
    readonly property int refreshMinutes: {
        var n = parseInt(String(setting("refreshMinutes", "15")), 10)
        return isFinite(n) ? Math.max(5, Math.min(240, n)) : 15
    }
    readonly property int perFeed: {
        var n = parseInt(String(setting("perFeed", "20")), 10)
        return isFinite(n) ? Math.max(5, Math.min(50, n)) : 20
    }

    // ---- data ------------------------------------------------------------

    property var articles: []
    property var readMap: ({})
    property var savedMap: ({})
    property var savedArticles: []
    property var feedStatus: ({})
    property var followed: []
    property var blocked: []
    property var interests: []
    property var prefs: Engine.defaultPrefs()
    property int cursorIndex: 0
    property string panelPage: "home"
    property bool setupDone: false
    property double fetchedAt: 0
    property double updatedAt: 0
    property double lastAttempt: 0
    property bool loading: false
    property int loadDone: 0
    property int loadTotal: 0
    property bool startupDone: false
    property double clock: Date.now()

    property string lastMessage: ""
    property bool lastUndoable: false
    property int messageSerial: 0
    property var undoSnapshot: null

    readonly property int unread: Engine.countUnread(articles, readMap)
    readonly property int forYouUnread: Engine.filterArticles(root.articles, {
        category: "local",
        stream: "news",
        followedOnly: root.followed.length > 0,
        followed: root.followed,
        blocked: root.blocked,
        unreadOnly: true,
        readMap: root.readMap
    }).length
    readonly property int total: articles.length

    readonly property int sourcesTotal: feeds.length
    readonly property int sourcesOk: {
        var n = 0
        for (var i = 0; i < feeds.length; i++) {
            var st = feedStatus[feeds[i].id]
            if (st && st.ok) n++
        }
        return n
    }
    readonly property var failedNames: {
        var out = []
        for (var i = 0; i < feeds.length; i++) {
            var st = feedStatus[feeds[i].id]
            if (st && !st.ok) out.push(feeds[i].name)
        }
        return out
    }
    readonly property bool allFailed: fetchedAt > 0 && sourcesTotal > 0 && failedNames.length === sourcesTotal

    readonly property string tooltip: {
        if (loading && total === 0) return "News - fetching feeds…"
        if (total === 0) return failedNames.length > 0 ? "News - couldn't reach any source" : "News"
        var parts = [unread === 0 ? "All caught up" : unread + (unread === 1 ? " unread article" : " unread articles")]
        parts.push(sourcesOk + "/" + sourcesTotal + " sources")
        if (fetchedAt > 0) parts.push("updated " + Engine.timeAgo(fetchedAt, clock) + (Engine.timeAgo(fetchedAt, clock) === "now" ? "" : " ago"))
        return parts.join(" · ")
    }

    readonly property bool leader: {
        if (!bar || typeof bar.moduleWidgets !== "function") return true
        var peers = bar.moduleWidgets(moduleName)
        return !peers || peers.length === 0 || peers[0] === root
    }

    // ---- persistence -----------------------------------------------------

    Process {
        id: mkdir
        command: ["mkdir", "-p", root.stateDir]
        running: true
    }

    FileView {
        id: stateFile
        path: root.statePath
        watchChanges: true
        atomicWrites: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.applyFile(text())
        onLoadFailed: root.fileReady()
    }

    function applyFile(text) {
        var s = Engine.parseState(text)
        if (s && (!root.startupDone || s.updatedAt >= root.updatedAt)) {
            root.articles = s.articles
            root.readMap = s.read
            root.savedMap = s.saved || ({})
            root.feedStatus = s.status
            root.fetchedAt = s.fetchedAt
            root.updatedAt = s.updatedAt
            root.followed = s.followed || []
            root.blocked = s.blocked || []
            root.interests = s.interests || []
            root.setupDone = !!s.setupDone
            if (Array.isArray(s.savedArticles)) root.savedArticles = s.savedArticles
            if (s.prefs) {
                var merged = Engine.copyMap(root.prefs)
                for (var pk in s.prefs) merged[pk] = s.prefs[pk]
                root.prefs = merged
            }
            if (s.feedsOverride && s.feedsOverride.length)
                root._feedsOverride = s.feedsOverride
        }
        fileReady()
    }

    function fileReady() {
        if (root.startupDone) return
        root.startupDone = true
        if (!root.prefs.regionId && root.detectedRegion)
            root.setPref("regionId", root.detectedRegion.id)
        root.ensureResearchDefault()
        if (!root.setupDone)
            Qt.callLater(function() { root.open() })
        else
            root.maybeRefresh()
    }

    function ensureResearchDefault() {
        if (!root.setupDone || root.prefs.researchDefaultMigrated === true) return
        var hasResearch = root.feeds.some(function(feed) { return feed.stream === "research" })
        if (!hasResearch) {
            var arxiv = Catalog.find("arxiv-ai")
            if (arxiv) {
                root._feedsOverride = root.feeds.concat([arxiv])
                if (root.followed.indexOf(arxiv.id) < 0)
                    root.followed = root.followed.concat([arxiv.id])
            }
        } else {
            var researchFeed = root.feeds.filter(function(feed) { return feed.stream === "research" })[0]
            if (researchFeed && root.followed.indexOf(researchFeed.id) < 0)
                root.followed = root.followed.concat([researchFeed.id])
        }
        root.setPref("researchDefaultMigrated", true)
    }

    Timer {
        id: persistTimer
        interval: 300
        onTriggered: {
            root.updatedAt = Date.now()
            stateFile.setText(Engine.serializeState({
                updatedAt: root.updatedAt,
                fetchedAt: root.fetchedAt,
                articles: root.articles,
                read: root.readMap,
                saved: root.savedMap,
                status: root.feedStatus,
                followed: root.followed,
                blocked: root.blocked,
                interests: root.interests,
                setupDone: root.setupDone,
                prefs: root.prefs,
                feedsOverride: root._feedsOverride,
                savedArticles: root.savedArticles
            }))
        }
    }

    function persist() { persistTimer.restart() }

    // ---- fetching --------------------------------------------------------

    property var job: null

    function refresh() {
        if (root.loading || !root.setupDone) return
        root.loading = true
        root.loadDone = 0
        root.loadTotal = root.feeds.length
        root.lastAttempt = Date.now()
        watchdog.restart()
        root.job = Engine.refreshAll(root.feeds, { perFeed: root.perFeed, concurrency: 4 },
            function(done, count) { root.loadDone = done; root.loadTotal = count },
            function(result) { root.finishRefresh(result) })
    }

    function finishRefresh(result) {
        watchdog.stop()
        root.job = null
        root.loading = false
        var anyOk = false
        for (var id in result.status) if (result.status[id].ok) anyOk = true

        if (anyOk) {
            root.articles = Engine.carryOver(result.articles, root.articles, result.status)
            root.fetchedAt = Date.now()
            root.readMap = Engine.pruneRead(root.readMap, root.articles)
        }
        root.feedStatus = result.status
        root.persist()
        root.maybeNotifyUnread()
    }

    Timer {
        id: watchdog
        interval: 30000
        onTriggered: if (root.job) root.job.abort()
    }

    function maybeRefresh() {
        if (!root.leader || !root.startupDone || root.loading || !root.setupDone) return
        var last = Math.max(root.fetchedAt, root.lastAttempt)
        if (last === 0 || Date.now() - last >= root.refreshMinutes * 60000) root.refresh()
    }

    function inQuietHours() {
        if (!root.prefs || !root.prefs.quietHours) return false
        var h = new Date().getHours()
        return h >= 22 || h < 7
    }

    function maybeNotifyUnread() {
        if (!root.prefs || !root.prefs.notifyUnread) return
        if (root.inQuietHours()) return
        var n = root.unread
        var at = parseInt(String(root.prefs.notifyAt != null ? root.prefs.notifyAt : 5), 10)
        if (!isFinite(at) || at < 1) at = 5
        if (n < at) return
        var msg = n + (n === 1 ? " unread story" : " unread stories")
        Quickshell.execDetached(["notify-send", "--app-name=NewsDash", "NewsDash", msg])
    }

    function refreshIfStale() {
        if (root.loading || !root.setupDone) return
        var last = Math.max(root.fetchedAt, root.lastAttempt)
        if (last === 0 || Date.now() - last >= root.refreshMinutes * 60000) root.refresh()
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            root.clock = Date.now()
            root.maybeRefresh()
        }
    }

    readonly property string feedsKey: feeds.map(function(f) { return f.url }).join("\n")
    onFeedsKeyChanged: if (root.startupDone && root.setupDone && root.leader && !root.loading && root.fetchedAt > 0) root.refresh()

    // ---- read / saved / follows ------------------------------------------

    function announce(text, undoable) {
        root.lastMessage = text
        root.lastUndoable = undoable === true
        root.messageSerial++
    }

    function isRead(id) { return !!root.readMap[id] }

    function markRead(id) {
        if (root.readMap[id]) return
        var m = Engine.copyMap(root.readMap)
        m[id] = Date.now()
        root.readMap = m
        root.persist()
    }

    function toggleRead(id) {
        var m = Engine.copyMap(root.readMap)
        if (m[id]) delete m[id]
        else m[id] = Date.now()
        root.readMap = m
        root.persist()
    }

    function markAllRead(ids) {
        var list = ids && ids.length ? ids : root.articles.map(function(a) { return a.id })
        var m = Engine.copyMap(root.readMap)
        var n = 0
        var now = Date.now()
        for (var i = 0; i < list.length; i++) if (!m[list[i]]) { m[list[i]] = now; n++ }
        if (n === 0) return 0
        root.undoSnapshot = root.readMap
        root.readMap = m
        root.persist()
        root.announce("Marked " + n + (n === 1 ? " article" : " articles") + " as read", true)
        return n
    }

    function undo() {
        if (!root.undoSnapshot) return
        root.readMap = root.undoSnapshot
        root.undoSnapshot = null
        root.persist()
        root.announce("Restored unread articles", false)
    }

    function toggleSaved(article) {
        if (!article || !article.id) return
        var m = Engine.copyMap(root.savedMap)
        if (m[article.id]) {
            delete m[article.id]
            root.savedArticles = root.savedArticles.filter(function(a) { return a.id !== article.id })
            root.announce("Removed from saved", false)
        } else {
            m[article.id] = Date.now()
            var copy = {
                id: article.id, feedId: article.feedId, source: article.source,
                category: article.category, title: article.title, link: article.link,
                summary: article.summary || "", published: article.published
            }
            root.savedArticles = [copy].concat(root.savedArticles.filter(function(a) { return a.id !== article.id }))
            root.announce("Saved for later", false)
        }
        root.savedMap = m
        root.persist()
    }

    function openArticle(a) {
        var url = Engine.safeUrl(a.link)
        if (url) Quickshell.execDetached(["xdg-open", url])
        if (root.prefs.markOnOpen !== false) root.markRead(a.id)
    }

    function openRandom(stream) {
        var article = Engine.randomArticle(root.articles, { stream: stream, blocked: root.blocked })
        if (!article) article = Engine.randomArticle(root.articles, { stream: stream })
        if (article) root.openArticle(article)
        else root.announce(stream === "writing" ? "No writing available yet" : "No news available yet", false)
    }

    function openRandomAny() {
        var article = Engine.randomArticle(root.articles, { blocked: root.blocked })
        if (!article) article = Engine.randomArticle(root.articles, {})
        if (article) root.openArticle(article)
        else root.announce("No stories available yet", false)
    }

    function validateFeedUrl(url, done) {
        var target = String(url || "").trim()
        if (target && !/^https?:\/\//i.test(target)) target = "https://" + target
        if (!Engine.isHttp(target)) {
            if (done) done(false, "Use an http or https feed URL")
            return
        }
        var probe = { id: "probe", name: target, url: target, category: "custom", stream: "writing" }
        Engine.fetchText(target, function(err, text) {
            if (err) {
                if (done) done(false, "Could not fetch this feed")
                return
            }
            try {
                var items = Engine.parseFeed(text, probe, 1, Date.now())
                if (!items.length) {
                    if (done) done(false, "The URL did not contain a readable RSS or Atom entry")
                    return
                }
                if (done) done(true, "")
            } catch (e) {
                if (done) done(false, "The URL is not a readable RSS or Atom feed")
            }
        })
    }

    function resetSetup() {
        root._feedsOverride = null
        root.interests = []
        root.followed = []
        root.savedMap = ({})
        root.savedArticles = []
        root.readMap = ({})
        root.articles = []
        var p = Engine.defaultPrefs()
        if (root.detectedRegion) p.regionId = root.detectedRegion.id
        root.prefs = p
        root.setupDone = false
        root.setSetting("setupDone", "false")
        root.persist()
        Qt.callLater(function() { root.open() })
    }

    // Feed management from Settings UI
    function addFeed(f) {
        var url = String(f.url || "").trim()
        if (url && !/^https?:\/\//i.test(url)) url = "https://" + url
        if (!Engine.isHttp(url)) return
        var list = root.feeds.slice()
        for (var i = 0; i < list.length; i++) if ((f.id && list[i].id === f.id) || list[i].url === url) return
        list.push({ id: f.id || Engine.slug(f.name || url), name: f.name || url.replace(/^https?:\/\//, "").split("/")[0], url: url, category: f.category || "", stream: Engine.normalizeStream(f.stream || f.type, f.category), arxivId: f.arxivId || "", featured: f.featured === true, enabled: true })
        root._feedsOverride = list
        root.persist()
        root.refresh()
    }

    function removeFeed(id) {
        root._feedsOverride = root.feeds.filter(function(f) { return f.id !== id })
        root.followed = root.followed.filter(function(x) { return x !== id })
        root.persist()
        root.refresh()
    }

    function setFeedEnabled(id, on) {
        var list = root.feeds.map(function(f) {
            if (f.id !== id) return f
            var c = Engine.copyMap(f)
            c.enabled = on
            c.silenced = !on
            return c
        })
        root._feedsOverride = list
        root.persist()
        if (on) root.refresh()
    }

    function setFeedStream(id, stream) {
        var list = root.feeds.map(function(f) {
            if (f.id !== id) return f
            var c = Engine.copyMap(f)
            c.stream = Engine.normalizeStream(stream, c.category)
            return c
        })
        root._feedsOverride = list
        root.persist()
        root.refresh()
    }

    function searchArxiv(query, done) {
        Engine.searchArxiv(query, done)
    }

    function addArxivPaper(article) {
        var id = Engine.arxivIdFromUrl(article ? article.link : "")
        if (!id) return false
        root.addFeed({
            id: "arxiv-" + Engine.slug(id),
            arxivId: id,
            name: "arXiv · " + String(article.title || id),
            url: Engine.arxivFeedUrl(id),
            category: "research",
            stream: "research"
        })
        return true
    }

    function setFollowed(id, on) {
        var list = root.followed.slice()
        var i = list.indexOf(id)
        if (on && i < 0) list.push(id)
        if (!on && i >= 0) list.splice(i, 1)
        root.followed = list
        root.persist()
    }

    function toggleInterest(id) {
        var list = root.interests.slice()
        var i = list.indexOf(id)
        if (i >= 0) list.splice(i, 1)
        else list.push(id)
        root.interests = list
        root.persist()
    }

    function addBlocked(phrase) {
        var p = String(phrase || "").trim()
        if (!p) return
        var list = root.blocked.slice()
        if (list.indexOf(p) >= 0) return
        list.push(p)
        root.blocked = list
        root.persist()
    }

    function removeBlocked(phrase) {
        root.blocked = root.blocked.filter(function(x) { return x !== phrase })
        root.persist()
    }

    function setPref(key, value) {
        var p = Engine.copyMap(root.prefs)
        p[key] = value
        root.prefs = p
        root.persist()
    }

    function completeSetup(feedIds, interests, customFeeds, extras) {
        extras = extras || {}
        var list = Catalog.feedsFromIds(feedIds)
        if (!list.length) list = Catalog.feedsFromIds(Catalog.defaultSelection(root.localeHints))
        if (customFeeds && customFeeds.length) {
            for (var ci = 0; ci < customFeeds.length; ci++) {
                var c = customFeeds[ci]
                if (!c || !c.url) continue
                var dup = false
                for (var cj = 0; cj < list.length; cj++) {
                    if (list[cj].url === c.url) { dup = true; break }
                }
                if (dup) continue
                var slug = Engine.slug(c.name || c.url)
                list.push({ id: "custom:" + slug, name: (c.name || c.url), url: c.url, category: c.category || "", stream: Engine.normalizeStream(c.stream || c.type, c.category || "blogs"), enabled: true })
            }
        }
        root._feedsOverride = list
        root.interests = interests || []
        root.followed = list.map(function(f) { return f.id })
        var p = Engine.copyMap(root.prefs)
        if (extras.regionId) p.regionId = extras.regionId
        else if (!p.regionId && root.detectedRegion) p.regionId = root.detectedRegion.id
        if (extras.prefs) {
            for (var pk in extras.prefs) p[pk] = extras.prefs[pk]
        }
        p.researchDefaultMigrated = true
        root.prefs = p
        root.setupDone = true
        root.setSetting("setupDone", "true")
        root.persist()
        root.refresh()
    }

    function copyLink(article) {
        var url = article ? Engine.safeUrl(article.link) : ""
        if (!url) return
        Quickshell.execDetached(["wl-copy", url])
        root.announce("Link copied", false)
    }

    function applyRegion(regionId, addFeeds) {
        root.setPref("regionId", regionId)
        if (!addFeeds) return
        var ids = Catalog.detectLocalFeedIds({ locale: regionId })
        var region = Catalog.findRegion(regionId)
        if (region) ids = ["gnews-" + region.id].concat(region.feeds || [])
        for (var i = 0; i < ids.length; i++) {
            var f = Catalog.find(ids[i])
            if (f) root.addFeed(f)
        }
    }

    function importOpmlText(text) {
        var items = Engine.parseOpml(text)
        var n = 0
        for (var i = 0; i < items.length; i++) {
            var before = root.feeds.length
            root.addFeed(items[i])
            if (root.feeds.length > before) n++
        }
        root.announce(n ? ("Imported " + n + " feeds") : "No new feeds in that OPML", false)
        return n
    }

    function exportOpml() {
        return Engine.toOpml(root.feeds)
    }

    function copyOpml() {
        var xml = root.exportOpml()
        if (!xml) return
        Quickshell.execDetached(["wl-copy", xml])
        root.announce("OPML copied", false)
    }

    Process {
        id: pasteOpml
        command: ["wl-paste"]
        running: false
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.importOpmlText(text)
        }
    }

    function importOpmlClipboard() {
        pasteOpml.running = false
        Qt.callLater(function() { pasteOpml.running = true })
    }

    function visibleStories() {
        return Engine.filterArticles(root.articles, {
            blocked: root.blocked,
            unreadOnly: !!root.prefs.hideRead,
            readMap: root.readMap
        })
    }

    function moveCursor(delta) {
        var list = root.visibleStories()
        if (!list.length) return
        var next = root.cursorIndex + delta
        if (next < 0) next = 0
        if (next > list.length - 1) next = list.length - 1
        root.cursorIndex = next
    }

    function openCursor() {
        var list = root.visibleStories()
        if (!list.length) return
        var i = Math.max(0, Math.min(root.cursorIndex, list.length - 1))
        root.openArticle(list[i])
    }

    function saveCursor() {
        var list = root.visibleStories()
        if (!list.length) return
        var i = Math.max(0, Math.min(root.cursorIndex, list.length - 1))
        root.toggleSaved(list[i])
    }

    function copyCursor() {
        var list = root.visibleStories()
        if (!list.length) return
        var i = Math.max(0, Math.min(root.cursorIndex, list.length - 1))
        root.copyLink(list[i])
    }

    Timer {
        interval: 1500
        running: true
        onTriggered: root.fileReady()
    }

    // ---- panel plumbing --------------------------------------------------

    readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
    readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

    function open() { if (panelLoader.item) panelLoader.item.open() }
    function close() { if (panelLoader.item) panelLoader.item.close() }
    function togglePanel() { if (panelLoader.item) panelLoader.item.toggle() }
    function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch() }
    function stepPage(delta) { if (panelLoader.item && panelLoader.item.stepPage) panelLoader.item.stepPage(delta) }

    function injectPanel() {
        var target = panelLoader.item
        if (!target) return
        if ("bar" in target) target.bar = root.bar
        if ("settings" in target) target.settings = root.settings
        if ("anchorItem" in target) target.anchorItem = button
        if ("hostWidget" in target) target.hostWidget = root
    }

    onBarChanged: injectPanel()
    onSettingsChanged: injectPanel()

    Loader {
        id: panelLoader
        active: true
        source: Qt.resolvedUrl("NewsDashboard.qml")
        visible: false
        onLoaded: {
            root.injectPanel()
            Qt.callLater(root.injectPanel)
        }
    }

    IpcHandler {
        target: "paudelsamir.newsdash"

        function open(): void { root.open() }
        function close(): void { root.close() }
        function show(): void { root.open() }
        function hide(): void { root.close() }
        function toggle(): void { root.togglePanel() }
        function refresh(): void { root.refresh() }
        function resetsetup(): void { root.resetSetup() }
        function markall(): void { root.markAllRead([]) }
    }

    // ---- the capsule (original design preserved) -------------------------

    readonly property int badgeCount: badgeMode === "foryou" ? forYouUnread : unread
    readonly property bool hasUnread: badgeCount > 0
    readonly property bool countVisible: !vertical && (badgeMode === "always" || badgeMode === "foryou" || (badgeMode === "when-unread" && hasUnread))

    // Persist a widget setting back into the bar entry (shell.json), the way
    // the clock panel does: update locally, then let the shell echo the write back.
    function setSetting(name, value) {
        var entry = { id: root.moduleName }
        for (var key in root.settings) if (key !== "id") entry[key] = root.settings[key]
        entry[name] = String(value)
        root.settings = entry
        if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
            root.bar.shell.updateEntryInline(root.moduleName, entry)
    }

    readonly property real openPanelIndicatorWidth: pill.width
    readonly property real openPanelIndicatorHeight: Math.max(Style.space(10), Math.round(Style.bar.iconSlot * 0.55))

    implicitWidth: root.barVisible ? button.implicitWidth : 0
    implicitHeight: root.barVisible ? button.implicitHeight : 0

    WidgetButton {
        id: button
        anchors.fill: parent
        visible: root.barVisible
        bar: root.bar
        text: ""
        labelVisible: false
        hasVisualContent: true
        fixedWidth: root.vertical ? -1 : pill.width + Style.spaceReal(root.barDensity === "compact" ? 5 : 8.5) * 2
        fixedHeight: root.vertical ? Style.bar.iconSlot + Style.space(8) : -1
        tooltipText: root.tooltip

        onPressed: function(b) {
            if (b === Qt.RightButton) root.refresh()
            else if (b === Qt.MiddleButton) root.markAllRead([])
            else root.togglePanel()
        }

        Rectangle {
            id: pill
            anchors.centerIn: parent
              height: Math.round(Style.font.body * (root.barDensity === "compact" ? 1.6 : 1.8))
              width: root.vertical ? height : Math.max(height, content.implicitWidth + Style.space(root.barDensity === "compact" ? 7 : 10))
            radius: height / 2

              color: root.allFailed ? pt.alpha(pt.danger, 0.14)
                  : root.barTone === "light" ? "#ffffff"
                  : root.barTone === "accent" ? pt.alpha(pt.accent, root.hasUnread ? 0.22 : 0.14)
                  : root.barTone === "quiet" ? pt.alpha(button.foreground, 0.045)
                  : root.hasUnread ? pt.alpha(pt.accent, 0.16)
                  : pt.alpha(button.foreground, 0.07)
            border.width: 1
              border.color: root.allFailed ? pt.alpha(pt.danger, 0.4)
                        : root.barTone === "light" ? "#d8d8dc"
                        : root.barTone === "accent" ? pt.alpha(pt.accent, 0.5)
                        : root.barTone === "quiet" ? pt.alpha(button.foreground, 0.1)
                        : root.hasUnread ? pt.alpha(pt.accent, 0.42)
                        : pt.alpha(button.foreground, 0.16)

            Behavior on color { ColorAnimation { duration: pt.dur } }
            Behavior on border.color { ColorAnimation { duration: pt.dur } }
            Behavior on width { NumberAnimation { duration: pt.dur; easing.type: Easing.OutCubic } }

            SequentialAnimation on opacity {
                running: root.loading
                loops: Animation.Infinite
                onRunningChanged: if (!running) pill.opacity = 1
                NumberAnimation { to: 0.55; duration: 650; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1; duration: 650; easing.type: Easing.InOutSine }
            }

            SequentialAnimation {
                id: bump
                NumberAnimation { target: pill; property: "scale"; to: 1.1; duration: 120; easing.type: Easing.OutCubic }
                NumberAnimation { target: pill; property: "scale"; to: 1; duration: 320; easing.type: Easing.OutBack }
            }

            Connections {
                target: root
                function onUnreadChanged() { if (root.startupDone) bump.restart() }
            }

            Row {
                id: content
                anchors.centerIn: parent
                spacing: root.countVisible ? Style.space(5) : 0

                Text {
                    textFormat: Text.PlainText
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.allFailed ? "\uf071" : "\uf1ea"
                    color: root.allFailed ? pt.danger
                        : root.barTone === "light" ? "#111111"
                         : root.hasUnread ? pt.accent
                        : pt.alpha(button.foreground, 0.92)
                    font.family: pt.glyphFont
                    font.pixelSize: Math.round(Style.font.body * 1.0)
                    renderType: Text.NativeRendering
                    Behavior on color { ColorAnimation { duration: pt.dur } }
                }

                Text {
                    textFormat: Text.PlainText
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.countVisible
                    text: Engine.badge(root.badgeCount)
                    color: root.barTone === "light" ? "#111111"
                        : root.hasUnread ? pt.accent : pt.alpha(button.foreground, 0.92)
                    font.family: button.fontFamily
                    font.pixelSize: button.fontSize
                    font.weight: Font.DemiBold
                    font.features: ({ "tnum": 1 })
                    renderType: Text.NativeRendering
                    Behavior on color { ColorAnimation { duration: pt.dur } }
                }
            }

            Rectangle {
                visible: root.hasUnread && (root.badgeMode === "dot" || root.vertical)
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: -Style.space(1)
                anchors.topMargin: -Style.space(1)
                width: Style.space(7)
                height: width
                radius: width / 2
                color: pt.accent
                border.width: 1
                border.color: pt.bg
            }
        }
    }
}
