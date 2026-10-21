# Jellyfin Desktop

[Jellyfin Desktop](https://github.com/jellyfin/jellyfin-desktop), the Jellyfin
client with mpv inside. Three of its settings are changed from the defaults,
for the reasons under Notes: a volume gain so the slider matches the Windows
client, no fullscreen at start so Hyprland places the window, and NVDEC
decoding on the NVIDIA card.

## Files

None in the repo. The client keeps its config in
`~/.local/share/jellyfin-desktop/profiles/<profile>/jellyfin-desktop.conf`,
and that file holds the server address and a per-machine profile ID, so it
stays out. The settings below are made in the app, under Settings.

## Install

CachyOS/Arch: `paru -S jellyfin-desktop-git` (AUR).

Then in the app, Settings:

- Other, "Other configuration":

  ```text
  volume-gain=16
  hwdec=nvdec-copy
  ```

- Main: Fullscreen off.
- Video: Hardware Decoding stays on Disabled (see Notes).

## Notes

### Other configuration is the way to set mpv options

Each `key=value` line in Settings, Other, "Other configuration" becomes an mpv
property at startup, after the client has set its own. The log shows
`Parsing other configuration:` with the lines. The upstream README also
mentions an `mpv.conf` in the profile folder; this build never enables mpv's
config loading, so that file is ignored.

### Volume: `volume-gain=16`

mpv's volume slider is cubic: the slider value over 100, cubed, is the gain.
50% is 18 dB down, 30% is 31 dB down. The Windows client, Jellyfin Media
Player, adds `volume-gain=16` on every play; Jellyfin Desktop adds none, so
the same slider position was 16 dB quieter and sounded dull on Linux. With
the gain set, the slider means the same on both systems, around 30% for
normal listening. The gain is applied before the
[headset EQ](../pipewire/SETUP.md), whose -6 dB preamp leaves headroom.

### Window: fullscreen off

With Fullscreen on, the client goes fullscreen at startup on Qt's primary
screen, which on Wayland is the first output the compositor lists, not the
focused one. Off, it is a normal window and Hyprland tiles it on the focused
monitor; fullscreen from inside the app then stays on that monitor. Settings
has a "force fullscreen screen" field for pinning a monitor if fullscreen at
start is wanted.

### Decoding: `hwdec=nvdec-copy`, toggle on Disabled

The client renders through an OpenGL ES context and, with its own Hardware
Decoding set to Copy or Enabled, loads mpv's VA-API path, which has no driver
for the NVIDIA card and glitches. `hwdec=nvdec-copy` in "Other configuration"
decodes on NVDEC and copies the frames to the renderer, which does not depend
on that interop. It is applied after the client's own `hwdec=no`, so the toggle
stays on Disabled and the line wins.

## Verify

Play a file, then in the newest file under
`~/.local/share/jellyfin-desktop/profiles/<profile>/logs/`:

```bash
grep -E 'Parsing other configuration|Using hardware decoding' jellyfin-desktop.log | tail -2
# "Parsing other configuration: volume-gain=16\nhwdec=nvdec-copy"
# vd: Using hardware decoding (nvdec-copy).
```

The window opens on the focused monitor, not fullscreen.
