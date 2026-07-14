# Orca Mode Studio

**Product URL:** https://orca.teaboard.link  

A **local-first, multi-agent orchestration mode designer** for [Orca](https://orca.com)-compatible workflows.

Anyone can:

1. Define a **coordinator** + **worker pool** (Codex, Claude, Grok, … — multiple at once)
2. Export a **Playbook** + **Quick Command**
3. Optionally install the **agent skill** (`orca-mode-pack`) in one command
4. Run supervised orchestration on their own machine

No cloud account is required for mode design. Mode configuration is stored **on the user’s device** (`~/.orca/…`).

## Product principles

| Principle | Meaning |
|-----------|---------|
| Universal | Built for any builder/team — not a single creator’s personal workflow |
| Multi-agent | Workers are a **pool**, not a single model |
| Local-first | Studio is static; installs land on the user’s machine |
| Engine-compatible | Uses Orca `orchestration` lifecycle (`task-create` → `dispatch --inject` → `worker_done`) |

## User journeys

### A) Web studio
1. Open https://orca.teaboard.link  
2. **Build mode** — name, coordinator, worker checkboxes, policies  
3. **Install pack** — download / copy Quick Command into Orca  

### B) Agent skill
```bash
curl -fsSL https://orca.teaboard.link/setup-mode-pack.sh | bash
```
Then in an agent: `/orchestration-mode`

### C) CLI pack generator
```bash
bash generate-pack.sh \
  --name my-mode \
  --display "MyMode" \
  --coord grok \
  --worker-entry 'role=implement|agent=codex|cmd=codex -m gpt-5.6 -c model_reasoning_effort="xhigh"' \
  --worker-entry 'role=review|agent=claude|cmd=claude --model claude-sonnet-5' \
  --worker-entry 'role=research|agent=grok|cmd=grok -m grok-4.5' \
  --max 3
```

## Repository layout

| Path | Purpose |
|------|---------|
| `index.html` | Product studio (Vercel) |
| `setup-mode-pack.sh` | One-line skill installer |
| `generate-pack.sh` | CLI pack generator |
| `skills/orca-mode-pack/` | Agent skill sources |
| `templates/` | REQUEST schema & human form |
| `사용방법.md` | Extended Korean guide |

## Deploy (operators)

Static site on Vercel from `main`:

- Framework: Other  
- No build command  
- Output: repository root  

Push to `main` → production updates at the product URL.

## Engine skills (end users, once)

```bash
npx skills add https://github.com/stablyai/orca --skill orchestration
npx skills add https://github.com/stablyai/orca --skill orca-cli
```

## License

Personal and educational use welcome. Orca trademarks belong to their respective owners; this project provides a compatible mode-design layer only.
