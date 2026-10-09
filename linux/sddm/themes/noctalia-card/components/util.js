.pragma library

// A theme.conf colour ("#rrggbb") with an alpha.
function alpha(hex, a) {
    const c = Qt.darker(hex, 1.0);
    return Qt.rgba(c.r, c.g, c.b, a);
}

// file:// URL for a path in the synced assets folder.
function asset(dir, name) {
    return "file://" + dir + "/" + name;
}
