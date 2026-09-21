#!/usr/bin/env bash
# Read-only: compares each manifest entry for this OS against the live file and
# reports what differs. Never writes anything.
#   ./status.sh            summary
#   ./status.sh --diff     also show diffs
cd "$(dirname "$0")" || exit 1
case "$(uname -s)" in Darwin) os=mac ;; Linux) os=linux ;; *) os=other ;; esac
show_diff=${1:-}
status=0
while IFS=$'\t' read -r scope repo dest mode; do
    [[ -z "$scope" || "$scope" == \#* ]] && continue
    [[ "$scope" == all || "$scope" == "$os" ]] || continue
    dest="${dest/#\~/$HOME}"
    if [[ ! -e "$dest" ]]; then
        printf 'missing   %s\n' "$dest"; status=1; continue
    fi
    if [[ "$mode" == dir ]]; then
        # SETUP.md is this repo's documentation and never belongs at the
        # destination. lazy-lock.json is deliberately not excluded: lazy.nvim
        # rewrites it on every plugin update, and that is real drift worth seeing.
        out=$(diff -rq -x '.gitkeep' -x 'SETUP.md' "$repo" "$dest" 2>/dev/null)
    else
        out=$(diff -q "$repo" "$dest" 2>/dev/null)
    fi
    if [[ -n "$out" ]]; then
        printf 'differs   %s  (repo: %s)\n' "$dest" "$repo"; status=1
        [[ "$show_diff" == --diff ]] && diff -ru "$repo" "$dest" | sed 's/^/    /' | head -40
    else
        printf 'ok        %s\n' "$dest"
    fi
done < manifest.tsv
exit $status
