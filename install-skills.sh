#!/usr/bin/env bash
# Instala as skills globalmente em ~/.claude/skills para que fiquem
# disponiveis em QUALQUER repositorio/branch desta sessao do Claude Code.
# Pensado para rodar como SessionStart hook / setup script do ambiente web,
# onde o container e efemero e ~/.claude e recriado a cada sessao.
set -euo pipefail

SKILLS_REPO="https://github.com/cfelipemoreira/generico.git"
SKILLS_BRANCH="claude/friendly-pasteur-metsok"
DEST="$HOME/.claude/skills"
TMP="$(mktemp -d)"

# Usa o token do ambiente se o repo for privado
AUTH=""
[ -n "${GITHUB_TOKEN:-}" ] && AUTH="x-access-token:${GITHUB_TOKEN}@"
URL="${SKILLS_REPO/https:\/\//https://${AUTH}}"

git clone --depth 1 --filter=blob:none --sparse -b "$SKILLS_BRANCH" "$URL" "$TMP" >/dev/null 2>&1
git -C "$TMP" sparse-checkout set .claude/skills >/dev/null 2>&1

mkdir -p "$DEST"
cp -r "$TMP/.claude/skills/." "$DEST/"
rm -rf "$TMP"

echo "[install-skills] $(find "$DEST" -name SKILL.md | wc -l) skills instaladas em $DEST"
