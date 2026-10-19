# uwsm

uwsm (Universal Wayland Session Manager) starts the Hyprland session. These two
files set the session's environment variables. uwsm exports them to the
session's systemd user environment, so apps that systemd or D-Bus start get
them too.

## Files

| Repo | Destination |
|---|---|
| [`env`](env) | `~/.config/uwsm/env` |
| [`env-hyprland`](env-hyprland) | `~/.config/uwsm/env-hyprland` |

## Install

```bash
sudo pacman -S uwsm
```

The values name themes from other packages: the Qt theme engine `qtengine`
([`linux/noctalia`](../noctalia/SETUP.md)) and the cursor theme
`breeze_cursors` ([`linux/hypr`](../hypr/SETUP.md)).

Copy both files. They take effect at the next log in. The login screen starts
the uwsm session ([`linux/sddm`](../sddm/SETUP.md)).

## Notes

uwsm sources `env` for every compositor, then `env-hyprland` for Hyprland only
(`man uwsm`, Files). Both are shell files of `export` lines.

- `env`: the Qt theme (`qtengine`) and Qt window settings, and the cursor
  theme and size. The cursor values must match the Hyprland config:
  `cursorTheme` in [`linux/hypr/hypr-vars.lua`](../hypr/hypr-vars.lua) and
  `cursorSize` in [`linux/hypr/variables.lua`](../hypr/variables.lua).
- `env-hyprland`: the toolkit backends (Wayland first, X11 as fallback), the
  XDG session variables, and the NVIDIA video decoding variables.

### NVIDIA video decoding

With the NVIDIA driver loaded (`/proc/driver/nvidia/version` exists),
`env-hyprland` and Hyprland's `env.lua` set two variables from the
NVIDIA VA-API driver's
[Firefox instructions](https://github.com/elFarto/nvidia-vaapi-driver#firefox):

- `LIBVA_DRIVER_NAME=nvidia` makes VA-API load the NVIDIA driver
  (`libva-nvidia-driver`).
- `MOZ_DISABLE_RDD_SANDBOX=1` turns off the sandbox of Firefox's media
  decoding process, which the driver can't run in. Firefox's other sandboxes
  stay on.

On other GPUs both lines are skipped, because `LIBVA_DRIVER_NAME=nvidia`
breaks VA-API there.

Firefox and Zen, which is built on Firefox, also need one setting. Put it in
a `user.js` file in the profile folder of each browser. The profile names are
random, so the files are not in the manifest:

```js
user_pref("media.hardware-video-decoding.force-enabled", true);
```

Without these, Firefox decodes video on the CPU. With them, a 1080p60 Twitch
stream's decoding process drops from about 17% of a CPU core to 1%. mpv and
Jellyfin decode on the GPU without them.

Apps that systemd or D-Bus start read the variables from uwsm, not from
Hyprland's `hyprland/env.lua` ([`linux/hypr`](../hypr/SETUP.md)).
`hyprland/env.lua` sets the same variables for apps that Hyprland starts
itself. Change both when a variable changes.

## Verify

```bash
./status.sh | grep uwsm   # ok on both lines
```

After you log out and back in:

```bash
systemctl --user show-environment | grep -E '^(QT_QPA_PLATFORMTHEME|XCURSOR_THEME|XDG_CURRENT_DESKTOP)='
```

It prints `qtengine`, `breeze_cursors` and `Hyprland`. With a video playing in
Firefox on an NVIDIA GPU:

```bash
grep -c nvidia_drv_video /proc/$(pgrep -f 'firefox.*contentproc.*rdd')/maps   # 1 or more
```
