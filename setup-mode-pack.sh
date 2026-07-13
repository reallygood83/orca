#!/usr/bin/env bash
# Orca Mode Pack — one-line installer for end users
#
#   curl -fsSL https://orca-lime.vercel.app/setup-mode-pack.sh | bash
#
# Installs:
#   ~/.agents/skills/orca-mode-pack/   (agent skill)
#   ~/.orca/studio/generate-pack.sh    (CLI pack generator)
set -euo pipefail

SITE="${ORCA_SITE:-https://orca-lime.vercel.app}"
SKILL_DIR="${ORCA_INSTALL_DIR:-$HOME/.agents/skills/orca-mode-pack}"
TOOLS_DIR="${ORCA_TOOLS_DIR:-$HOME/.orca/studio}"

echo ""
echo "══════════════════════════════════════════"
echo "  Orca Mode Pack 설치"
echo "══════════════════════════════════════════"
echo ""

command -v curl >/dev/null || { echo "error: curl 필요" >&2; exit 1; }
command -v mkdir >/dev/null || { echo "error: mkdir 필요" >&2; exit 1; }

fetch() {
  local dest="$1" url="$2"
  echo "  · $url"
  curl -fsSL "$url" -o "$dest"
}

mkdir -p "$SKILL_DIR/references" "$TOOLS_DIR" "$HOME/.orca/jinjing/studio" "$HOME/.orca/templates"

echo "→ 스킬 다운로드 ($SKILL_DIR)"
fetch "$SKILL_DIR/SKILL.md" \
  "$SITE/skills/orca-mode-pack/SKILL.md"
fetch "$SKILL_DIR/references/REQUEST.template.md" \
  "$SITE/skills/orca-mode-pack/references/REQUEST.template.md"
fetch "$SKILL_DIR/references/mode-pack.schema.json" \
  "$SITE/skills/orca-mode-pack/references/mode-pack.schema.json"

cp "$SKILL_DIR/references/REQUEST.template.md" "$HOME/.orca/templates/" 2>/dev/null || true
cp "$SKILL_DIR/references/mode-pack.schema.json" "$HOME/.orca/templates/" 2>/dev/null || true

echo "→ generate-pack.sh"
fetch "$TOOLS_DIR/generate-pack.sh" "$SITE/generate-pack.sh"
chmod +x "$TOOLS_DIR/generate-pack.sh"
cp "$TOOLS_DIR/generate-pack.sh" "$HOME/.orca/jinjing/studio/generate-pack.sh"
chmod +x "$HOME/.orca/jinjing/studio/generate-pack.sh"

cat > "$HOME/.orca/MODE-PACK-INSTALLED.md" <<EOF
# Orca Mode Pack installed

- skill: $SKILL_DIR
- generate-pack: $TOOLS_DIR/generate-pack.sh
- site: $SITE
- installedAt: $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Use

1. Agent: \`/orchestration-mode\` or \`조율 모드 만들기\`
2. Studio: $SITE
3. Engine (once):
   npx skills add https://github.com/stablyai/orca --skill orchestration
   npx skills add https://github.com/stablyai/orca --skill orca-cli
EOF

echo ""
echo "✓ 설치 완료"
echo "  스킬:   $SKILL_DIR/SKILL.md"
echo "  생성기: $TOOLS_DIR/generate-pack.sh"
echo ""
echo "다음:"
echo "  1) Orca → Experimental → Orchestration ON"
echo "  2) 에이전트: /orchestration-mode"
echo "  3) 웹 모드: $SITE"
echo ""
echo "엔진 스킬(PC당 1회 권장):"
echo "  npx skills add https://github.com/stablyai/orca --skill orchestration"
echo "  npx skills add https://github.com/stablyai/orca --skill orca-cli"
echo ""
