# snapshots (btrfs + snapper)

CachyOS installs the stack on its own: btrfs with `@`, `@home`, `@log`, `@cache`
subvolumes, `snapper` with a `root` config, `snap-pac` (pre/post snapshot on every
pacman transaction), `limine-snapper-sync` (every root snapshot is a boot menu
entry; restore with `limine-snapper-restore`), and `btrfs-assistant` as a GUI.

What this package adds, from the ArchWiki, SUSE's snapper manual and common
community setups:

- root timeline on, limits 5 hourly / 7 daily / nothing longer (ArchWiki example)
- a `home` config with its own timeline: 12 hourly, 14 daily, 2 weekly, 1 monthly,
  `ALLOW_USERS=roynul` + `SYNC_ACL=yes` so home snapshots are usable without sudo
- `snapper-timeline.timer` enabled, `.snapshots` pruned from `updatedb`

`setup-snapshots.sh` does all of it; run once with sudo on a fresh install. It is
not in `manifest.tsv` because it is a one-shot, not a file to copy.

## Daily use

```fish
snapper -c home create -d "before noctalia"       # and `sudo snapper -c root create -d ...`
snapper -c home list
snapper -c home undochange N..0 [path]            # revert home (or one path) to snapshot N
```

Unbootable system: pick a snapshot in the Limine menu, log in, run
`limine-snapper-restore`, reboot. Snapshots live on the same disk: they are not
backups.
