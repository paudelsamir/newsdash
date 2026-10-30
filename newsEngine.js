.pragma library

// newsEngine.js - async feed fetch, tolerant RSS/Atom parsing, read/saved state.
// Runs in the QML JS engine (XMLHttpRequest, no DOM).

var DEFAULT_FEEDS = [
    { id: "arch",  name: "Arch News",    category: "linux",   url: "https://archlinux.org/feeds/news/" },
    { id: "hn",    name: "Hacker News",  category: "technology", url: "https://hnrss.org/frontpage" },
    { id: "ars",   name: "Ars Technica", category: "technology", url: "https://feeds.arstechnica.com/arstechnica/index" },
    { id: "verge", name: "The Verge",    category: "technology", url: "https://www.theverge.com/rss/index.xml" },
    { id: "bbc",   name: "BBC World",    category: "world",   url: "https://feeds.bbci.co.uk/news/world/rss.xml" },
    { id: "nasa",  name: "NASA",         category: "science", url: "https://www.nasa.gov/feed/" },
    { id: "arxiv-ai", name: "arXiv · AI", category: "research", stream: "research", url: "https://export.arxiv.org/api/query?search_query=cat:cs.AI&start=0&max_results=20&sortBy=submittedDate&sortOrder=descending" },
    { id: "simonw", name: "Simon Willison", category: "blogs", url: "https://simonwillison.net/atom/everything/" },
    { id: "onlinekhabar", name: "Onlinekhabar", category: "local", url: "https://www.onlinekhabar.com/feed" }
]

function slug(text) {
    var s = String(text || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "")
    return s || "feed"
}

function isHttp(url) {
    return /^https?:\/\/[^\s]+$/i.test(String(url || ""))
}

function streamForCategory(category) {
    return String(category || "").toLowerCase() === "blogs" ? "writing" : "news"
}

function normalizeStream(stream, category) {
    var value = String(stream || "").toLowerCase()
    return value === "news" || value === "writing" || value === "research" || value === "other"
        ? value
        : streamForCategory(category)
}

function articleStream(article) {
    return normalizeStream(article && article.stream, article && article.category)
}

function normalizeFeeds(raw) {
    var list = []
    if (Array.isArray(raw)) {
        list = raw
    } else if (typeof raw === "string" && raw.trim() !== "") {
        var lines = raw.split(/\r?\n|;/)
        for (var i = 0; i < lines.length; i++) {
            var parts = lines[i].split("|")
            if (parts.length < 2) continue
            list.push({ name: parts[0].trim(), url: parts[1].trim(), category: (parts[2] || "").trim() })
        }
    }

    var out = []
    var seen = {}
    for (var j = 0; j < list.length; j++) {
        var f = list[j]
        if (!f || !isHttp(f.url)) continue
        var base = slug(f.id || f.name || f.url)
        var id = base
        var n = 2
        while (seen[id]) id = base + "-" + (n++)
        seen[id] = true
        out.push({
            id: id,
            name: String(f.name || f.url).trim(),
            url: String(f.url).trim(),
            category: String(f.category || "").trim(),
            stream: normalizeStream(f.stream || f.type, f.category),
            arxivId: String(f.arxivId || "").trim(),
            featured: f.featured === true,
            enabled: f.enabled !== false,
            silenced: !!f.silenced
        })
    }
    return out.length ? out : DEFAULT_FEEDS.slice()
}

var NAMED_ENTITIES = {
    amp: "&", lt: "<", gt: ">", quot: "\"", apos: "'", nbsp: " ",
    hellip: "\u2026", mdash: "\u2014", ndash: "\u2013",
    lsquo: "\u2018", rsquo: "\u2019", ldquo: "\u201C", rdquo: "\u201D",
    copy: "\u00A9", reg: "\u00AE", trade: "\u2122", middot: "\u00B7", bull: "\u2022"
}

function fromCodePoint(code) {
    if (!isFinite(code) || code <= 0 || code > 0x10FFFF) return ""
    if (code <= 0xFFFF) return String.fromCharCode(code)
    code -= 0x10000
    return String.fromCharCode(0xD800 + (code >> 10), 0xDC00 + (code & 0x3FF))
}

function decodeEntities(text) {
    return String(text).replace(/&(#x[0-9a-f]+|#\d+|[a-z]+);/gi, function (match, g) {
        if (g.charAt(0) === "#") {
            var hex = g.charAt(1) === "x" || g.charAt(1) === "X"
            return fromCodePoint(hex ? parseInt(g.slice(2), 16) : parseInt(g.slice(1), 10))
        }
        var v = NAMED_ENTITIES[g.toLowerCase()]
        return v === undefined ? match : v
    })
}

function plainText(raw) {
    if (!raw) return ""
    var s = String(raw)
    var cdata = /<!\[CDATA\[([\s\S]*?)\]\]>/.exec(s)
    if (cdata) {
        s = s.replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, "$1")
    } else {
        s = decodeEntities(s)
    }
    s = s.replace(/<(script|style)\b[\s\S]*?<\/\1>/gi, " ")
    s = s.replace(/<[^>]*>/g, " ")
    s = decodeEntities(s)
    return s.replace(/\s+/g, " ").trim()
}

function truncate(text, max) {
    if (text.length <= max) return text
    var cut = text.slice(0, max)
    var space = cut.lastIndexOf(" ")
    if (space > max * 0.6) cut = cut.slice(0, space)
    return cut.replace(/[\s.,;:!?-]+$/, "") + "\u2026"
}

function safeUrl(url) {
    var u = String(url || "").trim()
    return /^https?:\/\/[^\s]+$/i.test(u) ? u : ""
}

function escapeRe(s) {
    return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
}

function innerOf(block, names) {
    for (var i = 0; i < names.length; i++) {
        var n = escapeRe(names[i])
        var m = new RegExp("<" + n + "(?:\\s[^>]*)?>([\\s\\S]*?)</" + n + "\\s*>", "i").exec(block)
        if (m) return m[1]
    }
    return ""
}

function atomLink(block) {
    var re = /<link\b([^>]*?)\/?>/gi
    var m
    var fallback = ""
    while ((m = re.exec(block)) !== null) {
        var href = /href\s*=\s*["']([^"']+)["']/i.exec(m[1])
        if (!href) continue
        var rel = /rel\s*=\s*["']([^"']+)["']/i.exec(m[1])
        if (!rel || rel[1] === "alternate") return decodeEntities(href[1])
        if (!fallback) fallback = decodeEntities(href[1])
    }
    return fallback
}

var MONTHS = { jan: 0, feb: 1, mar: 2, apr: 3, may: 4, jun: 5, jul: 6, aug: 7, sep: 8, oct: 9, nov: 10, dec: 11 }
var ZONES = { Z: 0, GMT: 0, UT: 0, UTC: 0, EST: -300, EDT: -240, CST: -360, CDT: -300, MST: -420, MDT: -360, PST: -480, PDT: -420 }

function parseDate(text) {
    var s = String(text || "").trim()
    if (!s) return 0
    var t = Date.parse(s)
    if (isFinite(t)) return t
    var m = /(\d{1,2})\s+([A-Za-z]{3})[A-Za-z]*\s+(\d{2,4})\s+(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([+-]\d{4}|[A-Za-z]{1,4})?/.exec(s)
    if (!m) return 0
    var mon = MONTHS[m[2].toLowerCase()]
    if (mon === undefined) return 0
    var year = parseInt(m[3], 10)
    if (year < 100) year += year < 50 ? 2000 : 1900
    var offset = 0
    if (m[7]) {
        if (/^[+-]\d{4}$/.test(m[7])) {
            var sign = m[7].charAt(0) === "-" ? -1 : 1
            offset = sign * (parseInt(m[7].slice(1, 3), 10) * 60 + parseInt(m[7].slice(3, 5), 10))
        } else if (ZONES[m[7].toUpperCase()] !== undefined) {
            offset = ZONES[m[7].toUpperCase()]
        }
    }
    return Date.UTC(year, mon, parseInt(m[1], 10), parseInt(m[4], 10), parseInt(m[5], 10), parseInt(m[6] || "0", 10)) - offset * 60000
}

function hash(text) {
    var h = 5381
    for (var i = 0; i < text.length; i++) h = ((h << 5) + h + text.charCodeAt(i)) | 0
    return (h >>> 0).toString(36)
}

function parseFeed(xml, feed, limit, now) {
    var text = String(xml || "")
    var blocks = text.match(/<item\b[\s\S]*?<\/item\s*>/gi)
    var atom = false
    if (!blocks || blocks.length === 0) {
        blocks = text.match(/<entry\b[\s\S]*?<\/entry\s*>/gi)
        atom = true
    }
    if (!blocks || blocks.length === 0) {
        if (!/<(rss|feed|rdf:RDF)\b/i.test(text)) throw new Error("Not a feed")
        return []
    }

    var ceiling = (now || Date.now()) + 86400000
    var out = []
    for (var i = 0; i < blocks.length; i++) {
        var b = blocks[i]
        var title = plainText(innerOf(b, ["title"]))
        var link = atom ? atomLink(b) : plainText(innerOf(b, ["link"]))
        if (!link) link = atomLink(b)
        link = safeUrl(link)
        if (!title || !link) continue

        var guid = plainText(innerOf(b, atom ? ["id"] : ["guid"])) || link
        var published = parseDate(plainText(innerOf(b, ["pubDate", "published", "updated", "dc:date", "date"])))
        if (!published) published = (now || Date.now())
        if (published > ceiling) published = now || Date.now()

        var summary = plainText(innerOf(b, ["description", "summary", "content:encoded", "content"]))
        if (summary === title) summary = ""

        out.push({
            id: feed.id + ":" + hash(guid),
            feedId: feed.id,
            source: feed.name,
            category: feed.category || "",
            stream: normalizeStream(feed.stream, feed.category),
            title: truncate(title, 180),
            link: link,
            summary: truncate(summary, 240),
            published: published
        })
    }
    out.sort(function (a, c) { return c.published - a.published })
    return limit > 0 ? out.slice(0, limit) : out
}

var MAX_FEED_BYTES = 1500000

function fetchText(url, done) {
    var xhr = new XMLHttpRequest()
    var finished = false
    function finish(err, text) {
        if (finished) return
        finished = true
        done(err, text)
    }
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== XMLHttpRequest.DONE) return
        if (xhr.status >= 200 && xhr.status < 300) {
            var text = xhr.responseText || ""
            if (text.length > MAX_FEED_BYTES) text = text.slice(0, MAX_FEED_BYTES)
            finish(null, text)
        } else finish(new Error("HTTP " + xhr.status), "")
    }
    xhr.onerror = function () { finish(new Error("Network error"), "") }
    xhr.ontimeout = function () { finish(new Error("Timed out"), "") }
    try {
        xhr.open("GET", url)
        xhr.timeout = 20000
        xhr.setRequestHeader("Accept", "application/rss+xml, application/atom+xml, application/xml, text/xml, */*")
        xhr.setRequestHeader("User-Agent", "NewsDash/2.1 (Omarchy; RSS reader)")
        xhr.send()
    } catch (e) {
        finish(e, "")
    }
    return {
        abort: function () { try { xhr.abort() } catch (e) {} finish(new Error("Timed out"), "") }
    }
}

function arxivIdFromUrl(url) {
    var match = /arxiv\.org\/(?:abs|pdf)\/([^?#]+?)(?:\.pdf)?$/i.exec(String(url || ""))
    return match ? match[1] : ""
}

function arxivFeedUrl(id) {
    var value = String(id || "").trim()
    return value ? "https://export.arxiv.org/api/query?id_list=" + encodeURIComponent(value) : ""
}

function searchArxiv(query, done) {
    var term = String(query || "").trim().slice(0, 160)
    if (!term) {
        if (done) done(null, [])
        return
    }
    var url = "https://export.arxiv.org/api/query?search_query=all:" + encodeURIComponent(term)
        + "&start=0&max_results=8&sortBy=submittedDate&sortOrder=descending"
    fetchText(url, function(err, text) {
        if (err) {
            if (done) done(err, [])
            return
        }
        try {
            var papers = parseFeed(text, { id: "arxiv-search", name: "arXiv", category: "research", stream: "research" }, 8, Date.now())
            if (done) done(null, papers)
        } catch (e) {
            if (done) done(e, [])
        }
    })
}

function refreshAll(feeds, opts, onProgress, onDone) {
    opts = opts || {}
    var perFeed = opts.perFeed || 20
    var concurrency = opts.concurrency || 4
    var active = []
    var queue = []
    var results = []
    var status = {}
    var done = 0
    var aborted = false
    var now = Date.now()

    for (var i = 0; i < feeds.length; i++) {
        if (feeds[i].enabled === false || feeds[i].silenced) {
            status[feeds[i].id] = { ok: true, skipped: true, count: 0 }
            done++
            continue
        }
        queue.push(feeds[i])
    }

    function report() {
        if (onProgress) onProgress(done, feeds.length)
    }

    function finishOne() {
        done++
        report()
        if (done >= feeds.length) {
            results.sort(function (a, c) { return c.published - a.published })
            onDone({ articles: results, status: status })
        } else {
            pump()
        }
    }

    function pump() {
        while (active.length < concurrency && queue.length > 0 && !aborted) {
            (function (feed) {
                var handle = fetchText(feed.url, function (err, text) {
                    var idx = active.indexOf(handle)
                    if (idx >= 0) active.splice(idx, 1)
                    if (aborted) return
                    if (err) {
                        status[feed.id] = { ok: false, error: String(err.message || err), count: 0 }
                    } else {
                        try {
                            var items = parseFeed(text, feed, perFeed, now)
                            for (var k = 0; k < items.length; k++) results.push(items[k])
                            status[feed.id] = { ok: true, count: items.length }
                        } catch (e) {
                            status[feed.id] = { ok: false, error: String(e.message || e), count: 0 }
                        }
                    }
                    finishOne()
                })
                active.push(handle)
            })(queue.shift())
        }
    }

    report()
    if (queue.length === 0) {
        onDone({ articles: [], status: status })
        return { abort: function () {} }
    }
    pump()
    return {
        abort: function () {
            aborted = true
            for (var i = 0; i < active.length; i++) active[i].abort()
            active = []
            // complete remaining as timed out
            while (queue.length) {
                var f = queue.shift()
                status[f.id] = { ok: false, error: "Timed out", count: 0 }
                done++
            }
            report()
            onDone({ articles: results, status: status })
        }
    }
}

function copyMap(m) {
    var o = {}
    for (var k in m) if (Object.prototype.hasOwnProperty.call(m, k)) o[k] = m[k]
    return o
}

function countUnread(articles, readMap) {
    var n = 0
    for (var i = 0; i < articles.length; i++) if (!readMap[articles[i].id]) n++
    return n
}

function unreadBySource(articles, readMap) {
    var o = {}
    for (var i = 0; i < articles.length; i++) {
        var a = articles[i]
        if (readMap[a.id]) continue
        o[a.feedId] = (o[a.feedId] || 0) + 1
    }
    return o
}

function pruneRead(readMap, articles) {
    var keep = {}
    var ids = {}
    for (var i = 0; i < articles.length; i++) ids[articles[i].id] = true
    for (var k in readMap) if (ids[k]) keep[k] = readMap[k]
    return keep
}

function carryOver(fresh, previous, status) {
    // Keep articles from failed feeds so a temporary outage does not wipe them
    var out = fresh.slice()
    var seen = {}
    for (var i = 0; i < out.length; i++) seen[out[i].id] = true
    for (var j = 0; j < previous.length; j++) {
        var a = previous[j]
        if (seen[a.id]) continue
        var st = status[a.feedId]
        if (st && !st.ok) {
            out.push(a)
            seen[a.id] = true
        }
    }
    out.sort(function (a, c) { return c.published - a.published })
    return out
}

function timeAgo(ts, now) {
    var s = Math.max(0, Math.floor(((now || Date.now()) - ts) / 1000))
    if (s < 45) return "now"
    if (s < 3600) return Math.floor(s / 60) + "m"
    if (s < 86400) return Math.floor(s / 3600) + "h"
    if (s < 604800) return Math.floor(s / 86400) + "d"
    return Math.floor(s / 604800) + "w"
}

function badge(n) {
    return String(n)
}

function greeting(now) {
    var h = (now ? new Date(now) : new Date()).getHours()
    if (h < 5) return "Good night"
    if (h < 12) return "Good morning"
    if (h < 17) return "Good afternoon"
    return "Good evening"
}

function weekdayName(now) {
    var d = now ? new Date(now) : new Date()
    return ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][d.getDay()]
}

function monthDay(now) {
    var d = now ? new Date(now) : new Date()
    var months = ["January", "February", "March", "April", "May", "June",
                  "July", "August", "September", "October", "November", "December"]
    return months[d.getMonth()] + " " + d.getDate()
}

function parseState(text) {
    try {
        var o = JSON.parse(text || "{}")
        if (!o || typeof o !== "object") return null
        return {
            updatedAt: o.updatedAt || 0,
            fetchedAt: o.fetchedAt || 0,
            articles: Array.isArray(o.articles) ? o.articles : [],
            read: o.read && typeof o.read === "object" ? o.read : {},
            saved: o.saved && typeof o.saved === "object" ? o.saved : {},
            status: o.status && typeof o.status === "object" ? o.status : {},
            followed: Array.isArray(o.followed) ? o.followed : [],
            blocked: Array.isArray(o.blocked) ? o.blocked : [],
            interests: Array.isArray(o.interests) ? o.interests : [],
            setupDone: !!o.setupDone,
            prefs: (function () {
                var d = defaultPrefs()
                if (o.prefs && typeof o.prefs === "object") {
                    for (var k in o.prefs) d[k] = o.prefs[k]
                }
                return d
            })(),
            feedsOverride: Array.isArray(o.feedsOverride) ? o.feedsOverride : null,
            savedArticles: Array.isArray(o.savedArticles) ? o.savedArticles.slice(0, 200) : []
        }
    } catch (e) {
        return null
    }
}

function serializeState(s) {
    return JSON.stringify({
        updatedAt: s.updatedAt || 0,
        fetchedAt: s.fetchedAt || 0,
        articles: s.articles || [],
        read: s.read || {},
        saved: s.saved || {},
        status: s.status || {},
        followed: s.followed || [],
        blocked: s.blocked || [],
        interests: s.interests || [],
        setupDone: !!s.setupDone,
        prefs: s.prefs || {},
        feedsOverride: s.feedsOverride || null,
        savedArticles: Array.isArray(s.savedArticles) ? s.savedArticles.slice(0, 200) : []
    })
}

function isBlocked(article, blocked) {
    if (!blocked || !blocked.length) return false
    var hay = (article.title + " " + (article.summary || "")).toLowerCase()
    for (var i = 0; i < blocked.length; i++) {
        var phrase = String(blocked[i] || "").toLowerCase().trim()
        if (phrase && hay.indexOf(phrase) >= 0) return true
    }
    return false
}

function filterArticles(articles, opts) {
    opts = opts || {}
    var out = []
    var max = opts.limit > 0 ? opts.limit : 0
    for (var i = 0; i < articles.length; i++) {
        var a = articles[i]
        if (opts.blocked && isBlocked(a, opts.blocked)) continue
        if (opts.feedId && opts.feedId !== "all" && a.feedId !== opts.feedId) continue
        if (opts.category && a.category !== opts.category) continue
        if (opts.stream && articleStream(a) !== opts.stream) continue
        if (opts.unreadOnly && opts.readMap && opts.readMap[a.id]) continue
        if (opts.savedOnly && opts.savedMap && !opts.savedMap[a.id]) continue
        if (opts.followedOnly && opts.followed && opts.followed.indexOf(a.feedId) < 0) continue
        if (opts.interestOnly && opts.interests && opts.interests.length) {
            if (opts.interests.indexOf(a.category) < 0 && a.category !== "local") continue
        }
        if (opts.query) {
            var q = String(opts.query).toLowerCase()
            if ((a.title + " " + a.source + " " + (a.summary || "")).toLowerCase().indexOf(q) < 0) continue
        }
        out.push(a)
        if (max && out.length >= max) break
    }
    return out
}

function randomArticle(articles, opts) {
    var list = filterArticles(articles || [], opts || {})
    if (!list.length) return null
    return list[Math.floor(Math.random() * list.length)]
}

function scoreArticle(article, opts) {
    opts = opts || {}
    var now = opts.now || Date.now()
    var ageH = Math.max(0, (now - (article.published || now)) / 3600000)
    var recency = Math.max(0, 48 - ageH)
    var unread = opts.readMap && opts.readMap[article.id] ? 0 : 18
    var local = article.category === "local" ? 14 : 0
    var interest = 0
    if (opts.interests && opts.interests.length && article.category)
        interest = opts.interests.indexOf(article.category) >= 0 ? 10 : 0
    var followed = 0
    if (opts.followed && opts.followed.length)
        followed = opts.followed.indexOf(article.feedId) >= 0 ? 6 : 0
    return recency + unread + local + interest + followed
}

function rankForYou(articles, opts) {
    var list = articles.slice()
    list.sort(function (a, c) {
        var ds = scoreArticle(c, opts) - scoreArticle(a, opts)
        if (ds !== 0) return ds
        return (c.published || 0) - (a.published || 0)
    })
    return opts && opts.limit > 0 ? list.slice(0, opts.limit) : list
}

function sortUnreadFirst(articles, readMap) {
    var list = articles.slice()
    list.sort(function (a, c) {
        var ar = readMap && readMap[a.id] ? 1 : 0
        var cr = readMap && readMap[c.id] ? 1 : 0
        if (ar !== cr) return ar - cr
        return (c.published || 0) - (a.published || 0)
    })
    return list
}

function toOpml(feeds) {
    var lines = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        "<opml version=\"2.0\">",
        "  <head><title>NewsDash</title></head>",
        "  <body>"
    ]
    for (var i = 0; i < feeds.length; i++) {
        var f = feeds[i]
        if (!f || !f.url) continue
        var title = String(f.name || f.url).replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;")
        var url = String(f.url).replace(/&/g, "&amp;").replace(/"/g, "&quot;")
        lines.push("    <outline type=\"rss\" text=\"" + title + "\" title=\"" + title + "\" xmlUrl=\"" + url + "\" category=\"" + String(f.category || "") + "\"/>")
    }
    lines.push("  </body>", "</opml>")
    return lines.join("\n")
}

function parseOpml(text) {
    var out = []
    var re = /<outline\b([^>]*)\/?>/gi
    var m
    while ((m = re.exec(String(text || ""))) !== null) {
        var attrs = m[1]
        var url = /xmlUrl\s*=\s*["']([^"']+)["']/i.exec(attrs)
            || /url\s*=\s*["']([^"']+)["']/i.exec(attrs)
        if (!url) continue
        var href = decodeEntities(url[1])
        if (!isHttp(href)) continue
        var title = /(?:title|text)\s*=\s*["']([^"']+)["']/i.exec(attrs)
        var cat = /category\s*=\s*["']([^"']+)["']/i.exec(attrs)
        out.push({
            name: title ? decodeEntities(title[1]) : href.replace(/^https?:\/\//, "").split("/")[0],
            url: href,
            category: cat ? decodeEntities(cat[1]) : "custom"
        })
        if (out.length >= 80) break
    }
    return out
}

function defaultPrefs() {
    return {
        headlinesOnly: true,
        dense: false,
        markOnOpen: true,
        quietHours: false,
        dailyBriefing: true,
        notifyUnread: false,
        notifyAt: 5,
        hideRead: false,
        unreadFirst: false,
        forYouLimit: 8,
        researchDefaultMigrated: false,
        frosted: true,
        fontScale: 1,
        maxHome: 60,
        regionId: "",
        openExternal: true
    }
}

function highlights(articles, readMap, limit) {
    // Prefer unread, diversify by source, newest first
    limit = limit || 8
    var bySource = {}
    var picked = []
    var candidates = articles.slice().sort(function (a, c) {
        var ar = readMap && readMap[a.id] ? 1 : 0
        var cr = readMap && readMap[c.id] ? 1 : 0
        if (ar !== cr) return ar - cr
        return c.published - a.published
    })
    for (var i = 0; i < candidates.length && picked.length < limit; i++) {
        var a = candidates[i]
        var n = bySource[a.feedId] || 0
        if (n >= 2) continue
        bySource[a.feedId] = n + 1
        picked.push(a)
    }
    return picked
}
