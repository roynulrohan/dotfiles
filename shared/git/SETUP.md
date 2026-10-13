# git

Git's user config: identity, commits and tags signed with the SSH key, and
`gh` as the credential helper for GitHub. The SSH key and its GitHub sign-in
are set up by hand on each machine (Install).

## Files

| Repo | Destination |
|---|---|
| [`gitconfig`](gitconfig) | `~/.gitconfig` |
| not in the repo | `~/.gitconfig.local`: settings for one machine only. `gitconfig` includes it last, and git ignores it if it doesn't exist |

## Install

- CachyOS/Arch: `sudo pacman -S git github-cli openssh lazygit micro`, then
  `systemctl --user enable --now ssh-agent.socket`. To unlock the key at login,
  see [`linux/ssh`](../../linux/ssh/SETUP.md).
- macOS: `brew install git gh lazygit micro`. macOS has its own ssh-agent.

After copying, on every new machine:

1. `ssh-keygen -t ed25519 -C roynulrohan@gmail.com`, with a passphrase.
2. `gh auth login`: GitHub.com, SSH, upload the key.
3. Verified commits: `gh auth refresh -s admin:ssh_signing_key`, then
   `gh ssh-key add ~/.ssh/id_ed25519.pub --type signing`. `gitconfig` sets
   `commit.gpgsign` and `tag.gpgsign` to `true`, so register the key before
   the first commit, or GitHub shows "Unverified".

## Notes

- `gitconfig` is deliberately plain: rebase on pull, auto upstream on first
  push, prune on fetch, rerere, histogram diffs, micro as the editor.
- Signing uses the SSH key, no GPG.
- Never copy private keys between machines.

## Verify

```bash
./status.sh | grep gitconfig                           # ok
ssh -T git@github.com                                  # "You've successfully authenticated"
gh ssh-key list | cut -f5                              # authentication and signing
git cat-file -p HEAD | grep -c 'BEGIN SSH SIGNATURE'   # 1, in a repo: the last commit is signed
```
