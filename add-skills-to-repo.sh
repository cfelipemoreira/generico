#!/usr/bin/env bash
# add-skills-to-repo.sh
# Copia as 60 skills (formato .claude/skills/<nome>/SKILL.md) para QUALQUER
# repositorio, para que carreguem automaticamente como skills de projeto.
#
# Uso:
#   ./add-skills-to-repo.sh [caminho-do-repo]   # default: diretorio atual
#
# Depois e so commitar e dar push na branch padrao do repo de destino.
set -euo pipefail

SRC_REPO="https://github.com/cfelipemoreira/generico.git"
SRC_BRANCH="claude/pensive-mendel-lq533f"   # branch que guarda as skills

TARGET="${1:-$(pwd)}"
TARGET="$(cd "$TARGET" && pwd)"

# Confirma que o destino e um repositorio git
if ! git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERRO: '$TARGET' nao e um repositorio git." >&2
  exit 1
fi

# Usa o token do ambiente se existir (repo publico nem precisa)
AUTH=""
[ -n "${GITHUB_TOKEN:-}" ] && AUTH="x-access-token:${GITHUB_TOKEN}@"
URL="${SRC_REPO/https:\/\//https://${AUTH}}"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Baixando skills de $SRC_BRANCH ..."
git clone --depth 1 --filter=blob:none --sparse -b "$SRC_BRANCH" "$URL" "$TMP" >/dev/null 2>&1
git -C "$TMP" sparse-checkout set .claude/skills >/dev/null 2>&1

DEST="$TARGET/.claude/skills"
mkdir -p "$DEST"
cp -r "$TMP/.claude/skills/." "$DEST/"

# Stage automatico para facilitar o commit
git -C "$TARGET" add .claude/skills >/dev/null 2>&1 || true

COUNT="$(find "$DEST" -name SKILL.md | wc -l | tr -d ' ')"
echo "OK: $COUNT skills instaladas em $DEST (e ja adicionadas ao stage)."
echo "Agora rode:"
echo "  git -C \"$TARGET\" commit -m 'Adiciona skills de marketing'"
echo "  git -C \"$TARGET\" push"
