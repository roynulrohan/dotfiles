# Linux fish entry point. Everything shared lives in conf.d/ (shared/fish),
# which fish sources before this file. The prompt and hooks are in
# conf.d/05-roynul-init.fish.

# conf.d/00 already adds both directories. These lines put them in front again,
# with bun ahead of ~/.local/bin.
export PATH="$HOME/.local/bin:$PATH"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# Machine-only lines, such as PATH additions from installers, go in local.fish.
# It stays out of the repo and is sourced last, so it can override anything.
test -r $__fish_config_dir/local.fish; and source $__fish_config_dir/local.fish
