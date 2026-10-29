# Preferences

What I want from a setup, whatever tool does the job. The config files show
today's values. This file holds what they can't: rankings, conventions that
carry across tools, the intent behind a layout, and hard no's. Where a package
does the job today, the item names it, so a new tool can take over the same
job.

## General

- **Built-in features and established packages first.** Small custom pieces
  for edge cases are fine. Large custom scripts are not.
- **Keep config for hardware that isn't connected right now.** Don't remove it
  because a device is missing today.
- **Keep a full second desktop as a fallback** for when the main one breaks.
  Keep its apps too, such as its terminal and its theme. Today: KDE Plasma,
  from CachyOS's install.
- **Review and pin third-party code.** A plugin or package that runs code is
  read first, then pinned to the reviewed commit or version. Today:
  split-monitor-workspaces and the local Noctalia plugins. The community
  plugin hypr-submap is not pinned: Noctalia fetches it again at every start.
- **12-hour time** everywhere a clock shows.
- **Every mouse runs at 1600 DPI.** Today: Solaar for the Logitech mice
  ([`linux/solaar`](../linux/solaar/SETUP.md)). The gaming mice keep it in
  their onboard profiles.

## Look

- **Colours come from the wallpaper** and reach every app that can take them.
  Linux has no fixed palette. Today:
  [`linux/noctalia`](../linux/noctalia/SETUP.md), Colour templates. VS Code is
  the exception: it keeps One Dark Pro.
- **The Mac keeps fixed palettes** and gets no palette generator. Today:
  [`mac/kitty`](../mac/kitty/SETUP.md), [`shared/ghostty`](../shared/ghostty/SETUP.md).
- **Windows are translucent by default.** Apps that show content edge to edge
  are opaque: terminals, browsers, Discord, file managers, image and video
  players. VS Code and Orca stay translucent. Today:
  [`linux/hyprmod`](../linux/hyprmod/SETUP.md).
- **One spacing grid** for gaps, the bar and borders. Today:
  [`linux/hypr`](../linux/hypr/SETUP.md), Look.
- **Live wallpapers on every monitor.** The still image behind each one is
  picked for its own look: the original artwork over a frame from the video.
  Today: [`linux/wallpaper`](../linux/wallpaper/SETUP.md).
- **The login screen and the lock screen look alike.** Today:
  [`linux/sddm`](../linux/sddm/SETUP.md), [`linux/noctalia`](../linux/noctalia/SETUP.md).
- **Night light is always on, and a button in the shell turns it off.**
  Today: Noctalia's Always On ([`linux/noctalia`](../linux/noctalia/SETUP.md)).

## Bar

- **Islands on an invisible bar.** Each widget or group is its own rounded
  pill.
- **Left: information.** System stats and workspaces.
- **Middle: the apps of the current workspace.**
- **Right: controls.** Media, network and volume, updates, tray, clock, system
  toggles and notifications, power.
- **Workspaces show only occupied ones, as numbers.** The active one stands
  out.

Today: Noctalia on Linux ([`linux/noctalia`](../linux/noctalia/SETUP.md), Bar).
The Mac's SketchyBar is a smaller version ([`mac/wm`](../mac/wm/SETUP.md)).

## Keys

- **Super is the main modifier,** on the second key left of the spacebar (Win
  on a PC keyboard), on every keyboard. Today on the Mac: Karabiner ([`mac/wm`](../mac/wm/SETUP.md)).
- **Arrows move, Shift resizes, Alt makes the step finer.** This applies to
  windows and to anything else that moves or resizes, such as the image
  viewer. Today: [`linux/hypr`](../linux/hypr/SETUP.md), Window mode;
  [`linux/mpv`](../linux/mpv/SETUP.md).
- **Workspace and monitor keys: Shift takes the window along, Alt sends it
  without following.**
- **Each monitor has its own workspaces, 1 to 10.**
- **The Mac binds are a smaller copy of the Linux ones.**

### Key roles

The role matters, not the app or the exact key.

- **Must:** Super+T terminal, Super+E file manager, Super+B browser; Super+M
  music, Super+D chat and Super+S scratch (pop-up workspaces), and Super+Alt+S
  to send a window to scratch. A mouse's thumb button also toggles scratch.
- **Use:** the launcher; lock; clipboard history; the keyboard's own media
  keys, volume knob and mute; Super+Shift+S region screenshot on a frozen
  screen; colour picker; restarting the shell (Ctrl+Super+Alt+R).
- **Nice to have:** session menu, emoji picker, editor on Super+C, system
  monitor pop-up (Ctrl+Shift+Esc).
- **Not used, so don't build around them:** Print and Super+P screenshots; a todo pop-up; F10 to F12 for
  volume (the keyboard has its own keys, and those keys belong to apps:
  fullscreen and developer tools).
- **Open to whatever the shell offers:** sidebars and panels, clearing
  notifications, recording, deleting clipboard entries, an audio mixer.
- **Pop-up workspaces** other than music, chat and scratch go unused. Windows
  come back with the workspace number keys.

## Tools

- **fish and starship** on every machine.
- **kitty is the terminal** on both machines; Ghostty is a second terminal on
  the Mac. Both must show the greeting's image logo.
- **JetBrainsMono Nerd Font** everywhere.
- **Modern command-line tools:** eza, bat, fd, ripgrep, fzf, zoxide.
- **bun over npm and npx,** except in a project with its own lockfile.
- **Browser:** Zen for now. I'm open to other browsers, and to using more
  than one.
- **Default apps:** Zen for web pages, a dedicated viewer for PDFs (Okular),
  the code editor for text and code files, the spreadsheet for CSV, Dolphin
  for folders, mpv for images and videos, Gwenview for SVG and editing.
  Equibop is the Discord app.
- **Folders sort by date modified, newest first,** and each folder remembers
  its own view.
- **Hyprland binds and rules go through HyprMod** where it can express them.
  Today: [`linux/hyprmod`](../linux/hyprmod/SETUP.md).
- **Claude Code is the main coding agent.** Agents ask before they install a
  tool for themselves, such as rtk or a skills manager.

## Hard no's

- **No EasyEffects.** The headset EQ runs in PipeWire.
- **Nothing that writes to the mice.** G HUB on Windows owns their onboard
  profiles. No battery-warning scripts either.
- **No Omarchy.**
- **No hibernation.** The PC uses zram only, with no swap file on disk.
