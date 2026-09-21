# dotclaude, phases 0 to 3, Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the private `dotclaude` repo, make every entry of `~/.claude` (except `settings.local.json`) a symlink into it, replace the ECC rule pile with switchable rule sets, delete the duplicated ECC copies, strip AI content out of `dotfiles`, and add the context advisory hook.

**Architecture:** `dotclaude` is a content repo plus four bash scripts (`install.sh`, `scripts/lib.sh`, `scripts/rules.sh`, `scripts/doctor.sh`) and one Node hook. `~/.claude/rules` links to `dotclaude/rules/active/`, a gitignored directory of one symlink per enabled rule set that `rules.sh apply` rebuilds from `rules/enabled` (or a per machine override). `~/.claude/skills` links to `dotclaude/skills/`, where third party installers keep writing and `.gitignore` keeps only authored skills. Tests are plain bash scripts run against a temporary `CLAUDE_HOME`, and `node --test` for the hook.

**Tech Stack:** bash 3.2 compatible scripts (macOS default), Node 22 ESM for the hook, `jq` for JSON, `git`, `gh`. No bats, no shellcheck required (shellcheck is added to the Brewfile as optional).

**Spec:** `docs/plans/2026-09-21-ai-setup-redesign.md` (sections 2, 3, 6 phases 0 to 3, 7)

## Global Constraints

- Repo path: `~/Documents/PersonalProjects/dotclaude`, GitHub `RomanKovalchukDev/dotclaude`, private.
- Every script starts with `#!/usr/bin/env bash` and `set -euo pipefail`; no bash 4 only features (`declare -A`, `mapfile`, `${var,,}`).
- Every script honours `CLAUDE_HOME` (default `$HOME/.claude`) so tests run against a temp dir.
- Markdown written in this plan (README, rules, CLAUDE.md, SKILL.md) uses no dashes as punctuation; list bullets `- ` and words like `path-scoped` are fine.
- In tests, a value used in both the act and the assert is one local variable, never two literals.
- `mine` rule set: under 8 KB unconditional, `common/` under 3 KB.
- ECC source of truth for the fork: `~/.claude/plugins/cache/everything-claude-code/everything-claude-code/1.9.0/rules/`, never the copies in `~/.claude/rules`.
- Nothing from ECC is copied except `rules/`. Skills, agents, commands come from the plugin.
- Commit messages: `<type>: <description>`, types feat fix refactor docs test chore.
- Hook thresholds default 250000, 500000, 750000, overridable by `CA_NOTE`, `CA_CHECKPOINT`, `CA_DRIFT`.
- The machine has a PreToolUse hook that blocks any shell command containing both `git commit` and a `--no-…` flag. Keep `install.sh --skip-plugins` (not `--no-plugins`) and never put a commit in the same shell command as such a flag.

---

## File structure

`dotclaude/` (new repo)

| Path | Responsibility |
| --- | --- |
| `install.sh` | one shot machine setup: backup, links, manifests, rule sets, nerd links |
| `scripts/lib.sh` | shared helpers: `dc_root`, `dc_home`, `dc_link`, `dc_adopt_dir`, `dc_backup`, `dc_unconditional_bytes`, `dc_log` |
| `scripts/rules.sh` | rule set management |
| `scripts/doctor.sh` | health check, exit 1 on any failure |
| `scripts/link-nerd-skills.sh` | symlink team skills from `ai/mobile/*` into `skills/` |
| `scripts/install-skills.sh` | reinstall third party skills listed in `config/skills.manifest` when missing |
| `scripts/statusline.sh` | moved from dotfiles unchanged |
| `config/settings.json` | Claude Code settings, linked |
| `config/plugins.manifest`, `config/install-plugins.sh` | moved from dotfiles |
| `config/skills.manifest` | third party skills: name, expected link target, install command |
| `config/mcp-servers.json`, `config/install-mcp.sh` | moved from dotfiles |
| `CLAUDE.md` | personal contract |
| `rules/enabled` | default enabled sets |
| `rules/sets/ecc/` | verbatim ECC rules + `VERSION` |
| `rules/sets/mine/` | pruned fork |
| `rules/active/` | gitignored, generated |
| `skills/handoff/SKILL.md`, `skills/memory-update/SKILL.md` | authored skills |
| `agents/.gitkeep`, `commands/.gitkeep` | linked dirs, empty |
| `hooks/context-advisory.mjs` | advisory hook |
| `output-styles/concise.md` | output style |
| `memory/patterns/.gitkeep` | cross product lessons |
| `tests/lib.sh`, `tests/run.sh`, `tests/test_*.sh`, `tests/hook.test.mjs` | tests |
| `README.md` | how to use |

`dotfiles/` (modified)

| Path | Change |
| --- | --- |
| `ai/` | deleted |
| `machine-setup/unix/install-ai.sh` | rewritten: clone `dotclaude` if missing, run its `install.sh` |
| `machine-setup/bootstrap.sh:298-340` | dry run text and success text updated |
| `machine-setup/unix/Brewfile` | add `shellcheck` and `jq` |
| `README.md` | `ai/` section replaced by a pointer to `dotclaude` |

---

### Task 0: Backup the current `~/.claude` state

**Files:**
- Create: `~/.claude/backups/2026-09-21-pre-redesign.tgz`
- Create: `~/.claude/backups/2026-09-21-plugin-list.txt`

- [ ] **Step 1: Archive the entries that will change**

```bash
mkdir -p ~/.claude/backups
tar -czf ~/.claude/backups/2026-09-21-pre-redesign.tgz \
  -C ~/.claude CLAUDE.md settings.json rules skills agents commands hooks
claude plugin list > ~/.claude/backups/2026-09-21-plugin-list.txt
```

- [ ] **Step 2: Verify the archive is restorable**

Run: `tar -tzf ~/.claude/backups/2026-09-21-pre-redesign.tgz | wc -l`
Expected: a number above 400 (skills alone hold hundreds of files).

Run: `tar -tzf ~/.claude/backups/2026-09-21-pre-redesign.tgz | grep -c '^rules/common/'`
Expected: `10`

No commit; this is outside any repo.

---

### Task 1: Repo skeleton and test harness

**Files:**
- Create: `~/Documents/PersonalProjects/dotclaude/.gitignore`
- Create: `~/Documents/PersonalProjects/dotclaude/README.md`
- Create: `~/Documents/PersonalProjects/dotclaude/tests/lib.sh`
- Create: `~/Documents/PersonalProjects/dotclaude/tests/run.sh`
- Create: `~/Documents/PersonalProjects/dotclaude/tests/test_harness.sh`

**Interfaces:**
- Produces: `tests/lib.sh` exports `assert_eq <expected> <actual> <msg>`, `assert_file <path>`, `assert_link <link> <target>`, `assert_not_exists <path>`, `assert_contains <needle> <haystack>`, `tmp_home` (prints a fresh temp dir and exports `CLAUDE_HOME`), `fail <msg>`, `finish`. Every `test_*.sh` sources it and is run by `tests/run.sh`.

- [ ] **Step 1: Create the repo**

```bash
mkdir -p ~/Documents/PersonalProjects/dotclaude && cd ~/Documents/PersonalProjects/dotclaude
git init -b main
gh repo create RomanKovalchukDev/dotclaude --private --source=. --remote=origin
```

- [ ] **Step 2: Write `.gitignore`**

```gitignore
# generated by scripts/rules.sh apply
rules/active/

# ~/.claude/skills links here; third party installers write into it.
# Only authored skills are tracked.
skills/*
!skills/handoff/
!skills/memory-update/

# runtime state of hooks
state/

.DS_Store
```

- [ ] **Step 3: Write the test helpers `tests/lib.sh`**

```bash
#!/usr/bin/env bash
# Minimal assertions for the dotclaude scripts. Source this from tests/test_*.sh.
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$TESTS_DIR/.." && pwd)"
export REPO
FAILURES=0

fail() {
  echo "  FAIL: $*" >&2
  FAILURES=$((FAILURES + 1))
}

assert_eq() {
  local expected="$1" actual="$2" msg="${3:-}"
  [ "$expected" = "$actual" ] || fail "${msg} expected '$expected' got '$actual'"
}

assert_file() {
  [ -f "$1" ] || fail "expected file $1"
}

assert_link() {
  local link="$1" target="$2"
  [ -L "$link" ] || { fail "expected symlink $link"; return; }
  assert_eq "$target" "$(readlink "$link")" "link target of $link"
}

assert_not_exists() {
  [ ! -e "$1" ] && [ ! -L "$1" ] || fail "expected $1 to not exist"
}

assert_contains() {
  local needle="$1" haystack="$2"
  case "$haystack" in
    *"$needle"*) ;;
    *) fail "expected output to contain '$needle', got: $haystack" ;;
  esac
}

tmp_home() {
  local dir
  dir="$(mktemp -d "${TMPDIR:-/tmp}/dotclaude-test.XXXXXX")"
  mkdir -p "$dir/.claude"
  export CLAUDE_HOME="$dir/.claude"
  echo "$dir"
}

finish() {
  if [ "$FAILURES" -gt 0 ]; then
    echo "$FAILURES failure(s) in $(basename "$0")" >&2
    exit 1
  fi
  echo "ok $(basename "$0")"
}
```

- [ ] **Step 4: Write the runner `tests/run.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
status=0
for t in test_*.sh; do
  bash "$t" || status=1
done
if [ -f hook.test.mjs ]; then
  node --test hook.test.mjs || status=1
fi
exit $status
```

- [ ] **Step 5: Write a harness self test `tests/test_harness.sh`**

```bash
#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

home="$(tmp_home)"
assert_eq "$home/.claude" "$CLAUDE_HOME" "tmp_home exports CLAUDE_HOME"

expected_target="$home/target"
touch "$expected_target"
ln -s "$expected_target" "$home/link"
assert_link "$home/link" "$expected_target"

assert_not_exists "$home/missing"
assert_contains "needle" "hay needle stack"
finish
```

- [ ] **Step 6: Run the harness**

Run: `chmod +x tests/*.sh && tests/run.sh`
Expected: `ok test_harness.sh`

- [ ] **Step 7: Write a first README**

````markdown
# dotclaude

The tracked contents of `~/.claude`. Everything there except `settings.local.json` is a symlink into this repository, so a machine can be rebuilt with one command and every change to rules, skills, hooks or settings is a commit.

## Install

```sh
git clone git@github.com:RomanKovalchukDev/dotclaude.git ~/Documents/PersonalProjects/dotclaude
~/Documents/PersonalProjects/dotclaude/install.sh
```

`install.sh` backs up any real file it replaces into `~/.claude/backups/<timestamp>/`.

## Layout

| Path | Purpose |
| --- | --- |
| `CLAUDE.md` | personal contract, the only file loaded into every request |
| `config/` | `settings.json`, plugin manifest, skills manifest, MCP servers |
| `rules/sets/<name>/` | rule sets; `rules/enabled` lists the default ones |
| `skills/` | authored skills; third party installers also write here (ignored) |
| `hooks/` | Claude Code hooks |
| `memory/` | personal memory, private |
| `scripts/` | `rules.sh`, `doctor.sh`, helpers |

## Daily commands

```sh
scripts/rules.sh list          # sets, enabled marks, unconditional bytes
scripts/rules.sh only mine     # A/B switch, applies at the next session
scripts/doctor.sh              # health check
tests/run.sh
```
````

- [ ] **Step 8: Commit**

```bash
git add .gitignore README.md tests/
git commit -m "chore: repo skeleton and bash test harness"
```

---

### Task 2: `scripts/lib.sh` shared helpers

**Files:**
- Create: `scripts/lib.sh`
- Test: `tests/test_lib.sh`

**Interfaces:**
- Produces (all in `scripts/lib.sh`):
  - `dc_root` prints the repo root.
  - `dc_home` prints `$CLAUDE_HOME` or `$HOME/.claude`.
  - `dc_log <msg>` prints to stderr with a `dotclaude:` prefix.
  - `dc_backup_dir` prints (and creates) `<home>/backups/<YYYYmmdd-HHMMSS>`, memoised in `DC_BACKUP_DIR`.
  - `dc_link <target> <link>`: if `<link>` is a symlink to `<target>` do nothing; if it is any other symlink replace it; if it is a real file or dir move it to the backup dir first; then create the symlink. Prints `linked <link>` or `ok <link>`.
  - `dc_adopt_dir <real_dir> <repo_dir>`: move every entry of `<real_dir>` that does not already exist in `<repo_dir>` into `<repo_dir>`; entries that exist in both go to the backup dir; then remove the emptied `<real_dir>`.
  - `dc_unconditional_bytes <dir>`: prints the byte total of `*.md` files under `<dir>` that are not path scoped (no frontmatter, or frontmatter without a `paths:` key).
  - `dc_is_scoped <file>`: exit 0 when the markdown file has a `paths:` key in its frontmatter.

- [ ] **Step 1: Write the failing tests `tests/test_lib.sh`**

```bash
#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
source "$REPO/scripts/lib.sh"

home="$(tmp_home)"

# dc_home honours CLAUDE_HOME
assert_eq "$CLAUDE_HOME" "$(dc_home)" "dc_home"

# dc_link creates, is idempotent, backs up real files
target="$home/repo-file"; echo repo > "$target"
link="$CLAUDE_HOME/CLAUDE.md"
echo old > "$link"
dc_link "$target" "$link" > /dev/null
assert_link "$link" "$target"
backup="$(dc_backup_dir)"
assert_eq "old" "$(cat "$backup/CLAUDE.md")" "real file moved to backup"
out="$(dc_link "$target" "$link")"
assert_contains "ok" "$out"

# dc_link replaces a foreign symlink without backing it up
foreign="$home/foreign"; touch "$foreign"
ln -sfn "$foreign" "$CLAUDE_HOME/hooks"
dc_link "$home/repo-hooks" "$CLAUDE_HOME/hooks" > /dev/null
assert_link "$CLAUDE_HOME/hooks" "$home/repo-hooks"
assert_not_exists "$backup/hooks"

# dc_adopt_dir moves unknown entries, backs up conflicts, removes the dir
real="$CLAUDE_HOME/skills"; repo_dir="$home/repo-skills"
mkdir -p "$real/third-party" "$real/handoff" "$repo_dir/handoff"
echo installed > "$real/third-party/SKILL.md"
echo stale > "$real/handoff/SKILL.md"
echo authored > "$repo_dir/handoff/SKILL.md"
dc_adopt_dir "$real" "$repo_dir"
assert_eq "installed" "$(cat "$repo_dir/third-party/SKILL.md")" "adopted entry"
assert_eq "authored" "$(cat "$repo_dir/handoff/SKILL.md")" "repo entry untouched"
assert_eq "stale" "$(cat "$backup/skills/handoff/SKILL.md")" "conflict backed up"
assert_not_exists "$real"

# dc_unconditional_bytes counts only unscoped markdown
rules="$home/rules"; mkdir -p "$rules/swift"
unscoped_body="# Always loaded"
printf '%s\n' "$unscoped_body" > "$rules/always.md"
printf -- '---\npaths:\n  - "**/*.swift"\n---\n# Swift only\n' > "$rules/swift/style.md"
printf -- '---\ndescription: no paths key\n---\nbody\n' > "$rules/described.md"
expected_bytes=$(( $(wc -c < "$rules/always.md") + $(wc -c < "$rules/described.md") ))
assert_eq "$expected_bytes" "$(dc_unconditional_bytes "$rules")" "unconditional bytes"
dc_is_scoped "$rules/swift/style.md" || fail "swift/style.md should be scoped"
! dc_is_scoped "$rules/always.md" || fail "always.md should not be scoped"

finish
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/test_lib.sh`
Expected: error `scripts/lib.sh: No such file or directory`.

- [ ] **Step 3: Write `scripts/lib.sh`**

```bash
#!/usr/bin/env bash
# Shared helpers for dotclaude scripts. Source, do not execute.
set -euo pipefail

dc_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

dc_home() {
  echo "${CLAUDE_HOME:-$HOME/.claude}"
}

dc_log() {
  echo "dotclaude: $*" >&2
}

dc_backup_dir() {
  if [ -z "${DC_BACKUP_DIR:-}" ]; then
    DC_BACKUP_DIR="$(dc_home)/backups/$(date +%Y%m%d-%H%M%S)"
    export DC_BACKUP_DIR
  fi
  mkdir -p "$DC_BACKUP_DIR"
  echo "$DC_BACKUP_DIR"
}

dc_backup() {
  local path="$1" dest
  dest="$(dc_backup_dir)/$(basename "$path")"
  mv "$path" "$dest"
  dc_log "backed up $path to $dest"
}

dc_link() {
  local target="$1" link="$2"
  if [ -L "$link" ]; then
    if [ "$(readlink "$link")" = "$target" ]; then
      echo "ok $link"
      return 0
    fi
    rm "$link"
  elif [ -e "$link" ]; then
    dc_backup "$link"
  fi
  mkdir -p "$(dirname "$link")"
  ln -s "$target" "$link"
  echo "linked $link"
}

dc_adopt_dir() {
  local real_dir="$1" repo_dir="$2" entry name backup
  mkdir -p "$repo_dir"
  for entry in "$real_dir"/* "$real_dir"/.[!.]*; do
    [ -e "$entry" ] || [ -L "$entry" ] || continue
    name="$(basename "$entry")"
    if [ -e "$repo_dir/$name" ] || [ -L "$repo_dir/$name" ]; then
      backup="$(dc_backup_dir)/$(basename "$real_dir")"
      mkdir -p "$backup"
      mv "$entry" "$backup/$name"
      dc_log "conflict $name kept from repo, old copy in $backup"
    else
      mv "$entry" "$repo_dir/$name"
      dc_log "adopted $name into $repo_dir"
    fi
  done
  rmdir "$real_dir"
}

dc_is_scoped() {
  local file="$1"
  [ "$(head -n 1 "$file")" = "---" ] || return 1
  awk 'NR == 1 { next } /^---$/ { exit 1 } /^paths:/ { found = 1; exit 0 } END { exit found ? 0 : 1 }' "$file"
}

dc_unconditional_bytes() {
  local dir="$1" total=0 file size
  while IFS= read -r file; do
    if ! dc_is_scoped "$file"; then
      size="$(wc -c < "$file" | tr -d ' ')"
      total=$((total + size))
    fi
  done < <(find "$dir" -name '*.md' -type f | sort)
  echo "$total"
}
```

Note on `dc_is_scoped`: the awk program exits 0 as soon as `paths:` appears inside the frontmatter, exits 1 at the closing `---`, and the `END` block covers files whose frontmatter never closes.

- [ ] **Step 4: Run the tests**

Run: `bash tests/test_lib.sh`
Expected: `ok test_lib.sh`

- [ ] **Step 5: Commit**

```bash
git add scripts/lib.sh tests/test_lib.sh
git commit -m "feat: shared helpers for links, adoption, backups and rule scoping"
```

---

### Task 3: Rule sets and `scripts/rules.sh`

**Files:**
- Create: `rules/enabled`
- Create: `rules/sets/ecc/` (copied) and `rules/sets/ecc/VERSION`
- Create: `scripts/rules.sh`
- Test: `tests/test_rules.sh`

**Interfaces:**
- Consumes: `dc_root`, `dc_home`, `dc_unconditional_bytes` from `scripts/lib.sh`.
- Produces: `scripts/rules.sh <list|status|apply|enable NAME|disable NAME|only NAME>`.
  - Enabled sets come from `<home>/rules.enabled.local` when it exists, else `<root>/rules/enabled`. One set name per line, `#` comments allowed.
  - `apply` rebuilds `<root>/rules/active/` as one relative symlink per enabled set (`active/mine -> ../sets/mine`), removing symlinks that are no longer enabled, and warns about non symlink entries.
  - `enable`, `disable`, `only` write `<home>/rules.enabled.local` then `apply`.
  - `list` prints one line per set: `* mine   4211 bytes unconditional` (asterisk for enabled).
  - `status` prints the source of the enabled list and the active entries.
  - Unknown set names exit 2 with a message.

- [ ] **Step 1: Copy the ECC rules verbatim**

```bash
cd ~/Documents/PersonalProjects/dotclaude
ECC=~/.claude/plugins/cache/everything-claude-code/everything-claude-code/1.9.0
mkdir -p rules/sets
cp -R "$ECC/rules" rules/sets/ecc
echo "1.9.0" > rules/sets/ecc/VERSION
printf 'mine\n' > rules/enabled
find rules/sets/ecc -name '*.md' | wc -l
```

Expected: `70` markdown files (README plus 9 common plus 12 languages times 5).

- [ ] **Step 2: Write the failing tests `tests/test_rules.sh`**

```bash
#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

home="$(tmp_home)"
# Work on a copy of the repo so rules/active and enabled edits do not touch the checkout.
work="$home/repo"
cp -R "$REPO" "$work"
rules="$work/scripts/rules.sh"
rm -rf "$work/rules/active" "$CLAUDE_HOME/rules.enabled.local"

set_a="seta"; set_b="setb"
mkdir -p "$work/rules/sets/$set_a" "$work/rules/sets/$set_b"
echo "# a" > "$work/rules/sets/$set_a/a.md"
echo "# b" > "$work/rules/sets/$set_b/b.md"
printf '%s\n' "$set_a" > "$work/rules/enabled"

# apply uses rules/enabled when no local override exists
bash "$rules" apply > /dev/null
assert_link "$work/rules/active/$set_a" "../sets/$set_a"
assert_not_exists "$work/rules/active/$set_b"

# enable adds a set and writes the local override
bash "$rules" enable "$set_b" > /dev/null
assert_link "$work/rules/active/$set_b" "../sets/$set_b"
assert_file "$CLAUDE_HOME/rules.enabled.local"

# disable removes the link
bash "$rules" disable "$set_a" > /dev/null
assert_not_exists "$work/rules/active/$set_a"
assert_link "$work/rules/active/$set_b" "../sets/$set_b"

# only leaves exactly one
bash "$rules" only "$set_a" > /dev/null
assert_link "$work/rules/active/$set_a" "../sets/$set_a"
assert_not_exists "$work/rules/active/$set_b"

# list marks enabled sets and reports unconditional bytes
a_bytes="$(wc -c < "$work/rules/sets/$set_a/a.md" | tr -d ' ')"
listing="$(bash "$rules" list)"
assert_contains "* $set_a" "$listing"
assert_contains "$a_bytes bytes" "$listing"
assert_contains "  $set_b" "$listing"

# unknown set exits 2
if bash "$rules" enable nope 2> /dev/null; then fail "enable nope should fail"; fi
bash "$rules" enable nope 2> /dev/null || assert_eq 2 $? "exit code for unknown set"

# status names the source
assert_contains "rules.enabled.local" "$(bash "$rules" status)"

finish
```

- [ ] **Step 3: Run to verify it fails**

Run: `bash tests/test_rules.sh`
Expected: `FAIL` lines mentioning `rules.sh: No such file or directory`.

- [ ] **Step 4: Write `scripts/rules.sh`**

```bash
#!/usr/bin/env bash
# Manage rule sets: which directories under rules/sets are linked into rules/active.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

ROOT="$(dc_root)"
SETS="$ROOT/rules/sets"
ACTIVE="$ROOT/rules/active"
DEFAULT="$ROOT/rules/enabled"
LOCAL="$(dc_home)/rules.enabled.local"

usage() {
  cat <<EOF
usage: rules.sh <command> [set]

  list            sets, enabled marks, unconditional bytes per set
  status          source of the enabled list and the active links
  apply           rebuild rules/active from the enabled list
  enable <set>    add a set (writes $LOCAL)
  disable <set>   remove a set
  only <set>      enable exactly one set
EOF
  exit 1
}

enabled_source() {
  if [ -f "$LOCAL" ]; then echo "$LOCAL"; else echo "$DEFAULT"; fi
}

enabled_sets() {
  grep -v '^[[:space:]]*#' "$(enabled_source)" | grep -v '^[[:space:]]*$' || true
}

require_set() {
  if [ ! -d "$SETS/$1" ]; then
    dc_log "unknown set '$1'. Available: $(ls "$SETS" | tr '\n' ' ')"
    exit 2
  fi
}

write_local() {
  mkdir -p "$(dirname "$LOCAL")"
  printf '%s\n' "$@" > "$LOCAL"
}

apply() {
  mkdir -p "$ACTIVE"
  local entry name wanted
  wanted="$(enabled_sets)"
  for entry in "$ACTIVE"/*; do
    [ -e "$entry" ] || [ -L "$entry" ] || continue
    name="$(basename "$entry")"
    if [ ! -L "$entry" ]; then
      dc_log "warning: $entry is not a managed symlink, leaving it alone"
      continue
    fi
    if ! printf '%s\n' "$wanted" | grep -qx "$name"; then
      rm "$entry"
      echo "unlinked $name"
    fi
  done
  for name in $wanted; do
    require_set "$name"
    if [ -L "$ACTIVE/$name" ] && [ "$(readlink "$ACTIVE/$name")" = "../sets/$name" ]; then
      echo "ok $name"
    else
      rm -f "$ACTIVE/$name"
      ln -s "../sets/$name" "$ACTIVE/$name"
      echo "linked $name"
    fi
  done
}

cmd_list() {
  local name mark bytes wanted
  wanted="$(enabled_sets)"
  for name in $(ls "$SETS"); do
    mark=" "
    printf '%s\n' "$wanted" | grep -qx "$name" && mark="*"
    bytes="$(dc_unconditional_bytes "$SETS/$name")"
    printf '%s %-16s %8s bytes unconditional\n' "$mark" "$name" "$bytes"
  done
}

cmd_status() {
  echo "enabled list: $(enabled_source)"
  echo "active:"
  ls -l "$ACTIVE" 2> /dev/null | awk 'NR > 1 { print "  " $9 " -> " $11 }'
}

cmd_enable() {
  require_set "$1"
  local current
  current="$(enabled_sets)"
  if ! printf '%s\n' "$current" | grep -qx "$1"; then
    current="$(printf '%s\n%s\n' "$current" "$1" | grep -v '^$')"
  fi
  write_local $current
  apply
}

cmd_disable() {
  require_set "$1"
  local current
  current="$(enabled_sets | grep -vx "$1" || true)"
  write_local $current
  apply
}

cmd_only() {
  require_set "$1"
  write_local "$1"
  apply
}

case "${1:-}" in
  list) cmd_list ;;
  status) cmd_status ;;
  apply) apply ;;
  enable) [ -n "${2:-}" ] || usage; cmd_enable "$2" ;;
  disable) [ -n "${2:-}" ] || usage; cmd_disable "$2" ;;
  only) [ -n "${2:-}" ] || usage; cmd_only "$2" ;;
  *) usage ;;
esac
```

- [ ] **Step 5: Run the tests**

Run: `chmod +x scripts/rules.sh && bash tests/test_rules.sh`
Expected: `ok test_rules.sh`

- [ ] **Step 6: Try it on the real repo**

Run: `scripts/rules.sh list; echo "exit $?"`
Expected: `  ecc   <N> bytes unconditional` where N is about 15200 (README 4310 plus common 10628 plus a few bytes), and `exit 0`. `list` must not fail because `mine` does not exist yet; only `apply` fails on a missing enabled set.

- [ ] **Step 7: Commit**

```bash
git add rules/ scripts/rules.sh tests/test_rules.sh
git commit -m "feat: switchable rule sets with verbatim ECC set"
```

---

### Task 4: The `mine` rule set

**Files:**
- Create: `rules/sets/mine/common/{coding-style,testing,security,git-workflow,document-driven-pipeline}.md`
- Create: `rules/sets/mine/{swift,kotlin,dart,typescript,golang,python,csharp,java,php,cpp,rust,perl}/*.md`
- Test: `tests/test_mine_budget.sh`

**Interfaces:**
- Consumes: `rules/sets/ecc/` from Task 3, `dc_unconditional_bytes`, `dc_is_scoped`.
- Produces: the default enabled set. Budget: `common/` under 3072 bytes, whole set under 8192 unconditional.

- [ ] **Step 1: Write the failing budget test `tests/test_mine_budget.sh`**

```bash
#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
source "$REPO/scripts/lib.sh"

mine="$REPO/rules/sets/mine"
common_budget=3072
set_budget=8192

[ -d "$mine" ] || fail "rules/sets/mine missing"
common_bytes="$(dc_unconditional_bytes "$mine/common")"
set_bytes="$(dc_unconditional_bytes "$mine")"
[ "$common_bytes" -le "$common_budget" ] || fail "common is $common_bytes bytes, budget $common_budget"
[ "$set_bytes" -le "$set_budget" ] || fail "set is $set_bytes bytes unconditional, budget $set_budget"

# every language file must be path scoped
while IFS= read -r file; do
  dc_is_scoped "$file" || fail "$file is not path scoped"
done < <(find "$mine" -mindepth 2 -name '*.md' -not -path '*/common/*')

# no dashes as punctuation in mine: em dash, or space hyphen space outside list bullets
dash_hits="$(grep -rn -e '—' -e ' - [a-zA-Z]' "$mine" | grep -v ':[0-9]*:[[:space:]]*- ' || true)"
[ -z "$dash_hits" ] || fail "dash punctuation found: $(echo "$dash_hits" | head -3)"

# no references to ECC agents
agent_hits="$(grep -rln -e 'tdd-guide' -e 'build-error-resolver' -e 'planner agent' -e 'code-reviewer agent' "$mine" || true)"
[ -z "$agent_hits" ] || fail "ECC agent reference in: $(echo "$agent_hits" | head -3)"

finish
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/test_mine_budget.sh`
Expected: `FAIL: rules/sets/mine missing`

- [ ] **Step 3: Seed the language dirs from ECC**

```bash
cd ~/Documents/PersonalProjects/dotclaude
mkdir -p rules/sets/mine/common rules/sets/mine/dart
for lang in swift kotlin typescript golang python csharp java php cpp rust perl; do
  cp -R rules/sets/ecc/$lang rules/sets/mine/$lang
done
```

- [ ] **Step 4: Write `common/coding-style.md`**

```markdown
# Coding style

- Prefer new values over in place mutation. Return updated copies; mutate only where the language idiom expects it (pointer receivers in Go, `inout` in Swift when a copy is measurably costly).
- Small files with one responsibility. Around 200 to 400 lines is typical, 800 is the ceiling that triggers a split.
- Functions under 50 lines, nesting under four levels. If either is exceeded, extract.
- Handle errors at the boundary where they can be acted on. Never swallow an error silently. User facing code gets a readable message, internals get context in the log.
- Validate at system boundaries: user input, API responses, file content. Fail fast with a clear message.
- No hardcoded values that could change: constants or configuration.
- Names and tests explain the code. Do not write explanatory comments.
```

- [ ] **Step 5: Write `common/testing.md`**

```markdown
# Testing

- Write the test first, watch it fail, implement, watch it pass, then refactor.
- A value used in both the act and the assert is one local constant, never two literals. Exception: asserting a type's built in default against a literal.
- Unit tests for logic, integration tests for boundaries (API, storage), end to end for the critical flows only.
- Fix the implementation, not the test, unless the test is provably wrong.
- Report test results as they are. If something fails, show the output.
```

- [ ] **Step 6: Write `common/security.md`**

```markdown
# Security

- No secrets in source, ever. Environment variables or a secret manager. If a secret may have leaked, say so and rotate it.
- Never print a secret value. Print the command that retrieves it.
- Parameterised queries, sanitised HTML, CSRF protection on state changing endpoints, authorisation checked server side.
- Error messages never leak internals to users.
- Before a commit that touches input handling, auth, or storage, re read the diff with these points in mind.
```

- [ ] **Step 7: Write `common/git-workflow.md`**

```markdown
# Git

- Git mutations (branch, checkout, stage, commit, push, stash, reset, pull, remote) only on an explicit request in the current turn. Reads are free.
- Preserve unrelated staged, unstaged and untracked changes.
- Commit format: `<type>: <description>` with types feat, fix, refactor, docs, test, chore, perf, ci. Body optional. English.
- Pull requests: summarise the whole branch (`git diff <base>...HEAD`), not the last commit. No test plan section. Never mention the assistant.
```

- [ ] **Step 8: Write `common/document-driven-pipeline.md`**

Take the current live file, which is already personal, and remove dash punctuation:

```bash
cp ~/.claude/rules/common/document-driven-pipeline.md rules/sets/mine/common/document-driven-pipeline.md
sed -i '' -e 's/ — / /g' -e 's/ (e\.g\., \([^)]*\))/ (for example \1)/g' rules/sets/mine/common/document-driven-pipeline.md
grep -n -e '—' -e ' - [a-zA-Z]' rules/sets/mine/common/document-driven-pipeline.md || echo "clean"
```

Expected: `clean`. If a line is printed, rephrase it by hand.

- [ ] **Step 9: Write `dart/coding-style.md`**

```markdown
---
paths:
  - "**/*.dart"
  - "**/pubspec.yaml"
---
# Dart and Flutter

Conventions come from the Very Good Ventures plugin. Before writing Flutter code invoke the matching skill: `vgv-ai-flutter-plugin:bloc` for state, `vgv-ai-flutter-plugin:layered-architecture` for structure, `vgv-ai-flutter-plugin:testing` for tests, `vgv-ai-flutter-plugin:navigation`, `vgv-ai-flutter-plugin:material-theming`, `vgv-ai-flutter-plugin:internationalization`, `vgv-ai-flutter-plugin:accessibility` as the task needs.

- `very_good_analysis` lints on, zero warnings before a commit.
- `dart format` on every file touched.
- Widgets small; extract when the build method exceeds one screen.
```

- [ ] **Step 10: Fix the copied language dirs**

Each language dir has five files that reference the deleted common files and ECC agents. Apply these edits to every `rules/sets/mine/<lang>/*.md`:

```bash
cd ~/Documents/PersonalProjects/dotclaude/rules/sets/mine
# links to deleted common files
grep -rl 'common/patterns.md\|common/hooks.md\|common/agents.md\|common/performance.md\|common/development-workflow.md' . \
  | xargs sed -i '' -E 's#> This file extends \[common/(patterns|hooks|agents|performance|development-workflow)\.md\]\([^)]*\).*#> Language specific conventions.#'
# ECC agent references
grep -rl 'tdd-guide\|build-error-resolver' . | xargs sed -i '' \
  -e 's/Use \*\*tdd-guide\*\* agent/Write the test first/g' \
  -e 's/Use the \*\*tdd-guide\*\* agent/Write the test first/g' \
  -e 's/Use \*\*build-error-resolver\*\* agent/Fix build errors incrementally/g' \
  -e 's/Use the \*\*build-error-resolver\*\* agent/Fix build errors incrementally/g'
# em dashes
grep -rl -e '—' . | xargs sed -i '' -e 's/ — /, /g' -e 's/—/, /g'
# spaced hyphens outside list bullets
grep -rl ' - [a-zA-Z]' . | while read -r f; do
  awk '{ if ($0 ~ /^[[:space:]]*- /) print $0; else { gsub(/ - /, ", "); print $0 } }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
# hooks.md files describe ECC PostToolUse formatter hooks (plugin behaviour, not a preference)
rm ./*/hooks.md
```

Then read each remaining language file once (`cat rules/sets/mine/swift/*.md` and so on) and fix by hand any sentence the sed rules mangled.

- [ ] **Step 11: Run the budget test and fix what it reports**

Run: `bash tests/test_mine_budget.sh`
Expected: `ok test_mine_budget.sh`. If it reports dash punctuation or an agent reference, open the named file and rephrase by hand. If `common` exceeds 3072 bytes, shorten sentences; do not drop a rule.

- [ ] **Step 12: Verify the whole set and enable it**

Run: `scripts/rules.sh list && scripts/rules.sh apply`
Expected: `* mine` with an unconditional total under 8192 (only `common/*` counts, about 2.5 KB), `  ecc` about 15 KB, then `linked mine`.

- [ ] **Step 13: Commit**

```bash
git add rules/sets/mine tests/test_mine_budget.sh
git commit -m "feat: mine rule set, pruned fork of ECC 1.9.0"
```

---

### Task 5: `CLAUDE.md`

**Files:**
- Create: `CLAUDE.md`
- Modify: `tests/test_mine_budget.sh` (add the CLAUDE.md byte check)

**Interfaces:**
- Consumes: the current `dotfiles/ai/.claude/CLAUDE.md` (working tree version, which already has the Testing section).
- Produces: `CLAUDE.md` under 5632 bytes.

- [ ] **Step 1: Add the failing check to `tests/test_mine_budget.sh`** (append before `finish`)

```bash
claude_md_budget=5632
claude_md="$REPO/CLAUDE.md"
[ -f "$claude_md" ] || fail "CLAUDE.md missing"
claude_md_bytes="$(wc -c < "$claude_md" | tr -d ' ')"
[ "$claude_md_bytes" -le "$claude_md_budget" ] || fail "CLAUDE.md is $claude_md_bytes bytes, budget $claude_md_budget"
```

Run: `bash tests/test_mine_budget.sh`
Expected: `FAIL: CLAUDE.md missing`

- [ ] **Step 2: Write `CLAUDE.md`**

```markdown
## General

Do not tell me I am right all the time. Be critical. We're equals. Try to be neutral and objective.

Do not excessively use emojis.

## Precedence

Most specific wins: a repository guide over a product hub contract over this file. Exception: safety, git, privacy and output rules in this file always win.

## Hard rules

- Git mutations (branch, checkout, stage, commit, push, stash, reset, pull, remote) only on an explicit request in the current turn. Reads are free. Otherwise output the command as text.
- Never write explanatory comments into code. Names and tests are the explanation.
- Never print a secret value. Output the command that retrieves it.
- Preserve unrelated staged, unstaged and untracked changes in every repository.
- Identifiers, commit messages and logs are English.

## Context budget

- Progressive disclosure: task terms, the repository guide, at most three memory hits, the relevant files, their direct callers and tests. Widen only for a named unanswered question. Never preload a whole vault, every skill body, every guide, or logs.
- Batch independent checks into one message. Keep tool output near 4 KB; take targeted excerpts.
- One distinct task per session. When a phase turns noisy, write a handoff (skill `handoff`) and continue in a fresh session.

## Memory

A verified correction produces exactly one narrow durable change, preferred in this order: regression test, repository guide, product hub, rule, skill, `memory/patterns`, personal memory. Show the path. No guesses, secrets or transcripts.

## Testing

In tests, never type the same literal in two places (once in the arrange/act, once in the assert). Extract a single local constant and reference it in both the input and the expectation, so the test verifies that a value round-trips through one source of truth instead of matching two independently typed literals that can silently drift apart. Exception: a test that asserts a type's built-in default value against a literal is a single occurrence and is fine as-is.

## Writing docs / README

Never use dashes as punctuation in documentation or README files. Rephrase sentences using periods, commas, or parentheses instead.

## Coding standards

Language rules live in `~/.claude/rules/` (managed by `dotclaude/scripts/rules.sh`) and load only for matching files. Do not duplicate them here.

### Swift / iOS (mandatory)

Do not write Swift code without first invoking the relevant nerd skill via the Skill tool. The skills contain team conventions that override generic Swift best practices.

- Views, ViewModels, Coordinators, design system: `/nerd-swiftui-view`
- Naming, formatting, file organization: `/nerd-swift-codestyle`
- Tests: `/nerd-swift-testing`
- async/await, Tasks, actors, Combine: `/nerd-swift-concurrency`
- Networking, API clients: `/nerd-swift-networking`
- Architecture, layer boundaries, repositories: `/nerd-swift-architecture`
- Keychain, tokens, biometric auth: `/nerd-swift-security`
- DocC: `/nerd-swift-docc`
- Code review: `/nerd-swift-code-review`
- Networking from OpenAPI: `/nerd-swift-gen-api`
- Screen from Figma: `/nerd-swift-gen-screen`
- Component from Figma: `/nerd-swift-gen-component`
- New iOS project: `/nerd-ios-setup`

### Kotlin / Android / KMP (mandatory)

Same rule: invoke the nerd skill first.

- Compose screen: `/nerd-compose-screen-generation`, adaptive: `/nerd-adaptive-compose-screen-generation`
- Compose components: `/nerd-compose-ui-components`
- KMP screen and components: `/nerd-kmp-screen-generation`, `/nerd-kmp-ui-components`
- Design system: `/nerd-generate-design-system`, KMP: `/nerd-kmp-design-system-generation`
- API and data layer: `/nerd-api-data-generator`
- KDoc: `/nerd-kdoc-writer`
- New project: `/nerd-new-project-setup`, KMP: `/nerd-kmp-new-project-setup`
- Pre commit and quality gate: `/nerd-setup-precommit`, `/nerd-setup-quality-gate`
- Commit: `/nerd-code-commit`

When multiple skills apply, invoke the most specific one first, then reference the other as needed.

## Using GitHub

For questions about GitHub, use the gh tool.
Never mention Claude Code in PR descriptions, PR comments, or issue comments.
Do not include a "Test plan" section in PR descriptions.

## Product hubs

A product hub is recognised by a `*-hub/workspace.json` in an ancestor directory. Inside one: `nerd-hub-search` for facts about the product, `nerd-hub-graph` for architecture and blast radius, `nerd-hub-impact` before writing a PR description, `nerd-hub-drift` for spec drift, `handoff` when ending a noisy session. Team `.claude/` directories of sibling repositories are inert when a session starts at the product root; read a repository's own `CLAUDE.md` before changing it.
```

- [ ] **Step 3: Run the check**

Run: `bash tests/test_mine_budget.sh && wc -c CLAUDE.md`
Expected: `ok test_mine_budget.sh` and a byte count under 5632.

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md tests/test_mine_budget.sh
git commit -m "feat: personal CLAUDE.md with precedence, hard rules, context budget and memory policy"
```

---

### Task 6: `config/`, output style, manifests

**Files:**
- Create: `config/settings.json` (from dotfiles working tree)
- Create: `config/plugins.manifest`, `config/install-plugins.sh` (moved)
- Create: `config/mcp-servers.json`, `config/install-mcp.sh` (moved)
- Create: `config/skills.manifest`
- Create: `scripts/install-skills.sh`
- Create: `scripts/statusline.sh` (moved)
- Create: `output-styles/concise.md`
- Test: `tests/test_manifests.sh`

**Interfaces:**
- Produces: `config/skills.manifest` lines `name<TAB>expected_link_target<TAB>install_command`; `expected_link_target` is `-` for skills that are real directories; `install_command` is `-` when unknown. `scripts/install-skills.sh` runs the command for every listed skill missing from `<root>/skills/` and skips `-` with a warning. `doctor.sh` (Task 8) reads the same file.

- [ ] **Step 1: Move files from dotfiles**

```bash
cd ~/Documents/PersonalProjects/dotclaude
D=~/Documents/PersonalProjects/dotfiles/ai
mkdir -p config output-styles
cp "$D/.claude/settings.json" config/settings.json
cp "$D/.claude/plugins/plugins.manifest" config/plugins.manifest
cp "$D/.claude/plugins/install-plugins.sh" config/install-plugins.sh
cp "$D/.claude/mcp-configs/mcp-servers.json" config/mcp-servers.json
cp "$D/.claude/mcp-configs/install-mcp.sh" config/install-mcp.sh
cp "$D/scripts/statusline.sh" scripts/statusline.sh
grep -n 'plugins.manifest\|mcp-servers.json\|DOTFILES\|dirname' config/install-plugins.sh config/install-mcp.sh | head
```

Read the grep output: if either script resolves its data file relative to `$DOTFILES` or a dotfiles path, change it to `"$(dirname "${BASH_SOURCE[0]}")/plugins.manifest"` (respectively `mcp-servers.json`).

- [ ] **Step 2: Write the failing test `tests/test_manifests.sh`**

```bash
#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

manifest="$REPO/config/skills.manifest"
assert_file "$manifest"
# three tab separated columns on every non comment line
bad="$(grep -v '^#' "$manifest" | grep -v '^$' | awk -F'\t' 'NF != 3 { print }')"
assert_eq "" "$bad" "manifest rows with a column count other than 3"

# install-skills.sh runs the command only for missing skills
home="$(tmp_home)"
work="$home/repo"; cp -R "$REPO" "$work"
mkdir -p "$work/skills/present"
marker="$home/ran"
printf 'present\t-\ttouch %s-present\nmissing\t-\ttouch %s-missing\nunknown\t-\t-\n' "$marker" "$marker" > "$work/config/skills.manifest"
out="$(bash "$work/scripts/install-skills.sh" 2>&1)"
assert_not_exists "$marker-present"
assert_file "$marker-missing"
assert_contains "unknown" "$out"

# settings.json is valid JSON and keeps the plugin list
jq -e '.enabledPlugins["everything-claude-code@everything-claude-code"]' "$REPO/config/settings.json" > /dev/null || fail "settings.json invalid or plugin list missing"

finish
```

Run: `bash tests/test_manifests.sh`
Expected: `FAIL: expected file .../config/skills.manifest`

- [ ] **Step 3: Discover where the third party skills came from and write `config/skills.manifest`**

```bash
ls -la ~/.claude/skills | grep -- '->' | grep -v nerd-
ls ~/.agents/skills; cat ~/.agents/skills/*/SKILL.md 2>/dev/null | grep -i -m5 'source\|repo\|http'
ls ~/.claude/office-skills; cat ~/.claude/office-skills/README* 2>/dev/null | head -20
plannotator --help 2>&1 | head -5
```

Write the manifest with what those commands reveal. Columns are tab separated. Where the install command is not discoverable, write `-`:

```
# name	expected_link_target	install_command
# expected_link_target: absolute path the ~/.claude/skills entry links to, or - for a real directory
# install_command: shell command that (re)creates the skill, or - when unknown
docx	/Users/roman/.claude/office-skills/public/docx	-
pdf	/Users/roman/.claude/office-skills/public/pdf	-
pptx	/Users/roman/.claude/office-skills/public/pptx	-
xlsx	/Users/roman/.claude/office-skills/public/xlsx	-
find-skills	../../.agents/skills/find-skills	npx skills add find-skills
swift-concurrency	../../.agents/skills/swift-concurrency	-
swift-testing-expert	../../.agents/skills/swift-testing-expert	-
swiftui-expert-skill	../../.agents/skills/swiftui-expert-skill	-
plannotator	-	-
plannotator-annotate	-	-
plannotator-compound	-	-
plannotator-last	-	-
plannotator-review	-	-
plannotator-setup-goal	-	-
plannotator-visual-explainer	-	-
```

Replace each `-` in the third column with the real command when step 3's output shows it. `learned` is not listed: it is deleted in Task 9.

- [ ] **Step 4: Write `scripts/install-skills.sh`**

```bash
#!/usr/bin/env bash
# Reinstall third party skills listed in config/skills.manifest when they are missing.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

ROOT="$(dc_root)"
MANIFEST="$ROOT/config/skills.manifest"

grep -v '^#' "$MANIFEST" | grep -v '^$' | while IFS=$'\t' read -r name _target command; do
  if [ -e "$ROOT/skills/$name" ] || [ -L "$ROOT/skills/$name" ]; then
    echo "ok $name"
    continue
  fi
  if [ "$command" = "-" ]; then
    dc_log "warning: $name is missing and has no install command in $MANIFEST"
    continue
  fi
  dc_log "installing $name"
  (cd "$ROOT" && sh -c "$command")
done
```

- [ ] **Step 5: Write `output-styles/concise.md`**

```markdown
---
name: Concise
description: Compact engineering responses without losing verification or risk reporting
keep-coding-instructions: true
---

Respond concisely and lead with the outcome. Do not repeat the prompt, narrate routine tool steps, or restate a conclusion. Keep progress updates brief. Include commands, test results, changed files, risks and follow ups only when they help the user verify or act.
```

- [ ] **Step 6: Run the tests**

Run: `chmod +x scripts/install-skills.sh config/*.sh && bash tests/test_manifests.sh`
Expected: `ok test_manifests.sh`

- [ ] **Step 7: Commit**

```bash
git add config/ scripts/install-skills.sh scripts/statusline.sh output-styles/ tests/test_manifests.sh
git commit -m "feat: settings, plugin and skill manifests, concise output style"
```

---

### Task 7: Authored skills, linked dirs, nerd skill linking

**Files:**
- Create: `skills/handoff/SKILL.md`, `skills/memory-update/SKILL.md`
- Create: `agents/.gitkeep`, `commands/.gitkeep`, `memory/patterns/.gitkeep`
- Create: `scripts/link-nerd-skills.sh`
- Test: `tests/test_link_nerd.sh`

**Interfaces:**
- Produces: `scripts/link-nerd-skills.sh [ios_repo] [android_repo]` links every `nerd-*` directory holding a `SKILL.md` from both repos into `<root>/skills/`, replacing dangling links, and prints one line per skill. Defaults: `~/Documents/PersonalProjects/ai/mobile/nerd-ios-skills` and `.../nerd-android-skills`.

- [ ] **Step 1: Write the failing test `tests/test_link_nerd.sh`**

```bash
#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

home="$(tmp_home)"
work="$home/repo"; cp -R "$REPO" "$work"
ios="$home/ios"; android="$home/android"
ios_skill="nerd-swiftui-view"; android_skill="nerd-code-commit"
mkdir -p "$ios/$ios_skill" "$android/$android_skill" "$ios/readmes" "$work/skills"
touch "$ios/$ios_skill/SKILL.md" "$android/$android_skill/SKILL.md"
ln -s "$home/gone/$ios_skill" "$work/skills/$ios_skill"   # dangling, like today

bash "$work/scripts/link-nerd-skills.sh" "$ios" "$android" > /dev/null
assert_link "$work/skills/$ios_skill" "$ios/$ios_skill"
assert_link "$work/skills/$android_skill" "$android/$android_skill"
assert_not_exists "$work/skills/readmes"

finish
```

Run: `bash tests/test_link_nerd.sh`
Expected: `FAIL` about `link-nerd-skills.sh: No such file`.

- [ ] **Step 2: Write `scripts/link-nerd-skills.sh`**

```bash
#!/usr/bin/env bash
# Link team skills (nerd-*) from the iOS and Android skill repos into skills/.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

ROOT="$(dc_root)"
IOS="${1:-$HOME/Documents/PersonalProjects/ai/mobile/nerd-ios-skills}"
ANDROID="${2:-$HOME/Documents/PersonalProjects/ai/mobile/nerd-android-skills}"

link_all() {
  local repo="$1" dir
  if [ ! -d "$repo" ]; then
    dc_log "warning: $repo not found, clone it and re run"
    return 0
  fi
  for dir in "$repo"/nerd-*/; do
    [ -f "$dir/SKILL.md" ] || continue
    dc_link "${dir%/}" "$ROOT/skills/$(basename "$dir")"
  done
}

mkdir -p "$ROOT/skills"
link_all "$IOS"
link_all "$ANDROID"
```

- [ ] **Step 3: Write `skills/handoff/SKILL.md`**

```markdown
---
name: handoff
description: Write a compact continuation note when a task will continue in another session, after a noisy phase, or when the context advisory asks for it. Personal memory only, never a team repository.
---

# Handoff

1. Resolve the target directory. Inside a product hub (`*-hub/workspace.json` in an ancestor): `~/Documents/PersonalProjects/dotclaude/memory/<product>/tasks/<repo>/`, where `<product>` is the hub's `product` field and `<repo>` the current repository directory name, or `_root` at the product folder. Outside a hub: `~/Documents/PersonalProjects/dotclaude/memory/misc/tasks/<repo>/`.
2. Write `<task-id>.md` with these headings in this order: Goal, Current state, Verified facts, User corrections, Rejected approaches, Changed files, Checks run, Remaining work, Next action (exactly one).
3. Target about 800 tokens, never above 1500. Update the same file on later handoffs; never append chat history, logs, secrets or diffs.
4. The note must make sense without this conversation. Print the path you wrote.
```

- [ ] **Step 4: Write `skills/memory-update/SKILL.md`**

```markdown
---
name: memory-update
description: Record a verified reusable lesson (explicit user correction, repeated mistake, stable preference, non obvious command, technical decision) in the single narrowest durable place.
---

# Memory update

1. Verify the claim. Search existing memory (`~/Documents/PersonalProjects/dotclaude/memory/` and the native memory directory) for a note that already covers it.
2. Choose exactly one target, in this order of preference: a regression test, the repository guide, the product hub (as a pull request, never a direct write), a rule set file, a skill, `dotclaude/memory/patterns/` for cross product lessons, the product's personal memory folder.
3. Update rather than duplicate. Keep the note atomic and sourced. Exclude secrets, production values, transcripts, logs, diffs, speculation.
4. Print the exact path changed. Never answer only "remembered".
```

- [ ] **Step 5: Placeholders for linked dirs**

```bash
mkdir -p agents commands memory/patterns
touch agents/.gitkeep commands/.gitkeep memory/patterns/.gitkeep
```

- [ ] **Step 6: Run the tests**

Run: `chmod +x scripts/link-nerd-skills.sh && bash tests/test_link_nerd.sh`
Expected: `ok test_link_nerd.sh`

- [ ] **Step 7: Commit**

```bash
git add skills/handoff skills/memory-update agents commands memory scripts/link-nerd-skills.sh tests/test_link_nerd.sh
git commit -m "feat: handoff and memory-update skills, nerd skill linking"
```

---

### Task 8: `install.sh` and `scripts/doctor.sh`

**Files:**
- Create: `install.sh`
- Create: `scripts/doctor.sh`
- Test: `tests/test_install.sh`, `tests/test_doctor.sh`

**Interfaces:**
- Consumes: everything above.
- Produces:
  - `install.sh [--skip-plugins]`: creates the links of spec 3.1, adopts real `skills`, `agents`, `commands` dirs into the repo, backs up real `rules`, `hooks`, `output-styles`, `CLAUDE.md`, `settings.json`, `statusline.sh`, runs `rules.sh apply`, `link-nerd-skills.sh`, `install-skills.sh`, and unless `--skip-plugins` `config/install-plugins.sh`.
  - `scripts/doctor.sh`: prints `ok`, `warn`, `fail` lines and exits 1 if any `fail`. Checks: each link of 3.1 points to the repo; no dangling symlink under `skills/`, `rules/active/`; every `rules/active` entry is a managed symlink into `sets/`; every manifest skill exists; entries in `skills/` that are neither manifest, `nerd-*`, nor tracked by git are `warn` (unmanaged); hooks referenced in `config/settings.json` exist; `node`, `jq`, `claude` on PATH; every plugin in `plugins.manifest` appears in `<home>/plugins/installed_plugins.json` (warn only).

- [ ] **Step 1: Write the failing test `tests/test_install.sh`**

```bash
#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

home="$(tmp_home)"
work="$home/repo"; cp -R "$REPO" "$work"
rm -rf "$work/rules/active"

# a realistic pre install ~/.claude: real rules dir with ECC junk, real skills dir with an installer skill
mkdir -p "$CLAUDE_HOME/rules/common" "$CLAUDE_HOME/skills/plannotator" "$CLAUDE_HOME/agents" "$CLAUDE_HOME/commands"
echo junk > "$CLAUDE_HOME/rules/common/agents.md"
installer_skill_body="installer owned"
echo "$installer_skill_body" > "$CLAUDE_HOME/skills/plannotator/SKILL.md"
echo old > "$CLAUDE_HOME/CLAUDE.md"

bash "$work/install.sh" --skip-plugins > /dev/null 2>&1

assert_link "$CLAUDE_HOME/CLAUDE.md" "$work/CLAUDE.md"
assert_link "$CLAUDE_HOME/settings.json" "$work/config/settings.json"
assert_link "$CLAUDE_HOME/statusline.sh" "$work/scripts/statusline.sh"
assert_link "$CLAUDE_HOME/rules" "$work/rules/active"
assert_link "$CLAUDE_HOME/skills" "$work/skills"
assert_link "$CLAUDE_HOME/agents" "$work/agents"
assert_link "$CLAUDE_HOME/commands" "$work/commands"
assert_link "$CLAUDE_HOME/hooks" "$work/hooks"
assert_link "$CLAUDE_HOME/output-styles" "$work/output-styles"

# installer owned skill adopted into the repo dir, ECC rules junk backed up not adopted
assert_eq "$installer_skill_body" "$(cat "$work/skills/plannotator/SKILL.md")" "adopted skill"
backup="$(ls -d "$CLAUDE_HOME"/backups/*/ | head -1)"
assert_file "${backup}rules/common/agents.md"
assert_not_exists "$work/rules/active/common"
assert_link "$work/rules/active/mine" "../sets/mine"

# idempotent: second run changes nothing and creates no second backup dir
bash "$work/install.sh" --skip-plugins > /dev/null 2>&1
assert_eq 1 "$(ls -d "$CLAUDE_HOME"/backups/*/ | wc -l | tr -d ' ')" "backup dirs after second run"

finish
```

Run: `bash tests/test_install.sh`
Expected: `FAIL` lines, `install.sh: No such file`.

- [ ] **Step 2: Write `install.sh`**

```bash
#!/usr/bin/env bash
# Link ~/.claude into this repository. Safe to re run.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/scripts/lib.sh"

ROOT="$(dc_root)"
HOME_DIR="$(dc_home)"
WITH_PLUGINS=1
[ "${1:-}" = "--skip-plugins" ] && WITH_PLUGINS=0

mkdir -p "$HOME_DIR" "$ROOT/hooks" "$ROOT/skills" "$ROOT/agents" "$ROOT/commands" "$ROOT/output-styles"

# Directories whose current contents are worth keeping (installer written skills, personal agents/commands).
for name in skills agents commands; do
  if [ -d "$HOME_DIR/$name" ] && [ ! -L "$HOME_DIR/$name" ]; then
    dc_adopt_dir "$HOME_DIR/$name" "$ROOT/$name"
  fi
done

# Files and directories that are replaced outright (a real copy goes to the backup dir).
dc_link "$ROOT/CLAUDE.md" "$HOME_DIR/CLAUDE.md"
dc_link "$ROOT/config/settings.json" "$HOME_DIR/settings.json"
dc_link "$ROOT/scripts/statusline.sh" "$HOME_DIR/statusline.sh"
dc_link "$ROOT/rules/active" "$HOME_DIR/rules"
dc_link "$ROOT/skills" "$HOME_DIR/skills"
dc_link "$ROOT/agents" "$HOME_DIR/agents"
dc_link "$ROOT/commands" "$HOME_DIR/commands"
dc_link "$ROOT/hooks" "$HOME_DIR/hooks"
dc_link "$ROOT/output-styles" "$HOME_DIR/output-styles"

mkdir -p "$HOME_DIR/mcp-configs"
dc_link "$ROOT/config/mcp-servers.json" "$HOME_DIR/mcp-configs/mcp-servers.json"

"$ROOT/scripts/rules.sh" apply
"$ROOT/scripts/link-nerd-skills.sh"
"$ROOT/scripts/install-skills.sh"

if [ "$WITH_PLUGINS" = 1 ] && command -v claude > /dev/null; then
  bash "$ROOT/config/install-plugins.sh" || dc_log "warning: some plugins failed to install"
fi

dc_log "done. Run scripts/doctor.sh to verify."
```

- [ ] **Step 3: Run the install test**

Run: `chmod +x install.sh && bash tests/test_install.sh`
Expected: `ok test_install.sh`. `link-nerd-skills.sh` warns about missing repos in the temp home; that is expected (stderr is discarded in the test).

- [ ] **Step 4: Write the failing test `tests/test_doctor.sh`**

```bash
#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

home="$(tmp_home)"
work="$home/repo"; cp -R "$REPO" "$work"
rm -rf "$work/rules/active"
bash "$work/install.sh" --skip-plugins > /dev/null 2>&1
doctor="$work/scripts/doctor.sh"

# clean install passes (plugins are warn only in a temp home)
if ! bash "$doctor" > /dev/null 2>&1; then fail "doctor should pass after a clean install: $(bash "$doctor" 2>&1 | grep fail)"; fi

# a dangling skill link fails
dangling="nerd-gone"
ln -s "$home/nowhere" "$work/skills/$dangling"
out="$(bash "$doctor" 2>&1 || true)"
assert_contains "fail" "$out"
assert_contains "$dangling" "$out"
rm "$work/skills/$dangling"

# an unmanaged real directory in skills warns but passes
unmanaged="some-copy"
mkdir -p "$work/skills/$unmanaged"; touch "$work/skills/$unmanaged/SKILL.md"
out="$(bash "$doctor" 2>&1)"
assert_contains "warn" "$out"
assert_contains "$unmanaged" "$out"

# a wrong CLAUDE.md link fails
rm "$CLAUDE_HOME/CLAUDE.md"; echo real > "$CLAUDE_HOME/CLAUDE.md"
if bash "$doctor" > /dev/null 2>&1; then fail "doctor should fail when CLAUDE.md is not a link"; fi

finish
```

Run: `bash tests/test_doctor.sh`
Expected: `FAIL` lines, `doctor.sh: No such file`.

- [ ] **Step 5: Write `scripts/doctor.sh`**

```bash
#!/usr/bin/env bash
# Health check for the dotclaude installation. Exit 1 on any fail line.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

ROOT="$(dc_root)"
HOME_DIR="$(dc_home)"
STATUS=0

ok()   { echo "ok    $*"; }
warn() { echo "warn  $*"; }
fail() { echo "fail  $*"; STATUS=1; }

check_link() {
  local link="$1" target="$2"
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then ok "$link"; else fail "$link should link to $target"; fi
}

check_link "$HOME_DIR/CLAUDE.md" "$ROOT/CLAUDE.md"
check_link "$HOME_DIR/settings.json" "$ROOT/config/settings.json"
check_link "$HOME_DIR/statusline.sh" "$ROOT/scripts/statusline.sh"
check_link "$HOME_DIR/rules" "$ROOT/rules/active"
check_link "$HOME_DIR/skills" "$ROOT/skills"
check_link "$HOME_DIR/agents" "$ROOT/agents"
check_link "$HOME_DIR/commands" "$ROOT/commands"
check_link "$HOME_DIR/hooks" "$ROOT/hooks"
check_link "$HOME_DIR/output-styles" "$ROOT/output-styles"

# rules/active: only managed symlinks, none dangling
for entry in "$ROOT"/rules/active/*; do
  [ -e "$entry" ] || [ -L "$entry" ] || continue
  name="$(basename "$entry")"
  if [ ! -L "$entry" ]; then fail "rules/active/$name is not a symlink"
  elif [ ! -d "$entry" ]; then fail "rules/active/$name is dangling"
  elif [ "$(readlink "$entry")" != "../sets/$name" ]; then fail "rules/active/$name points outside sets/"
  else ok "rule set $name"; fi
done

# skills: dangling links fail, unmanaged entries warn
manifest_names="$(grep -v '^#' "$ROOT/config/skills.manifest" | grep -v '^$' | cut -f1)"
tracked="$(cd "$ROOT" && git ls-files skills | cut -d/ -f2 | sort -u)"
for entry in "$ROOT"/skills/*; do
  [ -e "$entry" ] || [ -L "$entry" ] || continue
  name="$(basename "$entry")"
  if [ -L "$entry" ] && [ ! -e "$entry" ]; then fail "skills/$name is a dangling link ($(readlink "$entry"))"; continue; fi
  case "$name" in nerd-*) ok "team skill $name"; continue ;; esac
  if printf '%s\n' "$manifest_names" | grep -qx "$name"; then ok "third party skill $name"
  elif printf '%s\n' "$tracked" | grep -qx "$name"; then ok "authored skill $name"
  else warn "skills/$name is unmanaged: not in skills.manifest, not nerd-*, not tracked"; fi
done
for name in $manifest_names; do
  [ -e "$ROOT/skills/$name" ] || [ -L "$ROOT/skills/$name" ] || warn "manifest skill $name is not installed (scripts/install-skills.sh)"
done

# hooks referenced from settings exist
for hook in $(jq -r '.. | .command? // empty' "$ROOT/config/settings.json" | grep -o '[^" ]*hooks/[^" ]*' | sed "s#\$HOME#$HOME#; s#~#$HOME#"); do
  if [ -f "$hook" ]; then ok "hook $hook"; else fail "hook $hook missing"; fi
done

# tools
for tool in node jq claude; do
  if command -v "$tool" > /dev/null; then ok "tool $tool"; else warn "tool $tool not on PATH"; fi
done

# plugins from the manifest are installed (warn only)
installed="$HOME_DIR/plugins/installed_plugins.json"
if [ -f "$installed" ]; then
  for plugin in $(grep '^plugin ' "$ROOT/config/plugins.manifest" | awk '{ print $2 }'); do
    if jq -e --arg p "$plugin" '.plugins[$p]' "$installed" > /dev/null 2>&1; then ok "plugin $plugin"; else warn "plugin $plugin not installed"; fi
  done
else
  warn "no installed_plugins.json at $installed"
fi

exit $STATUS
```

- [ ] **Step 6: Run both tests**

Run: `chmod +x scripts/doctor.sh && tests/run.sh`
Expected: every line `ok test_*.sh`.

- [ ] **Step 7: Commit**

```bash
git add install.sh scripts/doctor.sh tests/test_install.sh tests/test_doctor.sh
git commit -m "feat: install.sh links ~/.claude into the repo, doctor.sh verifies it"
```

---

### Task 9: Cut over `~/.claude` (phase 2)

**Files:**
- Modify: `~/.claude/` (live)
- Create: `~/.claude/backups/2026-09-21-ecc-copies.txt`

This task is manual and ordered. Do not parallelise.

- [ ] **Step 1: Remove the ECC copies from the live skills, agents, commands dirs**

```bash
ECC=~/.claude/plugins/cache/everything-claude-code/everything-claude-code/1.9.0
cd ~/.claude
: > backups/2026-09-21-ecc-copies.txt
for s in skills/*/; do n=$(basename "$s"); [ -L "skills/$n" ] && continue; [ -d "$ECC/skills/$n" ] && { echo "skills/$n" >> backups/2026-09-21-ecc-copies.txt; rm -rf "skills/$n"; }; done
for a in agents/*.md; do n=$(basename "$a"); [ -f "$ECC/agents/$n" ] && { echo "agents/$n" >> backups/2026-09-21-ecc-copies.txt; rm "$a"; }; done
for c in commands/*.md; do n=$(basename "$c"); [ -f "$ECC/commands/$n" ] && { echo "commands/$n" >> backups/2026-09-21-ecc-copies.txt; rm "$c"; }; done
rm -rf skills/learned
wc -l backups/2026-09-21-ecc-copies.txt; ls skills | wc -l; ls agents commands
```

Expected: `135` lines removed; `skills` has 16 entries plus 18 dangling `nerd-*` links; `agents` is empty; `commands` holds the five `nerd-*.md` plus any non ECC leftovers. The five `nerd-*.md` move to their own plugin (built separately), so park them:

```bash
mkdir -p backups/nerd-commands && mv commands/nerd-*.md backups/nerd-commands/
ls commands
```

Expected: empty, or only files you recognise as yours.

- [ ] **Step 2: Retire the dead hooks file**

```bash
mv ~/.claude/hooks/hooks.json ~/.claude/backups/ecc-hooks.json
mv ~/.claude/hooks/README.md ~/.claude/backups/ecc-hooks-README.md
rmdir ~/.claude/hooks
```

`rules/` is left in place; `install.sh` backs it up.

- [ ] **Step 3: Run the installer**

```bash
cd ~/Documents/PersonalProjects/dotclaude && ./install.sh --skip-plugins
```

Expected output includes `linked .../rules`, `linked .../skills`, `adopted plannotator into .../skills` and similar lines for the office and `.agents` links, `linked mine`, then `linked` lines for 18 `nerd-*` skills from the iOS repo and 14 from Android.

- [ ] **Step 4: Verify**

```bash
scripts/doctor.sh; echo "exit $?"
ls -la ~/.claude | grep -- '->'
scripts/rules.sh list
```

Expected: `exit 0`, nine arrows, `* mine` under 8192 bytes. Any `warn skills/<x> is unmanaged` names a skill to add to `config/skills.manifest` or delete.

- [ ] **Step 5: Verify in a fresh session**

Open a new terminal, `cd $(mktemp -d)`, run `claude`, and ask: `list the skills you have available whose name starts with nerd- or tdd-`. Expected: `tdd-workflow` appears once (as `everything-claude-code:tdd-workflow`), the `nerd-*` skills appear once each. Then open a Swift file in a nerd repo through the assistant and ask which rule files are loaded; expected: `swift/coding-style.md` and siblings from `mine`. Exit.

Then the A/B switch:

```bash
scripts/rules.sh only ecc && scripts/rules.sh status
scripts/rules.sh only mine && scripts/rules.sh status
```

Expected: `active:` shows exactly the named set each time.

- [ ] **Step 6: Commit whatever the adoption changed in the repo**

```bash
cd ~/Documents/PersonalProjects/dotclaude && git status --short
```

Expected: nothing tracked changed (adopted skills are ignored). If `config/skills.manifest` was edited in step 4, commit it: `git add config/skills.manifest && git commit -m "chore: record adopted third party skills"`.

- [ ] **Step 7: Push**

```bash
git push -u origin main
```

---

### Task 10: Strip AI content from `dotfiles` (phase 2, second half)

**Files:**
- Delete: `dotfiles/ai/` (whole directory)
- Modify: `dotfiles/machine-setup/unix/install-ai.sh` (rewrite)
- Modify: `dotfiles/machine-setup/bootstrap.sh:298-340`
- Modify: `dotfiles/machine-setup/unix/Brewfile`
- Modify: `dotfiles/README.md` (the `ai/` section)

- [ ] **Step 1: Confirm dotclaude holds the live content before deleting**

```bash
cd ~/Documents/PersonalProjects/dotfiles
diff ai/.claude/settings.json ~/Documents/PersonalProjects/dotclaude/config/settings.json && echo same-settings
grep -c 'Swift / iOS' ~/Documents/PersonalProjects/dotclaude/CLAUDE.md
```

Expected: `same-settings` and `1`. (If Task 11 already ran, `diff` shows the added `hooks` and `outputStyle` keys and nothing else.)

- [ ] **Step 2: Delete `ai/` and rewrite `install-ai.sh`**

```bash
git rm -r ai
```

New `machine-setup/unix/install-ai.sh`:

```bash
#!/bin/bash
# AI configuration lives in the private dotclaude repository. This script only fetches and runs it.
set -e

DOTCLAUDE_DIR="${DOTCLAUDE_DIR:-$HOME/Documents/PersonalProjects/dotclaude}"
DOTCLAUDE_REPO="git@github.com:RomanKovalchukDev/dotclaude.git"

if ! command -v claude > /dev/null 2>&1; then
  echo "Claude Code CLI not found. Install it from https://code.claude.com and re run." >&2
  exit 1
fi

if [ ! -d "$DOTCLAUDE_DIR/.git" ]; then
  echo "Cloning dotclaude into $DOTCLAUDE_DIR"
  git clone "$DOTCLAUDE_REPO" "$DOTCLAUDE_DIR"
fi

exec "$DOTCLAUDE_DIR/install.sh"
```

- [ ] **Step 3: Update `bootstrap.sh`**

Replace the three `echo "    - ..."` lines in the dry run block (lines 304 to 306) and the three in the success block (lines 332 to 334) with one line each: `echo "    - dotclaude (private): CLAUDE.md, rules, skills, hooks, plugins"`. Leave the rest of `setup_claude_code` unchanged.

- [ ] **Step 4: Brewfile**

Append to `machine-setup/unix/Brewfile`:

```ruby
brew "jq"
brew "shellcheck"
```

- [ ] **Step 5: README**

Replace the `### ai/` section of `README.md` with:

```markdown
### AI configuration

Claude Code configuration is not part of this repository. It lives in the private `dotclaude` repository, which `machine-setup/unix/install-ai.sh` clones and installs during bootstrap. Everything under `~/.claude` except `settings.local.json` is a symlink into that repository.
```

Also remove the "Layered Architecture" and "Structure" bullets that follow it (they describe the deleted `ai/` layout).

- [ ] **Step 6: Verify bootstrap still parses and the installer is a no op on this machine**

```bash
bash -n machine-setup/bootstrap.sh && bash -n machine-setup/unix/install-ai.sh && echo parse-ok
bash machine-setup/unix/install-ai.sh | grep -c '^ok '
```

Expected: `parse-ok`, then a count of at least 9 (every link already correct).

- [ ] **Step 7: Commit dotfiles**

```bash
git add -A ai machine-setup/unix/install-ai.sh machine-setup/bootstrap.sh machine-setup/unix/Brewfile README.md docs/plans
git commit -m "refactor: move AI configuration to the private dotclaude repository"
```

The pre existing uncommitted changes in `config/unix/ghostty/config`, `config/unix/git/gitconfig.symlink` and `config/unix/bin/plannotator` are unrelated; leave them unstaged.

---

### Task 11: Context advisory hook (phase 3)

**Files:**
- Create: `hooks/context-advisory.mjs`
- Modify: `config/settings.json` (add `hooks` and `outputStyle`)
- Test: `tests/hook.test.mjs`

**Interfaces:**
- Consumes: hook JSON on stdin: `{ "session_id", "transcript_path", "hook_event_name" }` (`UserPromptSubmit` or `PreCompact`).
- Produces: on `UserPromptSubmit`, prints one advisory to stdout the first time each threshold is crossed in a session (stdout of this event is added to the model's context); on `PreCompact`, resets the session's state so advisories fire again after compaction. State file: `<repo>/state/context-advisory/<session_id>.json` as `{ "level": n }` (`CA_STATE_DIR` overrides the directory). Context size is the sum of `input_tokens + cache_read_input_tokens + cache_creation_input_tokens` of the last `usage` object in the transcript's final 2 MB. Env: `CA_NOTE` (250000), `CA_CHECKPOINT` (500000), `CA_DRIFT` (750000). Never exits non zero.

- [ ] **Step 1: Write the failing tests `tests/hook.test.mjs`**

```javascript
import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, writeFileSync, rmSync } from "node:fs";
import { join, dirname } from "node:path";
import { tmpdir } from "node:os";
import { fileURLToPath } from "node:url";

const repo = join(dirname(fileURLToPath(import.meta.url)), "..");
const hook = join(repo, "hooks", "context-advisory.mjs");

function transcriptWith(tokens, dir) {
  const path = join(dir, "transcript.jsonl");
  const lines = [
    JSON.stringify({ type: "user", message: { role: "user", content: "hi" } }),
    "not json at all",
    JSON.stringify({ type: "assistant", message: { usage: { input_tokens: 2, cache_read_input_tokens: tokens - 2, cache_creation_input_tokens: 0 } } }),
  ];
  writeFileSync(path, lines.join("\n") + "\n");
  return path;
}

function run(event, transcriptPath, sessionId, stateRoot, env = {}) {
  const input = JSON.stringify({ session_id: sessionId, transcript_path: transcriptPath, hook_event_name: event });
  const result = spawnSync("node", [hook], { input, env: { ...process.env, CA_STATE_DIR: stateRoot, ...env }, encoding: "utf8" });
  assert.equal(result.status, 0, result.stderr);
  return result.stdout;
}

test("prints nothing below the first threshold", () => {
  const dir = mkdtempSync(join(tmpdir(), "ca-"));
  const out = run("UserPromptSubmit", transcriptWith(100_000, dir), "s1", dir);
  assert.equal(out, "");
  rmSync(dir, { recursive: true });
});

test("prints the note once when crossing 250k, then stays silent", () => {
  const dir = mkdtempSync(join(tmpdir(), "ca-"));
  const transcript = transcriptWith(260_000, dir);
  const first = run("UserPromptSubmit", transcript, "s2", dir);
  assert.match(first, /Context note/);
  const second = run("UserPromptSubmit", transcript, "s2", dir);
  assert.equal(second, "");
  rmSync(dir, { recursive: true });
});

test("escalates to checkpoint and drift, one line each", () => {
  const dir = mkdtempSync(join(tmpdir(), "ca-"));
  run("UserPromptSubmit", transcriptWith(260_000, dir), "s3", dir);
  const checkpoint = run("UserPromptSubmit", transcriptWith(510_000, dir), "s3", dir);
  assert.match(checkpoint, /Context checkpoint/);
  assert.doesNotMatch(checkpoint, /Context note/);
  const drift = run("UserPromptSubmit", transcriptWith(760_000, dir), "s3", dir);
  assert.match(drift, /Context drift/);
  rmSync(dir, { recursive: true });
});

test("PreCompact resets so the note fires again", () => {
  const dir = mkdtempSync(join(tmpdir(), "ca-"));
  const transcript = transcriptWith(300_000, dir);
  run("UserPromptSubmit", transcript, "s4", dir);
  run("PreCompact", transcript, "s4", dir);
  const again = run("UserPromptSubmit", transcript, "s4", dir);
  assert.match(again, /Context note/);
  rmSync(dir, { recursive: true });
});

test("thresholds come from the environment", () => {
  const dir = mkdtempSync(join(tmpdir(), "ca-"));
  const lowNote = "1000";
  const out = run("UserPromptSubmit", transcriptWith(5_000, dir), "s5", dir, { CA_NOTE: lowNote });
  assert.match(out, /Context note/);
  rmSync(dir, { recursive: true });
});

test("missing transcript or empty stdin is silent and exits 0", () => {
  const dir = mkdtempSync(join(tmpdir(), "ca-"));
  const out = run("UserPromptSubmit", join(dir, "nope.jsonl"), "s6", dir);
  assert.equal(out, "");
  const empty = spawnSync("node", [hook], { input: "", encoding: "utf8" });
  assert.equal(empty.status, 0);
  assert.equal(empty.stdout, "");
  rmSync(dir, { recursive: true });
});
```

Run: `node --test tests/hook.test.mjs`
Expected: all six tests fail with `Cannot find module .../hooks/context-advisory.mjs`.

- [ ] **Step 2: Write `hooks/context-advisory.mjs`**

```javascript
#!/usr/bin/env node
// Claude Code hook: advisory notes as the context window grows. Never blocks, never exits non zero.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const stateDir = process.env.CA_STATE_DIR || path.join(repo, "state", "context-advisory");
const TAIL_BYTES = 2 * 1024 * 1024;

function threshold(name, fallback) {
  const value = Number(process.env[name]);
  return Number.isFinite(value) && value > 0 ? value : fallback;
}

const LEVELS = [
  {
    at: threshold("CA_NOTE", 250000),
    text: "Context note: this session is past the first context threshold. Finish the current sub task normally; when it ends, a fresh session seeded with a handoff (skill `handoff`) costs far less than continuing here.",
  },
  {
    at: threshold("CA_CHECKPOINT", 500000),
    text: "Context checkpoint: each tool round now replays a very large context. Close the current coherent phase, write a handoff with the `handoff` skill, and continue in a fresh session. Do not abandon work mid change to do this.",
  },
  {
    at: threshold("CA_DRIFT", 750000),
    text: "Context drift warning: this session is near compaction. Re check current source and the user's explicit corrections before trusting any earlier conclusion in this conversation.",
  },
];

function readStdin() {
  try {
    return fs.readFileSync(0, "utf8");
  } catch {
    return "";
  }
}

function tail(file) {
  if (!file || !fs.existsSync(file)) return "";
  const fd = fs.openSync(file, "r");
  try {
    const size = fs.fstatSync(fd).size;
    const length = Math.min(size, TAIL_BYTES);
    const buffer = Buffer.alloc(length);
    fs.readSync(fd, buffer, 0, length, size - length);
    return buffer.toString("utf8");
  } finally {
    fs.closeSync(fd);
  }
}

function findUsage(value, out = []) {
  if (!value || typeof value !== "object") return out;
  if (value.usage && typeof value.usage === "object") out.push(value.usage);
  for (const nested of Object.values(value)) findUsage(nested, out);
  return out;
}

function observedContext(transcriptPath) {
  let latest = 0;
  for (const line of tail(transcriptPath).split("\n")) {
    if (!line.trim().startsWith("{")) continue;
    try {
      for (const usage of findUsage(JSON.parse(line))) {
        const total = ["input_tokens", "cache_read_input_tokens", "cache_creation_input_tokens"]
          .reduce((sum, key) => sum + (Number(usage[key]) || 0), 0);
        if (total > 0) latest = total;
      }
    } catch {
      // partial or malformed line, ignored
    }
  }
  return latest;
}

function stateFile(sessionId) {
  const safe = String(sessionId || "unknown").replace(/[^a-zA-Z0-9_-]/g, "_");
  return path.join(stateDir, `${safe}.json`);
}

function loadLevel(file) {
  try {
    return Number(JSON.parse(fs.readFileSync(file, "utf8")).level) || 0;
  } catch {
    return 0;
  }
}

function saveLevel(file, level) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const temporary = `${file}.${process.pid}.tmp`;
  fs.writeFileSync(temporary, JSON.stringify({ level }));
  fs.renameSync(temporary, file);
}

function main() {
  let input;
  try {
    input = JSON.parse(readStdin());
  } catch {
    return;
  }
  const file = stateFile(input.session_id);
  if (input.hook_event_name === "PreCompact") {
    saveLevel(file, 0);
    return;
  }
  if (input.hook_event_name !== "UserPromptSubmit") return;

  const context = observedContext(input.transcript_path);
  const reached = LEVELS.filter((level) => context >= level.at).length;
  const previous = loadLevel(file);
  if (reached > previous) {
    process.stdout.write(`${LEVELS[reached - 1].text}\n`);
    saveLevel(file, reached);
  }
}

try {
  main();
} catch {
  // a hook must never break a prompt
}
```

- [ ] **Step 3: Run the hook tests**

Run: `node --test tests/hook.test.mjs`
Expected: `# pass 6`.

- [ ] **Step 4: Register the hook and the output style in `config/settings.json`**

Add these two top level keys (keep everything else):

```json
"outputStyle": "Concise",
"hooks": {
  "UserPromptSubmit": [
    { "hooks": [ { "type": "command", "command": "node \"$HOME/.claude/hooks/context-advisory.mjs\"" } ] }
  ],
  "PreCompact": [
    { "hooks": [ { "type": "command", "command": "node \"$HOME/.claude/hooks/context-advisory.mjs\"" } ] }
  ]
}
```

Run: `jq . config/settings.json > /dev/null && scripts/doctor.sh | grep hook`
Expected: `ok    hook /Users/roman/.claude/hooks/context-advisory.mjs`.

- [ ] **Step 5: Live check**

Start a new `claude` session in any directory and send one prompt. Expected: no advisory (context is small) and no error banner about hooks. Then run `/hooks` and confirm both events list the command.

- [ ] **Step 6: Run the whole suite and commit**

```bash
tests/run.sh
git add hooks/context-advisory.mjs tests/hook.test.mjs config/settings.json
git commit -m "feat: context advisory hook and concise output style"
git push
```

---

### Task 12: Final README and phase gate

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Extend the README with what exists now**

Append to `README.md`:

```markdown
## Rule sets

`rules/sets/<name>/` holds one set each. `rules/enabled` lists the defaults; `~/.claude/rules.enabled.local` overrides them on this machine. `mine` is the personal set, `ecc` is Everything Claude Code 1.9.0 untouched (for comparison runs), `exp-<name>` are experiments layered on `mine`. `mine` and `ecc` contradict each other, so enable one or the other, not both.

## Third party skills

`~/.claude/skills` links into `skills/`. Installers (office skills, skills.sh, Plannotator) keep writing there; `config/skills.manifest` records each one and how to reinstall it, `scripts/install-skills.sh` reinstalls what is missing, and `scripts/doctor.sh` warns about anything unmanaged. Team `nerd-*` skills are symlinks created by `scripts/link-nerd-skills.sh`.

## Hooks

`hooks/context-advisory.mjs` prints a short note the first time a session passes 250k, 500k and 750k tokens of context, and resets after compaction. Override with `CA_NOTE`, `CA_CHECKPOINT`, `CA_DRIFT` in `~/.claude/settings.local.json` under `env`.

## Personal memory

`memory/patterns/` holds cross product lessons. Product folders (`memory/<product>/`) are created by the `handoff` skill and, later, by `scripts/link-memory.sh`.
```

- [ ] **Step 2: Commit and push**

```bash
git add README.md
git commit -m "docs: rule sets, third party skills, hooks, memory"
git push
```

- [ ] **Step 3: Phase gate**

Use the setup for a few days. Before starting phases 4 to 8 (marketplace rename, `nerd-hub` plugin), note in `memory/patterns/` anything the advisories or rule sets got wrong.

---

## Self review

**Spec coverage (sections 2, 3, 6 phases 0 to 3, 7):**
- 3 tree: `install.sh` (T8), `scripts/lib.sh` (T2), `doctor.sh` (T8), `rules.sh` (T3), `link-nerd-skills.sh` (T7), `link-memory.sh` is phase 7 and out of scope; `statusline.sh`, `config/*` (T6), `CLAUDE.md` (T5), `rules/` (T3, T4), `skills/handoff`, `skills/memory-update` (T7), `agents/`, `commands/` (T7), `hooks/context-advisory.mjs` (T11), `output-styles/concise.md` (T6), `memory/patterns/` (T7), README (T1, T12).
- 3.1 links: T8 and verified in T9.
- 3.2 rule sets, local override, `list` bytes, A/B: T3, exercised in T9 step 5.
- 3.3 CLAUDE.md outline: T5, every listed section present.
- 3.4 handoff, memory-update, advisory: T7, T11.
- Phase 0: T0. Phase 1: T1 to T8. Phase 2: T9, T10. Phase 3: T11.
- Section 7 ECC upgrade note: `rules/sets/ecc/VERSION` from T3.

**Placeholders:** `config/skills.manifest` third column contains `-` for install commands not discoverable at plan time; the script and doctor handle `-` explicitly and T6 step 3 tells the executor how to discover them. That is a documented unknown, not a placeholder.

**Type consistency:** helper names `dc_root`, `dc_home`, `dc_log`, `dc_backup_dir`, `dc_backup`, `dc_link`, `dc_adopt_dir`, `dc_is_scoped`, `dc_unconditional_bytes` are used identically in T2, T3, T4 test, T6, T7, T8. `rules.sh` subcommands `list status apply enable disable only` match between T3 script, T3 test, T8 install, T9. `install.sh --skip-plugins` is the same flag in T8 script, T8 tests, T9. The hook's env names `CA_NOTE`, `CA_CHECKPOINT`, `CA_DRIFT`, `CA_STATE_DIR` match between T11 script, test and README.
