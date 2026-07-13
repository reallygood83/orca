#!/usr/bin/env bash
# Orca Mode Pack — one-line installer (for end users)
#
#   curl -fsSL https://orca-lime.vercel.app/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/reallygood83/orca/main/install.sh | bash
#
# Options (env):
#   ORCA_INSTALL_ENGINE=1   also print engine skill install commands
#   ORCA_INSTALL_DIR=...    override skill dir (default: ~/.agents/skills/orca-mode-pack)
set -euo pipefail

REPO_RAW="${ORCA_REPO_RAW:-https://raw.githubusercontent.com/reallygood83/orca/main}"
SITE="${ORCA_SITE:-https://orca-lime.vercel.app}"
SKILL_DIR="${ORCA_INSTALL_DIR:-$HOME/.agents/skills/orca-mode-pack}"
TOOLS_DIR="${ORCA_TOOLS_DIR:-$HOME/.orca/studio}"

echo ""
echo "══════════════════════════════════════════"
echo "  Orca Mode Pack 설치"
echo "══════════════════════════════════════════"
echo ""

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "error: '$1' 가 필요합니다." >&2
    exit 1
  }
}

need_cmd curl
need_cmd mkdir

fetch() {
  local dest="$1"
  shift
  local url
  for url in "$@"; do
    if curl -fsSL "$url" -o "$dest" 2>/dev/null; then
      return 0
    fi
  done
  echo "error: failed to download → $dest" >&2
  echo "  tried: $*" >&2
  exit 1
}

echo "→ 스킬 폴더: $SKILL_DIR"
mkdir -p "$SKILL_DIR/references"

echo "→ SKILL.md 다운로드…"
fetch "$SKILL_DIR/SKILL.md" \
  "$SITE/pack/SKILL.md" \
  "$SITE/skills/orca-mode-pack/SKILL.md" \
  "$REPO_RAW/pack/SKILL.md" \
  "$REPO_RAW/skills/orca-mode-pack/SKILL.md"

echo "→ REQUEST 템플릿 · 스키마 다운로드…"
fetch "$SKILL_DIR/references/REQUEST.template.md" \
  "$SITE/pack/references/REQUEST.template.md" \
  "$SITE/skills/orca-mode-pack/references/REQUEST.template.md" \
  "$REPO_RAW/pack/references/REQUEST.template.md" \
  "$REPO_RAW/skills/orca-mode-pack/references/REQUEST.template.md"
fetch "$SKILL_DIR/references/mode-pack.schema.json" \
  "$SITE/pack/references/mode-pack.schema.json" \
  "$SITE/skills/orca-mode-pack/references/mode-pack.schema.json" \
  "$REPO_RAW/pack/references/mode-pack.schema.json" \
  "$REPO_RAW/skills/orca-mode-pack/references/mode-pack.schema.json"

# Also publish templates at top-level for older paths
mkdir -p "$HOME/.orca/templates" 2>/dev/null || true
cp "$SKILL_DIR/references/REQUEST.template.md" "$HOME/.orca/templates/REQUEST.template.md" 2>/dev/null || true
cp "$SKILL_DIR/references/mode-pack.schema.json" "$HOME/.orca/templates/mode-pack.schema.json" 2>/dev/null || true

echo "→ generate-pack.sh (CLI 팩 생성기)…"
mkdir -p "$TOOLS_DIR"
fetch "$TOOLS_DIR/generate-pack.sh" \
  "$SITE/generate-pack.sh" \
  "$REPO_RAW/generate-pack.sh"
chmod +x "$TOOLS_DIR/generate-pack.sh"
# Compat path used by skill text
mkdir -p "$HOME/.orca/jinjing/studio"
cp "$TOOLS_DIR/generate-pack.sh" "$HOME/.orca/jinjing/studio/generate-pack.sh"
chmod +x "$HOME/.orca/jinjing/studio/generate-pack.sh"

# Marker so agents know pack tooling is present
cat > "$HOME/.orca/MODE-PACK-INSTALLED.md" <<EOF
# Orca Mode Pack installed

- skill: $SKILL_DIR
- generate-pack: $TOOLS_DIR/generate-pack.sh
- site: $SITE
- installedAt: $(date -u +%Y-%m-%dT%H:%M:%SZ)

## How to use

1. In Grok / Claude / Codex agent: say \`/orchestration-mode\` or \`조율 모드 만들기\`
2. Or open the studio: $SITE
3. Register Orca Quick Command from your generated pack

## Engine skills (once per machine)

\`\`\`bash
npx skills add https://github.com/stablyai/orca --skill orchestration
npx skills add https://github.com/stablyai/orca --skill orca-cli
\`\`\`
EOF

echo ""
echo "✓ 설치 완료"
echo ""
echo "  스킬:     $SKILL_DIR/SKILL.md"
echo "  생성기:   $TOOLS_DIR/generate-pack.sh"
echo "  안내:     $HOME/.orca/MODE-PACK-INSTALLED.md"
echo ""
echo "다음 단계:"
echo "  1) Orca 앱에서 Experimental → Orchestration ON"
echo "  2) 에이전트에게: /orchestration-mode  또는  조율 모드 만들기"
echo "  3) 또는 웹에서 모드 설계: $SITE"
echo ""
echo "엔진 스킬(PC당 1회, 권장):"
echo "  npx skills add https://github.com/stablyai/orca --skill orchestration"
echo "  npx skills add https://github.com/stablyai/orca --skill orca-cli"
echo ""

if [[ "${ORCA_INSTALL_ENGINE:-0}" == "1" ]]; then
  if command -v npx >/dev/null 2>&1; then
    echo "→ 엔진 스킬 설치 시도 (ORCA_INSTALL_ENGINE=1)…"
    npx --yes skills add https://github.com/stablyai/orca --skill orchestration || true
    npx --yes skills add https://github.com/stablyai/orca --skill orca-cli || true
  fi
fi
