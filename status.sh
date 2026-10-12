#!/usr/bin/env bash
# Read-only: compares each manifest entry for this OS against the live file and
# reports what differs. Never writes anything.
#   ./status.sh            summary
#   ./status.sh --diff     also show the diff under each "differs" line
#
#   ok        the live copy matches the repo
#   differs   the live copy differs; copy one way or the other
#   missing   not copied yet
#   seeded    differs, but the app rewrites this file itself (mode seed)
#   skipped   the app the row needs (column 5) isn't installed
#   leftover  a retired destination still exists (mode gone); remove it
# [sudo] marks destinations outside $HOME. Exit status is 1 when any line is
# differs, missing or leftover.
cd "$(dirname "$0")" || exit 1
case "$(uname -s)" in Darwin) os=mac ;; Linux) os=linux ;; *) os=other ;; esac
show_diff=${1:-}
status=0

# Never compared inside a "dir" entry. SETUP.md is this repo's documentation and
# never belongs at the destination. theme.conf.user is the SDDM theme's link to
# its synced colours (linux/sddm), made at install. fontconfig writes .uuid into
# every font folder. lazy-lock.json is deliberately not excluded: lazy.nvim
# rewrites it on every plugin update, and that is real drift worth seeing.
excludes=(-x .gitkeep -x SETUP.md -x theme.conf.user -x .uuid)

report() { printf '%-9s %s%s\n' "$1" "$2" "${3:+  $3}"; }

# Column 5: a command name, or a path (/… or ~/…) that must exist.
has() {
    case "$1" in
        /* | \~*) [[ -e "${1/#\~/$HOME}" ]] ;;
        *) command -v "$1" >/dev/null 2>&1 ;;
    esac
}

while IFS=$'\t' read -r scope repo dest mode needs; do
    [[ -z "$scope" || "$scope" == \#* ]] && continue
    [[ "$scope" == all || "$scope" == "$os" ]] || continue
    [[ "$mode" == manual ]] && continue
    dest="${dest/#\~/$HOME}"
    sudo=
    [[ "$dest" == "$HOME"/* ]] || sudo='[sudo]'

    if [[ "$mode" == gone ]]; then
        if [[ -e "$dest" ]]; then report leftover "$dest" "$sudo"; status=1; fi
        continue
    fi
    if [[ -n "$needs" ]] && ! has "$needs"; then
        report skipped "$dest" "(no $needs)"; continue
    fi
    if [[ ! -e "$dest" ]]; then
        report missing "$dest" "$sudo"; status=1; continue
    fi

    if [[ "$mode" == dir ]]; then
        out=$(diff -rq "${excludes[@]}" "$repo" "$dest" 2>&1)
    else
        out=$(diff -q "$repo" "$dest" 2>&1)
    fi
    noexec=
    [[ "$mode" == copy-x && ! -x "$dest" ]] && noexec='not executable'

    if [[ -z "$out" && -z "$noexec" ]]; then
        report ok "$dest"
    elif [[ "$mode" == seed ]]; then
        report seeded "$dest" "(repo: $repo)"
    else
        report differs "$dest" "(repo: $repo)${noexec:+ $noexec}${sudo:+ $sudo}"; status=1
        if [[ "$show_diff" == --diff && -n "$out" ]]; then
            if [[ "$mode" == dir ]]; then
                diff -ru "${excludes[@]}" "$repo" "$dest"
            else
                diff -u "$repo" "$dest"
            fi | sed 's/^/    /' | head -40
        fi
    fi
done < manifest.tsv
exit $status
