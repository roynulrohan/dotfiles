# Share Cursor

A Noctalia control centre plugin, `roynul/share-cursor`. Its button switches
Hyprland to a software cursor, so a screen share shows the pointer.
Chromium-based screen share, such as Equibop's, leaves a hardware cursor out
of the stream. Install and enable it with [`linux/noctalia`](../../SETUP.md).

## The button

- A click switches the software cursor on or off. The button lights up while
  it is on.
- While it is on, screenshots show the cursor too. Switch it off after the
  share.
- A Hyprland config reload or a new login switches it off.
- Off is Hyprland's default, Auto. On NVIDIA, Auto still picks a software
  cursor when VRR is on or there is more than one GPU. Screenshots then show
  the cursor with the button off.

## In the control centre

`config.toml` lists it as `roynul/share-cursor:share-cursor` in
`[[control_center.shortcuts]]`, in place of Wi-Fi.

## How it works

[`cursor.luau`](cursor.luau) sets `cursor:no_hardware_cursors` to 1 (on) or
2 (off, Auto) with `hyprctl eval`. A Lua config rejects `hyprctl keyword`. It
then reads the value back with `hyprctl -j getoption`. The service publishes
the state to the button. While the state is on, the service reads the value
every 5 seconds, so the button goes dark after a config reload.

## Files

| File | What |
|---|---|
| [`plugin.toml`](plugin.toml) | The manifest |
| [`shortcut.luau`](shortcut.luau) | The button |
| [`service.luau`](service.luau) | Publishes the state, and reads it again while it is on |
| [`cursor.luau`](cursor.luau) | Reads and sets Hyprland's cursor option |
