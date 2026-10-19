# Workspace pills

A Noctalia bar plugin, `roynul/workspace-pills`. It shows the workspaces of the
bar's monitor as numbered pills, animated like HyDE's waybar: the workspaces
with windows, plus the active one. The active pill is wider and filled with
`primary`. Click a pill to switch to its workspace. Special workspaces never
show. Install and enable it with [`linux/noctalia`](../../SETUP.md).

It replaces the built-in `workspaces` widget. With `hide_when_empty`, that
widget rebuilds without its animation when a workspace gets its first window or
loses its last. Those pills then snap in and out. Keep this plugin until the
built-in widget animates these changes.

## On the bar

`config.toml` names it in `[bar.default] start` as
`"roynul/workspace-pills:pills"`. A bar can name a plugin entry directly, with
no `[widget]` block. To go back to the built-in widget, put `"workspaces"`
there again.

It looks like the built-in widget at the `[widget.workspaces]` settings in
`config.toml`. Its sizes are constants in `pills.luau`, so those settings do
not change it.

## Files

- [`plugin.toml`](plugin.toml): the manifest. After you change it, run
  `noctalia msg plugins disable roynul/workspace-pills` and then `enable`.
- [`hyprland.luau`](hyprland.luau): a `[[service]]`, one for all bars. It
  follows Hyprland's event socket with `socat`, reads `hyprctl -j monitors`
  and `workspaces`, and publishes each monitor's workspaces to plugin state. A
  `workspacev2` event moves the active pill at once, before `hyprctl` answers.
- [`pills.luau`](pills.luau): the bar widget. It draws and animates the pills.
  The motion uses HyDE's `cubic-bezier(.55, -0.68, .48, 1.682)`: 0.4 s for the
  active pill and for pills that grow in or shrink out, 0.3 s for hover.

The comments in the `.luau` files explain how they work.

## Commands

```bash
noctalia msg plugin roynul/workspace-pills:hyprland all status    # counters and the published ids
noctalia msg plugin roynul/workspace-pills:hyprland all refresh   # read Hyprland again now
noctalia msg plugin roynul/workspace-pills:pills all status       # each bar's output, pills and frames
# Show a test state and stop reading Hyprland, until "all real"
noctalia msg plugin roynul/workspace-pills:hyprland all fake '{"DP-1": {"active": 3, "ids": [1, 3]}}'
noctalia msg plugin roynul/workspace-pills:hyprland all real
```

Without Hyprland, the service accepts only `fake`. The log is
`~/.cache/noctalia/noctalia.log`.
