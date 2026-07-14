#!/usr/bin/env bash
# Generate a custom Orca orchestration mode pack (JinJing-style).
#
# Usage:
#   bash generate-pack.sh --name my-orch --display "MyOrch" \
#     --coord grok \
#     --worker codex \
#     --worker-cmd 'codex -m gpt-5.6 -c model_reasoning_effort="xhigh"' \
#     --review-cmd 'claude --model sonnet' \
#     --max 3 --wt auto \
#     --triggers 'my-orch, orchestrate, 조율'
#
# Emits under $HOME/.orca/<name>/ (override with --out):
#   PLAYBOOK.md, README.md, meta.json, REQUEST.filled.md,
#   prompts/quick-command.txt, prompts/coordinator-start.md,
#   SKILL.md, install-quickref.md
set -euo pipefail

NAME="my-orch"
DISPLAY="MyOrch"
COORD="grok"
WORKER="codex"
WORKER_CMD='codex -m gpt-5.6 -c model_reasoning_effort="xhigh"'
REVIEW_CMD=""
WORKER_ENTRIES=()
MAX=3
WT="auto"
TRIGGERS="orchestrate, 조율"
FINALS="요약, 태스크별 결과, 결정/트레이드오프, 수정 파일, 리스크/다음 액션"
COORDINATION="supervised"
WAIT_MS=900000
OUT=""
PROJECT_RULES=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --display) DISPLAY="$2"; shift 2 ;;
    --coord) COORD="$2"; shift 2 ;;
    --worker) WORKER="$2"; shift 2 ;;
    --worker-cmd) WORKER_CMD="$2"; WORKER_ENTRIES+=("role=implement|agent=${WORKER:-codex}|cmd=$2"); shift 2 ;;
    --review-cmd) REVIEW_CMD="$2"; WORKER_ENTRIES+=("role=review|agent=claude|cmd=$2"); shift 2 ;;
    --worker-entry) WORKER_ENTRIES+=("$2"); shift 2 ;;
    --max) MAX="$2"; shift 2 ;;
    --wt) WT="$2"; shift 2 ;;
    --triggers) TRIGGERS="$2"; shift 2 ;;
    --finals) FINALS="$2"; shift 2 ;;
    --coordination) COORDINATION="$2"; shift 2 ;;
    --wait-ms) WAIT_MS="$2"; shift 2 ;;
    --project-rules) PROJECT_RULES="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,20p' "$0"
      exit 0
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit 1
      ;;
  esac
done

NAME="$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g; s/--*/-/g; s/^-//; s/-$//')"
[[ -z "$NAME" ]] && NAME="my-orch"
OUT="${OUT:-$HOME/.orca/$NAME}"
mkdir -p "$OUT/prompts"

label_of() {
  case "$1" in
    grok) echo Grok ;;
    claude) echo Claude ;;
    codex) echo Codex ;;
    opencode) echo OpenCode ;;
    *) echo "$1" ;;
  esac
}

COORD_LABEL="$(label_of "$COORD")"
WORKER_LABEL="$(label_of "$WORKER")"

case "$WT" in
  isolated)
    WT_BLOCK="**Isolated worktree (default)**

\`\`\`bash
orca worktree create --name \"deep-<short>\" --no-parent --json
orca terminal create --worktree id:<FULL_WORKTREE_ID> --title \"<short>\" \\
  --command '\${WORKER_CMD}' --json
orca terminal wait --terminal <handle> --for tui-idle --timeout-ms 60000 --json
\`\`\`"
    WT_BLOCK="${WT_BLOCK//\$\{WORKER_CMD\}/$WORKER_CMD}"
    ;;
  auto)
    WT_BLOCK="**Auto**: independent work → new worktree \`--no-parent\`; needs uncommitted/current branch → \`--worktree active\`.

Always use worker command: \`${WORKER_CMD}\`"
    ;;
  *)
    WT_BLOCK="**Same worktree (default)**

\`\`\`bash
orca terminal create --worktree active --title \"<short>\" \\
  --command '${WORKER_CMD}' --json
orca terminal wait --terminal <handle> --for tui-idle --timeout-ms 60000 --json
\`\`\`"
    ;;
esac

export GEN_OUT="$OUT" GEN_NAME="$NAME" GEN_DISPLAY="$DISPLAY"
export GEN_COORD_LABEL="$COORD_LABEL" GEN_WORKER_LABEL="$WORKER_LABEL"
export GEN_WORKER_CMD="$WORKER_CMD" GEN_REVIEW_CMD="$REVIEW_CMD"
export GEN_MAX="$MAX" GEN_WT_BLOCK="$WT_BLOCK" GEN_WT="$WT"
export GEN_TRIGGERS="$TRIGGERS" GEN_FINALS="$FINALS"
export GEN_COORD="$COORD" GEN_WORKER="$WORKER"
export GEN_COORDINATION="$COORDINATION" GEN_WAIT_MS="$WAIT_MS"
export GEN_PROJECT_RULES="$PROJECT_RULES"

export GEN_WORKER_ENTRIES="$(printf '%s\n' "${WORKER_ENTRIES[@]}")"


python3 <<'PY'
import json, os, re
from pathlib import Path
from datetime import datetime, timezone

out = Path(os.environ["GEN_OUT"])
name = os.environ["GEN_NAME"]
display = os.environ["GEN_DISPLAY"]
coord_l = os.environ["GEN_COORD_LABEL"]
worker_l = os.environ["GEN_WORKER_LABEL"]
worker_cmd = os.environ["GEN_WORKER_CMD"]
review_cmd = os.environ.get("GEN_REVIEW_CMD", "").strip()
max_w = os.environ["GEN_MAX"]
wt_block = os.environ["GEN_WT_BLOCK"]
triggers_raw = os.environ["GEN_TRIGGERS"]
finals = os.environ["GEN_FINALS"]
coord = os.environ["GEN_COORD"]
worker = os.environ["GEN_WORKER"]
coordination = os.environ.get("GEN_COORDINATION", "supervised")
wait_ms = int(os.environ.get("GEN_WAIT_MS", "900000"))
project_rules = os.environ.get("GEN_PROJECT_RULES", "").strip()
wt = os.environ["GEN_WT"]

workers = []
for e in os.environ.get("GEN_WORKER_ENTRIES", "").splitlines():
    e = e.strip()
    if not e:
        continue
    d = {"role": "implement", "agent": worker or "codex", "command": worker_cmd, "ownership": "edit"}
    for part in e.split("|"):
        if "=" not in part:
            continue
        k, v = part.split("=", 1)
        if k == "role":
            d["role"] = v
        elif k == "agent":
            d["agent"] = v
        elif k == "cmd":
            d["command"] = v
    d["ownership"] = "review-only" if d["role"] == "review" else "edit"
    workers.append(d)
if not workers:
    workers = [{"role": "implement", "agent": worker or "codex", "command": worker_cmd, "ownership": "edit"}]
    if review_cmd:
        workers.append({"role": "review", "agent": "claude", "command": review_cmd, "ownership": "review-only"})

_impl = next((w for w in workers if w["role"] == "implement"), workers[0])
worker_cmd = _impl["command"]
worker = _impl["agent"]
worker_l = ", ".join(f'{w["agent"]}/{w["role"]}' for w in workers)
_rev = next((w for w in workers if w["role"] == "review"), None)
review_cmd = _rev["command"] if _rev else ""

trig_list = [t.strip() for t in triggers_raw.split(",") if t.strip()]
trig_fmt = ", ".join(f"`{t}`" for t in trig_list) or f"`{display}`"

spawn_lines = []
for i, w in enumerate(workers):
    spawn_lines.append(
        f"""# {w['agent']} ({w['role']})
```bash
orca terminal create --worktree active --title "{w['agent']}-{w['role']}" \\
  --command '{w['command']}' --json
orca terminal wait --terminal <handle_{i}> --for tui-idle --timeout-ms 60000 --json
orca orchestration task-create --spec "[{w['role']}/{w['agent']}] <task>" --json
orca orchestration dispatch --task <task_id_{i}> --to <handle_{i}> --inject --json
```"""
    )
review_section = "\n\n".join(spawn_lines)
role_rows = "\n".join(
    f"| **Worker ({w['role']})** | `{w['command']}` | "
    f"{'findings only' if w['ownership']=='review-only' else 'deep work + worker_done'} |"
    for w in workers
)

handoff_note = ""
if coordination == "handoff":
    handoff_note = """
> ⚠️ This pack is marked **handoff**. Do **not** use `dispatch --inject` or `check --wait`.
> Use `orca worktree create --prompt` / `terminal send`, then stop monitoring.
"""
else:
    handoff_note = """
This is **supervised Orca orchestration** — not a full handoff.
Use `task-create` + `dispatch --inject` + `check --wait` for `worker_done`.
"""

project_block = ""
if project_rules:
    project_block = f"\n## Project rules (baked in)\n\n{project_rules}\n"

playbook = f"""# {display} Orchestration Mode (Orca) — Global

{coord_l} is the **coordinator**. Worker pool: **{worker_l}**.
You may run **multiple worker agents at once** (Codex + Claude + Grok, etc.).
Everything reports back to the coordinator for the **final synthesis**.

{handoff_note}

Engine skill: `orchestration` (`orca orchestration …`)  
Mode skill (optional): copy `SKILL.md` to `~/.agents/skills/{name}/`  
This file is **your operating system** on top of the engine.

Generated by: `generate-pack.sh` · schema: REQUEST.template.md

---

## When to use

User says any of: {trig_fmt}.

Then follow this file strictly.

---

## Preconditions

```bash
orca status --json
orca orchestration task-list --json
command -v {coord} || true
```

Orca → Settings → Experimental → Orchestration: ON

---

## Role split

| Role | Agent / command | Job |
|------|-----------------|-----|
| **Coordinator** | {coord_l} | Decompose, dispatch, wait, synthesize FINAL |
{role_rows}

**Multi-worker:** each row = its own terminal + `dispatch --inject`.  
**Model rule:** models live only in worker `command` strings. Never pass `--model` to `dispatch`.

---

## Coordinator loop

### 1) Decompose
2–6 self-contained tasks. Assign tasks to the best worker role (implement/review/research).
Max **{max_w}** concurrent deep workers.

### 2) Create tasks
```bash
orca orchestration task-create --spec "[role/agent] <self-contained task>" --json
# deps: --deps '["<id>"]'
```

### 3) Spawn workers (one terminal per agent)
{review_section}

### 4) Dispatch
```bash
orca orchestration dispatch --task <task_id> --to <handle> --inject --json
```
Never full-handoff-and-abandon in supervised mode.

### 5) Wait
```bash
orca orchestration check --wait \\
  --types worker_done,escalation,decision_gate \\
  --timeout-ms {wait_ms} --json
```
- Loop once per worker. Timeout / count:0 = checkpoint, not failure.
- Reply to `decision_gate` with `orca orchestration reply`.

### 6) Synthesize FINAL
Sections: {finals}.

---

## Worker obligations
With a live inject preamble: do the TASK, then **one** `worker_done`
to the coordinator handle with payload:
`taskId`, `dispatchId`, `filesModified`, optional `reportPath` — then idle.

## Project overlay
Read `<repo>/.orca/{name}.md` or `.orca/PLAYBOOK.md` and `AGENTS.md` when present.
Global rules win for mechanics; project rules win for domain/safety.
{project_block}
"""

_team = " ; ".join(f"{w['agent']}/{w['role']}:{{{w['command']}}}" for w in workers)
quick = (
    f"{display} mode (user pack). Read and follow $HOME/.orca/{name}/PLAYBOOK.md and the orchestration skill. "
    f"If this repo has .orca/{name}.md or .orca/PLAYBOOK.md, also follow as overlay. "
    f"You are {coord_l} coordinator: decompose → dispatch a multi-agent worker pool via orca orchestration "
    f"task-create + dispatch --inject → check --wait for worker_done → synthesize FINAL. "
    f"Coordination={coordination}. Max concurrent: {max_w}. "
    f"Workers: {_team}. "
    f"Goal:"
)

coord_start = f"""# {display} — coordinator start

1. Read `$HOME/.orca/{name}/PLAYBOOK.md`
2. Read engine skill `orchestration`
3. `orca status --json`
4. Decompose Goal into 2–6 tasks
5. Spawn workers with:
   - implement: `{worker_cmd}`
""" + (f"   - review: `{review_cmd}`\n" if review_cmd else "") + f"""6. `dispatch --inject` + `check --wait` (timeout {wait_ms}ms)
7. FINAL: {finals}

Goal:
"""

skill_md = f"""---
name: {name}
description: >
  Run the user-defined Orca mode pack "{display}" ({coordination}).
  Trigger: {", ".join(trig_list) or display}. Coordinator={coord_l}.
  Implement worker: {worker_cmd}.
  Loads $HOME/.orca/{name}/PLAYBOOK.md then supervised orchestration loop.
---

# {display} mode

1. Read `$HOME/.orca/{name}/PLAYBOOK.md` and `meta.json`
2. Follow engine skill `orchestration` for commands
3. Spawn workers only with commands from meta:
   - implement: `{worker_cmd}`
""" + (f"   - review: `{review_cmd}`\n" if review_cmd else "") + f"""4. Max concurrent: {max_w}; worktree: {wt}; wait: {wait_ms}ms
5. FINAL sections: {finals}

Do not invent different model commands. Do not use dispatch for handoff packs.
"""

readme = f"""# {display} orchestration pack

Install path: `$HOME/.orca/{name}/`

| File | Purpose |
|------|---------|
| `PLAYBOOK.md` | Operating rules for the coordinator |
| `prompts/quick-command.txt` | Paste into Orca Quick Command (Global) |
| `prompts/coordinator-start.md` | Full paste for a new Grok/Claude tab |
| `meta.json` | Machine-readable config |
| `SKILL.md` | Optional agent skill (`~/.agents/skills/{name}/`) |
| `REQUEST.filled.md` | The inputs used to generate this pack |

## Setup

1. Engine skills (once per machine):
   ```bash
   npx skills add https://github.com/stablyai/orca --skill orchestration
   npx skills add https://github.com/stablyai/orca --skill orca-cli
   ```
2. Orca → Settings → Quick Commands  
   - Label: **{display}**  
   - Scope: **Global**  
   - Text: contents of `prompts/quick-command.txt`
3. Optional agent skill:
   ```bash
   mkdir -p "$HOME/.agents/skills/{name}"
   cp "$HOME/.orca/{name}/SKILL.md" "$HOME/.agents/skills/{name}/SKILL.md"
   ```
4. Studio (visual): https://github.com/reallygood83/orca  
   or `open "$HOME/.orca/jinjing/studio/index.html"`

## Regenerate

```bash
bash "$HOME/.orca/jinjing/studio/generate-pack.sh" \\
  --name {name} --display "{display}" \\
  --coord {coord} --worker {worker} \\
  --worker-cmd '{worker_cmd}' \\
""" + (f"  --review-cmd '{review_cmd}' \\\n" if review_cmd else "") + f"""  --max {max_w} --wt {wt} --coordination {coordination}
```
"""

workers_meta = workers

meta = {
    "name": name,
    "displayName": display,
    "coordination": coordination,
    "coordinator": {"agent": coord},
    "workers": workers_meta,
    "workerCmd": worker_cmd,
    "reviewCmd": review_cmd or None,
    "maxWorkers": int(max_w),
    "worktreePolicy": wt,
    "waitTimeoutMs": wait_ms,
    "triggers": trig_list,
    "finalSections": finals,
    "schema": "mode-pack.schema.json",
    "generatedAt": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
}

request_filled = f"""# REQUEST filled — {display}

| Field | Value |
|-------|--------|
| modeName | `{name}` |
| displayName | {display} |
| coordination | {coordination} |
| coordinator.agent | {coord} |
| implement.command | `{worker_cmd}` |
| review.command | `{review_cmd or "—"}` |
| worktreePolicy | {wt} |
| maxConcurrent | {max_w} |
| waitTimeoutMs | {wait_ms} |
| triggers | {triggers_raw} |
| finalSections | {finals} |

See skill `orca-mode-pack` references/REQUEST.template.md for full field docs.
"""

install_quickref = f"""# Install quickref — {display}

```bash
# 1) Pack already at:
echo "$HOME/.orca/{name}"

# 2) Optional skill install
mkdir -p "$HOME/.agents/skills/{name}"
cp "$HOME/.orca/{name}/SKILL.md" "$HOME/.agents/skills/{name}/SKILL.md"

# 3) Smoke
orca status --json
```

Manual: Orca Quick Command ← `prompts/quick-command.txt` (Label: {display}, Global)
"""

(out / "PLAYBOOK.md").write_text(playbook, encoding="utf-8")
(out / "prompts" / "quick-command.txt").write_text(quick + "\n", encoding="utf-8")
(out / "prompts" / "coordinator-start.md").write_text(coord_start, encoding="utf-8")
(out / "README.md").write_text(readme, encoding="utf-8")
(out / "SKILL.md").write_text(skill_md, encoding="utf-8")
(out / "meta.json").write_text(json.dumps(meta, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
(out / "REQUEST.filled.md").write_text(request_filled, encoding="utf-8")
(out / "install-quickref.md").write_text(install_quickref, encoding="utf-8")

print(f"✓ Pack written to: {out}")
for rel in [
    "PLAYBOOK.md",
    "prompts/quick-command.txt",
    "prompts/coordinator-start.md",
    "README.md",
    "SKILL.md",
    "meta.json",
    "REQUEST.filled.md",
    "install-quickref.md",
]:
    print(f"  · {rel}")
print()
print(f"Next: Orca Quick Command ← prompts/quick-command.txt (label: {display})")
print(f'Optional: cp SKILL.md → ~/.agents/skills/{name}/')
PY

chmod +x "$OUT/../$NAME/../" 2>/dev/null || true
echo "done: $OUT"
