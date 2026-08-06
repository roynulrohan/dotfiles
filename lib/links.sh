#!/usr/bin/env bash
# Shared link map. Sourced by install.sh and sync.sh — expects $DOTFILES to be set.
#
# Format: <repo-relative source>::<absolute destination>
# Add a line here and both scripts pick it up.

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

LINKS=(
  "claude/CLAUDE.md::$CLAUDE_DIR/CLAUDE.md"
  "claude/RTK.md::$CLAUDE_DIR/RTK.md"
  "claude/settings.json::$CLAUDE_DIR/settings.json"
  "claude/hooks/rtk-rewrite.sh::$CLAUDE_DIR/hooks/rtk-rewrite.sh"
  "claude/skills/gh::$CLAUDE_DIR/skills/gh"
  "ccstatusline/settings.json::$HOME/.config/ccstatusline/settings.json"
)
