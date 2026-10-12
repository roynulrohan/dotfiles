# macOS fish entry point; linux/fish/config.fish is the Linux one. Everything
# shared lives in conf.d/. starship, zoxide and direnv start here, not in
# conf.d/05, so they still come after the conda hook below.

# ---------------------------------------------------------------------------
# PATH carried over from legacy/zsh (zprofile + zshrc + zshenv). Every entry is
# guarded so a Mac without the tool stays quiet. Homebrew, ~/.local/bin and bun
# are already handled by shared/fish/conf.d/00-roynul-env.fish.
# ---------------------------------------------------------------------------
# Rust (zshenv sourced ~/.cargo/env)
test -d $HOME/.cargo/bin; and fish_add_path -g $HOME/.cargo/bin

# python.org framework build, and Homebrew's unversioned python/pip shims
test -d /Library/Frameworks/Python.framework/Versions/3.12/bin; and fish_add_path -g /Library/Frameworks/Python.framework/Versions/3.12/bin
set -q HOMEBREW_PREFIX; and test -d $HOMEBREW_PREFIX/opt/python@3.9/libexec/bin; and fish_add_path -g $HOMEBREW_PREFIX/opt/python@3.9/libexec/bin

# Java: Homebrew openjdk
if set -q HOMEBREW_PREFIX
    for jdk in $HOMEBREW_PREFIX/opt/openjdk/bin $HOMEBREW_PREFIX/opt/openjdk@11/bin
        test -d $jdk; and fish_add_path -g $jdk
    end
end

# Android SDK
if test -d $HOME/Library/Android/sdk
    set -gx ANDROID_HOME $HOME/Library/Android/sdk
    for d in emulator tools tools/bin platform-tools
        test -d $ANDROID_HOME/$d; and fish_add_path -g $ANDROID_HOME/$d
    end
end

# nvm itself doesn't run in fish (see shared/fish/SETUP.md), but its default node
# stays on PATH so the global npm packages (tsc, yarn, ...) keep resolving.
if test -r $HOME/.nvm/alias/default
    set -l v (string trim < $HOME/.nvm/alias/default)
    string match -q 'v*' $v; or set v v$v
    test -d $HOME/.nvm/versions/node/$v/bin; and fish_add_path -g $HOME/.nvm/versions/node/$v/bin
end

# Misc tool dirs
for d in $HOME/.amplify/bin $HOME/.console-ninja/.bin $HOME/.antigravity/antigravity/bin \
        $HOME/.local/share/solana/install/active_release/bin
    test -d $d; and fish_add_path -g $d
end

# kitty.app is not a Homebrew cask here, so kitty and kitten are not on PATH;
# the fastfetch wrapper in shared/fish needs kitten for animated GIF logos.
test -d /Applications/kitty.app/Contents/MacOS; and fish_add_path -g --append /Applications/kitty.app/Contents/MacOS

# conda, if miniconda is installed
test -x $HOME/miniconda3/bin/conda; and $HOME/miniconda3/bin/conda shell.fish hook | source

if status is-interactive
    command -q starship; and starship init fish | source
    command -q zoxide;   and zoxide init fish --cmd cd | source
    command -q direnv;   and direnv hook fish | source

    # From legacy/zsh. macOS only.
    command -q bat; and alias cat bat

    # fzf from legacy/zsh: fd-backed and .gitignore-aware, bat/eza previews,
    # ctrl-t / ctrl-r / alt-c key bindings
    if command -q fzf
        if command -q fd
            set -gx FZF_DEFAULT_COMMAND 'fd --hidden --strip-cwd-prefix --exclude .git'
            set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
            set -gx FZF_ALT_C_COMMAND 'fd --type=d --hidden --strip-cwd-prefix --exclude .git'
        end
        command -q bat; and set -gx FZF_CTRL_T_OPTS "--preview 'bat -n --color=always --line-range :500 {}'"
        command -q eza; and set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"
        fzf --fish | source
    end

    # claude-mem worker (legacy/zsh alias)
    alias claude-mem 'bun "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
end

# Machine-only lines, such as PATH additions from installers, go in local.fish.
# It stays out of the repo and is sourced last, so it can override anything.
test -r $__fish_config_dir/local.fish; and source $__fish_config_dir/local.fish
