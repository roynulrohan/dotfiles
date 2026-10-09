# Linux fish entry point. Everything shared lives in conf.d/ (shared/fish),
# which fish sources before this file; the prompt and hooks are in
# conf.d/05-roynul-init.fish.

# Carried over from the config.fish this replaced. conf.d/00 already adds both
# directories; these lines keep bun ahead of ~/.local/bin, as before.
export PATH="$HOME/.local/bin:$PATH"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
