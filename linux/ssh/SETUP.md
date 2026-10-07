# ssh

Unlock the SSH key at login from KDE Wallet, so git can sign commits without
`ssh-add` after every reboot.

| Repo | Destination |
|---|---|
| `ssh-add.service` | `~/.config/systemd/user/ssh-add.service` |

## How it fits together

- **Agent:** openssh's own `ssh-agent.socket` (user unit, enabled), socket
  `$XDG_RUNTIME_DIR/ssh-agent.socket`; `shared/fish` points `SSH_AUTH_SOCK` at it.
- **Passphrase:** `ksshaskpass`, KDE's askpass helper, looks it up in KDE Wallet,
  which PAM unlocks with the login password. The first time it asks and offers
  to remember it ("Remember password").
- **Login:** `ssh-add.service` runs `ssh-add` once with the graphical session,
  with `SSH_ASKPASS=ksshaskpass` and `SSH_ASKPASS_REQUIRE=force`.

Source: the Arch Wiki's KDE Wallet page, "Using the KDE Wallet to store ssh key
passphrases".

## Install

```bash
sudo pacman -S ksshaskpass
systemctl --user enable --now ssh-agent.socket
cp ssh-add.service ~/.config/systemd/user/
systemctl --user daemon-reload && systemctl --user enable --now ssh-add.service
```

Answer the dialog once (tick "Remember password").

## Verify

```bash
ssh-add -l    # lists the key after login, without typing anything
```
