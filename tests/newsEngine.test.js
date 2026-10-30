const fs = require("fs")
const path = require("path")
const src = fs.readFileSync(path.join(__dirname, "..", "newsEngine.js"), "utf8").replace(/^\.pragma library\n/, "")
eval(src)

function assert(cond, msg) {
    if (!cond) throw new Error(msg)
}

const markup = {
    id: "x",
    title: '<img src="https://example.invalid/tracker">Hello',
    source: "Test",
    summary: "<b>bold</b> dek",
    category: "world",
    feedId: "t",
    published: 1
}

assert(plainText(markup.title) === "Hello", "plainText strips img")
assert(plainText(markup.summary) === "bold dek", "plainText strips b")

const blocked = filterArticles([markup, { id: "y", title: "Keep me", source: "A", category: "world", feedId: "t", published: 2 }], {
    blocked: ["hello"]
})
assert(blocked.length === 1 && blocked[0].id === "y", "blocked phrase hides title match")

const unread = filterArticles([
    { id: "a", title: "A", feedId: "f", category: "tech", published: 2 },
    { id: "b", title: "B", feedId: "f", category: "tech", published: 1 }
], { unreadOnly: true, readMap: { a: 1 } })
assert(unread.length === 1 && unread[0].id === "b", "unreadOnly drops read ids")

const cat = filterArticles([
    { id: "a", title: "A", feedId: "f", category: "local", published: 1 },
    { id: "b", title: "B", feedId: "f", category: "tech", published: 1 }
], { category: "local" })
assert(cat.length === 1 && cat[0].id === "a", "category filter")

const streams = filterArticles([
        { id: "n", title: "News", feedId: "n", category: "world", stream: "news", published: 2 },
        { id: "w", title: "Essay", feedId: "w", category: "blogs", stream: "writing", published: 1 }
], { stream: "writing" })
assert(streams.length === 1 && streams[0].id === "w", "stream filter")
assert(normalizeStream("", "blogs") === "writing", "blogs normalize to writing")

const atom = parseFeed(`<feed xmlns="http://www.w3.org/2005/Atom">
    <entry><title>Essay</title><id>tag:example,2026:1</id>
        <link rel="alternate" href="https://example.com/essay"/>
        <updated>2026-10-30T10:00:00Z</updated>
    </entry>
</feed>`, { id: "atom", name: "Example", category: "blogs", stream: "writing" }, 5, Date.now())
assert(atom.length === 1 && atom[0].stream === "writing" && atom[0].link === "https://example.com/essay", "Atom stream parsing")
assert(arxivIdFromUrl("https://arxiv.org/abs/2401.12345v2") === "2401.12345v2", "arXiv id extraction")
assert(arxivFeedUrl("2401.12345").indexOf("https://export.arxiv.org/api/query?id_list=2401.12345") === 0, "arXiv feed URL")
assert(badge(120) === "120", "badge keeps full unread count")

const opml = parseOpml(`<opml><body>
  <outline type="rss" text="Example" xmlUrl="https://example.com/feed.xml" category="blogs"/>
  <outline xmlUrl="javascript:alert(1)"/>
</body></opml>`)
assert(opml.length === 1 && opml[0].url.indexOf("https://") === 0, "OPML keeps only http(s)")

const state = parseState(JSON.stringify({
    setupDone: true,
    prefs: { dense: true },
    articles: [{ id: "1", title: "t" }]
}))
assert(state.setupDone === true, "parseState setupDone")
assert(state.prefs.dense === true, "parseState merges prefs")
assert(state.prefs.frosted === true, "parseState default prefs remain")

const xml = toOpml([{ name: 'A & "B"', url: "https://example.com/rss" }])
assert(xml.indexOf("&amp;") >= 0 && xml.indexOf("&quot;") >= 0, "OPML escapes title")

console.log("newsEngine tests ok")
