# snapshots (btrfs + snapper)

Btrfs snapshots with snapper: a timeline for root and for home, a snapshot
before and after every pacman transaction, and a boot menu entry for every
root snapshot. CachyOS installs most of the stack; `setup-snapshots.sh` adds
the timelines and the `home` config.

## Files

| Repo | Destination |
|---|---|
| [`setup-snapshots.sh`](setup-snapshots.sh) | none: run once with sudo (a `manual` row in `manifest.tsv`) |

The script changes system files outside the repo: it edits
`/etc/snapper/configs/root`, creates `/etc/snapper/configs/home`, adds
`.snapshots` to `/etc/updatedb.conf` and enables snapper's timers.

## Install

On CachyOS/Arch:

```bash
sudo pacman -S snapper snap-pac limine-snapper-sync btrfs-assistant
```

CachyOS preinstalls all four, with btrfs subvolumes `@`, `@home`, `@log` and
`@cache` and snapper's `root` config. `limine-snapper-sync` is in CachyOS's own
repo; plain Arch has it in the AUR.

The script gives the user who runs it with sudo access to the home snapshots
(`ALLOW_USERS` is set from `$SUDO_USER`). Run it once on a fresh install,
from this folder:

```bash
sudo ./setup-snapshots.sh
```

Run it only once: `create-config` stops the script if a `home` config already
exists.

## Notes

### What CachyOS installs

- `snapper` with a `root` config.
- `snap-pac`: a pre and a post snapshot on every pacman transaction.
- `limine-snapper-sync`: every root snapshot is a boot menu entry; restore with
  `limine-snapper-restore`.
- `btrfs-assistant`: a GUI for snapshots and subvolumes.

### What the script adds

From the ArchWiki, SUSE's snapper manual and common community setups:

- The root timeline on, with CachyOS's limits: 5 hourly, 7 daily, nothing
  longer (the ArchWiki example).
- A `home` config with its own timeline: 12 hourly, 14 daily, 2 weekly,
  1 monthly, and `NUMBER_LIMIT=20`, `NUMBER_LIMIT_IMPORTANT=15`.
  `ALLOW_USERS` and `SYNC_ACL=yes` make home snapshots usable without sudo.
- `snapper-timeline.timer` and `snapper-cleanup.timer` enabled, and
  `.snapshots` pruned from `updatedb`.
- A first named snapshot of each config, "baseline after snapshot setup".

### Daily use

```fish
snapper -c home create -d "before a big change"   # and `sudo snapper -c root create -d ...`
snapper -c home list
snapper -c home undochange N..0 [path]            # revert home (or one path) to snapshot N
```

Unbootable system: pick a snapshot in the Limine menu, log in, run
`limine-snapper-restore`, reboot. Snapshots live on the same disk: they are not
backups.

## Verify

```bash
snapper list-configs                               # home and root
snapper -c home list | tail -3                     # recent timeline snapshots, without sudo
grep '^TIMELINE_LIMIT' /etc/snapper/configs/root   # HOURLY 5, DAILY 7, the rest 0
systemctl is-enabled snapper-timeline.timer        # enabled
```
