---
name: orca-mode-pack
description: >
  Create, install, and run personalized Orca supervised orchestration modes
  (JinJing-style packs). Trigger when user says /orchestration-mode, /jinjing,
  조율 모드, 내 모드 만들기, 오케스트레이션 팩, or wants custom coordinator/worker
  models for Orca dispatch. Generates PLAYBOOK + Quick Command + optional agent
  skill from a REQUEST template; does not replace the engine skill `orchestration`.
---

# Orca Mode Pack (나만의 /orchestration)

**Engine** = `orchestration` skill (`orca orchestration …`)  
**This skill** = **user-owned operating system** on top: coordinator/worker models, worktree policy, triggers, FINAL format.

Like **JinJing** (`~/.orca/jinjing/`) but for **any user profile**.

## When to use

| User says | Action |
|-----------|--------|
| `/jinjing`, 진징 | Run **existing** JinJing pack (`~/.orca/jinjing/JINJING.md`) |
| `/orchestration-mode`, 내 조율 모드 만들기 | **Create/install** a pack from REQUEST |
| `/my-orch`, `<모드이름> 모드로` | **Run** installed pack `$HOME/.orca/<name>/PLAYBOOK.md` |
| 모델 지정해서 조율 | Fill REQUEST → generate pack → run supervised loop |

If the user only wants engine docs, use `orchestration` skill.  
If full ownership transfer (handoff), use `orca-cli` — **do not** inject lifecycle.

## Preconditions

```bash
orca status --json
command -v orca
# optional studio
test -f "$HOME/.orca/jinjing/studio/index.html" || test -f "./index.html"
```

Experimental → Orchestration must be enabled in Orca Settings.

## REQUEST schema (what the user must provide)

Copyable template: [`references/REQUEST.template.md`](references/REQUEST.template.md)  
JSON schema: [`references/mode-pack.schema.json`](references/mode-pack.schema.json)

### Minimum fields

| Field | Required | Example |
|-------|----------|---------|
| `modeName` | yes | `my-orch` (slug: `[a-z0-9-]+`) |
| `displayName` | yes | `MyOrch` |
| `coordination` | yes | `supervised` (default) \| `handoff` |
| `coordinator.agent` | yes | `grok` \| `claude` \| `codex` \| `gemini` \| `hermes` \| `opencode` |
| `workers[]` | ≥1 (**여러 명 OK**) | Codex+Claude+Grok+Gemini+Hermes 동시 가능 |
| `workers[].role` | yes | `implement` \| `review` \| `test` \| `research` |
| `workers[].agent` | yes | `codex` \| `claude` \| `grok` \| `gemini` \| `hermes` \| … |
| `workers[].command` | yes | full CLI command with model/effort |
| `worktreePolicy` | yes | `active` \| `isolated` \| `auto` |
| `maxConcurrent` | no | default `3` |
| `triggers` | no | slash/aliases for Quick Command |
| `finalSections` | no | FINAL report sections |

### Model specification rule

**Models are never set on `dispatch`.**  
Encode them in `workers[].command` (and document `model` / `effort` for humans).

```text
agent: codex
model: gpt-5.6
effort: xhigh
command: codex -m gpt-5.6 -c model_reasoning_effort="xhigh"
```

## Create pack (agent procedure)

1. Collect missing REQUEST fields (ask only for gaps).
2. Generate pack:

```bash
bash "$HOME/.orca/jinjing/studio/generate-pack.sh" \
  --name my-orch \
  --display "MyOrch" \
  --coord grok \
  --worker codex \
  --worker-cmd 'codex -m gpt-5.6 -c model_reasoning_effort="xhigh"' \
  --review-cmd 'claude --model sonnet' \
  --max 3 \
  --wt auto \
  --triggers 'my-orch, 조율' \
  --out "$HOME/.orca/my-orch"
```

Or open studio: `open "$HOME/.orca/jinjing/studio/index.html"` (tab 3).

3. Tell user to register Orca Quick Command (Global) with `prompts/quick-command.txt`.
4. Optional project overlay: `bash install-into-project.sh` pattern under pack README.

## Run pack (supervised)

1. Read `$HOME/.orca/<modeName>/PLAYBOOK.md` (and repo `.orca/<modeName>.md` overlay if any).
2. Confirm `coordination=supervised` → use `task-create` + `dispatch --inject` + `check --wait`.
3. Spawn workers with **exact** `workers[].command` from `meta.json`.
4. Max concurrent = `maxConcurrent`.
5. On all `worker_done`, synthesize FINAL with `finalSections`.
6. Never treat review-only `worker_done` as edit authority unless PLAYBOOK says coordinator owns fixes.

## Multi-agent / multi-role dispatch

**Workers are a pool, not a single model.** Example:

```text
implement → codex -m gpt-5.6 …
design    → gemini -m gemini-3.5-flash
review    → claude --model sonnet
research  → grok -m grok-4.5 …
research  → hermes chat --tui
```

**Hermes note:** spawn with `orca terminal create --command "hermes chat --tui"`.
`tui-idle` may time out; still try `dispatch --inject` after a short wait.

- Create **separate terminals** per worker (different handles)
- Different task specs with `[role/agent]` prefix
- `maxConcurrent` caps parallel dispatches
- Review-only `worker_done` ≠ edit authority

## Anti-patterns

- Putting `--model` on `orca orchestration dispatch` (not supported)
- Using `dispatch --inject` for full handoff
- Ignoring pack PLAYBOOK and inventing different worker commands
- Deep DAG (>4 levels) without user ask
- Editing files as coordinator after review-only completion without named owner

## Related

- Engine: `orchestration`, `orca-cli`
- Reference pack: `~/.orca/jinjing/` (JinJing)
- Public studio: https://github.com/reallygood83/orca
