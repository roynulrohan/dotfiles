# SSH key at login

Unlocks the SSH key at login from KDE Wallet, so git can sign commits
([`shared/git`](../../shared/git/SETUP.md)) without `ssh-add` after every
reboot.

## Files

| Repo | Destination |
|---|---|
| [`ssh-add.service`](ssh-add.service) | `~/.config/systemd/user/ssh-add.service` |

Outside the repo: the key itself, `~/.ssh/id_ed25519`.

## Install

On CachyOS or Arch:

```bash
sudo pacman -S openssh ksshaskpass kwallet kwallet-pam
```

`ksshaskpass` reads the passphrase from KDE Wallet. `kwallet-pam` unlocks the
wallet with the login password. SDDM's PAM file (`/etc/pam.d/sddm`) already
calls it.

```bash
systemctl --user enable --now ssh-agent.socket
cp ssh-add.service ~/.config/systemd/user/
systemctl --user daemon-reload && systemctl --user enable --now ssh-add.service
```

Answer the passphrase dialog once and tick "Remember password".

## Notes

- **Agent:** openssh's own `ssh-agent.socket` (user unit, enabled), socket
  `$XDG_RUNTIME_DIR/ssh-agent.socket`. [`shared/fish`](../../shared/fish/SETUP.md)
  points `SSH_AUTH_SOCK` at it.
- **Login:** `ssh-add.service` runs `ssh-add` once with the graphical session,
  with `SSH_ASKPASS=ksshaskpass` and `SSH_ASKPASS_REQUIRE=force`. It loads
  `~/.ssh/id_ed25519`. A key with another name needs its own path in
  `ExecStart`.

Source: the Arch Wiki's KDE Wallet page, "Using the KDE Wallet to store ssh key
passphrases".

## Verify

```bash
systemctl --user is-active ssh-agent.socket   # active
ssh-add -l                                    # lists the key after login, without typing anything
```
