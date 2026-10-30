.pragma library

// Curated RSS / Atom catalog + region autodetect for first-run setup.
// Categories match the interest chips in setup and personalization.

var CATEGORIES = [
    { id: "technology", label: "Technology", icon: "\uf121" },
    { id: "business",   label: "Business",   icon: "\uf201" },
    { id: "science",    label: "Science",    icon: "\uf0c3" },
    { id: "research",   label: "Papers / Research", icon: "\uf02d" },
    { id: "politics",   label: "Politics",   icon: "\uf19c" },
    { id: "world",      label: "World",      icon: "\uf57d" },
    { id: "sports",     label: "Sports",     icon: "\uf1e3" },
    { id: "culture",    label: "Culture",    icon: "\uf1fc" },
    { id: "blogs",      label: "Blogs",      icon: "\uf15c" },
    { id: "local",      label: "Local",      icon: "\uf3c5" },
    { id: "linux",      label: "Linux",      icon: "\uf17c" }
]

// Regions drive local autodetect. hl/gl/ceid feed Google News RSS.
var REGIONS = [
    { id: "np", name: "Nepal", country: "NP", langs: ["ne", "ne_np"], tz: ["asia/kathmandu"], offset: [330, 345], hl: "en-NP", gl: "NP", ceid: "NP:en", feeds: ["onlinekhabar", "bbc-nepali", "kathmandupost", "setopati"] },
    { id: "in", name: "India", country: "IN", langs: ["hi", "hi_in", "en_in"], tz: ["asia/kolkata", "asia/calcutta"], offset: [330, 330], hl: "en-IN", gl: "IN", ceid: "IN:en", feeds: ["thehindu", "indianexpress", "toi", "mint"] },
    { id: "pk", name: "Pakistan", country: "PK", langs: ["ur", "ur_pk", "en_pk"], tz: ["asia/karachi"], offset: [300, 300], hl: "en-PK", gl: "PK", ceid: "PK:en", feeds: ["dawn"] },
    { id: "bd", name: "Bangladesh", country: "BD", langs: ["bn", "bn_bd"], tz: ["asia/dhaka"], offset: [360, 360], hl: "en-BD", gl: "BD", ceid: "BD:en", feeds: ["thedailystar"] },
    { id: "us", name: "United States", country: "US", langs: ["en_us"], tz: ["america/new_york", "america/chicago", "america/denver", "america/los_angeles", "america/phoenix", "america/anchorage", "pacific/honolulu"], offset: [-600, -240], hl: "en-US", gl: "US", ceid: "US:en", feeds: ["npr", "ap", "politico"] },
    { id: "gb", name: "United Kingdom", country: "GB", langs: ["en_gb"], tz: ["europe/london"], offset: [0, 60], hl: "en-GB", gl: "GB", ceid: "GB:en", feeds: ["bbc-news", "bbc-world", "guardian", "bbc-sport"] },
    { id: "ie", name: "Ireland", country: "IE", langs: ["en_ie", "ga"], tz: ["europe/dublin"], offset: [0, 60], hl: "en-IE", gl: "IE", ceid: "IE:en", feeds: ["irishtimes"] },
    { id: "ca", name: "Canada", country: "CA", langs: ["en_ca", "fr_ca"], tz: ["america/toronto", "america/vancouver", "america/edmonton", "america/winnipeg", "america/halifax"], offset: [-480, -210], hl: "en-CA", gl: "CA", ceid: "CA:en", feeds: ["cbc"] },
    { id: "au", name: "Australia", country: "AU", langs: ["en_au"], tz: ["australia/sydney", "australia/melbourne", "australia/brisbane", "australia/perth", "australia/adelaide"], offset: [480, 660], hl: "en-AU", gl: "AU", ceid: "AU:en", feeds: ["abc-au"] },
    { id: "nz", name: "New Zealand", country: "NZ", langs: ["en_nz", "mi"], tz: ["pacific/auckland"], offset: [720, 780], hl: "en-NZ", gl: "NZ", ceid: "NZ:en", feeds: ["rnz"] },
    { id: "de", name: "Germany", country: "DE", langs: ["de", "de_de"], tz: ["europe/berlin"], offset: [60, 120], hl: "de", gl: "DE", ceid: "DE:de", feeds: ["spiegel", "dw"] },
    { id: "fr", name: "France", country: "FR", langs: ["fr", "fr_fr"], tz: ["europe/paris"], offset: [60, 120], hl: "fr", gl: "FR", ceid: "FR:fr", feeds: ["lemonde"] },
    { id: "es", name: "Spain", country: "ES", langs: ["es", "es_es"], tz: ["europe/madrid"], offset: [60, 120], hl: "es", gl: "ES", ceid: "ES:es", feeds: ["elpais"] },
    { id: "it", name: "Italy", country: "IT", langs: ["it", "it_it"], tz: ["europe/rome"], offset: [60, 120], hl: "it", gl: "IT", ceid: "IT:it", feeds: ["ansa"] },
    { id: "nl", name: "Netherlands", country: "NL", langs: ["nl", "nl_nl"], tz: ["europe/amsterdam"], offset: [60, 120], hl: "nl", gl: "NL", ceid: "NL:nl", feeds: ["nos"] },
    { id: "se", name: "Sweden", country: "SE", langs: ["sv", "sv_se"], tz: ["europe/stockholm"], offset: [60, 120], hl: "sv", gl: "SE", ceid: "SE:sv", feeds: ["svt"] },
    { id: "jp", name: "Japan", country: "JP", langs: ["ja", "ja_jp"], tz: ["asia/tokyo"], offset: [540, 540], hl: "ja", gl: "JP", ceid: "JP:ja", feeds: ["nhk"] },
    { id: "sg", name: "Singapore", country: "SG", langs: ["en_sg"], tz: ["asia/singapore"], offset: [480, 480], hl: "en-SG", gl: "SG", ceid: "SG:en", feeds: ["cna"] },
    { id: "br", name: "Brazil", country: "BR", langs: ["pt", "pt_br"], tz: ["america/sao_paulo"], offset: [-180, -120], hl: "pt-BR", gl: "BR", ceid: "BR:pt-419", feeds: ["folha"] },
    { id: "za", name: "South Africa", country: "ZA", langs: ["en_za", "af"], tz: ["africa/johannesburg"], offset: [120, 120], hl: "en-ZA", gl: "ZA", ceid: "ZA:en", feeds: ["mg"] },
    { id: "world", name: "International", country: "", langs: [], tz: [], offset: [], hl: "en", gl: "US", ceid: "US:en", feeds: ["bbc-world", "guardian", "aljazeera"] }
]

var FEEDS = [
    // Technology
    { id: "hn", name: "Hacker News", category: "technology", url: "https://hnrss.org/frontpage" },
    { id: "ars", name: "Ars Technica", category: "technology", url: "https://feeds.arstechnica.com/arstechnica/index" },
    { id: "verge", name: "The Verge", category: "technology", url: "https://www.theverge.com/rss/index.xml" },
    { id: "techcrunch", name: "TechCrunch", category: "technology", url: "https://techcrunch.com/feed/" },
    { id: "wired", name: "Wired", category: "technology", url: "https://www.wired.com/feed/rss" },
    { id: "register", name: "The Register", category: "technology", url: "https://www.theregister.com/headlines.atom" },
    { id: "9to5mac", name: "9to5Mac", category: "technology", url: "https://9to5mac.com/feed/" },
    { id: "bleeping", name: "BleepingComputer", category: "technology", url: "https://www.bleepingcomputer.com/feed/" },
    { id: "mittr", name: "MIT Tech Review", category: "technology", url: "https://www.technologyreview.com/feed" },
    { id: "404media", name: "404 Media", category: "technology", url: "https://www.404media.co/rss" },

    // Business
    { id: "economist", name: "The Economist", category: "business", url: "https://www.economist.com/latest/rss.xml" },
    { id: "cnbc", name: "CNBC Business", category: "business", url: "https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=10001147" },
    { id: "ft", name: "Financial Times", category: "business", url: "https://www.ft.com/?format=rss" },
    { id: "bloomberg-tech", name: "Bloomberg Tech", category: "business", url: "https://feeds.bloomberg.com/technology/news.rss" },
    { id: "wsj-world", name: "WSJ World", category: "business", url: "https://feeds.content.dowjones.io/public/rss/RSSWorldNews" },
    { id: "mint", name: "Mint", category: "business", region: "in", url: "https://www.livemint.com/rss/companies" },

    // Science
    { id: "nasa", name: "NASA", category: "science", url: "https://www.nasa.gov/feed/" },
    { id: "nature", name: "Nature", category: "science", stream: "research", url: "https://www.nature.com/nature.rss" },
    { id: "newscientist", name: "New Scientist", category: "science", url: "https://www.newscientist.com/feed/" },
    { id: "livescience", name: "Live Science", category: "science", url: "https://www.livescience.com/feeds/all" },
    { id: "sciencenews", name: "Science News", category: "science", stream: "research", url: "https://www.sciencenews.org/feed" },
    { id: "physorg", name: "Phys.org", category: "science", url: "https://phys.org/rss-feed/" },

    // Research
    { id: "arxiv-ai", name: "arXiv · AI", category: "research", stream: "research", url: "https://export.arxiv.org/api/query?search_query=cat:cs.AI&start=0&max_results=20&sortBy=submittedDate&sortOrder=descending" },

    // Politics
    { id: "politico", name: "Politico", category: "politics", region: "us", url: "https://rss.politico.com/politics-news.xml" },
    { id: "thehill", name: "The Hill", category: "politics", region: "us", url: "https://thehill.com/homenews/feed/" },
    { id: "axios", name: "Axios", category: "politics", url: "https://api.axios.com/feed" },
    { id: "propublica", name: "ProPublica", category: "politics", url: "https://www.propublica.org/feeds/propublica/main" },

    // World
    { id: "bbc-world", name: "BBC World", category: "world", url: "https://feeds.bbci.co.uk/news/world/rss.xml" },
    { id: "bbc-news", name: "BBC News", category: "world", region: "gb", url: "https://feeds.bbci.co.uk/news/rss.xml" },
    { id: "guardian", name: "The Guardian", category: "world", url: "https://www.theguardian.com/world/rss" },
    { id: "aljazeera", name: "Al Jazeera", category: "world", url: "https://www.aljazeera.com/xml/rss/all.xml" },
    { id: "reuters", name: "Reuters", category: "world", url: "https://news.google.com/rss/search?q=when:24h+site:reuters.com&ceid=US:en&hl=en-US&gl=US" },
    { id: "npr", name: "NPR", category: "world", region: "us", url: "https://feeds.npr.org/1001/rss.xml" },
    { id: "ap", name: "AP Top News", category: "world", region: "us", url: "https://rsshub.app/apnews/topics/apf-topnews" },
    { id: "dw", name: "Deutsche Welle", category: "world", url: "https://rss.dw.com/rdf/rss-en-all" },

    // Sports
    { id: "bbc-sport", name: "BBC Sport", category: "sports", url: "https://feeds.bbci.co.uk/sport/rss.xml" },
    { id: "espn", name: "ESPN", category: "sports", url: "https://www.espn.com/espn/rss/news" },
    { id: "sky-sport", name: "Sky Sports", category: "sports", url: "https://www.skysports.com/rss/12040" },

    // Culture
    { id: "nytimes-arts", name: "NYT Arts", category: "culture", url: "https://rss.nytimes.com/services/xml/rss/nyt/Arts.xml" },
    { id: "vox", name: "Vox", category: "culture", url: "https://www.vox.com/rss/index.xml" },
    { id: "atlantic", name: "The Atlantic", category: "culture", url: "https://www.theatlantic.com/feed/all" },
    { id: "newyorker", name: "The New Yorker", category: "culture", url: "https://www.newyorker.com/feed/everything" },

    // Blogs
    { id: "simonw", name: "Simon Willison", category: "blogs", url: "https://simonwillison.net/atom/everything/" },
    { id: "paulg", name: "Paul Graham", category: "blogs", url: "http://www.aaronsw.com/2002/feeds/pgessays.rss" },
    { id: "daringfireball", name: "Daring Fireball", category: "blogs", url: "https://daringfireball.net/feeds/main" },
    { id: "kottke", name: "Kottke", category: "blogs", url: "https://feeds.kottke.org/main" },
    { id: "stratechery", name: "Stratechery", category: "blogs", url: "https://stratechery.com/feed/" },
    { id: "marginalia", name: "Marginal Revolution", category: "blogs", url: "https://marginalrevolution.com/feed" },
    { id: "lesswrong", name: "LessWrong", category: "blogs", url: "https://www.lesswrong.com/feed.xml" },
    { id: "gwern", name: "Gwern", category: "blogs", url: "https://www.gwern.net/atom.xml" },

    // Linux / FOSS
    { id: "arch", name: "Arch News", category: "linux", url: "https://archlinux.org/feeds/news/" },
    { id: "lwn", name: "LWN", category: "linux", url: "https://lwn.net/headlines/rss" },
    { id: "phoronix", name: "Phoronix", category: "linux", url: "https://www.phoronix.com/rss.php" },
    { id: "omarchy", name: "Omarchy", category: "linux", url: "https://omarchy.org/feed.xml" },

    // Local / regional
    { id: "onlinekhabar", name: "Onlinekhabar", category: "local", region: "np", url: "https://www.onlinekhabar.com/feed" },
    { id: "bbc-nepali", name: "BBC Nepali", category: "local", region: "np", url: "https://feeds.bbci.co.uk/nepali/rss.xml" },
    { id: "kathmandupost", name: "Kathmandu Post", category: "local", region: "np", url: "https://kathmandupost.com/rss" },
    { id: "setopati", name: "Setopati", category: "local", region: "np", url: "https://www.setopati.com/feed" },
    { id: "thehindu", name: "The Hindu", category: "local", region: "in", url: "https://www.thehindu.com/news/national/feeder/default.rss" },
    { id: "indianexpress", name: "Indian Express", category: "local", region: "in", url: "https://indianexpress.com/feed/" },
    { id: "toi", name: "Times of India", category: "local", region: "in", url: "https://timesofindia.indiatimes.com/rssfeedstopstories.cms" },
    { id: "dawn", name: "Dawn", category: "local", region: "pk", url: "https://www.dawn.com/feeds/home" },
    { id: "thedailystar", name: "The Daily Star", category: "local", region: "bd", url: "https://www.thedailystar.net/rss.xml" },
    { id: "cbc", name: "CBC", category: "local", region: "ca", url: "https://www.cbc.ca/webfeed/rss/rss-topstories" },
    { id: "abc-au", name: "ABC News AU", category: "local", region: "au", url: "https://www.abc.net.au/news/feed/51120/rss.xml" },
    { id: "rnz", name: "RNZ", category: "local", region: "nz", url: "https://www.rnz.co.nz/rss/national.xml" },
    { id: "spiegel", name: "Spiegel International", category: "local", region: "de", url: "https://www.spiegel.de/international/index.rss" },
    { id: "lemonde", name: "Le Monde", category: "local", region: "fr", url: "https://www.lemonde.fr/rss/une.xml" },
    { id: "elpais", name: "El País", category: "local", region: "es", url: "https://feeds.elpais.com/mrss-s/pages/ep/site/elpais.com/portada" },
    { id: "ansa", name: "ANSA", category: "local", region: "it", url: "https://www.ansa.it/sito/notizie/topnews/topnews_rss.xml" },
    { id: "nos", name: "NOS", category: "local", region: "nl", url: "https://feeds.nos.nl/nosnieuwsalgemeen" },
    { id: "svt", name: "SVT Nyheter", category: "local", region: "se", url: "https://www.svt.se/nyheter/rss.xml" },
    { id: "nhk", name: "NHK World", category: "local", region: "jp", url: "https://www3.nhk.or.jp/rss/news/cat0.xml" },
    { id: "cna", name: "CNA", category: "local", region: "sg", url: "https://www.channelnewsasia.com/api/v1/rss-outbound-feed?_format=xml" },
    { id: "folha", name: "Folha de S.Paulo", category: "local", region: "br", url: "https://feeds.folha.uol.com.br/emcimadahora/rss091.xml" },
    { id: "mg", name: "Mail & Guardian", category: "local", region: "za", url: "https://mg.co.za/feed/" },
    { id: "irishtimes", name: "The Irish Times", category: "local", region: "ie", url: "https://www.irishtimes.com/arc/outboundfeeds/rss/" }
]

var SUGGEST_BY_INTEREST = {
    technology: ["hn", "ars", "verge"],
    business: ["cnbc", "economist"],
    science: ["nasa", "physorg"],
    politics: ["axios", "propublica"],
    world: ["bbc-world", "guardian", "aljazeera"],
    sports: ["bbc-sport", "espn"],
    culture: ["atlantic", "vox"],
    blogs: ["simonw", "daringfireball"],
    research: ["arxiv-ai"],
    linux: ["arch", "omarchy", "phoronix"],
    local: []
}

function _norm(s) {
    return String(s || "").toLowerCase().replace(/[^a-z0-9_\/+-]+/g, "")
}

function _countryFromLocale(name) {
    var s = String(name || "")
    var m = /(?:^|[._-])([A-Z]{2})(?:[.@]|$)/.exec(s.replace(/\.utf-?8$/i, ""))
    if (m) return m[1]
    var parts = s.replace(/\.utf-?8$/i, "").split(/[._@-]/)
    for (var i = parts.length - 1; i >= 0; i--) {
        if (/^[A-Za-z]{2}$/.test(parts[i]) && parts[i] !== "en" && parts[i] !== "C")
            return parts[i].toUpperCase()
    }
    return ""
}

function _langFromLocale(name) {
    var s = String(name || "").replace(/\.utf-?8$/i, "")
    var m = /^([A-Za-z]{2,3})/.exec(s)
    return m ? m[1].toLowerCase() : ""
}

function findRegion(id) {
    if (!id) return null
    for (var i = 0; i < REGIONS.length; i++)
        if (REGIONS[i].id === id) return REGIONS[i]
    return null
}

function googleNewsFeed(region, langHint) {
    if (!region) return null
    var hl = region.hl
    var ceid = region.ceid
    var gl = region.gl
    var lang = _langFromLocale(langHint)
    if (region.id === "np" && (lang === "ne" || String(langHint).toLowerCase().indexOf("ne") === 0)) {
        hl = "ne"
        ceid = "NP:ne"
    }
    if (region.id === "in" && lang === "hi") {
        hl = "hi"
        ceid = "IN:hi"
    }
    return {
        id: "gnews-" + region.id,
        name: region.name + " headlines",
        category: "local",
        region: region.id,
        featured: true,
        url: "https://news.google.com/rss?hl=" + encodeURIComponent(hl) + "&gl=" + encodeURIComponent(gl) + "&ceid=" + encodeURIComponent(ceid)
    }
}

function find(id) {
    if (!id) return null
    for (var i = 0; i < FEEDS.length; i++)
        if (FEEDS[i].id === id) return FEEDS[i]
    if (String(id).indexOf("gnews-") === 0) {
        var region = findRegion(String(id).slice(6))
        return googleNewsFeed(region)
    }
    return null
}

function byCategory(catId, regionId) {
    var out = []
    for (var i = 0; i < FEEDS.length; i++) {
        var f = FEEDS[i]
        if (f.category !== catId) continue
        if (catId === "local" && regionId && regionId !== "world") {
            if (f.region && f.region !== regionId) continue
        }
        out.push(f)
    }
    if (catId === "local" && regionId && regionId !== "world") {
        var g = googleNewsFeed(findRegion(regionId))
        if (g) out.unshift(g)
    }
    return out
}

function recommendedFeeds(regionId) {
    var out = []
    var region = findRegion(regionId) || findRegion("world")
    var g = googleNewsFeed(region)
    if (g) out.push({ id: g.id, name: g.name, category: g.category, stream: "news", region: g.region, featured: true, url: g.url })

    var ids = ["bbc-world", "npr", "guardian", "simonw", "daringfireball", "stratechery", "arxiv-ai", "nature", "sciencenews"]
    for (var i = 0; i < ids.length; i++) {
        var f = find(ids[i])
        if (!f) continue
        out.push({
            id: f.id,
            name: f.name,
            category: f.category,
            stream: f.stream || (f.category === "blogs" ? "writing" : f.category === "research" ? "research" : "news"),
            region: f.region || "",
            featured: true,
            url: f.url
        })
    }
    return out
}

function _offsetFits(region, offset) {
    if (!region || !isFinite(offset)) return true
    var o = region.offset || []
    if (o.length < 2) return true
    return offset >= o[0] && offset <= o[1]
}

function detectRegion(hints) {
    hints = hints || {}
    var tz = _norm(hints.tz)
    var locale = String(hints.locale || hints.lang || "")
    var langFull = _norm(locale)
    var country = String(hints.country || _countryFromLocale(locale) || "").toUpperCase()
    var lang = _langFromLocale(locale)
    var offset = isFinite(hints.offsetMin) ? Number(hints.offsetMin) : NaN

    var i, r

    if (tz) {
        for (i = 0; i < REGIONS.length; i++) {
            r = REGIONS[i]
            for (var t = 0; t < (r.tz || []).length; t++)
                if (tz === _norm(r.tz[t]) || tz.indexOf(_norm(r.tz[t])) >= 0) return r
        }
    }

    if (country) {
        for (i = 0; i < REGIONS.length; i++) {
            if (REGIONS[i].country !== country) continue
            r = REGIONS[i]
            // The locale can say en_US on a machine that is actually abroad.
            // Only trust the locale country when the clock agrees with it.
            if (_offsetFits(r, offset)) return r
            break
        }
    }

    if (langFull) {
        for (i = 0; i < REGIONS.length; i++) {
            r = REGIONS[i]
            if (!_offsetFits(r, offset)) continue
            for (var l = 0; l < (r.langs || []).length; l++)
                if (langFull === _norm(r.langs[l]) || langFull.indexOf(_norm(r.langs[l])) === 0) return r
        }
    }

    if (lang && lang !== "en" && lang !== "c") {
        for (i = 0; i < REGIONS.length; i++) {
            r = REGIONS[i]
            if (!_offsetFits(r, offset)) continue
            for (var l2 = 0; l2 < (r.langs || []).length; l2++)
                if (_norm(r.langs[l2]) === lang || _norm(r.langs[l2]).indexOf(lang + "_") === 0) return r
        }
    }

    // Nepal vs India share UTC+5:45 / +5:30 - prefer NPT when offset is 345.
    if (isFinite(offset)) {
        if (offset >= 340 && offset <= 350) return findRegion("np")
        if (offset >= 325 && offset <= 335) return findRegion("in")
        for (i = 0; i < REGIONS.length; i++) {
            r = REGIONS[i]
            if (!r.offset || r.offset.length < 2) continue
            if (r.id === "world") continue
            if (offset >= r.offset[0] && offset <= r.offset[1]) {
                // Skip overly broad ranges when a tighter match exists later
                if (r.id === "us" && (offset > -200)) continue
                if ((r.id === "de" || r.id === "fr" || r.id === "es" || r.id === "it" || r.id === "nl" || r.id === "se") && !lang)
                    continue
                return r
            }
        }
        if (offset >= 0 && offset <= 60) return findRegion("gb")
        if (offset >= -480 && offset <= -240) return findRegion("us")
    }

    return findRegion("world")
}

function detectLocalFeedIds(hints) {
    var r = detectRegion(hints)
    var ids = ["gnews-" + r.id]
    var extra = r.feeds || []
    for (var i = 0; i < extra.length; i++)
        if (ids.indexOf(extra[i]) < 0) ids.push(extra[i])
    return ids
}

function suggestFeeds(interests, regionId, hints) {
    var region = findRegion(regionId) || detectRegion(hints)
    var ids = []
    function add(id) {
        if (!id || ids.indexOf(id) >= 0) return
        if (find(id)) ids.push(id)
    }

    var cats = Array.isArray(interests) ? interests.slice() : []
    if (cats.indexOf("local") < 0) cats.push("local")

    add("gnews-" + region.id)
    var localFeeds = region.feeds || []
    for (var i = 0; i < localFeeds.length && i < 4; i++) add(localFeeds[i])

    for (var c = 0; c < cats.length; c++) {
        var picks = SUGGEST_BY_INTEREST[cats[c]] || []
        for (var p = 0; p < picks.length; p++) add(picks[p])
    }

    return ids.slice(0, 18)
}

function defaultSelection(hints) {
    var r = detectRegion(hints)
    return suggestFeeds(["technology", "world", "local", "blogs", "research"], r.id, hints)
}

function feedsFromIds(ids) {
    var out = []
    for (var i = 0; i < ids.length; i++) {
        var f = find(ids[i])
        if (f) out.push({ id: f.id, name: f.name, category: f.category, stream: f.stream || (f.category === "blogs" ? "writing" : "news"), url: f.url, region: f.region || "" })
    }
    return out
}

function suggestedStarterIds(hints) {
    return defaultSelection(hints)
}
