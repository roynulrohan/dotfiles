# git and ssh

## Files

| Repo | Destination |
|---|---|
| `gitconfig` | `~/.gitconfig` |

## Install

- CachyOS: `pacman -S git github-cli openssh lazygit`, `systemctl --user enable --now ssh-agent.socket`
- macOS: `brew install git gh lazygit` (ssh-agent is built in)

## Manual, every new machine

1. `ssh-keygen -t ed25519 -C roynulrohan@gmail.com` with a passphrase
2. `gh auth login` — GitHub.com, SSH, upload the key
3. Verified commits: `gh auth refresh -s admin:ssh_signing_key`, then
   `gh ssh-key add ~/.ssh/id_ed25519.pub --type signing`, then set
   `commit.gpgsign` and `tag.gpgsign` to `true` in gitconfig. Left `false` in the
   committed file so an unregistered key doesn't produce "Unverified" badges.

## Notes

`gitconfig` is deliberately plain: rebase on pull, auto upstream on first push,
prune on fetch, rerere, histogram diffs, micro as editor. Signing uses the SSH
key, no GPG. Never copy private keys between machines.
