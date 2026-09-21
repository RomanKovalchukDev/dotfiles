# AI setup redesign

Date: 2026-09-21
Status: revision 5, for review
Owner: Roman

## 1. Goal

Make `~/.claude` a set of symlinks into one private repo (`dotclaude`) so it can be rebuilt with one command, cut the unconditional context from 24 KB to under 8 KB, make rule sets switchable, and give every product a team shared hub repo plus a team plugin (`nerd-hub`) that lets agents and people see the cross repo picture: specs, dependency graph, PR impact, knowledge base. Plain shell scripts, no CLI.

| Layer | Where | Owns | Audience |
| --- | --- | --- | --- |
| Machine | `dotfiles` (public) | shell, git, brew, macOS defaults; `bootstrap.sh` clones `dotclaude` and runs its installer | Roman |
| Global AI | `dotclaude` (new, private) | everything `~/.claude` links to: `CLAUDE.md`, settings, rule sets, personal skills and agents, hooks, output style, manifests, scripts, personal memory | Roman |
| Team tooling | `nerdzlab-marketplace` (renamed from `nerd-mobile-marketplace`) + new plugin `nerd-hub` (Roman's account first, org after adoption) | hub skills, hub scripts, hub session hook, hub template | every teammate, via `claude plugin install` |
| Product hub | `work/<product>/<product>-hub` (repo per product, scaffolded by `nerd-hub-init`) | product contract for agents, API spec, service map, dependency graph, knowledge base; data only | the team; PRs land here when the graph or behaviour changes |
| Platform | `work/<product>/<product>-{backend,ios,android,landing}` | team `CLAUDE.md`, team `.claude/` skills and hooks | each team |

Non goals: changing platform repos, a CLI, Codex or other agents, test case repos and test tagging (next step after this plan), mobile ai-readiness (separate plan; the hub and `nerd-hub-impact` are inputs to it).

## 2. Verified current state (2026-09-21)

Always loaded into every request today, about 24 KB: personal `CLAUDE.md` 2.2 K (fine), `rules/common/*.md` 11.8 K (ECC content, stale, never chosen), four unscoped top level duplicates of `common/` 5.8 K (loaded twice), `rules/README.md` 4.3 K (ECC install guide loaded as a rule). Language rule dirs are path scoped and correct.

ECC duplication (plugin 1.9.0 installed and enabled): `skills/` 47 of 63, `agents/` 28 of 28, `commands/` 60 of 65 are copies of what the plugin serves, frozen at the version `configure-ecc` ran with, each paying its description into context twice.

None of the other 16 skills are authored by Roman: `docx pdf pptx xlsx` link into `~/.claude/office-skills/` (Anthropic installer); `find-skills swift-concurrency swift-testing-expert swiftui-expert-skill` link into `~/.agents/skills/` (skills.sh); seven `plannotator-*` are written by the Plannotator installer; `learned` is an empty ECC output dir. The 18 `nerd-*` entries link to team repos.

Other: `~/.claude/hooks/hooks.json` is a dead ECC copy; nothing under `~/.claude/{rules,skills,agents,commands,hooks}` is version controlled; `dotfiles/ai/.claude/skills/{clone,install}.sh` point at stale repo names and paths; `dotfiles/ai/install.sh` tells the user to run ECC's installer; personal `CLAUDE.md` forbids dashes in docs while every ECC rule uses them; `qmd`, `graphify`, `oasdiff` not installed; node 22.20, system python 3.9.6, plannotator present.

## 3. `dotclaude` (private)

```
dotclaude/
  install.sh                 backup real entries, create every symlink in 3.1, apply manifests, rules.sh apply, link nerd skills
  scripts/
    lib.sh                   backup, reconcile_links, unconditional_bytes
    doctor.sh                every link, plugin, tool, hook present; unmanaged entries in rules/active, skills, commands, agents
    rules.sh                 list | enable | disable | only | status | apply
    link-nerd-skills.sh      symlinks ai/mobile/nerd-ios-skills/* and nerd-android-skills/* into skills/
    link-memory.sh           <product>: symlink native memory dirs into memory/<product>/
    statusline.sh
  config/
    settings.json
    plugins.manifest  install-plugins.sh
    skills.manifest          third party skills and their install command
    mcp-servers.json
  CLAUDE.md                  the only unconditional file, about 5 KB
  rules/
    enabled                  committed default: mine
    sets/mine/               common/ swift/ kotlin/ dart/ typescript/ golang/ python/ csharp/ java/ php/ cpp/ rust/ perl/
    sets/ecc/                ECC rules verbatim from the plugin, VERSION file inside
    sets/exp-<name>/         experiments
    active/                  gitignored; one symlink per enabled set, rebuilt by rules.sh apply
  skills/
    handoff/ memory-update/  authored, committed
    <everything else>        gitignored; written through the symlink by installers or link-nerd-skills
  agents/                    authored, committed; empty at first
  commands/                  empty; the nerd-* commands move to the nerd pipeline plugin built in parallel
  hooks/
    context-advisory.mjs     UserPromptSubmit, PreCompact
  output-styles/concise.md
  memory/
    patterns/                cross product lessons
    <product>/repos/<name>/  native memory of each platform repo, via link-memory.sh
    <product>/tasks/<name>/  handoffs written by the handoff skill
  README.md
```

### 3.1 `~/.claude` after `install.sh`

```
CLAUDE.md            -> dotclaude/CLAUDE.md
settings.json        -> dotclaude/config/settings.json
settings.local.json     real, machine specific, the only unlinked file
statusline.sh        -> dotclaude/scripts/statusline.sh
rules                -> dotclaude/rules/active
skills               -> dotclaude/skills
agents               -> dotclaude/agents
commands             -> dotclaude/commands
hooks                -> dotclaude/hooks
output-styles        -> dotclaude/output-styles
```

Third party installers keep writing into `~/.claude/skills`, which lands in `dotclaude/skills/` and is gitignored there; `skills.manifest` records how to reinstall each. `doctor.sh` reports anything in the linked dirs that is neither in a manifest nor a managed symlink nor committed.

### 3.2 Rule sets

`mine` and `ecc` are alternatives (they contradict), experiments are overlays on `mine`. `~/.claude/rules.enabled.local` overrides `enabled` per machine. Changes apply at the next session. `rules.sh list` prints unconditional bytes per set. `rules.sh only ecc` then `only mine` is the A/B switch for eval-harness runs.

`mine`, first version: from the plugin's `rules/` at 1.9.0, delete top level duplicates and README; in `common/` delete `agents.md`, `performance.md`, `hooks.md`, `patterns.md`, `development-workflow.md`; rewrite the rest short, in Roman's voice, 3 KB for the directory; in language dirs fix links to deleted files, drop ECC agent references, fix stale names; add `dart/` pointing at the VGV skills with `paths: **/*.dart`. No dashes as punctuation.

### 3.3 `CLAUDE.md` outline

General (current) · Precedence (repo guide over hub contract over this file, except safety, git, privacy, output where this file wins) · Hard rules (git mutations only on explicit request in the current turn; no explanatory comments; never print a secret, print the command that retrieves it; preserve unrelated changes; English) · Context budget (progressive disclosure, batch checks, output near 4 KB, fresh session per task, handoff when noisy) · Memory policy (one narrow durable change per verified correction: regression test, repo guide, hub, rule, skill, patterns, personal memory) · Testing (current) · Docs (current) · Mandatory nerd skills for Swift and Android · GitHub (current) · Product hubs (recognise by a `*-hub/workspace.json` in an ancestor; `nerd-hub-*` for search, graph, impact, drift; `handoff` when ending a noisy session).

### 3.4 Personal skills and hook

- `handoff`: write `memory/<product>/tasks/<repo>/<task>.md`: goal, state, verified facts, corrections, rejected approaches, changed files, remaining work, one next action; about 800 tokens. Outside a hub, write to `memory/misc/tasks/`.
- `memory-update`: apply the memory policy; team facts become a hub PR, personal ones go to `dotclaude/memory`.
- `context-advisory.mjs`: parse the transcript's last usage record; one advisory at 250k, 500k, 750k (finish sub task; write handoff and start fresh; near compaction, re verify). Thresholds by env. Never blocks.

## 4. `nerd-hub` plugin (team)

Developed under Roman's account and installed from a local marketplace path (`claude plugin marketplace add <path>`) until phase 8 passes; then published in `nerdzlab-marketplace` and installed with `claude plugin install nerd-hub@nerdzlab-marketplace`. Depends on bash, node, qmd, graphify, oasdiff; `nerd-hub-init` checks and prints install commands.

```
nerd-hub/
  .claude-plugin/plugin.json
  skills/
    nerd-hub-init/           scaffold a hub from template/, write the parent CLAUDE.md, register repos, set up qmd
    nerd-hub-search/         search the hub; read at most three hits
    nerd-hub-graph/          architecture, call path, blast radius questions only
    nerd-hub-impact/         before writing a PR description in a hub product, run ws-impact and include its block
    nerd-hub-drift/          run ws-drift and summarise
  scripts/
    lib.sh                   hub_root (walk up to a dir containing *-hub/workspace.json), read_repos, require tools
    ws-setup  ws-search  ws-graph  ws-deps  ws-impact  ws-drift
  hooks/
    hooks.json               SessionStart: hub-session-start.mjs
    hub-session-start.mjs    inside a hub: inject product name and current repo, capped at 1 KB; outside: nothing
  template/                  the hub scaffold, see 5.2
  README.md
```

Skills reference scripts as `"${CLAUDE_PLUGIN_ROOT}/scripts/ws-impact"`. CI in a hub repo clones the plugin and runs `scripts/ws-deps` to check `deps/graph.json` is current.

## 5. Product hub

### 5.1 On disk

```
work/book-reader/                       plain folder, not a repo
  CLAUDE.md                             one real line, written by nerd-hub-init:  @book-reader-hub/CLAUDE.md
  book-reader-hub/                      team repo, data only
  book-reader-backend/
  book-reader-ios/
  book-reader-android/
  book-reader-landing/
```

Claude Code loads `CLAUDE.md` from the cwd and every parent directory, so a session started in `book-reader-ios/` also reads `work/book-reader/CLAUDE.md`, whose `@` import pulls in the hub contract. Scripts find the hub by walking up until a directory contains `*-hub/workspace.json`. No symlinks in the parent.

Sessions start in a platform repo for single platform work (team `CLAUDE.md`, skills and hooks active) or in `work/book-reader/` for cross platform work (team `.claude/` inert; the hub contract names them and requires reading each repo's `CLAUDE.md` before changing it; nerd iOS and Android skills are global so conventions stay reachable).

### 5.2 Hub repo (data only)

```
book-reader-hub/
  README.md                how people use it: Obsidian, PR expectations, which plugin to install
  CLAUDE.md                product contract for agents, about 2 KB, {{ADAPT}} slots from the template
  workspace.json           repos: name, dir, kind, spec_export, spec_consumer
  spec/openapi.yaml        API source of truth, + CHANGELOG.md
  SERVICE-MAP.md           services, who calls whom, auth boundaries, environments; hand maintained
  deps/
    graph.json             generated by ws-deps, committed
    by-operation.md        operation to consumer files
    by-repo.md             repo to operations exposed or consumed
  knowledge/               Obsidian vault: 00-index.md, architecture/, decisions/, incidents/, external-systems/, features/
                           templates borrowed from ai-readiness-toolkit templates/vault
  .obsidian/               minimal config, no plugins required
  .gitignore               graphs/, qmd state
```

### 5.3 Dependency graph and PR impact

Nodes: `operation` (from `spec/openapi.yaml`, keyed by operationId), `file` (in a consumer or backend repo), `feature` (from `knowledge/features/`). Test case nodes are the next step after this plan.

`ws-deps` builds edges: backend files exposing operations from the route table or exported spec; consumer files by scanning each `spec_consumer` repo for generated client method names and operation paths (one scanner per kind: swift, kotlin, typescript).

`ws-impact <repo> [<base>..<head>]` (default: merge base of trunk to working tree): changed files; backend: export the spec at `<head>`, `oasdiff` against `spec/openapi.yaml`, map to operations, add operations whose implementing files changed; consumer: operations referenced by the changed files; expand through `ws-graph affected` for files not directly on an operation; walk the graph; print a Markdown block for the PR description: what to check first on other platforms, and whether the hub needs a PR (spec, service map, deps, or a feature note changed).

### 5.4 Drift

Against `spec/openapi.yaml`: backend export via `oasdiff breaking` and `changelog` (BREAKING, CHANGED, IN SYNC); each `spec_consumer` carries `.spec-hash` (sha256 of the spec it was generated from) and reports STALE, CURRENT, or UNKNOWN when missing. Dependency outside this plan: `nerd-swift-gen-api` and the Android generator write `.spec-hash`.

### 5.5 What loads per session type

| Starts in | Instruction files | Team `.claude/` | Personal memory |
| --- | --- | --- | --- |
| anywhere else | `dotclaude/CLAUDE.md` + enabled rule sets | none | native per cwd |
| `work/<p>/<p>-ios/` | ios `CLAUDE.md` + hub contract via parent import + global | active | native, linked to `dotclaude/memory/<p>/repos/ios/` |
| `work/<p>/` | hub contract + global | inert, contract says so | native, linked to `dotclaude/memory/<p>/repos/_root/` |

Nothing personal is ever written into a hub. `memory/patterns/` is added to a hub's qmd collection only on Roman's machine (local, uncommitted collection setting).

## 6. Migration

| Phase | Work | Done when |
| --- | --- | --- |
| 0 | Backup `~/.claude/{CLAUDE.md,settings.json,rules,skills,agents,commands,hooks}` to `~/.claude/backups/2026-09-21-pre-redesign.tgz`; record `claude plugin list`. | archive restorable |
| 1 | Create `dotclaude` per section 3: scripts, config, manifests, rule sets `mine` and `ecc`, `CLAUDE.md`, output style, `handoff` and `memory-update` skills. Move the five `nerd-*` commands out (their plugin is built in parallel). Commit. | `rules.sh list` shows `mine` under 8 KB unconditional; shellcheck clean |
| 2 | Cut over: delete ECC copies, run `install.sh`, `doctor.sh`. dotfiles: delete `ai/`, add the `dotclaude` line to `bootstrap.sh`, update README. | fresh session: no `everything-claude-code:` duplicates, nerd skills once, Swift rules load for a `.swift` file, `doctor.sh` clean, `rules.sh only ecc` then `only mine` work across restarts |
| 3 | `context-advisory.mjs`, register in `settings.json`, `outputStyle: Concise`. | each advisory once at its threshold, tested with a fake transcript |
| 4 | Rename `nerd-mobile-marketplace` to `nerdzlab-marketplace` (repo, `marketplace.json`, READMEs of the two skill repos, `plugins.manifest`). | `claude plugin marketplace add` of the new name lists the existing plugins |
| 5 | `nerd-hub` plugin under Roman's account: manifest, `lib.sh`, `ws-setup`, `ws-search`, `ws-graph`, `template/`, `nerd-hub-init`, `nerd-hub-search`, `nerd-hub-graph`, session hook. Install from a local marketplace path. Install qmd, uv + graphify, oasdiff. | `nerd-hub-init` on a throwaway product with two demo repos writes the parent `CLAUDE.md`, scaffolds the hub, indexes it; from a demo repo the hub contract is loaded and `nerd-hub-search` works |
| 6 | `ws-deps`, `ws-impact`, `ws-drift`, one scanner per consumer kind; `nerd-hub-impact`, `nerd-hub-drift`. | demo: removing an endpoint shows BREAKING, the impact block lists the iOS and Android files that use it, and says the hub needs a PR |
| 7 | `link-memory.sh`; personal `handoff` writes to the right product folder from inside a hub. | newest handoff readable from `dotclaude/memory/<demo>/tasks/` |
| 8 | First real product: `nerd-hub-init`, register repos, fill `SERVICE-MAP.md`, import the spec, `ws-deps`, `ws-impact` on a real PR. After a week of daily use, publish `nerd-hub` in `nerdzlab-marketplace` and share the hub with the team. | one hub in daily use for a week, then the plugin is installable from the marketplace |

Phases 0 to 3 stand alone and deliver the context budget and the rule set switch; pause there for a few days. Phase 6 is the largest piece of new logic and the only one with real uncertainty (scanner accuracy); its demo is the acceptance test.

## 7. Dependencies and follow ups

- Team generators writing `.spec-hash`: PRs in `nerd-ios-skills` and `android-ai-skills`.
- Test cases: a `test-cases` repo per product, `test` nodes in the graph, and a tagging convention. Next plan, after the hub is in daily use.
- Hub CI running `ws-deps` from the plugin: after phase 8.
- `ai-configs` mobile department and mobile ai-readiness: separate brainstorm.
- ECC upgrades: diff the plugin's `rules/` against `sets/ecc/VERSION`, cherry pick into `mine`. Manual.

## 8. Decisions from review

- `nerd-*` commands: out of `dotclaude`, into the nerd pipeline plugin built in parallel.
- Test cases: next step, out of this plan.
- `nerd-hub`: Roman's account and a local marketplace until phase 8, then `nerdzlab-marketplace`.
- Advisory thresholds: 250k / 500k / 750k as defaults, env overridable; revisit after a week of use.
