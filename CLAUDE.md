# dotfiles

Read `AGENTS.md` first. Rules for any edit here:

1. **Never commit a credential.** Some configs are committed *because* their key
   fields are empty. If one gets filled in on a machine, don't copy it back.
2. **Copy, don't symlink.** Machines keep normal files in normal places; this repo
   is the source to copy from and the place to copy changes back to.
   `manifest.tsv` maps repo paths to destinations; `./status.sh` shows drift.
3. **Never commit a framework's tree.** caelestia's `~/.config/hypr` and
   `~/.config/fish` are theirs; only `linux/caelestia` overrides are ours.
4. **Keep shared configs portable.** No hardcoded home paths; guard OS-specific
   bits so the other OS skips them. Document OS differences in the package's `SETUP.md`.
5. **Tag every commit with its device.** End the subject with `(cachy-os)`,
   `(macbook-pro)` and so on. The tag list is in `AGENTS.md`.
