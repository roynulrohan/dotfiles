# fish (macOS entry point)

See [`shared/fish/SETUP.md`](../../shared/fish/SETUP.md). This `config.fish` holds the Mac's PATH, conda and
fzf setup and initialises starship, zoxide and direnv after conda's hook. On
Linux, [`shared/fish/conf.d/05-roynul-init.fish`](../../shared/fish/conf.d/05-roynul-init.fish) initialises those three, and
[`linux/fish/config.fish`](../../linux/fish/config.fish) is the entry point.

| Repo | Destination |
|---|---|
| `config.fish` | `~/.config/fish/config.fish` |
