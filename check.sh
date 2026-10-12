#!/usr/bin/env bash
# Read-only checks for this repo. Run after `git add`, before every commit.
#   - syntax: JSON (comments allowed in .jsonc and the VS Code and Cursor
#     files), TOML, Python, Lua, shell and fish
#   - manifest.tsv: valid rows, repo paths exist, copy-x files executable in git
#   - coverage: every file is covered by a manifest row, unless it is a
#     top-level file, documentation (*.md), a licence, a .gitkeep or history
#   - secrets: gitleaks on staged and unstaged changes, if it is installed
# Luau (the Noctalia plugins) has no checker here. Prints only problems and
# skipped checks; exit status 1 when anything fails.
cd "$(dirname "$0")" || exit 1
fail=0

# Tracked files plus new ones not added yet; ignored and deleted files left out.
files=()
while IFS= read -r f; do
    [[ -f "$f" ]] && files+=("$f")
done < <(git ls-files --cached --others --exclude-standard | sort -u)

# JSON, TOML, Python, manifest and coverage.
python3 -I - "${files[@]}" <<'EOF' || fail=1
import ast, json, os, re, subprocess, sys, tomllib

files = sys.argv[1:]
failed = False

def bad(msg):
    global failed
    print(f"FAIL  {msg}")
    failed = True

def strip_jsonc(text):
    # Drop // and /* */ comments outside strings, then trailing commas.
    out, i, n, in_str = [], 0, len(text), False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if c == "\\":
                out.append(text[i + 1]); i += 1
            elif c == '"':
                in_str = False
        elif c == '"':
            in_str = True; out.append(c)
        elif text.startswith("//", i):
            while i < n and text[i] != "\n":
                i += 1
            continue
        elif text.startswith("/*", i):
            i = text.index("*/", i) + 2
            continue
        else:
            out.append(c)
        i += 1
    return re.sub(r",(\s*[}\]])", r"\1", "".join(out))

def is_python(path):
    if path.endswith(".py"):
        return True
    with open(path, "rb") as fh:
        first = fh.readline()
    return first.startswith(b"#!") and b"python" in first

for f in files:
    try:
        if f.endswith(".toml"):
            with open(f, "rb") as fh:
                tomllib.load(fh)
        elif f.endswith((".json", ".jsonc")):
            with open(f, encoding="utf-8") as fh:
                text = fh.read()
            if f.endswith(".jsonc") or f.startswith(("shared/vscode/", "shared/cursor/")):
                text = strip_jsonc(text)
            json.loads(text)
        elif is_python(f):
            with open(f, encoding="utf-8") as fh:
                ast.parse(fh.read(), f)
    except Exception as e:
        bad(f"{f}: {e}")

# manifest.tsv rows
modes = {"copy", "copy-x", "dir", "seed", "manual", "gone"}
rows, seen = [], set()
for n, line in enumerate(open("manifest.tsv", encoding="utf-8"), 1):
    line = line.rstrip("\n")
    if not line or line.startswith("#"):
        continue
    cols = line.split("\t")
    where = f"manifest.tsv:{n}"
    if len(cols) not in (4, 5):
        bad(f"{where}: {len(cols)} columns, want 4 or 5"); continue
    scope, repo, dest, mode = cols[:4]
    if scope not in ("all", "linux", "mac"):
        bad(f"{where}: unknown os '{scope}'")
    if mode not in modes:
        bad(f"{where}: unknown mode '{mode}'"); continue
    if (scope, dest) in seen and dest != "-":
        bad(f"{where}: {dest} appears twice")
    seen.add((scope, dest))
    if mode == "gone":
        if repo != "-":
            bad(f"{where}: a gone row has repo '-'")
        continue
    if mode == "manual" and dest != "-":
        bad(f"{where}: a manual row has destination '-'")
    if not os.path.exists(repo):
        bad(f"{where}: {repo} does not exist"); continue
    if mode == "dir" and not os.path.isdir(repo):
        bad(f"{where}: {repo} is not a directory")
    if mode == "copy-x":
        staged = subprocess.run(["git", "ls-files", "-s", "--", repo],
                                capture_output=True, text=True).stdout
        if staged and not staged.startswith("100755"):
            bad(f"{where}: {repo} is copy-x but not executable in git (git update-index --chmod=+x)")
    rows.append((mode, repo))

# Coverage
for f in files:
    base = os.path.basename(f)
    if ("/" not in f or f.endswith(".md") or base.startswith("LICENSE")
            or base == ".gitkeep" or f.startswith(("history/", "linux/caelestia/"))):
        continue
    if not any(f == repo or (mode in ("dir", "manual") and f.startswith(repo + "/"))
               for mode, repo in rows):
        bad(f"{f}: no manifest row covers it (add one, or a manual row)")

sys.exit(1 if failed else 0)
EOF

# Lua, shell and fish syntax.
for f in "${files[@]}"; do
    case "$f" in
        *.lua)
            command -v luac >/dev/null || continue
            out=$(luac -p -- "$f" 2>&1) || { printf 'FAIL  %s\n' "$out"; fail=1; } ;;
        *.fish)
            command -v fish >/dev/null || continue
            out=$(fish -n "$f" 2>&1) || { printf 'FAIL  %s: %s\n' "$f" "$out"; fail=1; } ;;
        *)
            first=
            IFS= read -r first < "$f" 2>/dev/null
            if [[ "$f" == *.sh || "$first" =~ ^\#!.*/(env\ )?(ba)?sh$ ]]; then
                out=$(bash -n -- "$f" 2>&1) || { printf 'FAIL  %s\n' "$out"; fail=1; }
            fi ;;
    esac
done
command -v luac >/dev/null || echo "skip  Lua syntax: luac isn't installed"
command -v fish >/dev/null || echo "skip  fish syntax: fish isn't installed"

# Secrets in what is about to be committed.
if command -v gitleaks >/dev/null; then
    for staged in --staged ''; do
        gitleaks git --pre-commit --redact --no-banner --log-level warn $staged . || fail=1
    done
else
    echo "skip  secrets: gitleaks isn't installed"
fi

exit $fail
