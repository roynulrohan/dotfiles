# git

## Files

| Repo | Destination |
|---|---|
| `gitconfig` | `~/.gitconfig` |

Same on both platforms. Symlink it.

## Contents

Identity (`Roynul Rohan <roynulrohan@gmail.com>`) plus buffer tuning for large
pushes — `http.postBuffer`, `pack.windowMemory`, `pack.packSizeLimit`. Nothing
platform-specific, no credentials.

## Notes

**No credential helper is configured.** On macOS git falls back to
`osxkeychain`; on Linux there's no default and every push will prompt. Either use
`gh auth login` and let the gh CLI handle it (preferred — that's the existing
setup), or set `credential.helper` explicitly.

**Change the identity if the machine isn't personal.** A work box wants a
different email; set it per-repo or via `includeIf` rather than editing this file.

**No signing key.** Commits are unsigned. If that changes, remember
`user.signingkey` is machine-specific and shouldn't be committed here.

## Verify

```bash
git config --global --list
git config --global user.email     # roynulrohan@gmail.com
```
