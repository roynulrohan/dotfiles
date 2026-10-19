# Workspace apps

A Noctalia bar plugin, `roynul/workspace-apps`. It shows the app icons of the
windows on the current workspace of the bar's monitor, in screen order. The
window that this monitor focused last is bright, and the others are dimmed.
Click an icon to focus its window. The widget hides when the workspace is
empty. It never reads window titles. Install and enable it with
[`linux/noctalia`](../../SETUP.md).

It replaces the built-in `taskbar` with `only_active_workspace`. On a monitor
whose workspace is empty, that widget shows every window from all monitors.
Keep this plugin until the built-in widget filters an empty workspace
correctly.

## Files

- [`plugin.toml`](plugin.toml): the manifest. After you change it, run
  `noctalia msg plugins disable roynul/workspace-apps` and then `enable`.
- [`hyprland.luau`](hyprland.luau): a `[[service]]`, one for all bars. It
  follows Hyprland's event socket with one `socat`, reads `hyprctl -j monitors`
  and `clients` after a burst of events, and publishes each monitor's window
  list to plugin state. A 5 s poll covers a dead stream.
- [`icons.luau`](icons.luau): the bar widget. It draws its monitor's list.
- [`translations/en.json`](translations/en.json): the labels of the setting.

The comments in the `.luau` files explain how they work.

## Setting

`hidden_tags` is empty by default. Set it under
`[plugin_settings."roynul/workspace-apps"]` in `config.toml`, or in Settings,
Plugins. Windows with any of these Hyprland tags get no icon. A tag from a
window rule matches without its trailing `*`. A tag change raises no Hyprland
event. After you change a window's tags, send `refresh` to update the bars at
once. Otherwise the 5 s poll catches it.

## Commands

```bash
noctalia msg plugin roynul/workspace-apps:hyprland all status    # counters to the log
noctalia msg plugin roynul/workspace-apps:hyprland all refresh   # read Hyprland again now
noctalia msg plugin roynul/workspace-apps:icons all refresh      # rebuild, icon cache too
noctalia msg plugin roynul/workspace-apps:icons all status       # each bar's output and icon count
```

The log is `~/.cache/noctalia/noctalia.log`.
