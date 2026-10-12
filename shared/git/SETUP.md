# git and ssh

## Files

| Repo | Destination |
|---|---|
| `gitconfig` | `~/.gitconfig` |
| — | `~/.gitconfig.local`: machine-only settings, not in the repo. `gitconfig` includes it last, and git ignores it if it doesn't exist |

## Install

- CachyOS: `pacman -S git github-cli openssh lazygit`, `systemctl --user enable --now ssh-agent.socket`
- macOS: `brew install git gh lazygit` (ssh-agent is built in)

## Manual, every new machine

1. `ssh-keygen -t ed25519 -C roynulrohan@gmail.com` with a passphrase
2. `gh auth login` — GitHub.com, SSH, upload the key
3. Verified commits: `gh auth refresh -s admin:ssh_signing_key`, then
   `gh ssh-key add ~/.ssh/id_ed25519.pub --type signing`. The committed
   gitconfig already sets `commit.gpgsign` and `tag.gpgsign` to `true`, so
   register the key before the first commit, or GitHub shows "Unverified".

## Notes

`gitconfig` is deliberately plain: rebase on pull, auto upstream on first push,
prune on fetch, rerere, histogram diffs, micro as editor. Signing uses the SSH
key, no GPG. Never copy private keys between machines.

## Verify

```bash
./status.sh | grep gitconfig                           # ok
ssh -T git@github.com                                  # "You've successfully authenticated"
gh ssh-key list | cut -f5                              # authentication and signing
git cat-file -p HEAD | grep -c 'BEGIN SSH SIGNATURE'   # 1, in a repo: the last commit is signed
```
