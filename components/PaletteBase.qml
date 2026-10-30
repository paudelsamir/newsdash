import QtQuick
import qs.Commons as Commons

// Reactive palette bridge: every color follows the host Omarchy theme live
// (Commons.Color), with fallbacks derived by tinting the host fg/bg. Instantiate
// as a property on a root item and reference `pt.*` where the old Theme.js
// tokens were used.
QtObject {
    id: pb

    // Host theme
    readonly property color fg: Commons.Color.popups.text
    readonly property color bg: Commons.Color.popups.background
    readonly property color accent: Commons.Color.accent
    readonly property color danger: Commons.Color.urgent
    readonly property color good: "#30d158"

    // Derivatives, recomputed when the host theme changes
    readonly property color fill: Qt.tint(pb.bg, pb.fga(0.055))
    readonly property color fillHover: Qt.tint(pb.bg, pb.fga(0.11))
    readonly property color border: Qt.tint(pb.bg, pb.fga(0.15))
    readonly property color separator: pb.border
    readonly property color secondary: pb.fga(0.80)
    readonly property color tertiary: pb.fga(0.55)
    readonly property color quaternary: pb.fga(0.36)
    readonly property color fgSubtle: pb.tertiary
    readonly property color label: pb.fg
    readonly property color onAccent: pb.textOver(pb.accent)

    function fga(a) {
        var c = Qt.color(pb.fg)
        return Qt.rgba(c.r, c.g, c.b, a)
    }

    function textOver(c) {
        var col = Qt.color(c)
        return (0.299 * col.r + 0.587 * col.g + 0.114 * col.b) > 0.52 ? "#1b1a17" : "#ffffff"
    }

    function alpha(c, a) {
        try {
            var col = Qt.color(c)
            return Qt.rgba(col.r, col.g, col.b, a)
        } catch (e) {
            return Qt.rgba(1, 1, 1, a)
        }
    }

    property real scale: 1
    function s(n) { return Math.round(n * pb.scale) }

    // Typography
    readonly property string font: "Inter, sans-serif"
    readonly property string serif: {
        var families = Qt.fontFamilies()
        var wanted = ["Newsreader", "Literata", "Source Serif 4", "Source Serif Pro", "Georgia", "Times New Roman"]
        for (var i = 0; i < wanted.length; i++)
            if (families.indexOf(wanted[i]) >= 0) return wanted[i]
        return pb.font
    }
    readonly property string iconFont: "Material Symbols Outlined"
    readonly property string glyphFont: {
        var families = Qt.fontFamilies()
        var wanted = ["Font Awesome 6 Free", "Font Awesome 6 Pro", "Font Awesome 5 Free", "Font Awesome"]
        for (var i = 0; i < wanted.length; i++)
            if (families.indexOf(wanted[i]) >= 0) return wanted[i]
        return pb.iconFont
    }
    readonly property int body: Math.round(13 * pb.scale)
    readonly property int callout: Math.round(14 * pb.scale)
    readonly property int caption: Math.round(11 * pb.scale)
    readonly property int footnote: Math.round(10 * pb.scale)
    readonly property int normal: Math.round(12 * pb.scale)
    readonly property int title3: Math.round(15 * pb.scale)
    readonly property real fast: 150
    readonly property int dur: Commons.Style.duration(180)
    readonly property int durFast: Commons.Style.duration(120)
}
