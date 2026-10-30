.pragma library
function s(n) { return n; }
var fontFamily = "Inter, sans-serif";
var font = fontFamily;
var iconFont = "Material Symbols Outlined";
var accent = "#d08b5b";
var good = "#30d158";
var danger = "#ff5f5f";
var fg = "#ece7dd";
var label = "#ece7dd";
var bg = "#161513";
var fill = "#211f1b";
var fillHover = "#2c2822";
var border = "#363230";
var body = 13;
var title3 = 15;
var secondary = "#c6c0b5";
var separator = "#363230";
var fast = 150;
var callout = 14;
var caption = 11;
var footnote = 10;
var normal = 12;
var quaternary = "#5d594f";
var fgSubtle = "#77776f";
var tertiary = "#9c958a";
var alpha = function(c, a) {
    try { var col = Qt.color(c); return Qt.rgba(col.r, col.g, col.b, a); }
    catch (e) { return Qt.rgba(1,1,1,a); }
};
